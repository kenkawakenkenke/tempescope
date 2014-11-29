/*
  Weather.cpp - State class representing a weather state on an OpenTempescope
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

#include "Weather.h"

Weather::Weather(double pNoon,WeatherType weatherType, boolean lightning){
  this->_pNoon=pNoon;
  this->_weatherType=weatherType;
  this->_lightning=lightning;
}

void Weather::setFrom(Weather other){
  this->_pNoon=other.pNoon();
  this->_weatherType=other.weatherType();
  this->_lightning=other.lightning();
}

double Weather::pNoon(){
  return _pNoon;
}
WeatherType Weather::weatherType(){
  return _weatherType;
}
boolean Weather::lightning(){
  return _lightning;
}
  
  
  void Weather::print(){
    
      Serial.print(pNoon());
      Serial.print(" ");
      Serial.print(weatherType());
      Serial.print(" ");
      Serial.print(lightning());
      Serial.println();
  }
  
void Weather::validateAndFix(){
  if(_pNoon<0)_pNoon=0;
  if(_pNoon>1)_pNoon=1;
  if(_weatherType<0)_weatherType=kClear;
  if(_weatherType>2)_weatherType=kRain;
  if(_lightning<0)_lightning=0;
  if(_lightning>1)_lightning=1;
}
