/*
  FanStateController.h - State controller for fans on a Tempescope
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
#ifndef FanStateController_h
#define FanStateController_h
#include <Arduino.h>
#include "StateController.h"
#include "PinController.h"

#define STATE_FAN_OFF 0
#define STATE_FAN_ON 1
#define ACTION_FAN_ON 0
#define T_FAN_ON_TTL 180000

class FanStateController: public StateController{
  public:
    FanStateController(PinController *pinController);
    
  protected:
    void stateChangedTo(int state);
    void transition(int state,int action);
    void stateTimedOut(int state);
  private:
    PinController *fanController;
};

#endif
