package com.tempescope.app;

import gis.model.Coordinate;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import com.tempescope.controller.TempescopeController;
import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;
import com.tempescope.wunderground.WundergroundManager;
import com.tempescope.wunderground.WundergroundQueryResult;

import common.ds.Tuple;
import common.util.DateUtil;
import common.util.MathUtil;

/*
 * Save_24HourForecast.java - save the next 24 hour forecast at a specific location
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
public class Save_24HourForecast
{
	
	public static void main(String[] args) throws InterruptedException
	{
		//initialize wunderground (weather API) manager
		WundergroundManager wundergroundManager;
		{
			//get Wunderground API key
			//if you don't already have a key, get one here: http://www.wunderground.com/weather/api/
			//and put it in tempescope.properties
			Properties prop=new Properties();
			try{
				prop.load(new FileInputStream(new File("tempescope.properties")));
			}catch(Exception e){
				System.err.println("can't find tempescope.properties!!!");
				System.exit(-1);
			}
			wundergroundManager=new WundergroundManager(prop.getProperty("wundergroundAPIKey"));
		}

		//initialize serial access to Tempescope
		TempescopeController tempescope=new TempescopeController();

		//your coordinate (write your favorite location in the world)
		Coordinate coord=new Coordinate(138.455511,34.728949);

		long tPerHour=2*60*1000/24; //real time(ms) per hour of simulation
		
		List<WundergroundQueryResult> results=wundergroundManager.forecastForCoords(coord);
		results=results.subList(0, Math.min(results.size(), 24));
		if(results.size()>0){

			ArrayList<Tuple<Long,Weather>> weathers=new ArrayList<Tuple<Long,Weather>>();
			for(WundergroundQueryResult result:results){
				System.out.println(result.t+"\t"+result.weatherStr);
				Boolean lightning=wundergroundManager.lightningForWeatherString(result.weatherStr);
				if(lightning==null)
					lightning=false;
				
				WeatherType weatherType=wundergroundManager.weatherTypeForWeatherString(result.weatherStr);
				if(weatherType==null)
					weatherType=WeatherType.kClear;

				int hour=DateUtil.getHour(result.t);
					double pNoon=0;
					if(hour<40)
						pNoon=0;
					else if(hour<7)
						pNoon=MathUtil.map(hour, 4, 7);
					else if(hour<16)
						pNoon=1.;
					else if(hour<19)
						pNoon=MathUtil.map(hour, 16, 19,1,0);
					else
						pNoon=0;
				Weather weather=new Weather(pNoon, weatherType, lightning);
				weathers.add(new Tuple<Long,Weather>(tPerHour,weather));
			}
			
			System.out.println("saving "+weathers.size());
			tempescope.saveWeather(weathers);
		}
	}
}
