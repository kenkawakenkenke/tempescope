//
//  ViewController.h
//  OpenBLE
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>
#import "LeDiscovery.h"
#import "BLECell.h"

@interface ScannerViewController: UITableViewController  <LeDiscoveryDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sensorsTable;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) CBPeripheral* currentPeripheral;

-(IBAction)refresh:(id)sender;

@end
