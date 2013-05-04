package com.tempescope.wunderground;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.json.simple.JSONObject;

/*
 * WeatherLocationManager.java - manager for locations on Wunderground
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
public class WeatherLocationManager implements Serializable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 6116121608138385631L;
	
	private Set<WeatherLocation> weatherLocations=new HashSet<WeatherLocation>();
	public Set<WeatherLocation> locations(){return weatherLocations;}
	private HashMap<String,WeatherLocation> locationForFull=new HashMap<String,WeatherLocation>();
	
	private transient File file;
	
	public void addWeatherLocation(WeatherLocation location){
		if(!locationForFull.containsKey(location.full)){
			weatherLocations.add(location);
			locationForFull.put(location.full, location);
			save();
		}
	}
	
	public static WeatherLocationManager getManager(File file){
		if(!file.exists()){
			WeatherLocationManager manager=new WeatherLocationManager();
			manager.file=file;
			return manager;
		}
		try{
			ObjectInputStream in=new ObjectInputStream(new BufferedInputStream(new FileInputStream(file)));
			WeatherLocationManager manager=(WeatherLocationManager)in.readObject();
			in.close();
			manager.file=file;
			return manager;
		}catch(IOException e){
			e.printStackTrace();
		} catch (ClassNotFoundException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public void save(){
		if(file!=null){
			try{
				ObjectOutputStream out=new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(file)));
				out.writeObject(this);
				out.close();
			}catch(IOException e){
				e.printStackTrace();
			}
		}
	}
}
