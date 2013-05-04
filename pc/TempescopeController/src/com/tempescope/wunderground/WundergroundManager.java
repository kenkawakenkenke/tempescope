package com.tempescope.wunderground;

import gis.model.Coordinate;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

import com.tempescope.model.WeatherType;

import common.ds.DoubleWindowedQueue;
import common.ds.Tuple;

/*
 * WundergroundManager.java - manager for accessing weather API on Wunderground
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
public class WundergroundManager
{
	HashMap<String,Boolean> lightningForWeather=new HashMap<String,Boolean>();
	HashMap<String,WeatherType> weatherCategoryForWeather=new HashMap<String,WeatherType>();
	public void setWeather(String weather,Boolean lightning, WeatherType weatherType){
		lightningForWeather.put(weather, lightning);
		weatherCategoryForWeather.put(weather, weatherType);
		lightningForWeather.put("Light "+weather, lightning);
		weatherCategoryForWeather.put("Light "+weather, weatherType);
		lightningForWeather.put("Heavy "+weather, lightning);
		weatherCategoryForWeather.put("Heavy "+weather, weatherType);
	}
	public WeatherType weatherTypeForWeatherString(String weather){
		WeatherType cat=weatherCategoryForWeather.get(weather);
		if(cat==null){
			for(String key:weatherCategoryForWeather.keySet())
				if(weather.contains(key))
					return weatherCategoryForWeather.get(key);
		}
		return cat;
	}
	public Boolean lightningForWeatherString(String weather){
		Boolean ret=lightningForWeather.get(weather);
		if(ret==null){
			for(String key:lightningForWeather.keySet())
				if(weather.contains(key))
					return lightningForWeather.get(key);
		}
		return ret;
	}
	public WundergroundManager(String api){
		this.api=api;
		
		setWeather("Drizzle",false,WeatherType.kRain);
		setWeather("Rain",false,WeatherType.kRain);
		setWeather("Snow",false,WeatherType.kRain);
		setWeather("Snow Grains",false,WeatherType.kRain);
		setWeather("Ice Crystals",false,WeatherType.kRain);
		setWeather("Ice Pellets",false,WeatherType.kRain);
		setWeather("Hail",false,WeatherType.kRain);
		setWeather("Mist",false,WeatherType.kCloud);
		setWeather("Fog",false,WeatherType.kCloud);
		setWeather("Fog Patches",false,WeatherType.kCloud);
		setWeather("Smoke",false,WeatherType.kCloud);
		setWeather("Volcanic Ash",false,WeatherType.kCloud);
		setWeather("Widespread Dust",false,WeatherType.kCloud);
		setWeather("Sand",false,WeatherType.kCloud);
		setWeather("Haze",false,WeatherType.kCloud);
		setWeather("Spray",false,WeatherType.kRain);
		setWeather("Dust Whirls",false,WeatherType.kCloud);
		setWeather("Sandstorm",false,WeatherType.kCloud);
		setWeather("Low Drifting Snow",false,WeatherType.kRain);
		setWeather("Low Drifting Widespread Dust",false,WeatherType.kCloud);
		setWeather("Low Drifting Sand",false,WeatherType.kCloud);
		setWeather("Blowing Snow",false,WeatherType.kRain);
		setWeather("Blowing Widespread Dust",false,WeatherType.kCloud);
		setWeather("Blowing Sand",false,WeatherType.kCloud);
		setWeather("Rain Mist",false,WeatherType.kRain);
		setWeather("Rain Showers",false,WeatherType.kRain);
		setWeather("Snow Showers",false,WeatherType.kRain);
		setWeather("Snow Blowing Snow Mist",false,WeatherType.kRain);
		setWeather("Ice Pellet Showers",false,WeatherType.kRain);
		setWeather("Hail Showers",false,WeatherType.kRain);
		setWeather("Small Hail Showers",false,WeatherType.kRain);
		setWeather("Thunderstorm",true,WeatherType.kCloud);
		setWeather("Thunderstorms and Rain",true,WeatherType.kRain);
		setWeather("Thunderstorms and Snow",true,WeatherType.kRain);
		setWeather("Thunderstorms and Ice Pellets",true,WeatherType.kRain);
		setWeather("Thunderstorms with Hail",true,WeatherType.kRain);
		setWeather("Thunderstorms with Small Hail",true,WeatherType.kRain);
		setWeather("Freezing Drizzle",false,WeatherType.kRain);
		setWeather("Freezing Rain",false,WeatherType.kRain);
		setWeather("Freezing Fog",false,WeatherType.kCloud);
		setWeather("Patches of Fog",false,WeatherType.kCloud);
		setWeather("Shallow Fog",false,WeatherType.kCloud);
		setWeather("Partial Fog",false,WeatherType.kClear);
		setWeather("Overcast",false,WeatherType.kCloud);
		setWeather("Clear",false,WeatherType.kClear);
		setWeather("Partly Cloudy",false,WeatherType.kClear);
		setWeather("Mostly Cloudy",false,WeatherType.kCloud);
		setWeather("Scattered Clouds",false,WeatherType.kClear);
		setWeather("Small Hail",false,WeatherType.kRain);
		setWeather("Squals",false,WeatherType.kClear);
		setWeather("Funnel Cloud",false,WeatherType.kCloud);
		setWeather("Unknown Precipitation",false,WeatherType.kRain);
		setWeather("Unknown",false,WeatherType.kClear);
	}

	private final String api;
	
	public URL getURLForConditions(Coordinate coord){
		String urlStr="http://api.wunderground.com/api/"+api+"/conditions/q/"+coord.latitude+","+coord.longitude+".json";
		try
		{
			return new URL(urlStr);
		} catch (MalformedURLException e)
		{
			e.printStackTrace();
		}
		return null;
	}
	public URL getForecastURLForConditions(Coordinate coord){
		String urlStr="http://api.wunderground.com/api/"+api+"/hourly/q/"+coord.latitude+","+coord.longitude+".json";
		try
		{
			return new URL(urlStr);
		} catch (MalformedURLException e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * Limits time so that we don't over-access the Wunderground API
	 */
	public static class RateLimiter{
		File f;
		DoubleWindowedQueue<Long> dayQueue=new DoubleWindowedQueue<Long>(86400000.);
		int dayLimit=500;
		DoubleWindowedQueue<Long> minQueue=new DoubleWindowedQueue<Long>(60000.);
		int minLimit=10;
		
		public RateLimiter(File f){
			this.f=f;
			if(!f.exists()) try
			{
				f.createNewFile();
			} catch (IOException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		public void loadFromFile(){
			synchronized(f){
			try{
				BufferedReader br=new BufferedReader(new InputStreamReader(new FileInputStream(f)));
				String str;
				while((str=br.readLine())!=null){
					long t=Long.parseLong(str);
					dayQueue.add((double)t, t);
					minQueue.add((double)t, t);
				}
				br.close();
			}catch(Exception e){
				e.printStackTrace();
			}
			}
		}

		public void waitEnoughTime(){
			synchronized(f){
				long limitFromDay=0;
				{
					dayQueue.purge((double)System.currentTimeMillis());
					if(dayQueue.size()>=dayLimit){
						int idx=dayQueue.size()-dayLimit;
						double tLim=dayQueue.get(idx).fst+86400000.;
						limitFromDay=(long)(tLim-System.currentTimeMillis());
					}
				}
				long limitFromMin=0;
				{
					minQueue.purge((double)System.currentTimeMillis());
					if(minQueue.size()>=minLimit){
						int idx=minQueue.size()-minLimit;
						double tLim=minQueue.get(idx).fst+60000.;
						limitFromMin=(long)(tLim-System.currentTimeMillis());
					}
				}
				
				long tWait=Math.max(limitFromDay, limitFromMin);

				if(tWait>0){
					System.out.println("waiting for: "+tWait);
					try
					{
						Thread.sleep(tWait);
					} catch (InterruptedException e)
					{
						e.printStackTrace();
					}
				}
				long tNow=System.currentTimeMillis();
				dayQueue.add((double)tNow,tNow);
				minQueue.add((double)tNow, tNow);
				
//				System.out.println(dayQueue.size());
				try{
					PrintWriter out=new PrintWriter(f);
					for(Tuple<Double, Long> t:dayQueue){
//						System.out.println(t.fst);
						out.println(t.snd);
					}
					out.close();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
		}
	}
	static final RateLimiter rateLimiter=new RateLimiter(new File("rateLimiterLog.txt"));
//	public static void waitEnoughTime(){
//		synchronized(lastRequestTimeFile){
//			try{
//				if(lastRequestTimeFile.exists()){
//					BufferedReader br=new BufferedReader(new InputStreamReader(new FileInputStream(lastRequestTimeFile)));
//					Date lastRequestTime=DateUtil.str2DateTime(br.readLine());
//					if(lastRequestTime!=null){
//						long waitTime=Math.max(0, (lastRequestTime.getTime()+minWaitTime)-(new Date()).getTime());
//						if(waitTime>0){
//							System.out.println("waiting for: "+waitTime);
//							try
//							{
//								Thread.sleep(waitTime);
//							} catch (InterruptedException e)
//							{
//								e.printStackTrace();
//							}
//						}
//					}
//					br.close();
//				}
//				
//				PrintWriter out=new PrintWriter(lastRequestTimeFile);
//				out.println(DateUtil.dateTime2Str(new Date()));
//				out.close();
//			}catch(IOException e){
//				e.printStackTrace();
//			}
//		}
//	}

	public WundergroundQueryResult queryForCoords(Coordinate coord){
		InputStream in=null;
		try{
			rateLimiter.waitEnoughTime();
			
			URL url=getURLForConditions(coord);
			URLConnection con=url.openConnection();
			in=con.getInputStream();
			
			JSONParser parser=new JSONParser();
			JSONObject rootObj=(JSONObject)parser.parse(new InputStreamReader(in));
			JSONObject currentObservation=(JSONObject)rootObj.get("current_observation");
			if(currentObservation!=null){
				for(Object key:rootObj.keySet())
					System.out.println(key+"\t"+rootObj.get(key));
				
				String weather=""+currentObservation.get("weather");
				String timezone=""+currentObservation.get("local_tz_long");
				WeatherLocation location=null;
				try{
					location=new WeatherLocation((JSONObject)currentObservation.get("observation_location"));
				}catch(Exception e){
					System.err.println((JSONObject)currentObservation.get("observation_location"));
					e.printStackTrace();
				}
			
				return new WundergroundQueryResult(TimeZone.getTimeZone(timezone), weather, location, new Date());
			}
		} catch (IOException e)
		{
			e.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		}finally{
			if(in!=null) try{
				in.close();} catch (IOException e1){e1.printStackTrace();}
		}
		return null;
	}
	static SimpleDateFormat fctimeFormatter=new SimpleDateFormat("h:mm a zz 'on' MMMM dd, yyyy",Locale.ENGLISH);
	public List<WundergroundQueryResult> forecastForCoords(Coordinate coord){
		InputStream in=null;
		ArrayList<WundergroundQueryResult> results=new ArrayList<WundergroundQueryResult>();
		try{
			rateLimiter.waitEnoughTime();
			
			URL url=getForecastURLForConditions(coord);
			URLConnection con=url.openConnection();
			in=con.getInputStream();
			
			JSONParser parser=new JSONParser();
			JSONObject rootObj=(JSONObject)parser.parse(new InputStreamReader(in));
			
			JSONArray hourly_forecast=(JSONArray)rootObj.get("hourly_forecast");
			if(hourly_forecast!=null){
				for(Object hourlyObj:hourly_forecast){

					JSONObject hourlyForecast=(JSONObject)hourlyObj;
//					for(Object key:hourlyForecast.keySet())
//						System.out.println(key+"\t"+hourlyForecast.get(key));
					JSONObject fctime=(JSONObject)hourlyForecast.get("FCTTIME");
					Date time=fctimeFormatter.parse(""+fctime.get("pretty"));
					String condition=""+hourlyForecast.get("condition");
					WundergroundQueryResult result=new WundergroundQueryResult(TimeZone.getDefault(), condition, null, time);
					results.add(result);
				}
				
//				String weather=""+currentObservation.get("weather");
//				String timezone=""+currentObservation.get("local_tz_long");
//				WeatherLocation location=new WeatherLocation((JSONObject)currentObservation.get("observation_location"));
//			
//				return new WundergroundQueryResult(TimeZone.getTimeZone(timezone), weather, location);
			}
		} catch (IOException e)
		{
			e.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		}finally{
			if(in!=null) try{
				in.close();} catch (IOException e1){e1.printStackTrace();}
		}
		return results;
	}
	
}
