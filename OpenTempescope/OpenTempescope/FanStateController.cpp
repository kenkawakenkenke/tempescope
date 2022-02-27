/*
  FanStateController.cpp - State controller for fans on an OpenTempescope
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

#include "FanStateController.h"

FanStateController::FanStateController(PinController* fanController){
  this->fanController=fanController;
  setState(STATE_FAN_OFF);
}
void FanStateController::stateChangedTo(int state){
  if(state==STATE_FAN_OFF){
    fanController->turnOff();
    setStateTTL(-1);
  }else if(state==STATE_FAN_ON_H){
    fanController->turnOn();
    setStateTTL((rand()%4000)+3000); //on for 500~2000 millis
  }else if(state==STATE_FAN_ON_L){
    fanController->turnOff();
    setStateTTL(3000);
  }else if(state==STATE_FAN_CLEARING){
    fanController->turnOn();
    setStateTTL(T_FAN_CLEAR_TTL); //clearing for fixed time
  }
}
void FanStateController::transition(int state,int action){
  if(action==ACTION_FAN_ON){
   if(state==STATE_FAN_OFF || state==STATE_FAN_CLEARING)
     setState(STATE_FAN_ON_H);
  }else if(action==ACTION_FAN_OFF){
   if(state==STATE_FAN_ON_H || state==STATE_FAN_ON_L)
     setState(STATE_FAN_CLEARING);
//     setState(STATE_FAN_OFF);
  }
}

/**
Called if state times out (millis()-inStateSince>=stateTTL)
*/
void FanStateController::stateTimedOut(int state){
  if(state==STATE_FAN_ON_H)
    setState(STATE_FAN_ON_L);
  else if(state==STATE_FAN_ON_L)
    setState(STATE_FAN_ON_H);
  else if(state==STATE_FAN_CLEARING){
    setState(STATE_FAN_OFF);
    for(int i=0;i<5;i++){
      digitalWrite(9,HIGH);
      delay(300);
      digitalWrite(9,LOW);
      delay(300);
    }
  }
}
