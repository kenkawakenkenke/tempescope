package common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

/*
 * DateUtil.java - Date utilities
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
public class DateUtil {
	public static final long DATE_MILS=24*60*60*1000;
	
	private static final DateUtil staticInst=new DateUtil();
	public static final TimeZone DEFAULT_TIMEZONE=TimeZone.getDefault();
	public static final TimeZone UTC_TIMEZONE=TimeZone.getTimeZone("UTC");
	
	/*************************************************************************
	 * Shifters
	 *************************************************************************/

	//add millis,secs,mins,hours
	public static Date addMillis(Date date,long millis){return new Date(date.getTime()+millis);}
	public static Date addSeconds(Date date,long seconds){return new Date(date.getTime()+seconds*1000);}
	public static Date addMins(Date date,long mins){return new Date(date.getTime()+mins*60000);}
	public static Date addHours(Date date,long hours){return new Date(date.getTime()+hours*3600000);}
	
	//add days
	public static Date addDays(Date day,int days){return addDays(day,days,DEFAULT_TIMEZONE);}
	public static Date addDays(Date day,int days,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(day);
		cal.add(Calendar.DATE, days);
		return cal.getTime();
	}
	//get previous date
	public static Date prevDay(Date day){return prevDay(day,DEFAULT_TIMEZONE);}
	public static Date prevDay(Date day,TimeZone timezone){return addDays(day,-1,timezone);}
	//get next date
	public static Date nextDay(Date day){return nextDay(day,DEFAULT_TIMEZONE);}
	public static Date nextDay(Date day,TimeZone timezone){return addDays(day,1,timezone);}

	//add months
	public static Date addMonths(Date day,int months){return addMonths(day,months,DEFAULT_TIMEZONE);}
	public static Date addMonths(Date day,int months,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(day);
		cal.add(Calendar.MONTH, months);
		return cal.getTime();
	}

	//add years
	public static Date addYears(Date day,int years){return addYears(day,years,DEFAULT_TIMEZONE);}
	public static Date addYears(Date day,int years,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(day);
		cal.add(Calendar.YEAR, years);
		return cal.getTime();
	}


	/***************************************************************************
	 * formatter/parsers
	 ***************************************************************************/
	
	//datetimes
	private SimpleDateFormat dfDateTime=init(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));
	//NOT THREAD SAFE
	public static String dateTime2Str(Date date){return dateTime2Str(date,DEFAULT_TIMEZONE);}
	//THREAD SAFE
	public static String dateTime2Str_(Date date){return dateTime2Str_(date,DEFAULT_TIMEZONE);}
	public static String dateTime2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfDateTime,timezone);}
	public static String dateTime2Str_(Date date,TimeZone timezone){return _format(date,get().dfDateTime,timezone);}

	public static Date str2DateTime(String str){return str2DateTime(str,DEFAULT_TIMEZONE);}
	public static Date str2DateTime_(String str){return str2DateTime_(str,DEFAULT_TIMEZONE);}
	public static Date str2DateTime(String str,TimeZone timezone){return _parse(str,staticInst.dfDateTime,timezone);}
	public static Date str2DateTime_(String str,TimeZone timezone){return _parse(str,get().dfDateTime,timezone);}
	
	//"flat" datetimes
	private SimpleDateFormat dfFlatDateTime=new SimpleDateFormat("yyyyMMddHHmmss");
	public static String flatDateTime2Str(Date date){return flatDateTime2Str(date,DEFAULT_TIMEZONE);}
	public static String flatDateTime2Str_(Date date){return flatDateTime2Str_(date,DEFAULT_TIMEZONE);}
	public static String flatDateTime2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfFlatDateTime,timezone);}
	public static String flatDateTime2Str_(Date date,TimeZone timezone){return _format(date,get().dfFlatDateTime,timezone);}

	public static Date str2FlatDateTime(String str){return str2FlatDateTime(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatDateTime_(String str){return str2FlatDateTime_(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatDateTime(String str,TimeZone timezone){return _parse(str,staticInst.dfFlatDateTime,timezone);}
	public static Date str2FlatDateTime_(String str,TimeZone timezone){return _parse(str,get().dfFlatDateTime,timezone);}
		
	//"flat" long datetimes
	private SimpleDateFormat dfFlatLongDateTime=new SimpleDateFormat("yyyyMMddHHmmssSSS");
	public static String flatLongDateTime2Str(Date date){return flatLongDateTime2Str(date,DEFAULT_TIMEZONE);}
	public static String flatLongDateTime2Str_(Date date){return flatLongDateTime2Str_(date,DEFAULT_TIMEZONE);}
	public static String flatLongDateTime2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfFlatLongDateTime,timezone);}
	public static String flatLongDateTime2Str_(Date date,TimeZone timezone){return _format(date,get().dfFlatLongDateTime,timezone);}

	public static Date str2FlatLongDateTime(String str){return str2FlatLongDateTime(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatLongDateTime_(String str){return str2FlatLongDateTime_(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatLongDateTime(String str,TimeZone timezone){return _parse(str,staticInst.dfFlatLongDateTime,timezone);}
	public static Date str2FlatLongDateTime_(String str,TimeZone timezone){return _parse(str,get().dfFlatLongDateTime,timezone);}
	
	//flat date
	private SimpleDateFormat dfFlatDate=new SimpleDateFormat("yyyyMMdd");
	public static String flatDate2Str(Date date){return flatDate2Str(date,DEFAULT_TIMEZONE);}
	public static String flatDate2Str_(Date date){return flatDate2Str_(date,DEFAULT_TIMEZONE);}
	public static String flatDate2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfFlatDate,timezone);}
	public static String flatDate2Str_(Date date,TimeZone timezone){return _format(date,get().dfFlatDate,timezone);}

	public static Date str2FlatDate(String str){return str2FlatDate(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatDate_(String str){return str2FlatDate_(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatDate(String str,TimeZone timezone){return _parse(str,staticInst.dfFlatDate,timezone);}
	public static Date str2FlatDate_(String str,TimeZone timezone){return _parse(str,get().dfFlatDate,timezone);}
	
	//flat short date
	private SimpleDateFormat dfFlatShortDate=new SimpleDateFormat("yyMMdd");
	public static String flatShortDate2Str(Date date){return flatShortDate2Str(date,DEFAULT_TIMEZONE);}
	public static String flatShortDate2Str_(Date date){return flatShortDate2Str_(date,DEFAULT_TIMEZONE);}
	public static String flatShortDate2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfFlatShortDate,timezone);}
	public static String flatShortDate2Str_(Date date,TimeZone timezone){return _format(date,get().dfFlatShortDate,timezone);}

	public static Date str2FlatShortDate(String str){return str2FlatShortDate(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatShortDate_(String str){return str2FlatShortDate_(str,DEFAULT_TIMEZONE);}
	public static Date str2FlatShortDate(String str,TimeZone timezone){return _parse(str,staticInst.dfFlatShortDate,timezone);}
	public static Date str2FlatShortDate_(String str,TimeZone timezone){return _parse(str,get().dfFlatShortDate,timezone);}
	
	//date
	private SimpleDateFormat dfDate=new SimpleDateFormat("yyyy-MM-dd");
	public static String date2Str(Date date){return date2Str(date,DEFAULT_TIMEZONE);}
	public static String date2Str_(Date date){return date2Str_(date,DEFAULT_TIMEZONE);}
	public static String date2Str(Date date,TimeZone timezone){return _format(date,staticInst.dfDate,timezone);}
	public static String date2Str_(Date date,TimeZone timezone){return _format(date,get().dfDate,timezone);}

	public static Date str2Date(String str){return str2Date(str,DEFAULT_TIMEZONE);}
	public static Date str2Date_(String str){return str2Date_(str,DEFAULT_TIMEZONE);}
	public static Date str2Date(String str,TimeZone timezone){return _parse(str,staticInst.dfDate,timezone);}
	public static Date str2Date_(String str,TimeZone timezone){return _parse(str,get().dfDate,timezone);}
	
	//excel date
	private SimpleDateFormat dfExcelDate=new SimpleDateFormat("yyyy/MM/dd");
	private String _excelDate2Str(Date date){
		return dfExcelDate.format(date);
	}
	public static String excelDate2Str(Date date){return staticInst._excelDate2Str(date);}
	public static String excelDate2Str_(Date date){return get()._excelDate2Str(date);}
	private Date _str2ExcelDate(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfExcelDate.parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	public static Date str2ExcelDate(String str){return staticInst._str2ExcelDate(str);}
	public static Date str2ExcelDate_(String str){return get()._str2ExcelDate(str);}
	
	//excel datetime
	private SimpleDateFormat dfExcelDateTime=new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	private String _excelDateTime2Str(Date date){
		return dfExcelDateTime.format(date);
	}
	public static String excelDateTime2Str(Date date){return staticInst._excelDateTime2Str(date);}
	public static String excelDateTime2Str_(Date date){return get()._excelDateTime2Str(date);}
	private Date _str2ExcelDateTime(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfExcelDateTime.parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	public static Date str2ExcelDateTime(String str){return staticInst._str2ExcelDateTime(str);}
	public static Date str2ExcelDateTime_(String str){return get()._str2ExcelDateTime(str);}
	
	//long exceldatetime
	private SimpleDateFormat dfLongExcelDateTime=new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
	private String _longExcelDateTime2Str(Date date){
		return dfLongExcelDateTime.format(date);
	}
	public static String longExcelDateTime2Str(Date date){return staticInst._longExcelDateTime2Str(date);}
	public static String longExcelDateTime2Str_(Date date){return get()._longExcelDateTime2Str(date);}
	private Date _str2LongExcelDateTime(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfLongExcelDateTime.parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	public static Date str2LongExcelDateTime(String str){return staticInst._str2LongExcelDateTime(str);}
	public static Date str2LongExcelDateTime_(String str){return get()._str2LongExcelDateTime(str);}
	
	//format long date
	private SimpleDateFormat dfLongDate=new SimpleDateFormat("yyyy-MM-dd(EEE)");
	private String _longDate2Str(Date date){
		return dfLongDate.format(date);
	}
	public static String longDate2Str(Date date){return staticInst._longDate2Str(date);}
	public static String longDate2Str_(Date date){return get()._longDate2Str(date);}
	private Date _str2LongDate(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfLongDate.parse(dateStr);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}
	public static Date str2LongDate(String str){return staticInst._str2LongDate(str);}
	public static Date str2LongDate_(String str){return get()._str2LongDate(str);}
	
	//format long datetime
	private SimpleDateFormat dfLongDateTime=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	private String _longDateTime2Str(Date date){
		return dfLongDateTime.format(date);
	}
	public static String longDateTime2Str(Date date){return staticInst._longDateTime2Str(date);}
	public static String longDateTime2Str_(Date date){return get()._longDateTime2Str(date);}
	private Date _str2LongDateTime(String dateStr){
		synchronized(dfLongDateTime){
			try {
				if(dateStr==null)return null;
				return dfLongDateTime.parse(dateStr);
			} catch (ParseException e) {
			}
		}
		return null;
	}
	public static Date str2LongDateTime(String str){return staticInst._str2LongDateTime(str);}
	public static Date str2LongDateTime_(String str){return get()._str2LongDateTime(str);}
	
	//format time
	private SimpleDateFormat dfTime=new SimpleDateFormat("HH:mm:ss");
	private String _time2Str(Date date){
		return dfTime.format(date);
	}
	public static String time2Str(Date date){return staticInst._time2Str(date);}
	public static String time2Str(Date date,TimeZone tz){return _format(date, staticInst.dfTime, tz);}
	public static String time2Str_(Date date){return get()._time2Str(date);}
	private Date _str2Time(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfTime.parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	public static Date str2Time(String str){return staticInst._str2Time(str);}
	public static Date str2Time_(String str){return get()._str2Time(str);}
	
	
	//format time HH:mm
	private SimpleDateFormat dfTimeHM=new SimpleDateFormat("HH:mm");
	private String _timeHM2Str(Date date){
		return dfTimeHM.format(date);
	}
	public static String timeHM2Str(Date date){return staticInst._timeHM2Str(date);}
	public static String timeHM2Str_(Date date){return get()._timeHM2Str(date);}
	private Date _str2TimeHM(String str){
		try {
			if(str==null)return null;
			return dfTimeHM.parse(str);
		} catch (ParseException e) {
		}
		return null;
	}
	public static Date str2TimeHM(String str){return staticInst._str2TimeHM(str);}
	public static Date str2TimeHM_(String str){return get()._str2TimeHM(str);}
	
	//format long time
	private SimpleDateFormat dfLongTime=new SimpleDateFormat("HH:mm:ss.SSS");
	private String _longTime2Str(Date date){
		return dfLongTime.format(date);
	}
	public static String longTime2Str(Date date){return staticInst._longTime2Str(date);}
	public static String longTime2Str_(Date date){return get()._longTime2Str(date);}
	private Date _str2LongTime(String dateStr){
		try {
			if(dateStr==null)return null;
			return dfLongTime.parse(dateStr);
		} catch (ParseException e) {
			//e.printStackTrace();
		}
		return null;
	}
	public static Date str2LongTime(String str){return staticInst._str2LongTime(str);}
	public static Date str2LongTime_(String str){return get()._str2LongTime(str);}
	
	//dow
	private SimpleDateFormat dfDayOfWeek=new SimpleDateFormat("(EEE)");
	private String _dayOfWeekStr(Date date){
		return dfDayOfWeek.format(date);
	}
	public static String dayOfWeekStr(Date date){return staticInst._dayOfWeekStr(date);}
	public static String dayOfWeekStr_(Date date){return get()._dayOfWeekStr(date);}
	private static final String dowNames[]=new String[]{"!","Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
	public static String dayOfWeekStr(int i){
		return dowNames[i];
	}
	public static String dayOfWeekStrStartingMonday(int i){
		return dayOfWeekStr((i+1)%7+1);
	}
	private static final String dowNames_jp[]=new String[]{"!","日","月","火","水","木","金","土"};
	public static String dayOfWeekStr_jp(int i){
		return dowNames_jp[i];
	}

	public static int dow(Date date){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		return cal.get(Calendar.DAY_OF_WEEK);
	}
	public static int dowStartingMonday(Date date){
		return (dow(date)+5)%7;
	}
	
	public static int dayOfYear(Date t){
		Calendar cal=Calendar.getInstance();
		cal.setTime(t);
		return cal.get(Calendar.DAY_OF_YEAR);
	}
	
	//format any
	public static String format2Str(Date date,String format){
		SimpleDateFormat formatter=new SimpleDateFormat(format);
		return formatter.format(date);
	}
	public static Date str2Format(String dateStr,String format){
		SimpleDateFormat formatter=new SimpleDateFormat(format);
		try {
			if(dateStr==null)return null;
			return formatter.parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	
	//utils
	public static SimpleDateFormat tzFormatter(SimpleDateFormat formatter,TimeZone timezone){
		if(timezone!=null){
			formatter=(SimpleDateFormat)formatter.clone();
			formatter.setTimeZone(timezone);
		}
		return formatter;
	}
	private static Date _parse(String dateStr,SimpleDateFormat formatter,TimeZone timezone){
		try {
			if(dateStr==null)return null;
			return tzFormatter(formatter,timezone).parse(dateStr);
		} catch (ParseException e) {
		}
		return null;
	}
	private static String _format(Date date,SimpleDateFormat formatter,TimeZone timezone){
		return tzFormatter(formatter,timezone).format(date);
	}
	
	/***************************************************************************
	 * durations
	 ***************************************************************************/
	public static int durationMins(Date from,Date to){return (int)(to.getTime()-from.getTime())/60000;}
	public static long durationMins_long(Date from,Date to){return (long)(to.getTime()-from.getTime())/60000;}
	public static int durationHours(Date from,Date to){return (int)(to.getTime()-from.getTime())/3600000;}
	public static int durationSeconds(Date from,Date to){return (int)((to.getTime()-from.getTime())/1000.);} //changed from (->) 11.02.15kk //return (int)Math.ceil((to.getTime()-from.getTime())/1000.);
	public static long durationMillis(Date from,Date to){return (long)(to.getTime()-from.getTime());}
	public static int durationDays(Date from,Date to){return (int)((to.getTime()-from.getTime())/(60000*60*24));}
	public static int durationYears(Date from,Date to){return durationYears(from,to,DEFAULT_TIMEZONE);}
	public static int durationYears(Date from,Date to,TimeZone timezone){
		Calendar calFrom=Calendar.getInstance(timezone),calTo=Calendar.getInstance(timezone);
		calFrom.setTime(from);
		calTo.setTime(to);
		return calTo.get(Calendar.YEAR)-calFrom.get(Calendar.YEAR);
	}
	public static float durationYearsF(Date from,Date to){return durationYearsF(from,to,DEFAULT_TIMEZONE);}
	public static float durationYearsF(Date from,Date to,TimeZone timezone){
		Calendar calFrom=Calendar.getInstance(timezone),calTo=Calendar.getInstance(timezone);
		calFrom.setTime(from);
		calTo.setTime(to);
		
		int years=calTo.get(Calendar.YEAR)-calFrom.get(Calendar.YEAR);
		calFrom.add(Calendar.YEAR, years);
		float diffDays=calTo.get(Calendar.DAY_OF_YEAR)/(float)calTo.getActualMaximum(Calendar.DAY_OF_YEAR)-calFrom.get(Calendar.DAY_OF_YEAR)/(float)calFrom.getActualMaximum(Calendar.DAY_OF_YEAR);
		return years+diffDays;
	}
	

	/***********************************************************************
	 * durations format
	 ***********************************************************************/
	public static String durationMins2Str(int mins){
		int hours=mins/60;
		mins=mins%60;
		String str="";
		if(hours!=0)
			str=hours+"時間";
		str+=mins+"分";
		return str;
	}
	public static String duration2TimeStr(long duration){
		return String.format("%02d:%02d", (duration/60)%24,Math.abs(duration)%60);
	}
	public static String longDuration2TimeStr(long duration){
		long mil=duration%1000;
		duration/=1000;
		long sec=duration%100;
		duration/=100;
		return String.format("%02d:%02d.%03d",duration,sec,mil);
	}
	public static String durationMils2TimeStr(long duration){
		String sign=duration<0?"-":"";
		duration=Math.abs(duration);
		long mils=duration%1000;
		duration=duration/1000;
		
		long secs=duration%60;
		duration=duration/60;
		
		long mins=duration%60;
		duration=duration/60;
		
		long hours=duration%60;
		duration=duration/60;
		
		return String.format("%s%d:%02d:%02d.%03d",sign,hours,mins,secs,mils);
	}
	

	/***********************************************************************
	 * transformations
	 ***********************************************************************/
	
	//set to date
	public static Date toDate(Date datetime){return toDate(datetime,DEFAULT_TIMEZONE);}
	public static Date toDate(Date datetime,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(datetime);
		cal.set(Calendar.HOUR_OF_DAY, 0);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);
		cal.set(Calendar.MILLISECOND,0);
		return cal.getTime();
	}

	//set to "time"
	public static Date toTime(Date datetime){return toTime(datetime,DEFAULT_TIMEZONE);}
	public static Date toTime(Date datetime,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(datetime);
		cal.set(Calendar.YEAR, 0);
		cal.set(Calendar.MONTH, 0);
		cal.set(Calendar.DATE, 1);
		return cal.getTime();
	}

	/***********************************************************************
	 * identity checkers
	 ***********************************************************************/
	public static boolean isWeekend(Date date){return isWeekend(date,DEFAULT_TIMEZONE);}
	public static boolean isWeekend(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		int dow=cal.get(Calendar.DAY_OF_WEEK);
		return dow==Calendar.SUNDAY || dow==Calendar.SATURDAY;
	}
	public static boolean isWeekday(Date date,TimeZone tz){return !isWeekend(date,tz);}
	public static boolean isWeekday(Date date){return !isWeekend(date);}

	/***********************************************************************
	 * component extraction
	 ***********************************************************************/
	//millis of day
	public static long getMillis(Date date){return getMillis(date,DEFAULT_TIMEZONE);}
	public static long getMillis(Date date,TimeZone timezone){
		long dMil=DateUtil.toDate(date,timezone).getTime();
		return date.getTime()-dMil;
	}
	//seconds of day
	public static int getSeconds(Date date){return getSeconds(date,DEFAULT_TIMEZONE);}
	public static int getSeconds(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return (cal.get(Calendar.HOUR_OF_DAY)*60+cal.get(Calendar.MINUTE))*60+cal.get(Calendar.SECOND);
	}
	//minutes of day
	public static int getMinutes(Date date){return getMinutes(date,DEFAULT_TIMEZONE);}
	public static int getMinutes(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return cal.get(Calendar.HOUR_OF_DAY)*60+cal.get(Calendar.MINUTE);
	}
	//hours of day
	public static int getHour(Date date){return getHour(date,DEFAULT_TIMEZONE);}
	public static int getHour(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return cal.get(Calendar.HOUR_OF_DAY);
	}
	//day of month
	public static int getDate(Date date){return getDate(date,DEFAULT_TIMEZONE);}
	public static int getDate(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return cal.get(Calendar.DATE);
	}
	
	//millis of sec
	public static int millis(Date date){
		long l=date.getTime();
		return (int)(l-(long)(l/1000)*1000);
	}
	//secs of minute
	public static int seconds(Date date){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		return cal.get(Calendar.SECOND);
	}
	//month of year
	public static int months(Date date){return months(date,DEFAULT_TIMEZONE);}
	public static int months(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return cal.get(Calendar.MONTH)+1;
	}
	//month of year (float)
	public static float month_float(Date date){return month_float(date,DEFAULT_TIMEZONE);}
	public static float month_float(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		float month=cal.get(Calendar.MONTH)+1;
		month+=(cal.get(Calendar.DATE)-1)/(float)cal.getActualMaximum(Calendar.DATE);
		return month;
	}
	//month of year (float)
	public static int years(Date date){return years(date,DEFAULT_TIMEZONE);}
	public static int years(Date date,TimeZone timezone){
		Calendar cal=Calendar.getInstance(timezone);
		cal.setTime(date);
		return cal.get(Calendar.YEAR);
	}

	/***********************************************************************
	 * updating
	 ***********************************************************************/
	public static Date setMonthDayHMSS(Date date,int month,int day,int hour,int min,int sec,int ss){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.MONTH, month);
		cal.set(Calendar.DAY_OF_MONTH, day);
		cal.set(Calendar.HOUR_OF_DAY, hour);
		cal.set(Calendar.MINUTE, min);
		cal.set(Calendar.SECOND,sec);
		cal.set(Calendar.MILLISECOND,ss);
		return cal.getTime();
	}
	public static Date setMinutes(Date date,int minutes){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.HOUR_OF_DAY, minutes/60);
		cal.set(Calendar.MINUTE, minutes%60);
		cal.set(Calendar.SECOND,0);
		cal.set(Calendar.MILLISECOND,0);
		return cal.getTime();
	}
	public static Date setSeconds(Date date,int seconds){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.HOUR_OF_DAY, seconds/60/60);
		seconds=seconds%(60*60);
		cal.set(Calendar.MINUTE, seconds/60);
		cal.set(Calendar.SECOND, seconds%60);
		return cal.getTime();
	}
	public static Date setMillis(Date date,long millis){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.MILLISECOND, (int)(millis%1000));
		millis/=1000;
		cal.set(Calendar.SECOND,(int)(millis%60));
		millis/=60;
		cal.set(Calendar.MINUTE,(int)(millis%60));
		millis/=60;
		cal.set(Calendar.HOUR_OF_DAY,(int)millis);
		return cal.getTime();
	}
	public static Date updMinutes(Date date,int minutes){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.MINUTE, minutes);
		return cal.getTime();
	}
	public static Date updSeconds(Date date,int seconds){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.SECOND, seconds);
		return cal.getTime();
	}
	public static Date updMillis(Date date,long millis){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.MILLISECOND, (int)millis);
		return cal.getTime();
	}
	public static Date updSecMil(Date date,int seconds,long millis){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.SECOND, seconds);
		cal.set(Calendar.MILLISECOND, (int)millis);
		return cal.getTime();
	}
	public static Date setDay(Date date,int day){
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.DATE,day);
		return cal.getTime();
	}
	public static Date newDate(int year,int month,int day){
		Calendar cal=Calendar.getInstance();
		cal.set(Calendar.YEAR,year);
		cal.set(Calendar.MONTH,month-1);
		cal.set(Calendar.DATE,day);
		return cal.getTime();
	}
	public static Date setSm(Date date, int sec, int mil) {
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.SECOND,sec);
		cal.set(Calendar.MILLISECOND,mil);
		return cal.getTime();
	}
	public static Date setMSm(Date date, int min, int sec, int mil) {
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.MINUTE, min);
		cal.set(Calendar.SECOND,sec);
		cal.set(Calendar.MILLISECOND,mil);
		return cal.getTime();
	}
	public static Date setHMSm(Date date, int hour,int min, int sec, int mil) {
		Calendar cal=Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.HOUR_OF_DAY, hour);
		cal.set(Calendar.MINUTE, min);
		cal.set(Calendar.SECOND,sec);
		cal.set(Calendar.MILLISECOND,mil);
		return cal.getTime();
	}
	
	public static Date combineDateTime(Date date,Date time){
		Calendar dateCal=Calendar.getInstance(),timeCal=Calendar.getInstance();
		dateCal.setTime(date);
		timeCal.setTime(time);
		
		dateCal.set(Calendar.HOUR_OF_DAY, timeCal.get(Calendar.HOUR_OF_DAY));
		dateCal.set(Calendar.MINUTE,timeCal.get(Calendar.MINUTE));
		dateCal.set(Calendar.SECOND, timeCal.get(Calendar.SECOND));
		dateCal.set(Calendar.MILLISECOND, timeCal.get(Calendar.MILLISECOND));
		
		return dateCal.getTime();
	}

	/***********************************************************************
	 * etc
	 ***********************************************************************/
	//returns 1 if weekday, -1 if weekend, 0 if not significantly either
	public static int isSignificantlyWDWE(int wdCount,int weCount){
		int N=wdCount+weCount;
		return isSignificantlyWDWE(wdCount/(double)N,N);
	}
	public static int isSignificantlyWDWE(double wdPerc,int N){
		double p=5/7.;
		//母比率の区間推定（α=95%）　（入門はじめての統計解析;p126）
		double m_N=wdPerc;
		double lower=m_N-1.96*Math.sqrt(m_N*(1-m_N)/(double)N);
		double upper=m_N+1.96*Math.sqrt(m_N*(1-m_N)/(double)N);
		if(p<=lower)
			return 1;
		else if(upper<=p)
			return -1;
		return 0;
	}
	
	public static String sqlToday(Date date,String field){
		return field+">='"+DateUtil.dateTime2Str(date)+"' and "+field+"<'"+DateUtil.dateTime2Str(DateUtil.nextDay(date))+"'";
	}
	
	public static SimpleDateFormat init(SimpleDateFormat formatter){
		formatter.setLenient(true);
		return formatter;
	}
	
	/**********************************
	 * Thread safety!!
	 */
	private final static ThreadLocal<DateUtil> threadLocals=new ThreadLocal<DateUtil>(){
		protected synchronized DateUtil initialValue(){
			return new DateUtil();
		}
	};
	public static DateUtil get(){
		return threadLocals.get();
	}
}
