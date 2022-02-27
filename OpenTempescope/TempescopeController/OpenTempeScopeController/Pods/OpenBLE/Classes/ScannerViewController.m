//
//  ViewController.m
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//


#import <Foundation/Foundation.h>

#import "ScannerViewController.h"


@implementation ScannerViewController

@synthesize currentPeripheral;
@synthesize sensorsTable;
@synthesize refreshControl;
@synthesize indicator;

#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//stuff that needs to happen once on creation
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//stuff that needs to happen every time we come back to this view controller
-(void)viewWillAppear:(BOOL)animated
{
    //Going to arbitrarily say you can only connect to one device at a time
    //Want to continue getting RSSI data, and also can't peripheral delegates
    //havent been changed when we come back here
    //so disconnect if we came back with a live peripheral
    if(currentPeripheral)
        [[LeDiscovery sharedInstance] disconnectPeripheral:currentPeripheral];
    
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    
    if( [[LeDiscovery sharedInstance] startScanningForUUIDString:nil] == CBCentralManagerStatePoweredOff)
    {
        [indicator stopAnimating];
    }else{
        [indicator startAnimating];
    }
    
    [sensorsTable reloadData];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
    [[LeDiscovery sharedInstance] stopScanning];
	[[LeDiscovery sharedInstance] setDiscoveryDelegate:nil];
}

- (IBAction)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [[LeDiscovery sharedInstance] stopScanning];
    [[LeDiscovery sharedInstance] clearFoundPeripherals];

    if( [[LeDiscovery sharedInstance] startScanningForUUIDString:nil] == CBCentralManagerStatePoweredOff)
    {
        [indicator stopAnimating];
    }else{
        [indicator startAnimating];
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)manualSegue
{
    [[LeDiscovery sharedInstance] stopScanning];

    //Switch to initial view controller of main storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger	res = 0;
    
	if (section == 0)
		res = [[[LeDiscovery sharedInstance] connectedPeripherals] count];
	else
		res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
	return res;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];

    static NSString *cellID = @"deviceCell";
	BLECell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    //2 sections, connected devices and discovered devices
	if ([indexPath section] == 0)
    {
		devices = [[LeDiscovery sharedInstance] connectedPeripherals];
        peripheral = [devices objectAtIndex:row];
	} else
    {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[peripheral name] length])
    {
        [cell.name setText:[peripheral name]];
    }
    else
    {
        [cell.name setText:@"Peripheral"];
    }
    
    NSDictionary *advertisingData = [[LeDiscovery sharedInstance] advertisingData];
    NSDictionary *peripheralDictionary = [advertisingData objectForKey:[peripheral identifier]];
    NSNumber *rssi = (NSNumber *)[peripheralDictionary objectForKey:@"RSSI"];
    [cell.RSSI setText:[rssi stringValue]];
    
    [cell.uuid setText:[[peripheral identifier] UUIDString]];

    if(peripheral.state  == CBPeripheralStateConnected)
    {
        [cell.status setText:@"Connected"];
    }else
    {
        [cell.status setText:@"Not Connected"];
    }
        
	return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CBPeripheral	*peripheral;
//    NSArray			*devices;
//    devices = [[LeDiscovery sharedInstance] connectedPeripherals];
//    peripheral = [devices objectAtIndex:indexPath.row];
//    
//    [[LeDiscovery sharedInstance] disconnectPeripheral:peripheral];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"disconnect";
//}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
	
	if ([indexPath section] == 0) {
        //because I've arbitrarily decided we only connect to one at a time
        //we should never get here
        //connected devices, segue on over
		devices = [[LeDiscovery sharedInstance] connectedPeripherals];
        currentPeripheral = [devices objectAtIndex:row];
        [self manualSegue];

	} else {
        //found devices, send off connect which will segue if successful
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
        [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
	}
}


#pragma mark -
#pragma mark LeDiscoveryDelegate 
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh 
{
    [indicator startAnimating];

    [sensorsTable reloadData];
}

- (void) discoveryStateChanged:(CBCentralManagerState)state
{
    if(state == CBCentralManagerStatePoweredOn){
        [self refresh:nil];
    }else
    {
        [indicator stopAnimating];
        
        NSString *title     = @"Bluetooth Power";
        NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

/** Peripheral disconnected -- do something? */
-(void)peripheralDidDisconnect:(CBPeripheral *)peripheral
{
    [sensorsTable reloadData];
}

/** Peripheral connected */
- (void) peripheralDidConnect:(CBPeripheral *)peripheral
{
    //Going to arbitrarily say you can only connect to one device at a time
    //so go ahead and segue
    currentPeripheral = peripheral;
    [self manualSegue];
}


#pragma mark -
#pragma mark Backgrounding Methods
/****************************************************************************/
/*                       Bacgrounding Methods                               */
/****************************************************************************/
- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    //stop scanning to save battery life
    [[LeDiscovery sharedInstance] stopScanning];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    //start scanning again
    if( [[LeDiscovery sharedInstance] startScanningForUUIDString:nil] == CBCentralManagerStatePoweredOff)
    {
        [indicator stopAnimating];
    }else{
        [indicator startAnimating];
    }
}

@end
