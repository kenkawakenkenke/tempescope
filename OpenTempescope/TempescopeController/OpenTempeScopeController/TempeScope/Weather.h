/*
 Weather.h
 Released as part of the OpenTempescope project - http://tempescope.com/opentempescope/
 Copyright (c) 2013 Ken Kawamoto.  All right reserved.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import <Foundation/Foundation.h>

#define WEATHER_CLEAR 0
#define WEATHER_RAIN 1
#define WEATHER_CLOUD 2

@interface Weather : NSObject

- (id)initWithPNoon:(double)pNoon weatherType:(int)weatherType lightning:(bool)lightning;

@property (atomic) double pNoon;
@property (atomic) int weatherType;
@property (atomic) BOOL lightning;

- (NSData *)toData;
- (void)setToArray:(uint8_t *)buf atIdx:(int)idx;
- (void)print;

@end
