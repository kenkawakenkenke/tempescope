/*
  MistStateController.cpp - Mist state controller for an OpenTempescope
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

#include "MistStateController.h"

MistStateController::MistStateController(PinController* mistController){
  this->mistController=mistController;
  setState(STATE_MIST_OFF);
}
void MistStateController::stateChangedTo(int state){
    if(state==STATE_MIST_OFF){
      mistController->turnOff();
      setStateTTL(-1);
    }
    else if(state==STATE_MIST_ON_H){
      mistController->turnOn();
      setStateTTL(-1);
//      setStateTTL((rand()%4000)+3000); //on for 500~2000 millis
    }else if(state==STATE_MIST_ON_L){
//      mistController->turnOff();
//      setStateTTL(3000);
    }
}
void MistStateController::transition(int state,int action){
  if(state==STATE_MIST_OFF && action==ACTION_MIST_ON)
    setState(STATE_MIST_ON_H);
  else if(state!=STATE_MIST_OFF && action==ACTION_MIST_OFF)
    setState(STATE_MIST_OFF);
}

/**
Called if state times out (millis()-inStateSince>=stateTTL)
*/
void MistStateController::stateTimedOut(int state){
  if(state==STATE_MIST_ON_H)
    setState(STATE_MIST_ON_L);
  else if(state==STATE_MIST_ON_L)
    setState(STATE_MIST_ON_H);
}
