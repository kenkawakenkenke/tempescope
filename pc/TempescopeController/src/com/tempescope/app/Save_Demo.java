package com.tempescope.app;

import java.util.ArrayList;

import com.tempescope.controller.TempescopeController;
import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;

import common.ds.Tuple;

/*
 * Save_Demo.java - save demo 
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
public class Save_Demo
{

	
	public static void main(String[] args) throws InterruptedException
	{
		final TempescopeController tempescope=new TempescopeController();
	
		ArrayList<Tuple<Long,Weather>> weathers=new ArrayList<Tuple<Long,Weather>>();
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kCloud,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kCloud,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0.5,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kCloud,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kCloud,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(1,WeatherType.kClear,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0.5,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kRain,false)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kRain,true)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kRain,true)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kRain,true)));
		weathers.add(new Tuple<Long,Weather>(5000l, new Weather(0,WeatherType.kClear,false)));
		
		System.out.println("saving "+weathers.size());
		tempescope.saveWeather(weathers);
		
		System.out.println("done");
	}
}
