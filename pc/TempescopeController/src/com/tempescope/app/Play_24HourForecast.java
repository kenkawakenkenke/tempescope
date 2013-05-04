package com.tempescope.app;

import gis.model.Coordinate;

import java.io.File;
import java.io.FileInputStream;
import java.util.List;
import java.util.Properties;

import com.tempescope.controller.TempescopeController;
import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;
import com.tempescope.wunderground.WundergroundManager;
import com.tempescope.wunderground.WundergroundQueryResult;

import common.util.DateUtil;
import common.util.MathUtil;

/*
 * Play_24HourForecast.java - play the next 24 hour forecast at specific location, without saving
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
public class Play_24HourForecast
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
		
		long updateCacheEvery_ms=30*60*1000; //how often to update weather cache (ms)
		long tLastUpdateCache=System.currentTimeMillis(); //time of last updating weather cache
		List<WundergroundQueryResult> weatherCache=null; //weather cache
		
		while(true){
			if(weatherCache==null || tLastUpdateCache+updateCacheEvery_ms<System.currentTimeMillis()){
				weatherCache=wundergroundManager.forecastForCoords(coord);
				weatherCache=weatherCache.subList(0, Math.min(weatherCache.size(), 24));
				if(weatherCache.size()==0)
					return;
				tLastUpdateCache=System.currentTimeMillis();
			}
			
			for(WundergroundQueryResult result:weatherCache){
				System.out.println(result.t+"\t"+result.weatherStr);
				Boolean lightning=wundergroundManager.lightningForWeatherString(result.weatherStr);
				if(lightning==null)
					lightning=false;
				
				WeatherType weatherType=wundergroundManager.weatherTypeForWeatherString(result.weatherStr);
				if(weatherType==null)
					weatherType=WeatherType.kClear;

				int minHead=DateUtil.getMinutes(result.t, result.tz);
				
				long tStartHour=System.currentTimeMillis();
				
				while(tStartHour+tPerHour > System.currentTimeMillis()){
					int min=(int)MathUtil.map(System.currentTimeMillis()-tStartHour, 0, tPerHour,minHead,minHead+60);

					double pNoon=0;
					if(min<4*60)
						pNoon=0;
					else if(min<7*60)
						pNoon=MathUtil.map(min, 4*60, 7*60);
					else if(min<16*60)
						pNoon=1.;
					else if(min<19*60)
						pNoon=MathUtil.map(min, 16*60, 19*60,1,0);
					else
						pNoon=0;
					
					tempescope.playWeather(new Weather(pNoon, weatherType,lightning));
					Thread.sleep(300);
				}
			}
			
		}
	}
}
