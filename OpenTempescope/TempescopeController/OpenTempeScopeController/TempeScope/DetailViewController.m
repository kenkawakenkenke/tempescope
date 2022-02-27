//
//  DetailViewController.m
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import "DetailViewController.h"
#import "LeDataService.h"
#import "ScannerViewController.h"
#import "Weather.h"

#define WEATHER_CLEAR 0
#define WEATHER_RAIN 1
#define WEATHER_CLOUD 2
#define WEATHER_STORM 3
#define WEATHER_RGB 4

@interface DetailViewController() {
@private
    bool background;
    NSTimer *RSSITimer;
}
@end

@implementation DetailViewController

@synthesize currentlyDisplayingService;
@synthesize response;
@synthesize input;
@synthesize sendButton;
@synthesize notifySwitch;
@synthesize RSSI;
@synthesize sliderTime;
@synthesize weatherType;
@synthesize lightning;
@synthesize rSlider;
@synthesize gSlider;
@synthesize bSlider;
@synthesize rValue;
@synthesize gValue;
@synthesize bValue;
@synthesize pNoonValue;



#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Tell Discovery to report to us if anything happens with our peripherals
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    
    //We left our peripheral in our root controller
    //This is a bit messy but moving between Storyboards is only half supported
    UINavigationController *navController = (UINavigationController*)[self.navigationController presentingViewController];
    ScannerViewController *rootController =(ScannerViewController*)[navController.viewControllers objectAtIndex:0];
    
    //Create a new DataService with peripheral, and tell it to report to us
    self.currentlyDisplayingService = [[LeDataService alloc] initWithPeripheral:(CBPeripheral*)rootController.currentPeripheral controller:self];
    
    //start the service
    [currentlyDisplayingService start];
    
    //Until we know service has started, disable sending
    [sendButton setEnabled:NO];
    
    //set peripheral name into navigation header
    self.navigationItem.title = [[currentlyDisplayingService peripheral] name];
    
    //we want to know if we went into the background or came back
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [RSSITimer invalidate];
    //nil delegates so nothing points to us
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:nil];
    [currentlyDisplayingService setController:nil];
}


#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)send:(id)sender
{
    //send data
    NSData* tosend=[[input text] dataUsingEncoding:NSUTF8StringEncoding];
    [currentlyDisplayingService write:tosend];
    
    //put sent text in chat box
    NSString* newStr = [[NSString alloc] initWithFormat:@"< %@\n",[input text]] ;
    [response setText:[newStr stringByAppendingString:response.text]];
}

-(IBAction)back:(id)sender
{
    //[RSSITimer invalidate];
    
    //We have to manually dismiss our view controller instead of using IB's back button
    //[[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) refreshRSSI
{
    self.RSSI.text = [[[currentlyDisplayingService peripheral]RSSI] stringValue ];
    [[currentlyDisplayingService peripheral]readRSSI];
}


#pragma mark -
#pragma mark LeDataProtocol Delegate Methods
/****************************************************************************/
/*				LeDataProtocol Delegate Methods                             */
/****************************************************************************/
/** Received data */
- (void) serviceDidReceiveData:(NSData*)data fromService:(LeDataService*)service
{
    
    if (service != currentlyDisplayingService)
        return;
    
    //format text and place in chat box
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    NSString* newStr2 = [[NSString alloc] initWithFormat:@"> %@",newStr] ;
    NSLog(@"serviceDidReceiveData: %@",newStr);
    [response setText:[newStr2 stringByAppendingString:response.text]];
    
    if(background){
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.alertBody = newStr;
        localNotif.alertAction = @"BLE Message!";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}

/** Confirms the data was received with ack (if supported), or the error */
-(void)didWriteFromService:(LeDataService *)service withError:(NSError *)error{
    //we just assume writes went through
    NSLog(@"didWriteFromService: %@ withError: %@",service, error);
}

/** Confirms service started fully */
- (void) serviceDidReceiveCharacteristicsFromService:(LeDataService*)service
{
    NSLog(@"serviceDidReceiveCharacteristicsFrom Service: %@",service);
    NSMutableDictionary *navbarTitleTextAttributes =[NSMutableDictionary dictionaryWithDictionary:self.navigationController.navigationBar.titleTextAttributes];
    [navbarTitleTextAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;

    //all services go, enable button
    [sendButton setEnabled:YES];
    
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
}


#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
/** Bluetooth support was disabled */
- (void) discoveryStateChanged:(CBCentralManagerState)state
{
    NSLog(@"discoveryStateChanged: %@",state);
    
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    //may just want to automatically go back to chooser
    //We have to manually dismiss our view controller instead of using IB's back button
    [[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

/** Peripheral disconnected -- do something? */
-(void)peripheralDidDisconnect:(CBPeripheral *)peripheral
{
    NSLog(@"peripheralDidDisconnect:");
    [RSSITimer invalidate];

    NSMutableDictionary *navbarTitleTextAttributes =[NSMutableDictionary dictionaryWithDictionary:self.navigationController.navigationBar.titleTextAttributes];
    [navbarTitleTextAttributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    
    //disable send
    [sendButton setEnabled:NO];
    
    //If we're not in the background, or we are but we want to maintain connection, Try to reconnect
    if((background && [notifySwitch isOn]) || (!background)){
        [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
    }
    
    //may also just want to automatically go back to chooser
    //We have to manually dismiss our view controller instead of using IB's back button
    //[[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

/** Peripheral connected */
- (void) peripheralDidConnect:(CBPeripheral *)peripheral
{
    NSLog(@"peripheralDidConnect: %@",peripheral);
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];

    //only get this if we reconnected, so restart service
    [currentlyDisplayingService start];
}

/** List of peripherals changed */
- (void) discoveryDidRefresh
{
    //shouldnt get this as we disable discovery in the Discovery class
}


#pragma mark -
#pragma mark Backgrounding Methods
/****************************************************************************/
/*                       Bacgrounding Methods                               */
/****************************************************************************/
- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"didEnterBackgroundNotification: %@", notification);
    [RSSITimer invalidate];

    //if we were trying to reconnect to a peripheral, lets stop for battery life
    if([[currentlyDisplayingService peripheral] state] == CBPeripheralStateConnecting || ![notifySwitch isOn])
    {
        [currentlyDisplayingService enteredBackground]; //disable any notifications we have
        [[LeDiscovery sharedInstance] disconnectPeripheral:[currentlyDisplayingService peripheral]]; //disconnect
    }
    
    background = YES;
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"didEnterForegroundNotification: %@",notification);
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];

    //if we're not connected, try to connect
    if([[currentlyDisplayingService peripheral] state] == CBPeripheralStateDisconnected)
    {
        [[LeDiscovery sharedInstance] connectPeripheral:[currentlyDisplayingService peripheral]];
    }
    
    background = NO;
}



- (IBAction)updateWeather:(id)sender{
    
    
    if(self.weatherType.selectedSegmentIndex == WEATHER_STORM){
        self.lightning.on = YES;
    }
    
    Weather *weather= [[Weather alloc] initWithPNoon:self.sliderTime.value weatherType:(int)self.weatherType.selectedSegmentIndex lightning:self.lightning.on];
    
    [weather print];
    int staticAnimationMinutes = 2;
    int staticDurationMinutes = 0;
    int staticPollIntervall = 1;
    
    uint8_t	buf[7];
    buf[0]='r';
    [weather setToArray:buf atIdx:1];
    // set duration of animation in minutes
    buf[4]=staticAnimationMinutes;
    // set duration of wait in 5 min slices
    buf[5]=staticDurationMinutes;
    //set poll intervall in 5 min slices
    buf[6]=staticPollIntervall;
    //NSLog(@"buffer to send: %@",[NSString stringWithFormat:@"%s", &buf]);
    
    //send test data
    /*
     NSString *test = @"bla";
     NSData* tosend=[test dataUsingEncoding:NSUTF8StringEncoding];
     [currentlyDisplayingService write:tosend];
     
     
     //put sent text in chat box
     NSString* newStr = [[NSString alloc] initWithFormat:@"< %@\n",test] ;
     NSLog(@"sent: %@",newStr);
     */
    
    //send data
    NSData* tosend=[NSData dataWithBytes:&buf length:sizeof(buf)];
    [currentlyDisplayingService write:tosend];
    
    
    //put sent text in chat box
    NSString* newStr = [[NSString alloc] initWithFormat:@"< r aDur %i wDur %i poll %i \n",staticAnimationMinutes, staticDurationMinutes, staticPollIntervall] ;
    if (response.text ==nil) {
        [response setText:newStr];
        
    }else {
        
        [response setText:[newStr stringByAppendingString:response.text]];
    }
    
    
    
    NSLog(@"updateRealWeather");
}



- (IBAction)rSliderValueChanged:(id)sender {
   // Set the label text to the value of the slider as it changes
   self.rValue.text = [NSString stringWithFormat:@"%.2f", self.rSlider.value];
}
- (IBAction)gSliderValueChanged:(id)sender {
   // Set the label text to the value of the slider as it changes
   self.gValue.text = [NSString stringWithFormat:@"%.2f", self.gSlider.value];
}
- (IBAction)bSliderValueChanged:(id)sender {
   // Set the label text to the value of the slider as it changes
   self.bValue.text = [NSString stringWithFormat:@"%.2f", self.bSlider.value];
}
- (IBAction)pNoonValueChanged:(id)sender {
    // Set the label text to the value of the slider as it changes
    self.pNoonValue.text = [NSString stringWithFormat:@"%.2f", self.sliderTime.value];
}

- (IBAction)updateRGB:(id)sender{
   //
   Weather *weather= [[Weather alloc] initWithPNoon:self.sliderTime.value weatherType:WEATHER_RGB lightning:self.lightning.on];
    
    uint8_t	buf[7];
    buf[0]='g';
    [weather setToArray:buf atIdx:1];
    buf[4]=(double)rSlider.value*255;
    buf[5]=(double)gSlider.value*255;
    buf[6]=(double)bSlider.value*255;
    [weather print];
    NSLog(@"send_b: %d,%d,%d",buf[4],buf[5],buf[6]);
    NSLog(@"send_v: %f,%f,%f",rSlider.value,gSlider.value,bSlider.value);
    
    //send data
    NSData* tosend=[NSData dataWithBytes:&buf length:sizeof(buf)];
    [currentlyDisplayingService write:tosend];
    
    //put sent text in chat box
    NSString* newStr = [[NSString alloc] initWithFormat:@"< g r%1.f g%1.f b%1.f \n",(double)rSlider.value*255, (double)gSlider.value*255, (double)bSlider.value*255] ;
    if (response.text ==nil) {
        [response setText:newStr];
        
    }else {
        
        [response setText:[newStr stringByAppendingString:response.text]];
    }

   NSLog(@"updateRGB");
}
@end