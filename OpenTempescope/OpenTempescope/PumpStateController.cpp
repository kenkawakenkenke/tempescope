/*
  PumpStateController.cpp - Pump state controller for an OpenTempescope
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

#include "PumpStateController.h"

PumpStateController::PumpStateController(PinController* pumpController){
  this->pumpController=pumpController;
  setState(STATE_PUMP_OFF);
}
void PumpStateController::stateChangedTo(int state){
  if(state==STATE_PUMP_ON){
    pumpController->turnOn();
  }
  else{
    pumpController->turnOff();
  }
}
void PumpStateController::transition(int state,int action){
  if(action==ACTION_PUMP_ON && state==STATE_PUMP_OFF)
    setState(STATE_PUMP_ON);
  else if(action==ACTION_PUMP_OFF && state==STATE_PUMP_ON)
    setState(STATE_PUMP_OFF);
}

/**
Called if state times out (millis()-inStateSince>=stateTTL)
*/
void PumpStateController::stateTimedOut(int state){
  //nothing to do
}
