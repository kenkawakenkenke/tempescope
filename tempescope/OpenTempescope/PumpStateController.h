/*
  PumpStateController.h - Pump state controller for an OpenTempescope
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

#ifndef PumpStateController_h
#define PumpStateController_h
#include <Arduino.h>
#include "StateController.h"
#include "PinController.h"

#define STATE_PUMP_OFF 0
#define STATE_PUMP_ON 1
#define ACTION_PUMP_ON 0
#define ACTION_PUMP_OFF 1

class PumpStateController: public StateController{
  public:
    PumpStateController(PinController *pumpController);
    
  protected:
    void stateChangedTo(int state);
    void transition(int state,int action);
    void stateTimedOut(int state);
  private:
    PinController *pumpController;
};

#endif
