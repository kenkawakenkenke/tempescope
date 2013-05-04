/*
  TempescopeRemote.ino - Main source file for Tempescope Remote hardware
  Released as part of the Tempescope project - http://kenkawakenkenke.github.io/tempescope/
  Copyright (c) 2013 Ken Kawamoto.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <VirtualWire.h>
#include "Weather.h"
#include "TempescopeController.h"

#define TXPIN 12

#define PIN_ONOFF 5
#define PIN_MANUAL_OR_ANIMATION 7 //true=kManual
#define PIN_DEMO_OR_SAVED 6 //true=kDemo false=kSaved
#define PIN_LIGHTNING 8
#define PIN_CHANGE_WEATHER 11
#define PIN_TOD 5


TempescopeController *controller;

void setup(){
  Serial.begin(9600);
  
  pinMode(13,OUTPUT);
  controller=new TempescopeController();
  
   pinMode(PIN_ONOFF,INPUT);
   pinMode(PIN_MANUAL_OR_ANIMATION,INPUT);
   pinMode(PIN_DEMO_OR_SAVED,INPUT);
   pinMode(PIN_LIGHTNING,INPUT);
   pinMode(PIN_CHANGE_WEATHER,INPUT);
 
 vw_set_tx_pin(TXPIN);
 vw_setup(1200);
 
  updateControllerFromPins();
  controller->sendUpdate(); //force update
  
  Serial.println("start");
  for(int i=0;i<10;i++){
    Serial.println("woot");
    delay(50);
  }
}


boolean prev_WeatherTypeTact=false;

const int todAvg_window = 8;
long todAvg_vals[todAvg_window];      // the readings from the analog input
int todAvg_idx = 0;                  // the index of the current reading
long todAvg_total = 0;                  // the running total
                       
    
void updateControllerFromPins(){
  //set on/off
  controller->setOn(digitalRead(PIN_ONOFF));
  
  //set animation mode
  AnimationMode mode=kManual;
  if(digitalRead(PIN_MANUAL_OR_ANIMATION))
    mode=kManual;
  else{
    if(digitalRead(PIN_DEMO_OR_SAVED))
      mode=kDemo;
    else
      mode=kSaved;
  }
  controller->setAnimationMode(mode);
  
  //set time of day
  {
    int val=analogRead(PIN_TOD);
    todAvg_total-= todAvg_vals[todAvg_idx];
    todAvg_vals[todAvg_idx]=val;
    todAvg_total+=val; 
    todAvg_idx++;
    if (todAvg_idx >= todAvg_window)        
      todAvg_idx = 0;   
    int avg=(int)todAvg_total/todAvg_window;
//      Serial.println(val);
    if(controller->setTODValue(avg)){
//      Serial.print("======= ");
//      Serial.println(avg);
      //if changed, reset our buffer
      for(int i=0;i<todAvg_window;i++)
        todAvg_vals[i]=avg;
      todAvg_total= todAvg_window*avg;
    }
//    controller->setTODValue(val);
  }
  
  //set lightning
  controller->setLightning(digitalRead(PIN_LIGHTNING));
  
  //weather tact pressed?
  boolean weatherTact=digitalRead(PIN_CHANGE_WEATHER);
  if(!prev_WeatherTypeTact && weatherTact){
    controller->incrementWeatherType();
//    Serial.println("clicked!");
  }
  prev_WeatherTypeTact=weatherTact;
//  Serial.println(weatherTact);
  
}

int readChar(){
  long loopLimit=10000;
    long loopI=0;
    while(Serial.available()==0){
      loopI++;
      if(loopI>=loopLimit){
        Serial.println("Serial give up!");
        return -1;
      }
    }
    char c=Serial.read();
    return c;
}
int readInt(){
  int num=0;
  boolean first=true;
  
  long loopLimit=10000;
  while(true){
    long loopI=0;
    while(Serial.available()==0){
      loopI++;
      if(loopI>=loopLimit){
        Serial.println("Serial give up!");
        return -1;
      }
    }
    char c=Serial.read();
    if(c=='\0' || c=='\n' || c==13 || c==',' || c==' '){
      if(!first){
        break;
      }
    }else{
//      Serial.print("[");
//      Serial.print(c);
//      Serial.println("]");
      num= 10*num+(c-'0');
      first=false;
    }
  }
  return num;
}
long readLong(){
  long num=0;
  boolean first=true;
  long loopLimit=10000;
  while(true){
    long loopI=0;
    while(Serial.available()==0){
      loopI++;
      if(loopI>=loopLimit){
        Serial.println("Serial give up!");
        return -1;
      }
    }
    char c=Serial.read();
    if(c=='\0' || c=='\n' || c==13 || c==',' || c==' '){
      if(!first){
        break;
      }
    }else{
      num= 10*num+(c-'0');
      first=false;
    }
  }
  return num;
}

#define FLG_START_MESSAGE 'Z'
void loop(){
  updateControllerFromPins();

  controller->sendUpdateIfDirty();
  
  //handle serial
  if(Serial.available()>0){
    { //find start of message
      char key;
      while((key=Serial.read())!=FLG_START_MESSAGE);
    }
    
    char func=readChar();
//    Serial.println(func);
    if(func=='r'){ //manual
//      int idx=readInt();
//      long t=readLong();
      int p_100=readInt();
      int weatherType=readInt();
      int lightning=readInt();
      
      Weather weather(p_100/100., (WeatherType)weatherType, lightning);
      weather.validateAndFix();
      
      controller->sendRealtimeWeather(weather);
      Serial.print("manual ");
      weather.print();
    }else if(func=='s'){ //save
      int idx=readInt();
      long t=readLong();
      int p_100=readInt();
      int weatherType=readInt();
      int lightning=readInt();
      
      Weather weather(p_100/100., (WeatherType)weatherType, lightning);
      weather.validateAndFix();
      
      controller->saveWeatherAtIndex(idx,t,weather);
      Serial.print("save ");
      weather.print();
    }else if(func=='l'){ //load saved
      Serial.println("load saved");
      controller->playSavedAnimation();
    }else if(func=='z'){ //off
      Serial.println("off");
      controller->turnOff();
    }else if(func=='d'){ //show demo
      Serial.println("demo");
      controller->playDemo();
    }else if(func=='f'){ //num frames
     int num=readInt();
      controller->sendAnimationFrameSize(num);
      Serial.print("num frames ");
      Serial.println(num);
    }
  }
  
//  delay(500);
//  Serial.println(weatherTact);
  
//  updateControllerFromPins();
//  controller->sendUpdateIfDirty();
  
//  int todValue=analogRead(PIN_TOD);
//  if(abs(todValue-manualMode_TODValue)>3){
//    
//    Serial.print(todValue);
//    Serial.print(" ");
//    Serial.println(tod);
//    sendRealtimeWeather(Weather(pNoonForTOD(tod), kClear, 0));
//  
//    manualMode_TODValue=todValue;
//  }
  
////  while(true){
////    sendRealtimeWeather(Weather(0, kClear, 0));
////    delay(1000);
////    sendRealtimeWeather(Weather(1, kClear, 0));
////    delay(1000);
////    sendRealtimeWeather(Weather(0, kClear, 0));
////    delay(1000);
////  }
//    
//  Serial.println("send");
////  playDemo();
//  
//  int length=24;
//  sendAnimationFrameSize(24);
//  for(int i=0;i<length;i++){
//    float p=0;
//    if(i<5)
//      p=0;
//    else if(i<7)
//      p= (i-5)/2.;
//    else if(i<17)
//      p=1;
//    else if(i<19)
//      p= (19-i)/2.;
//    else p=0;
//    
//    Serial.print(i);
//    Serial.print(" ");
//    Serial.println(p);
//    saveWeatherAtIndex(i,1000, Weather(p, kClear, 0));
//    delay(100);
//  }
//  delay(100);
////  sendAnimationFrameSize(3);
////    saveWeatherAtIndex(0,4000, Weather(0, kClear, 0));
////    delay(100);
////    saveWeatherAtIndex(1,4000, Weather(1, kClear, 0));
////    delay(100);
////    saveWeatherAtIndex(2,4000, Weather(0, kClear, 0));
////    delay(100);
////  }
//  playSavedAnimation();
//    delay(12000);
//  
//  
////  Serial.println("send");
//////  playDemo();
////  
////  
////  
////  
////  //save
////  int length=rand()%10+4;
////  
////  Serial.print("length:");
////  Serial.println(length);
////  
////  //send length
////  sendAnimationFrameSize(length);
////  
////  for(int i=0;i<length;i++){
////  digitalWrite(13,HIGH);
////      float p=(rand()%1000)/1000.;
////      Weather weather(
////        p,
////        (WeatherType)(rand()%3),
////  //      rand()%2==0?kClear:kCloudy,
////       rand()%2
////  //0
////      );
////      long dur=rand()%5000+2000;
////      
////      Serial.print(i);
////      Serial.print(" ");
////      Serial.print(dur);
////      Serial.print(" ");
////      Serial.print(weather.pNoon());
////      Serial.print(" ");
////      Serial.print(weather.weatherType());
////      Serial.print(" ");
////      Serial.print(weather.lightning());
////      Serial.println();
////      
////      sendRealtimeWeather(weather);
////      
////      digitalWrite(13,LOW);
////    delay(3000);
//////    saveWeatherAtIndex(i,dur,weather);
//////    
//////    
//////    delay(200);
////  }
////  
////      turnOff();
//////      playDemo();
////      Serial.println("off");
////      delay(5000);
//////  Serial.println("play");
//////  playSavedAnimation();
//////  digitalWrite(13,LOW);
//////  
//////  delay(10000);
}
