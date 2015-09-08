//
//  OWMWeatherAPI.h
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kOWMTempKelvin,
    kOWMTempCelcius,
    kOWMTempFahrenheit
} OWMTemperature;


@interface OWMWeatherAPI : NSObject

- (instancetype) initWithAPIKey:(NSString *) apiKey;

- (void) setApiVersion:(NSString *) version;
- (NSString *) apiVersion;

- (void) setTemperatureFormat:(OWMTemperature) tempFormat;
- (OWMTemperature) temperatureFormat;

- (void) setLangWithPreferedLanguage;
- (void) setLang:(NSString *) lang;
- (NSString *) lang;

#pragma mark - current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                      withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) currentWeatherByCityId:(NSString *) cityId
                  withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

#pragma mark - forecast

-(void) forecastWeatherByCityName:(NSString *) name
                     withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                       withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) forecastWeatherByCityId:(NSString *) cityId
                      withCount:(int) count
                   withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) forecastWeatherByCityId:(NSString *) cityId
                   withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                          andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                               withCount:(int) count
                            andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) dailyForecastWeatherByCityId:(NSString *) cityId
                           withCount:(int) count
                        andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

#pragma mark search

-(void) searchForCityName:(NSString *)name
         withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) searchForCityName:(NSString *)name
                withCount:(int) count
             andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

@end
