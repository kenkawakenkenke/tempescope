/*
  Weather.h - State class representing a weather state on an OpenTempescope
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

#ifndef Weather_h
#define Weather_h
#include <Arduino.h>

enum WeatherType{
  kClear,
  kRain,
  kCloudy};
  
class Weather {
  public:
  Weather(double pNoon,WeatherType weatherType, boolean lightning);
  double pNoon();
  WeatherType weatherType();
  boolean lightning();
  void setFrom(Weather other);
  void setFrom(double pNoon, WeatherType weatherType, boolean lightning);
  void print();
  void validateAndFix();
  
  private:
  
  double _pNoon;
  WeatherType _weatherType;
  boolean _lightning;
};

#endif
