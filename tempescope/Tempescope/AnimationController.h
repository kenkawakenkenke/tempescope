/*
  AnimationController.h - Class controlling weather animations on a Tempescope
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
#ifndef AnimationController_h
#define AnimationController_h
#include <Arduino.h>
#include <EEPROM.h>
#include "Weather.h"

typedef struct{
   long duration;
   Weather weather;
} AnimationFrame;

class AnimationController{
  public:
    AnimationController();
    void start();
    Weather getCurrentWeather();
    
    static AnimationController *readFromEEPROM(){
      int sizeOfWeather=sizeof(AnimationFrame);
      
      int lnt = EEPROM.read(1);
      if(lnt>50){
        lnt=50;
      }
        Serial.println("=================");
      Serial.print(sizeOfWeather);
      Serial.print(" ");
      Serial.println(lnt);
      delay(2000);
        
//      Serial.println(sizeOfWeather);
      AnimationController *controller=new AnimationController();
      controller->setNumFrames(lnt);
      long _durTotal=0;
      
//  for(int i=0;i<20;i++){
//    Serial.println("woot");
//    Serial.println(i);
//    delay(100);
//  }

//      AnimationFrame animFrame={0};
      for(int i=0;i<lnt;i++){
        
        int baseIdx= 2+ i*sizeOfWeather;
        int* frame=(int*)&(controller->_frames[i]);
        for(int j=0;j<sizeOfWeather;j++){
          *frame = EEPROM.read(baseIdx+j);
          frame++;
        }
        controller->_frames[i].weather.validateAndFix();
        if(controller->_frames[i].duration<0l)
          controller->_frames[i].duration=0l;
        if(controller->_frames[i].duration>30000l)
          controller->_frames[i].duration=30000l;
        
//        Serial.print("read weather: ");
//        Serial.print(i);
//        Serial.print(" ");
//        Serial.print(controller->_frames[i].duration);
//        Serial.print(" ");
        controller->_frames[i].weather.print();
      }
      
      //count total duration
      for(int i=0;i<lnt;i++)
        _durTotal+= controller->_frames[i].duration;
      return controller;
    }
    
    void setNumFrames(int numFrames);
    AnimationFrame *frameAtIndex(int idx){return &(_frames[idx]);};
    int numFrames(){return _numFrames;};
    void setFrameAt(int idx, long dur, Weather weather);
  private:
  int _numFrames;
  AnimationFrame *_frames;
  
    boolean _isRunning;
    long _tFrameStart;
    int _idxFrame;
    long _durTotal;
};

#endif
