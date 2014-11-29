/*
  LightStateController.cpp - Sun state controller for an OpenTempescope
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

#include "LightStateController.h"

LightStateController::LightStateController(LightController* lightController){
  this->_pNoon=0;
  this->lightController=lightController;
  setState(STATE_LIGHT_SUN);
}
int mapInt(float p,float origMin, float toMin,float from,float to){
  p= (p-origMin)/(toMin-origMin);
  return (int)(from+p*(to-from));
}
void LightStateController::showSunlight(){
  if(_pNoon<0.5)
    lightController->setRGB( mapInt(_pNoon,0,0.5,0,255),
                  mapInt(_pNoon,0,0.5,0,10),
                  mapInt(_pNoon,0,0.5,0,0));
  else
//    lightController->setRGB( mapInt(_pNoon,0.5,1,250,255),
//                  mapInt(_pNoon,0.5,1,10,135),
//                  mapInt(_pNoon,0.5,1,0,175));
//    lightController->setRGB( mapInt(_pNoon,0.5,1,250,255),
//                  mapInt(_pNoon,0.5,1,10,160),
//                  mapInt(_pNoon,0.5,1,0,255));
    lightController->setRGB( mapInt(_pNoon,0.5,1,250,20),
                  mapInt(_pNoon,0.5,1,10,180),
                  mapInt(_pNoon,0.5,1,0,255));
}
void LightStateController::setPNoon(float pNoon){
  this->_pNoon=pNoon;
  if(state()==STATE_LIGHT_SUN)
    showSunlight();
}
void LightStateController::stateChangedTo(int state){
  if(state==STATE_LIGHT_LNG_H){
      lightController->setRGB(140,100,255); //and turn on white light
      setStateTTL((rand()%100)+0); //on for 500~2000 millis
  }
  else if(state==STATE_LIGHT_LNG_L){
      lightController->setRGB(0,0,0); //and turn off light
      setStateTTL((rand()%1500)+100); //on for 500~2000 millis
  }else if(state==STATE_LIGHT_SUN){
    showSunlight();
    setStateTTL(-1);
  }
  
}
void LightStateController::transition(int state,int action){
  switch(state){
    case STATE_LIGHT_SUN: //if mist is in OFF state,
      if(action==ACTION_LIGHT_LNG_ON) //if the action is turn on,
        setState(STATE_LIGHT_LNG_H);
      else
        showSunlight();
      break;
    case STATE_LIGHT_LNG_H: //ON(high)
      if(action==ACTION_LIGHT_LNG_OFF)
        setState(STATE_LIGHT_SUN);
      break;
    case STATE_LIGHT_LNG_L: //ON(low)
      if(action==ACTION_LIGHT_LNG_OFF)
        setState(STATE_LIGHT_SUN);
      break;
  }
}

/**
Called if state times out (millis()-inStateSince>=stateTTL)
*/
void LightStateController::stateTimedOut(int state){
  if(state==STATE_LIGHT_LNG_H)
    setState(STATE_LIGHT_LNG_L);
  else if(state==STATE_LIGHT_LNG_L)
    setState(STATE_LIGHT_LNG_H);
}
