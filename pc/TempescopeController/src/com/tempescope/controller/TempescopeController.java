package com.tempescope.controller;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;

import gnu.io.CommPortIdentifier; 
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent; 
import gnu.io.SerialPortEventListener; 
import java.util.Enumeration;
import java.util.List;

import com.tempescope.model.Weather;
import com.tempescope.model.WeatherType;

import common.ds.Tuple;

import arduino.common.ArduinoSerial;

/*
 * TempescopeController.java - controller for tempescope
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
public class TempescopeController{
	private ArduinoSerial serial;

	private PrintWriter out;
	private BufferedReader br;
	public TempescopeController(){
		serial = new ArduinoSerial();
		serial.initialize();

		out=new PrintWriter(serial.output(),true);
		br=new BufferedReader(new InputStreamReader(serial.input()));
	}

	public void close(){
		serial.close();
	}
	public boolean playWeather(Weather weather){
		out.println(String.format("Zr,%d,%d,%d",(int)(weather.pNoon*100), weather.weatherType.weatherCode, weather.lightning?1:0));
		out.flush();
		return true;
	}

	public boolean saveWeather(List<Tuple<Long,Weather>> weathers){
		//send size
		out.println(String.format("Zf,%d",weathers.size()));
		int idx=0;
		for(Tuple<Long,Weather> weatherSpec:weathers){
			Weather weather=weatherSpec.snd;
			out.println(String.format("Zs,%d,%d,%d,%d,%d",idx,weatherSpec.fst,(int)(weather.pNoon*100), weather.weatherType.weatherCode, weather.lightning?1:0));

			idx++;
		}
		out.flush();
		return true;
	}

	public boolean playDemo(){
		//send size
		out.println("Zd");
		out.flush();
		return true;
	}
	public boolean playSaved(){
		//send size
		out.println("Zl");
		out.flush();
		return true;
	}
	public boolean turnOff(){
		//send size
		out.println("Zz");
		out.flush();
		return true;
	}

	public static void main(String[] args) throws Exception {
		TempescopeController weatherBox=new TempescopeController();
		System.out.println("play demo");
		weatherBox.playDemo();
		//		weatherBox.playWeather(new Weather(0.9,WeatherType.kClear,true));
		Thread.sleep(10000);
		System.out.println("off");
		weatherBox.turnOff();
		weatherBox.close();
	}
}