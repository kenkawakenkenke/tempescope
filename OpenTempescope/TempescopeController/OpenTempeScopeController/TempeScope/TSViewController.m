//
//  TSViewController.m
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import "TSViewController.h"
#import "LeDataService.h"
#import "ScannerViewController.h"
#import "LocationViewController.h"
#import "Weather.h"
#import "DetailViewController.h"
#import "OWMWeatherAPI.h"

#define WEATHER_CLEAR 0
#define WEATHER_RAIN 1
#define WEATHER_CLOUD 2
#define WEATHER_STORM 3
#define WEATHER_RGB 4


@interface TSViewController() {
    OWMWeatherAPI *_weatherAPI;
    NSDateFormatter *_dateFormatter;
    
    int tempeScopeWeatherCode;
    BOOL tempeScopeLighnting;
    NSString *weatherIconCode;
@private
    bool background;
    NSTimer *RSSITimer;
    DetailViewController *console;
}
@end

@implementation TSViewController 

@synthesize currentlyDisplayingService;
@synthesize notifySwitch;
@synthesize RSSI;


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

-(void) viewWillAppear:(BOOL)animated{
    
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    console = [[DetailViewController alloc]init];
    
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
    
    
    //set peripheral name into navigation header
    self.navigationItem.title = [[currentlyDisplayingService peripheral] name];
    
    //we want to know if we went into the background or came back
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //Helper *tempeHelper = [Helper getInstance];
    //tempeHelper.tempeView = self;
    //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.2]];
     //[self.view setNeedsDisplay ];
    NSString *dateComponents = @"H:m dMMMMYYY";
    
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale] ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:dateFormat];

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

-(IBAction)back:(id)sender
{
    [RSSITimer invalidate];
    
    //We have to manually dismiss our view controller instead of using IB's back button
    [[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
    if (console.response.text ==nil) {
        [console.response setText:newStr2];
    }else {
        [console.response setText:[newStr2 stringByAppendingString:console.response.text]];
    }
    
    if ([newStr isEqualToString:@"BLEup"]) {
        NSLog(@"request to update from BLE");
        [console.response setText:[newStr stringByAppendingString:console.response.text]];
        [self updateRealWeather:self];
    }
    
    
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
    NSLog(@"didWriteFromService:");
}

/** Confirms service started fully */
- (void) serviceDidReceiveCharacteristicsFromService:(LeDataService*)service
{
    NSLog(@"serviceDidReceiveCharacteristicsFrom Service: %@",service);
    NSMutableDictionary *navbarTitleTextAttributes =[NSMutableDictionary dictionaryWithDictionary:self.navigationController.navigationBar.titleTextAttributes];
    [navbarTitleTextAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    
    
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
    NSLog(@"discoveryStateChanged: %ld",(long)state);
    
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

//unwind seque
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"prepareForUnwind");
       
    
}

-(IBAction)prepareForUnwindFromCitySearch:(UIStoryboardSegue *)segue {
    NSLog(@"prepareForUnwindFromCitySearch");


    self.weatherCity.text = [NSString stringWithFormat:@"%@, %@",
                          _forecastList[@"city"][@"name"],
                          _forecastList[@"city"][@"country"]
                          ];
    
    self.temp.text = [NSString stringWithFormat:@"%.1f℃",
                      [_forecastList[@"list"][0][@"main"][@"temp"] floatValue] ];
    self.minTemp.text = [NSString stringWithFormat:@"%.1f℃",
                      [_forecastList[@"list"][0][@"main"][@"temp_min"] floatValue] ];
    self.maxTemp.text = [NSString stringWithFormat:@"%.1f℃",
                      [_forecastList[@"list"][0][@"main"][@"temp_max"] floatValue] ];
    self.wetterCode.text = [NSString stringWithFormat:@"%ld",
                         [_forecastList[@"list"][0][@"weather"][0][@"id"] integerValue] ];
    
    
    self.wetterText.text = _forecastList[@"list"][0][@"weather"][0][@"description"];
    self.timeStamp.text =  [_dateFormatter stringFromDate:_forecastList[@"list"][0][@"dt"]];
    
    [self mapWeatherCode:[self.wetterCode.text intValue]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"selectCity"]) {
        
        //get VC
        LocationViewController * controller = segue.destinationViewController;
        [controller setDelegate:self];
        [self.view endEditing:YES];
        
        
        
        //((LocationViewController *)[segue destinationViewController]).cityArray = tempeHelper.cityArray;
        
        
    }
    
}

#pragma mark -
#pragma mark CitySelectionDelegate
/****************************************************************************/
/*                       CitySelectionDelegate Methods                        */
/****************************************************************************/
-(void)forecastFromOWM:(NSDictionary *)forecast{
  
    _forecastList = forecast;
    
}
-(NSString *)getSearchString{
    return self.searchString.text;
}
- (IBAction)updateRealWeather:(id)sender {
    //ToDo set real weather
    
    
    
    NSDate *localDate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH";
    NSString *dateString = [timeFormatter stringFromDate: localDate];
    float tempeHour =[dateString floatValue]/24.0;
    //NSLog(@"time: %@ %f",dateString,tempeHour);

    
    [self mapWeatherCode:[self.wetterCode.text intValue]];
    
    Weather *weather= [[Weather alloc]
                       //Orts Tageszeit
                       initWithPNoon:tempeHour
                       weatherType:tempeScopeWeatherCode lightning:tempeScopeLighnting];
    //[self.tempescope disconnect];
    //[self.tempescope connect];
    
    

    //NSLog(@"aDur: %d wDur: %d", self.tempescope.animationDuration, self.tempescope.waitDuration *5);
    
    
    [weather print];
    
    uint8_t	buf[7];
    buf[0]='r';
    [weather setToArray:buf atIdx:1];
    // set duration of animation in 5min slices
    buf[4]=[self.animationDuration.text intValue];
    // set duration of wait in 15 slices
    buf[5]=[self.waitDuration.text intValue];
    buf[6]=[self.pollIntervall.text intValue];
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
    //NSLog(@"write:tosend %@",&buf);
    [currentlyDisplayingService write:tosend];
    
    
    //put sent text in chat box
    NSString* newStr = [[NSString alloc] initWithFormat:@"< %s\n",buf] ;
    if (console.response.text ==nil) {
        [console.response setText:newStr];
    }else {
        [console.response setText:[newStr stringByAppendingString:console.response.text]];
    }
    
    //updates the values in the view
    [self prepareForUnwindFromCitySearch:nil];
    
    NSLog(@"updateRealWeather");

    
}

- (IBAction)stopWeather:(id)sender {
    //ToDo set real weather
    
    
    
    uint8_t	buf[1];
    buf[0]='z';
    
    //send data
    NSData* tosend=[NSData dataWithBytes:&buf length:sizeof(buf)];
    //NSLog(@"write:tosend %@",&buf);
    [currentlyDisplayingService write:tosend];
    
    
    //put sent text in chat box
    NSString* newStr = [[NSString alloc] initWithFormat:@"< %s\n",buf] ;
    if (console.response.text ==nil) {
        [console.response setText:newStr];
    }else {
        [console.response setText:[newStr stringByAppendingString:console.response.text]];
    }
    
    NSLog(@"stopWeather");
    
    
}

-(void) mapWeatherCode: (int) owmWeatherCode{
    
  
    // map the OWM weather codes to OpentTempeScope weather codes
    
    
   
    NSLog(@"owmWeatherCode: %d",owmWeatherCode);

    
    switch(owmWeatherCode)
    {
        // thunderstorm (rain and lighning)
        case 200:
        case 201:
        case 202:
        case 230:
        case 231:
        case 232:
            tempeScopeWeatherCode = WEATHER_STORM;
            tempeScopeLighnting = YES;
            weatherIconCode = @"11";
            
            break;
        // thunderstorm (no rain and lighning)
        case 210:
        case 211:
        case 212:
        case 221:
            tempeScopeWeatherCode = WEATHER_CLEAR;
            tempeScopeLighnting = YES;
            weatherIconCode = @"11";
            break;
            
        // drizzle (Sprühregen)
        case 300:
        case 301:
        case 302:
        case 310:
        case 311:
        case 312:
        case 313:
        case 314:
        case 321:
            tempeScopeWeatherCode = WEATHER_RAIN;
            tempeScopeLighnting = NO;
            weatherIconCode = @"09";
            break;
        
        // Rain
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
            tempeScopeWeatherCode = WEATHER_RAIN;
            tempeScopeLighnting = NO;
            weatherIconCode = @"10";
            break;
            // Rain
        case 511:
            tempeScopeWeatherCode = WEATHER_RAIN;
            tempeScopeLighnting = NO;
            weatherIconCode = @"13";
            break;
            // Rain
        case 520:
        case 521:
        case 522:
        case 531:
            tempeScopeWeatherCode = WEATHER_RAIN;
            tempeScopeLighnting = NO;
            weatherIconCode = @"09";
            break;
        
        // Snow
        case 600:
        case 601:
        case 602:
        case 611:
        case 612:
        case 615:
        case 616:
        case 620:
        case 621:
        case 622:
            tempeScopeWeatherCode = WEATHER_CLOUD;
            tempeScopeLighnting = NO;
            weatherIconCode = @"13";
            break;
        
        //atmosphere, mist, smoke haze sand dust whirls fog sand , dust volcanic ash
        case 701:
        case 711:
        case 721:
        case 731:
        case 741:
        case 751:
        case 761:
        case 762:
        case 771:
        case 781:
            tempeScopeWeatherCode = WEATHER_CLOUD;
            tempeScopeLighnting = NO;
            weatherIconCode = @"50";
            break;
        // Cloud
        case 800:
            tempeScopeWeatherCode = WEATHER_CLEAR;
            tempeScopeLighnting = NO;
            weatherIconCode = @"01";
            break;
        case 801:
            tempeScopeWeatherCode = WEATHER_CLOUD;
            tempeScopeLighnting = NO;
            weatherIconCode = @"02";
            break;
        case 802:
            tempeScopeWeatherCode = WEATHER_CLOUD;
            tempeScopeLighnting = NO;
            weatherIconCode = @"03";
            break;
        case 803:
        case 804:
            tempeScopeWeatherCode = WEATHER_CLOUD;
            tempeScopeLighnting = NO;
            weatherIconCode = @"04";
            break;
        
        //extrem tornado tropical storm, huricane cold, hot windy, hail
        case 900:
        case 901:
        case 902:
        case 903:
        case 904:
        case 905:
        case 906:
            tempeScopeWeatherCode = WEATHER_CLEAR;
            tempeScopeLighnting = NO;
            weatherIconCode = @"01";
            break;
        //breeze Brise
        case 951:
        case 952:
        case 953:
        case 954:
        case 955:
        case 956:
        case 957:
            tempeScopeWeatherCode = WEATHER_CLEAR;
            tempeScopeLighnting = NO;
            weatherIconCode = @"01";
            break;
        //gale (sturm no thunder)
        case 958:
        case 959:
        case 960:
        case 961:
        case 962:
            tempeScopeWeatherCode = WEATHER_STORM;
            tempeScopeLighnting = YES;
            weatherIconCode = @"09";
            break;
        //default
        default:
            tempeScopeWeatherCode = WEATHER_CLEAR;
            tempeScopeLighnting = NO;
            weatherIconCode = @"01";
            break;
    }
    
    NSDate *localDate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH";
    NSString *nightDay;
    NSString *dateString = [timeFormatter stringFromDate: localDate];
    if ([dateString integerValue]>21 || [dateString integerValue]<6) {
        nightDay = @"n";
    }else {
        nightDay = @"d";
    }
    float tempeHour =[dateString floatValue]/24.0;
    NSLog(@"time: %@ %f",dateString,tempeHour);
    NSString *imageName;
    
    imageName = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@%@.png",weatherIconCode,nightDay];
    NSURL *url = [NSURL URLWithString:imageName];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    NSLog(@"image_icon_name: %@",url );
    
    self.weatherImage.image = img;
    
}
@end
