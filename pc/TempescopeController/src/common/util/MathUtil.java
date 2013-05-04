package common.util;


/*
 * MathUtil.java - math utilities
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
public class MathUtil {
	public static double fact(int m){
		double v=1;
		for(int i=2;i<=m;i++)
			v*=i;
		return v;
	}

	public static double map(double v,double origMin,double origMax,double min,double max){
		return map(v,origMin,origMax,min,max,true);
	}
	public static double map(double v,double origMin,double origMax,double min,double max, boolean limit){
		if(min>max){
			double t=max;
			max=min;
			min=t;
			t=origMin;
			origMin=origMax;
			origMax=t;
		}
		//System.out.println("= "+origMin+" "+v+" "+origMax+" "+min+" "+max);
		
		if(v==origMin)
			return min;
		
		v= (v-origMin)/(origMax-origMin)*(max-min)+min;
		//System.out.println(" => "+v);

		if(limit)
			return Math.min(Math.max(v,min),max);
		return v;
	}
	public static double map(double v,double origMin,double origMax){
		return map(v,origMin,origMax,0,1);
	}

	public static double square(double v){return v*v;}
	
	public static int argmax(double ...vs){
		double max=vs[0];
		int maxI=0;
		for(int i=1;i<vs.length;i++){
			double v=vs[i];
			if(v>max){
				max=v;
				maxI=i;
			}
		}
		return maxI;
	}
	public static double max(double ...vs){
		double max=vs[0];
		for(int i=1;i<vs.length;i++){
			double v=vs[i];
			if(v>max){
				max=v;
			}
		}
		return max;
	}
	public static int argmin(double ...vs){
		double min=vs[0];
		int minI=0;
		for(int i=1;i<vs.length;i++){
			double v=vs[i];
			if(v<min){
				min=v;
				minI=i;
			}
		}
		return minI;
	}
	public static double min(double ...vs){
		double min=vs[0];
		for(int i=1;i<vs.length;i++){
			double v=vs[i];
			if(v<min){
				min=v;
			}
		}
		return min;
	}
	
	public static String dp(double v,int dp){
		int nDP=0;
		
		double absV=Math.abs(v);
		double mask=1;
		for(nDP=0;nDP<=10;nDP++){
			if(absV*mask>=1){
				break;
			}
			mask*=10;
		}
		
		return String.format("%."+(nDP-1+dp)+"f", v);
	}
	
}
