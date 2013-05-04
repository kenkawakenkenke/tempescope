package com.tempescope.wunderground;

import java.util.Date;
import java.util.TimeZone;


/*
 * WundergroundQueryResult.java - weather query result from Wunderground
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
public class WundergroundQueryResult{
	public final TimeZone tz;
	public final String weatherStr;
	public final WeatherLocation location;
	public final Date t;
	
	public WundergroundQueryResult(TimeZone tz,String weatherStr, WeatherLocation location, Date t){
		this.tz=tz;
		this.weatherStr=weatherStr;
		this.location=location;
		this.t=t;
	}
}