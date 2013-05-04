package com.tempescope.app;

import com.tempescope.controller.TempescopeController;
import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;

/*
 * SimpleTest.java - simple test showing playing weather on a tempescope
 * 
 * Released as part of the Tempescope project - http://kenkawakenkenke.github.io/tempescope/
 * Copyright (c) 2013 Ken Kawamoto.  All right reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
public class SimpleTest
{
	
	public static void main(String[] args) throws InterruptedException
	{
		TempescopeController tempescope=new TempescopeController();
		
		//sunny!
		tempescope.playWeather(new Weather(1,WeatherType.kClear,false));
		Thread.sleep(5000);

		//rain+thunder!
		tempescope.playWeather(new Weather(1,WeatherType.kRain,true));
		Thread.sleep(5000);

		//cloud!
		tempescope.playWeather(new Weather(1,WeatherType.kCloud,true));
		Thread.sleep(5000);
		
		//good bye
		tempescope.turnOff();
	}
}
