package com.tempescope.app;

import com.tempescope.controller.TempescopeController;
import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;

/*
 * PlayRandomly.java - plays random weather every 10 seconds
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

public class PlayRandomly
{
	
	public static void main(String[] args) throws InterruptedException
	{
		TempescopeController tempescope=new TempescopeController();
		
		/*
		 * play random weather every 10 seconds
		 */
		while(true){
			//sunny!
			double pNoon=Math.random();
			WeatherType type=WeatherType.values()[(int)(Math.random()*WeatherType.values().length)];
			boolean lightning=Math.random()>0.8;
			
			System.out.println(pNoon+" "+type+" "+lightning);
			
			tempescope.playWeather(new Weather(pNoon, type, lightning));
			Thread.sleep(10000);
		}
	}
}
