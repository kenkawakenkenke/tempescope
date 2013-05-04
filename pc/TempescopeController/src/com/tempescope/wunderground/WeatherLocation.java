package com.tempescope.wunderground;

import gis.model.Coordinate;

import java.io.Serializable;

import org.json.simple.JSONObject;

/*
 * WeatherLocation.java - representation of weather location on Wunderground
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
public class WeatherLocation implements Serializable
{
	private static final long serialVersionUID = -2981464705447478421L;
	public final String full,state,country_iso3166,country,city;
	public final Coordinate coord;
	
	public WeatherLocation(JSONObject obj){
		full=""+obj.get("full");
		state=""+obj.get("state");
		country_iso3166=""+obj.get("country_iso3166");
		country=""+obj.get("country");
		city=""+obj.get("city");
		
		coord=new Coordinate(Double.parseDouble(""+obj.get("longitude")), Double.parseDouble(""+obj.get("latitude")));
	}
	
	public String toString(){
		return full;
	}
}
