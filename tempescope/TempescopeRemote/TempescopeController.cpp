/*
  TempescopeController.cpp - Tempescope remote internal state controller
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

#include "TempescopeController.h"


TempescopeController::TempescopeController(){
    
  _on=true;
  _animationMode=kManual;
  _manualMode_tod_1024=0;
  _manualMode_Lightning=false;
  _manualMode_WeatherType=kClear;
  
  tPrevSend=0;
  
  _dirty=true;  
}


void TempescopeController::setOn(boolean on){
  if(this->_on!=on){
    this->_on=on;
    this->_dirty=true;
  }
}

void TempescopeController::setAnimationMode(AnimationMode animationMode){
  if(this->_animationMode!=animationMode){
    this->_animationMode=animationMode;
    this->_dirty=true;
  }
}

boolean TempescopeController::setTODValue(int todValue){
  if(abs(this->_manualMode_tod_1024-todValue)>5){
    this->_manualMode_tod_1024=todValue;
    if(this->_animationMode==kManual && this->_on){ //only if we're in manual mode
      this->_dirty=true;
    }
      return true;
  }
  return false;
}

void TempescopeController::setLightning(boolean lightning){
  if(this->_manualMode_Lightning!=lightning){
    this->_manualMode_Lightning=lightning;
    if(this->_animationMode==kManual && this->_on) //only if we're in manual mode
      this->_dirty=true;
  }
}

void TempescopeController::incrementWeatherType(){
  if(_manualMode_WeatherType==kCloudy)
    _manualMode_WeatherType=kClear;
  else
    _manualMode_WeatherType=(WeatherType)(1+(int)_manualMode_WeatherType);
    if(this->_animationMode==kManual && this->_on) //only if we're in manual mode
      this->_dirty=true;
}

//
void TempescopeController::waitUntilSendable(){
//  long tWait=MIN_WAIT_BEFORE_SEND_MILLIS-(millis()-tPrevSend);
//  if(tWait>0)
//    delay(tWait);
}
void TempescopeController::sendBuf(){
    vw_send((uint8_t *)(buf),fixedSendLength);
    tPrevSend=millis();
}

void TempescopeController::playSavedAnimation(){
  waitUntilSendable();
  buf[0]='l';
  sendBuf();
}
void TempescopeController::playDemo(){
  waitUntilSendable();
     buf[0]='d';
  sendBuf();
}
void TempescopeController::turnOff(){
  waitUntilSendable();
     buf[0]='z';
  sendBuf();
}
void TempescopeController::sendRealtimeWeather(Weather weather){
  waitUntilSendable();
     buf[0]='r';
     memcpy(&(buf[1]),&weather, sizeof(Weather));
  sendBuf();
}
void TempescopeController::saveWeatherAtIndex(int i,long dur,Weather weather){
  waitUntilSendable();
     buf[0]='s';
     buf[1]=i;
     *((long*)&buf[2])=dur;
     memcpy(&(buf[6]),&weather, sizeof(Weather));
  sendBuf();
}
void TempescopeController::sendAnimationFrameSize(int numFrames){
  waitUntilSendable();
     buf[0]='f';
     buf[1]=numFrames;
  sendBuf();
}

void TempescopeController::sendUpdateIfDirty(){
  if(_dirty)
    sendUpdate();
}
void TempescopeController::sendUpdate(){
  if(_on){
      if(_animationMode==kManual){
        float tod= _manualMode_tod_1024/1024.;
        tod=sqrt(tod);
        float pNoon=pNoonForTOD(tod);
        sendRealtimeWeather(Weather(pNoon,_manualMode_WeatherType,_manualMode_Lightning));
      }
      else if(_animationMode==kDemo)
        playDemo();
      else if(_animationMode==kSaved)
        playSavedAnimation();
  }else
    turnOff();
    
//    digitalWrite(13,HIGH);
    Serial.println("sending...");
    Serial.print("on/off: "); Serial.println(_on);
    Serial.print("mode: "); Serial.println(_animationMode);
    Serial.print("tod: "); Serial.println(_manualMode_tod_1024);
    Serial.print("weatherType: "); Serial.println(_manualMode_WeatherType);
    Serial.print("lightning: "); Serial.println(_manualMode_Lightning);
    Serial.println();
    
//    delay(500);
//    digitalWrite(13,LOW);
//    delay(500);
  _dirty=false;
}


float TempescopeController::pNoonForTOD(float tod){
    if(tod<0.21)
      return 0;
    else if(tod<0.29)
      return (tod-0.21)/0.083333;
    else if(tod<0.708333)
      return 1;
    else if(tod<0.791666)
      return (0.791666-tod)/0.083333;
    else return 0;
}

