//
//  AppDelegate.m
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import "AppDelegate.h"
#import "LeDataService.h"   // For the Notification strings

@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //RKLogConfigureByName("RestKit", RKLogLevelTrace);
    //with one CBCentralManger restoration is actually not needed. Just to see
    //Used to debug CM restore only
    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    NSString *str = [NSString stringWithFormat: @"%@ %lu", @"Manager Restores: ", (unsigned long)centralManagerIdentifiers.count];
    NSLog(@"string %@",str);
    
    for(int i = 0;i<centralManagerIdentifiers.count;i++)
    {
        NSLog(@"identifiers %@",(NSString *)[centralManagerIdentifiers objectAtIndex:i]);
    }
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    
    return YES;
}


@end

// Override point for customization after application launch.

