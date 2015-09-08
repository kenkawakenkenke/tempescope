
//
//  TSViewController.h
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>
#import "LeDataService.h"
#import "LeDiscovery.h"
#import "LocationViewController.h"

@interface TSViewController : UIViewController <LeDiscoveryDelegate, LeDataProtocol, CitySelectionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *weatherCity;
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UILabel *RSSI;

@property (strong, nonatomic) LeDataService *currentlyDisplayingService;
//-------------
@property NSDictionary *forecastList;
@property (weak, nonatomic) IBOutlet UISearchBar *searchString;
@property (weak, nonatomic) IBOutlet UILabel *wetterText;
@property (weak, nonatomic) IBOutlet UILabel *wetterCode;

@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UITextField *animationDuration;
@property (weak, nonatomic) IBOutlet UITextField *waitDuration;
@property (weak, nonatomic) IBOutlet UITextField *pollIntervall;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImage;
@property (weak, nonatomic) IBOutlet UILabel *maxTemp;
@property (weak, nonatomic) IBOutlet UILabel *minTemp;

-(IBAction)back:(id)sender;
-(IBAction)updateRealWeather:(id)sender;

@end