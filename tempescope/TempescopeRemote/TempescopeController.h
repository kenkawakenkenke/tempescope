/*
  TempescopeController.h - Tempescope remote internal state controller
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
#ifndef TempescopeController_h
#define TempescopeController_h
#include <VirtualWire.h>
#include <Arduino.h>
#include "Weather.h"

#define fixedSendLength 15
#define MIN_WAIT_BEFORE_SEND_MILLIS 50

enum AnimationMode{
  kManual,
  kDemo,
  kSaved
};

  
class TempescopeController {
  public:
    TempescopeController();
    
    //accessors
    void setOn(boolean on);
    void setAnimationMode(AnimationMode mode);
    boolean setTODValue(int todValue);
    void setLightning(boolean lightning);
    void incrementWeatherType();
    
    void waitUntilSendable();
    void sendBuf();
    void playSavedAnimation();
    void playDemo();
    void turnOff();
    void sendRealtimeWeather(Weather weather);
    void saveWeatherAtIndex(int i,long dur,Weather weather);
    void sendAnimationFrameSize(int numFrames);
    
    void sendUpdateIfDirty();
    void sendUpdate();
    
    
    float pNoonForTOD(float tod);
    
  private:
    boolean _dirty;
    boolean _on;
    AnimationMode _animationMode;
    int _manualMode_tod_1024;
    boolean _manualMode_Lightning;
    WeatherType _manualMode_WeatherType;
    
    uint8_t buf[fixedSendLength];
    
    long tPrevSend;
};

#endif
