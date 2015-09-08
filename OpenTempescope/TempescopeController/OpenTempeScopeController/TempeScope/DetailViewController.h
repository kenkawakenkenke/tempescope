//
//  DetailViewController.h
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>
#import "LeDataService.h"
#import "LeDiscovery.h"

@interface DetailViewController : UIViewController <LeDiscoveryDelegate, LeDataProtocol>

@property (weak, nonatomic) IBOutlet UITextView *response;
@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UILabel *RSSI;

@property (strong, nonatomic) LeDataService *currentlyDisplayingService;

@property (weak, nonatomic) IBOutlet UISlider *sliderTime;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weatherType;
@property (weak, nonatomic) IBOutlet UISwitch *lightning;
@property (weak, nonatomic) IBOutlet UISlider *rSlider;
@property (weak, nonatomic) IBOutlet UISlider *gSlider;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;
@property (weak, nonatomic) IBOutlet UILabel *rValue;
@property (weak, nonatomic) IBOutlet UILabel *gValue;
@property (weak, nonatomic) IBOutlet UILabel *bValue;
@property (weak, nonatomic) IBOutlet UILabel *pNoonValue;

-(IBAction)send:(id)sender;
-(IBAction)back:(id)sender;

@end