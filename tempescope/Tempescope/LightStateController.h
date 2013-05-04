/*
  LightStateController.h - Sun state controller for a Tempescope
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

#ifndef LightStateController_h
#define LightStateController_h
#include <Arduino.h>
#include "StateController.h"
#include "LightController.h"

#define STATE_LIGHT_SUN 0 //sun
#define STATE_LIGHT_LNG_H 1 //lightning(high)
#define STATE_LIGHT_LNG_L 2 //lightning(low)
#define ACTION_LIGHT_LNG_ON 0
#define ACTION_LIGHT_LNG_OFF 1

class LightStateController: public StateController{
  public:
    LightStateController(LightController *lightController);
    void setPNoon(float pNoon);
  protected:
    void stateChangedTo(int state);
    void transition(int state,int action);
    void stateTimedOut(int state);
  private:
    void showSunlight();
    
    LightController *lightController;
    float _pNoon;
};

#endif
