/*
  FanStateController.cpp - State controller for fans on a Tempescope
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

#include "FanStateController.h"

FanStateController::FanStateController(PinController* fanController){
  this->fanController=fanController;
  setState(STATE_FAN_OFF);
}
void FanStateController::stateChangedTo(int state){
//  Serial.print("====================== state changed to: ");
//  Serial.println(state);
  if(state==STATE_FAN_ON){
    fanController->turnOn();
    setStateTTL(T_FAN_ON_TTL);
  }
  else{
    fanController->turnOff();
    setStateTTL(-1);
  }
}
void FanStateController::transition(int state,int action){
  if(action==ACTION_FAN_ON){
//  Serial.print("====================== action on: ");
//  Serial.print(state);
//  Serial.print(" ");
//  Serial.println(action);
    if(state==STATE_FAN_OFF)
      setState(STATE_FAN_ON);
    else
      setTimerToZero();
  }
}

/**
Called if state times out (millis()-inStateSince>=stateTTL)
*/
void FanStateController::stateTimedOut(int state){
  if(state==STATE_FAN_ON)
    setState(STATE_FAN_OFF);
}
