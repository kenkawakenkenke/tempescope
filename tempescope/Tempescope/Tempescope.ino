/*
  Tempescope.ino - Main source file for Tempescope hardware
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
#include <EEPROM.h>
#include "Weather.h"
#include "PinController.h"
#include "LightController.h"
#include "FanStateController.h"
#include "PumpStateController.h"
#include "MistStateController.h"
#include "LightStateController.h"
#include "AnimationController.h"

#define FLAG_SAVED_EXISTS 0xB4
#define PIN_RX 8
//pins
#define PIN_R 11
#define PIN_G 6
#define PIN_B 5
#define PIN_MIST 13
#define PIN_FAN 9
#define PIN_PUMP 2

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
void setup(){
  
  Serial.begin(9600);
  Serial.println("setup");
//  
//  Serial.print("int: ");
//  Serial.println(sizeof(int));
//  Serial.print("long: ");
//  Serial.println(sizeof(long));
//  Serial.print("float: ");
//  Serial.println(sizeof(float));
//  Serial.print("short: ");
//  Serial.println(sizeof(short));
  
  //low level controllers
  mistController=new PinController(PIN_MIST);
  fanController=new PinController(PIN_FAN);
  pumpController=new PinController(PIN_PUMP);
  lightController=new LightController(PIN_R,PIN_G,PIN_B);
  
  Serial.println("initializing...");
  for(int i=0;i<5;i++){
   lightController->setRGB(255,0,0);
   delay(100);
   lightController->setRGB(0,0,0);
   delay(50);
  }
 
  //state controllers
  fanStateController=new FanStateController(fanController);
  pumpStateController=new PumpStateController(pumpController);
  mistStateController=new MistStateController(mistController);
  lightStateController=new LightStateController(lightController);
  
  
  //setup demo animation
  demoAnimation=new AnimationController();
  {
    demoAnimation->setNumFrames(24);
    demoAnimation->setFrameAt(0,5000,Weather(0,kClear,false));
    demoAnimation->setFrameAt(1,5000,Weather(0,kCloudy,false));
    demoAnimation->setFrameAt(2,5000,Weather(0,kCloudy,false));
    demoAnimation->setFrameAt(3,5000,Weather(0,kCloudy,false));
    demoAnimation->setFrameAt(4,5000,Weather(0,kCloudy,false));
    demoAnimation->setFrameAt(5,5000,Weather(0.5,kRain,false));
    demoAnimation->setFrameAt(6,5000,Weather(1,kRain,false));
    demoAnimation->setFrameAt(7,5000,Weather(1,kRain,false));
    demoAnimation->setFrameAt(8,5000,Weather(1,kRain,false));
    demoAnimation->setFrameAt(9,5000,Weather(1,kRain,false));
    demoAnimation->setFrameAt(10,5000,Weather(1,kRain,false));
    demoAnimation->setFrameAt(11,5000,Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(12,5000,Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(13,5000,Weather(1,kCloudy,false));
    demoAnimation->setFrameAt(14,5000,Weather(1,kClear,false));
    demoAnimation->setFrameAt(15,5000,Weather(1,kClear,false));
    demoAnimation->setFrameAt(16,5000,Weather(1,kClear,false));
    demoAnimation->setFrameAt(17,5000,Weather(0.5,kClear,false));
    demoAnimation->setFrameAt(18,5000,Weather(0,kRain,false));
    demoAnimation->setFrameAt(19,5000,Weather(0,kRain,true));
    demoAnimation->setFrameAt(20,5000,Weather(0,kRain,true));
    demoAnimation->setFrameAt(21,5000,Weather(0,kCloudy,true));
    demoAnimation->setFrameAt(22,5000,Weather(0,kCloudy,false));
    demoAnimation->setFrameAt(23,5000,Weather(0,kClear,false));
//    demoAnimation->setFrameAt(0,3000,Weather(0,kClear,false));
//    demoAnimation->setFrameAt(1,5000,Weather(1,kClear,false));
//    demoAnimation->setFrameAt(2,5000,Weather(1,kClear,false));
//    demoAnimation->setFrameAt(3,5000,Weather(1,kCloudy,false));
//    demoAnimation->setFrameAt(4,5000,Weather(1,kClear,false));
//    demoAnimation->setFrameAt(5,5000,Weather(0,kClear,true));
//    demoAnimation->setFrameAt(6,5000,Weather(0,kClear,true));
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
  
  
  //load saved animation
  Serial.println("loading saved");
  boolean needsInitializingEEPROM=true;
  if(EEPROM.read(0)==FLAG_SAVED_EXISTS){
    Serial.println("saved flag up");
    savedAnimation=AnimationController::readFromEEPROM();//new AnimationController();
    
    //check saved animation(if exists) is sane
    int numFrames=savedAnimation->numFrames();
    if(numFrames>0 && numFrames<250){ //arbitrary...
      //clean up
      for(int i=0;i<numFrames;i++)
        savedAnimation->frameAtIndex(i)->weather.validateAndFix();
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
    char *frame=(char *)&weather;
    int sizeOfWeather=sizeof(Weather);
    for(int j=0;j<sizeOfWeather;j++)
      EEPROM.write(2+j,*(frame+j));
    EEPROM.write(0,FLAG_SAVED_EXISTS);
  }
  
  //setup RX
  vw_set_rx_pin(PIN_RX);
  vw_setup(1200); // Bits per sec
  vw_rx_start();    // Start the receiver PLL running
  
  if(savedAnimation->numFrames()>0){
    lightController->setRGB(0,0,255);
    currentAnimation=savedAnimation;
    Serial.println("starting with saved");
    Serial.println(savedAnimation->numFrames());
    for(int i=0;i<savedAnimation->numFrames();i++)
      savedAnimation->frameAtIndex(i)->weather.print();
  }else
  {
    lightController->setRGB(0,255,0);
    currentAnimation=demoAnimation;
    Serial.println("starting with demo");
  }
  currentAnimation->start();
  delay(3000);
  lightController->setRGB(0,0,0);
}

void doWeather(Weather weather){
  if(weather.lightning())
    lightStateController->doAction(ACTION_LIGHT_LNG_ON);
  else{
    lightStateController->setPNoon(weather.pNoon());
    lightStateController->doAction(ACTION_LIGHT_LNG_OFF);
  }
  
//      Serial.print("weather: ");
//      weather.print();
//      Serial.println();
  switch(weather.weatherType()){
    case kClear:
    {
    pumpStateController->doAction(ACTION_PUMP_OFF);
    fanStateController->doAction(NO_ACTION);
    mistStateController->doAction(ACTION_MIST_OFF);
    }break;
    case kRain:
    {
    pumpStateController->doAction(ACTION_PUMP_ON);
    fanStateController->doAction(NO_ACTION);
    mistStateController->doAction(ACTION_MIST_OFF);
    }break;
    case kCloudy:
    {
    pumpStateController->doAction(ACTION_PUMP_OFF);
    fanStateController->doAction(ACTION_FAN_ON);
    mistStateController->doAction(ACTION_MIST_ON);
    }break;
  }
}

uint8_t buf[VW_MAX_MESSAGE_LEN];
uint8_t buflen = VW_MAX_MESSAGE_LEN;
void loop(){
  
  if (vw_get_message(buf, &buflen)) // Non-blocking
  {
    char func=buf[0];
    if(func=='z'){ //off
      Serial.println("off");
      currentAnimation=nothingAnimation;
      currentAnimation->start();
    }else if(func=='r'){
      Weather newWeather=*(Weather*)&(buf[1]);
      newWeather.validateAndFix();
      newWeather.print();

      singleWeatherAnimation->setFrameAt(0,100,newWeather);
      
      currentAnimation=singleWeatherAnimation;
      currentAnimation->start();
    }else if(func=='d'){
      Serial.println("play demo");
      currentAnimation=demoAnimation;
      currentAnimation->start();
    }else if(func=='l'){ //play the saved animation
      Serial.println("play saved");
      currentAnimation=savedAnimation;
      currentAnimation->start();
    }else if(func=='s'){ //save a frame
      char idx=buf[1];
      long dur=*(long*)&(buf[2]);
      if(dur>60000)
        dur=60000; //just in case
      if(dur<=0)
        dur=1;
      Weather newWeather=*(Weather*)&(buf[6]);
      newWeather.validateAndFix();
      
      //copy to frame
      savedAnimation->setFrameAt(idx,dur,newWeather);
      char *frame=(char *)&newWeather;
      int sizeOfWeather=sizeof(Weather);
      int baseIdx= 2+ idx*sizeOfWeather;
      for(int j=0;j<sizeOfWeather;j++)
        EEPROM.write(baseIdx+j,*(frame+j));
        
      Serial.print("save: ");
      Serial.print((int)idx);
      Serial.print(" ");
      Serial.print(dur);
      Serial.print(" ");
      newWeather.print();
//  digitalWrite(13,LOW);
      //save to "saved"
    }else if(func=='f'){ //set length of animation frame
//  digitalWrite(13,HIGH);
      int length=buf[1];
      Serial.print("length: ");
      Serial.println((int)length);
      savedAnimation->setNumFrames(length);
      
//      Serial.println("here");
      EEPROM.write(1,length); //save
      //save to "saved"
      lightController->setRGB(255,255,0);
      savedAnimation->start();
    }
  }
  
  doWeather(currentAnimation->getCurrentWeather());
}
