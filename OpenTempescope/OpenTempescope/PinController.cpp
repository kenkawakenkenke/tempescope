/*
  PinController.cpp - Generic pin controller
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

#include "PinController.h"

PinController::PinController(int pin){
    this->pin=pin;
    pinMode(pin,OUTPUT);
    this->_on=false;
    digitalWrite(pin,LOW);
}
void PinController::turnOn(){
  if(!_on){
    digitalWrite(pin,HIGH);
    _on=true;
  }
}
void PinController::turnOff(){
  if(_on){
      digitalWrite(pin,LOW);
      _on=false;
  }
}
