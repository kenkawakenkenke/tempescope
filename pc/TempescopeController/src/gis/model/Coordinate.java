package gis.model;

import java.awt.geom.Point2D;
import java.io.Serializable;

/*
 * Coordinate.java - holds a coordinate location
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

public class Coordinate implements Serializable
{
	
	private static final long serialVersionUID = 775271873570365083L;
	public final double latitude,longitude;
	
	public Coordinate(String vStr,String vNS,String hStr,String hEW){
		latitude=toDouble(vStr)*(vNS.equals("N")?1:-1);
		longitude=toDouble(hStr)*(hEW.equals("E")?1:-1);
	}
	public static double toDouble(String str){
		double v=Double.parseDouble(str)/100;
		double sum=(int)(v);
		v-=sum;
		sum+= v/0.6;
		return sum;
	}
	
	public Coordinate(double longitude,double latitude){
		this.longitude=longitude;
		this.latitude=latitude;
	}
	
	private transient Point2D normalized=null;
	public Point2D normalized(){
		if(normalized==null){
			double lng=longitude;
			double lat=latitude;
	     if(lng>180)
	    	 lng -= 360;
	     lng/=360;
	     lng+=0.5;
	     lat=0.5-((Math.log(Math.tan((Math.PI/4)+(Math.toRadians(0.5*lat))))/Math.PI)/2.);
	     normalized=new Point2D.Double(lng, lat);
		}
		return normalized;
	}
	
	public static Coordinate coordFromNormalizedPoint(Point2D p){
		return coordFromNormalizedPoint(p.getX(),p.getY());
	}
	public static Coordinate coordFromNormalizedPoint(double x,double y){
	 	 double lng= (x-0.5)*360;
	 	 double lat= 2*Math.toDegrees(Math.atan(Math.exp(2*Math.PI*(0.5-y)))-Math.PI/4);
	 	 return new Coordinate(lng, lat);
	}
	
	public static double normalizeLatitude(double lat){
		if(lat>90)lat=90;
		else if(lat<-90)lat=-90;
		return lat;
	}
	public static double normalizeLongitude(double lng){
		if(lng>180)lng=-180+(lng-180);
		else if(lng<-180)lng=180+(lng+180);
		return lng;
	}
	public static double diffLongitude(double lng_left,double lng_right){
		return (lng_right>=lng_left?lng_right-lng_left: (360-(lng_left-lng_right)));
	}
	public static double diffLatitude(double lat_top,double lat_bot){
		return lat_top-lat_bot;
	}
	
	public String toString(){
		return longitude+","+latitude;
	}
	
	private transient double lat_cos=0;
	public double lat_cos(){
		if(lat_cos==0)
			lat_cos=Math.cos(latitude*PI_180);
		return lat_cos;
	}
	
	public transient static final double RADIUS_OF_EARTH=6371, DIAMETER_OF_EARTH=RADIUS_OF_EARTH*2;
	public transient static final double PI_180=Math.PI/180, PI_360=Math.PI/360;
	public double distanceWith(Coordinate other){
		final double	sin_dLat=StrictMath.sin((other.latitude-latitude)*PI_360),
						sin_dLon=StrictMath.sin((other.longitude-longitude)*PI_360);
		final double a = sin_dLat*sin_dLat + sin_dLon*sin_dLon * lat_cos() * other.lat_cos(); 
		return DIAMETER_OF_EARTH * StrictMath.atan2(StrictMath.sqrt(a), StrictMath.sqrt(1-a));  
	}
	
	static final double PI2=2*Math.PI, PI3=3*Math.PI;
	public Coordinate addDistance(double dist_km, double bearing){
		double lat1=toRad(latitude);
		double lng1=toRad(longitude);
		double dist2=dist_km/6371.01; //Earth's radius in km
		double brng=toRad(bearing);
		
		final double sin_lat1=Math.sin(lat1),
					cos_dist2=Math.cos(dist2),
					cos_lat1=Math.cos(lat1),
					sin_dist2=Math.sin(dist2),
					cos_brng=Math.cos(brng),
					sin_brng=Math.sin(brng);
		double lat2 = Math.asin( sin_lat1*cos_dist2 +
	                  cos_lat1*sin_dist2*cos_brng );
	    double lon2 = lng1 + Math.atan2(sin_brng*sin_dist2*cos_lat1,
	    		cos_dist2-sin_lat1*Math.sin(lat2));
	    lon2+=PI3;
	    while(lon2>PI2)
	    	lon2-=PI2;
	    lon2-=Math.PI;  
	 
	    return new Coordinate(toDeg(lon2),toDeg(lat2));
	}
	public static double toRad(double deg){
		return deg*Math.PI/180.;
	}
	public static double toDeg(double rad){
		return rad*180./Math.PI;
	}
	
	public boolean equals(Object _other){
		Coordinate other=(Coordinate)_other;
		return other.latitude==latitude && other.longitude==longitude;
	}
	public int hashCode(){
		return (int)((latitude+longitude)*1000000);
	}
}
