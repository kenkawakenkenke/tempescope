/*
  Tempescope.ino - Main source file for OpenTempescope hardware
  Released as part of the OpenTempescope project - http://tempescope.com/opentempescope/
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

#include <EEPROM.h>
#include "Weather.h"
#include "PinController.h"
#include "LightController.h"
#include "FanStateController.h"
#include "PumpStateController.h"
#include "MistStateController.h"
#include "LightStateController.h"
#include "AnimationController.h"
#include <SoftwareSerial.h>
#include <SimpleTimer.h>


SoftwareSerial mySerial(10, 11); // RX, TX

#define FLAG_SAVED_EXISTS 0xB4
#define PIN_RX 10
//pins
#define PIN_R 5
#define PIN_G 6
#define PIN_B 9
#define PIN_MIST 12
#define PIN_FAN 7
#define PIN_PUMP 2
int red =  255;

SimpleTimer timer;
int timerId;
unsigned long timeStart;

/*****************
Low level controllers
******************/
PinController  *mistController,
               *fanController,
               *pumpController;
LightController *lightController;

/*****************
State controllers
******************/
FanStateController *fanStateController;
PumpStateController *pumpStateController;
MistStateController *mistStateController;
LightStateController *lightStateController;

AnimationController *demoAnimation;
AnimationController *singleWeatherAnimation;
AnimationController *nothingAnimation;
AnimationController *savedAnimation=NULL;
AnimationController *currentAnimation;
AnimationController *webAnimation;



void setup(){
  Serial.begin(9600);
  // timed actions setup
  //timerId = timer.setInterval(5000, RepeatTask);
  
  //Serial.println("Serial begin");
  
  //low level controllers
  mistController=new PinController(PIN_MIST);
  fanController=new PinController(PIN_FAN);
  pumpController=new PinController(PIN_PUMP);
  lightController=new LightController(PIN_R,PIN_G,PIN_B);
  
  //initializing 
  for(int i=0;i<3;i++){
   lightController->setRGB(255,0,0);
   delay(80);
   lightController->setRGB(0,0,0);
   delay(30);
   }
  for(int i=0;i<3;i++){
      lightController->setRGB(0,255,0);
   delay(80);
   lightController->setRGB(0,0,0);
   delay(30);
   }
  for(int i=0;i<3;i++){
      lightController->setRGB(0,0,255);
   delay(80);
   lightController->setRGB(0,0,0);
   delay(30);
   }
   
   // set the data rate for the SoftwareSerial port
  mySerial.begin(9600);
  mySerial.println("Hello, myserial?");
 
  //state controllers
  fanStateController=new FanStateController(fanController);
  pumpStateController=new PumpStateController(pumpController);
  mistStateController=new MistStateController(mistController);
  //Serial.println("11x");
  lightStateController=new LightStateController(lightController);
  
  
  //setup demo animation
  demoAnimation=new AnimationController();
  {
    //original demo
    demoAnimation->setNumFrames(21);
    demoAnimation->setFrameAt(0,5000, Weather(0,kClear,false));
    demoAnimation->setFrameAt(1,5000, Weather(0.5,kClear,false));
    demoAnimation->setFrameAt(2,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(3,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(4,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(5,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(6,5000, Weather(1,kRain,false));
    demoAnimation->setFrameAt(7,5000, Weather(1,kRain,false));
    demoAnimation->setFrameAt(8,5000, Weather(1,kRain,false));
    demoAnimation->setFrameAt(9,5000, Weather(1,kRain,false));
    demoAnimation->setFrameAt(10,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(11,5000, Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(12,5000, Weather(1,kClear,false));
    demoAnimation->setFrameAt(13,5000, Weather(1,kClear,false));
    demoAnimation->setFrameAt(14,5000, Weather(0.5,kRain,false));
    demoAnimation->setFrameAt(15,5000, Weather(0,kRain,false));
    demoAnimation->setFrameAt(16,5000, Weather(0,kRain,true));
    demoAnimation->setFrameAt(17,5000, Weather(0,kRain,true));
    demoAnimation->setFrameAt(18,5000, Weather(0,kRain,true));
    demoAnimation->setFrameAt(19,5000, Weather(0,kClear,true));
    demoAnimation->setFrameAt(20,5000, Weather(0,kClear,false));
    
  }
  
  //for showing single weather
  singleWeatherAnimation=new AnimationController();
  {
    singleWeatherAnimation->setNumFrames(1);
    singleWeatherAnimation->setFrameAt(0,3000,Weather(0,kClear,false));
    
  }
  
  //for doing nothing
  nothingAnimation=new AnimationController();
  {
    nothingAnimation->setNumFrames(1);
    nothingAnimation->setFrameAt(0,10000,Weather(0,kClear,false));
  }

  webAnimation=new AnimationController();
  {
      webAnimation->setNumFrames(2);
      webAnimation->setFrameAt(0,3000, Weather(0,kClear,false));
      webAnimation->setFrameAt(1,3000, Weather(0,kClear,false));
  }
  
  //load saved animation
  boolean needsInitializingEEPROM=true;
  if(EEPROM.read(0)==FLAG_SAVED_EXISTS){
  //if(EEPROM.read(1)==FLAG_SAVED_EXISTS){
    Serial.println("load saved animation");
    savedAnimation=AnimationController::readFromEEPROM();//new AnimationController();
    
    //check saved animation(if exists) is sane
    int numFrames=savedAnimation->numFrames();
    if(numFrames>0 && numFrames<250){ //arbitrary...
      //clean up
      for(int i=0;i<numFrames;i++){
        savedAnimation->frameAtIndex(i)->weather.validateAndFix();
      }
      needsInitializingEEPROM=false;
    }
  }
  
  if(needsInitializingEEPROM){
    if(savedAnimation==NULL)
      savedAnimation=new AnimationController();
    savedAnimation->setNumFrames(1);
    Weather weather(0,kClear,false);
    savedAnimation->setFrameAt(0,3000,weather);
    
    EEPROM.write(1,1); //save length 
    int sizeOfWeather=sizeof(AnimationFrame);
    char *frame=(char *)(savedAnimation->frameAtIndex(0));
    for(int j=0;j<sizeOfWeather;j++)
      EEPROM.write(2+j,*(frame+j));
    EEPROM.write(0,FLAG_SAVED_EXISTS);
  }
  
  currentAnimation=singleWeatherAnimation;
  
  if(savedAnimation->numFrames()>0){
    //Serial.println("savedAnim.Frames >0");
    lightController->setRGB(0,0,255);
    currentAnimation=savedAnimation;
    currentAnimation=demoAnimation;
  }else
  {
    //Serial.println("savedAnim.Frames <0");
    lightController->setRGB(0,255,0);
    currentAnimation=demoAnimation;
  }

  //do nothing to start up
  currentAnimation=nothingAnimation;
  
  currentAnimation->start();
  delay(1000);
  lightController->setRGB(0,0,0);

  timeStart = 0;
  
  Serial.println("Setup ende");
  //request inital weather
  mySerial.print("BLEup");
}


// function to be called repeatedly
void RepeatTask() {
  unsigned long timeNow =millis();
  mySerial.print("BLEup");
  Serial.println("time since last fire"); 
  Serial.println((timeNow - timeStart)/1000);
  Serial.println("fetch data triggered");        
}


int freeRam () {
    extern int __heap_start, *__brkval;
    int v;
    return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}

uint8_t *_tester;

void doWeather(Weather weather){
  if(weather.lightning())
    lightStateController->doAction(ACTION_LIGHT_LNG_ON);
  else{
    lightStateController->setPNoon(weather.pNoon());
    lightStateController->doAction(ACTION_LIGHT_LNG_OFF);
  }
  
  switch(weather.weatherType()){
    case kClear:
    {
    pumpStateController->doAction(ACTION_PUMP_OFF);
    fanStateController->doAction(ACTION_FAN_OFF);
    mistStateController->doAction(ACTION_MIST_OFF);
    }break;
    case kRain:
    {
    pumpStateController->doAction(ACTION_PUMP_ON);
    fanStateController->doAction(ACTION_FAN_OFF);
    mistStateController->doAction(ACTION_MIST_OFF);
    }break;
    case kCloudy:
    {
    pumpStateController->doAction(ACTION_PUMP_OFF);
    fanStateController->doAction(ACTION_FAN_ON);
    mistStateController->doAction(ACTION_MIST_ON);
    }break;
    case kStorm:
    {
    pumpStateController->doAction(ACTION_PUMP_ON);
    fanStateController->doAction(ACTION_FAN_ON);
    mistStateController->doAction(ACTION_MIST_ON);
    }break;
    case kRGB:
    {
    pumpStateController->doAction(ACTION_PUMP_OFF);
    fanStateController->doAction(ACTION_FAN_OFF);
    mistStateController->doAction(ACTION_MIST_OFF);
    int result = lightStateController->setRGB(weather.red(),weather.green(),weather.blue());
    //Serial.println(lightStateController->state());
    //Serial.println(result);
    }break;

  }
}


byte readBuf[21];
int readPacket(byte buf[],int length){
  int idx=0;
  long tEnd=millis()+1000;
  while(millis()<tEnd && idx<length){
    if(mySerial.available()>0){
      int k=mySerial.read();
      buf[idx++]=k;
    }
  }
  return idx==length;
}

void loop(){

timer.run();
  
  //delay(300);
  //Serial.print("state ");
  //Serial.println(lightStateController->state());
  //mySerial.print("BlEupdate: ");
  //mySerial.println("update");
  //delay(1000);
  //Serial.println("RAM: " + String(freeRam(), DEC));
  if (mySerial.available()>0)
  {
    char func=mySerial.read();
    //Serial.write(func);
    Serial.print(func);
    boolean err=0;
    
    switch(func){
      case 'C':
        //connecting!
        
        //read and ignore (C)ONNECT
        readPacket(readBuf, 7);
        break;
      case 'D':
        //disconnecting!
        //read and ignore (D)ISCONNECT
        readPacket(readBuf, 10);
        break;
        
      case 'z':
        //off
//        Serial.println("off");
        timer.deleteTimer(timerId);
        currentAnimation=nothingAnimation;
        currentAnimation->start();
        
      break;
      
      case 'r':
        
        //play single weather
        if(readPacket(readBuf, 6)){
          double pNoon= readBuf[0]/255.;
          int weatherType= readBuf[1];
          int lightning=readBuf[2];
          //duration set from app in 1 minutes slices
          long duration=readBuf[3]*60*1000L;
          //wait frame in 5 min slices
          long waitFrame=readBuf[4]*60*1000L;
          //wait frame in 5 min slices
          long pollIntervall=readBuf[5]*60*5*1000L;
          //calculate waitFrame until next poll
          if (waitFrame >=pollIntervall -duration || waitFrame == 0)
          {
            waitFrame =pollIntervall -duration;
          }
          
          //Serial.println(pNoon);
          //Serial.println(weatherType);
          //Serial.println(lightning);
          Serial.println(" ");
          Serial.print("aDur ");
          Serial.print(duration/1000);
          Serial.print(" wDur: ");
          Serial.print(waitFrame/1000);
          Serial.print(" pollIntervall: ");
          Serial.print(pollIntervall/1000);
          Serial.print(" pNoon: ");
          Serial.print(pNoon);
          Serial.print(" weahthertype: ");
          Serial.print(weatherType);
          Serial.print(" lightning: ");
          Serial.println(lightning);

          //send back to iPhone
          //mySerial.println("play weather");

          timer.deleteTimer(timerId);
          timerId=timer.setInterval(pollIntervall, RepeatTask);
          timer.restartTimer(timerId);
          
          
          Weather newWeather(pNoon, (WeatherType)weatherType, lightning);
          //Serial.println("bevore validate and fix");
          //newWeather.print();
          newWeather.validateAndFix();
          //Serial.println("after validate and fix");
          newWeather.print();
          //play weather for certain time
            
          webAnimation->setFrameAt(0,duration,newWeather);
          webAnimation->setFrameAt(1,waitFrame,Weather(0,kClear,false));
        
          //singleWeatherAnimation->setFrameAt(0,duration,newWeather);
          //currentAnimation=singleWeatherAnimation;
          currentAnimation=webAnimation;
          
          currentAnimation->start();
          
          
        }else{
          err=1;
        }
      break;
      
      case 'd':
        //play demo
//        Serial.println("play demo");
        currentAnimation=demoAnimation;
        currentAnimation->start();
      break;
      
      case 'l':
        //play saved animation
//          Serial.println("play saved");
        currentAnimation=savedAnimation;
        currentAnimation->start();
      break;

      case 'g':
        //set rgb led
         //play single weather
        if(readPacket(readBuf, 6)){
          double pNoon= readBuf[0]/255.;
          int weatherType= readBuf[1];
          int lightning=readBuf[2];
          double red= readBuf[3]/255.;
          double green= readBuf[4]/255.;
          double blue= readBuf[5]/255.0;
          //Serial.println(pNoon);
          //Serial.println(weatherType);
          //Serial.println(lightning);
          
          Weather newWeather(pNoon, (WeatherType)weatherType, lightning, red, green, blue);
          
          newWeather.validateAndFix();
          newWeather.print();
    
          singleWeatherAnimation->setFrameAt(0,2000,newWeather);
          
          currentAnimation=singleWeatherAnimation;
          currentAnimation->start();

          //Serial.print("state ");
          //Serial.println(lightStateController->state());
          
        }else{
          err=1;
        }
      break;
      
      case 's':
        //save a frame
        if(readPacket(readBuf, 6)){
          
          int idx=readBuf[0];
          long dur= (((long)readBuf[1])<<8)|readBuf[2];
          if(dur>60000)
            dur=60000; //just in case
          if(dur<=0)
            dur=1;
            
          double pNoon= readBuf[3]/255.;
          int weatherType= readBuf[4];
          int lightning=readBuf[5];
          
          Weather newWeather(pNoon, (WeatherType)weatherType, lightning);
          newWeather.validateAndFix();
          
          //copy to frame
          savedAnimation->setFrameAt(idx,dur,newWeather);
          
          int sizeOfWeather=sizeof(AnimationFrame);
          char *frame=(char *)(savedAnimation->frameAtIndex(idx));
          int baseIdx= 2+ idx*sizeOfWeather;
          for(int j=0;j<sizeOfWeather;j++)
            EEPROM.write(baseIdx+j,*(frame+j));
            
          Serial.print("save: ");
          Serial.print((int)idx);
          Serial.print(" ");
          Serial.print(dur);
          Serial.print(" ");
          newWeather.print();
          digitalWrite(13,LOW);
          
        }else{
          err=1;
        }
      break;
      
      
      case 'f':
        //length of animation frame
        if(readPacket(readBuf, 1)){
          int length=readBuf[0];
          
          savedAnimation->setNumFrames(length);
      
          EEPROM.write(1,length); //save
          //save to "saved"
          lightController->setRGB(255,255,0);
          savedAnimation->start();
          
        }else{
          err=1;
        }
      break;
      
      default:
        err=1;
    }
    if(err){
      while(mySerial.available()>0) //kill everything in Socket
        mySerial.read();
    }
  }


  if (Serial.available())
    mySerial.write(Serial.read());
    
  
  doWeather(currentAnimation->getCurrentWeather());
  //digitalWrite(11,HIGH);
  //analogWrite(11,55); 
}
