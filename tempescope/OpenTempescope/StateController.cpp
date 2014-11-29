/*
  StateController.cpp - Abstract state controller
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

#include "StateController.h"

StateController::StateController(){
  inStateSince=millis();
  currentState=0;
  stateTTL-1;
  stateChangedTo(currentState);
}
int StateController::state(){
  return currentState;
}

void StateController::setStateTTL(long ttl){
  stateTTL=ttl;
}
void StateController::setState(int state){
  if(currentState!=state){
    currentState=state;
    setTimerToZero();
    stateChangedTo(currentState);
  }
}
void StateController::setTimerToZero(){
  inStateSince=millis();
}

void StateController::doAction(int action){
  if(action!=NO_ACTION)
    transition(currentState,action);
  if(stateTTL!=-1 && millis()-inStateSince>=stateTTL)
    stateTimedOut(currentState);
}
