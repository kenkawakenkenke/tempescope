/*
 DeviceSelectorViewController.m
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
#import "LocationViewController.h"
#import "OWMWeatherAPI.h"


@interface LocationViewController (){
    OWMWeatherAPI *_weatherAPI;
    NSArray *_cityArray;
    NSArray *_forecast;
    NSDateFormatter *_dateFormatter;
    int downloadCount;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ok_button;



@property (weak, nonatomic) IBOutlet UITableViewCell *cell;
@end

@implementation LocationViewController

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"finishLoading");
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    */
    [self.tableview reloadData];
    

    
}
- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    /*
    Helper *tempeHelper = [Helper getInstance];
    //tempeHelper.locationVC = self;
    [tempeHelper configureRestKit];
    
    self.cityArray = [[NSMutableArray alloc] init];
    self.cityArray =  [tempeHelper loadCities:[self.delegate getSearchString] on:self];
     */
    
    downloadCount = 0;
    
   // NSString *dateComponents = @"H:m yyMMMMd";
    NSString *dateComponents = @"H:m";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale] ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:dateFormat];
    
    _cityArray = @[];
    
    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"0c4fc54685c2ccd0a609e5f7aa148b68"]; // Replace the key with your own
    //_weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"11111111111"];
    
    // We want localized strings according to the prefered system language
    [_weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    //[_weatherAPI setTemperatureFormat:kOWMTempCelcius];
    
 
    [_weatherAPI searchForCityName:[_delegate getSearchString] withCount:20
                       andCallback:^(NSError *error, NSDictionary *result) {
                           downloadCount++;
                           
                           
                           if (error) {
                               // Handle the error;
                               return;
                           }
                           /*
                            
                            self.wetterText.text = [NSString stringWithFormat:@"%@",
                            result[@"weather"][@"description"]];
                            self.wetterCode.text = [NSString stringWithFormat:@"%@",
                            result[@"weather"][@"id"]];
                            self.maxTemp.text = [NSString stringWithFormat:@"%@",
                            result[@"main"][@"temp_max"]];
                            self.minTemp.text = [NSString stringWithFormat:@"%@",
                            result[@"main"][@"temp_min"]];
                            self.timeStamp.text =  [_dateFormatter stringFromDate:result[@"dt"]];
                            
                            */
                           
                           
                           _cityArray = result[@"list"];
                           [self.tableView reloadData];
                           
                           
                           
                           
                       }];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



/*
- (void)insertNewObject:(id)sender {
    if (!self.cityArray) {
        self.cityArray = [[NSMutableArray alloc] init];
    }
    [self.cityArray insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StadtCell" forIndexPath:indexPath];
    
    
/*

    if (sizeof(self.cityArray)>0) {
        City *stadt = [self.cityArray objectAtIndex:indexPath.row];
        cell.textLabel.text = stadt.cityName;
        cell.detailTextLabel.text = stadt.cityCode;
       
        if (stadt.selected){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        
    }
 */
    
    NSDictionary *cityData = [_cityArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %.1f℃ - %@",
                           cityData[@"name"],
                           [cityData[@"main"][@"temp"] doubleValue],
                           cityData[@"weather"][0][@"description"]
                           ];
    
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:cityData[@"dt"]];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_cityArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *cityData = [_cityArray objectAtIndex:indexPath.row];
    [_weatherAPI forecastWeatherByCityId:cityData[@"id"] withCount:1 withCallback:^(NSError *error, NSDictionary *result) {
     
        
        _forecast = result[@"list"];
        [self.delegate forecastFromOWM:result];
        
        
    }];
    
    
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.2]];
    [self performSegueWithIdentifier:@"citySelected" sender:self];
    
    /*
    
    City *tappedItem = [_cityArray objectAtIndex:indexPath.row];
    _stadt = tappedItem;
    //load forecast for selected City
         // NSLog(@"%@ %lu",self.forecastArray, (unsigned long)self.forecastArray.count);
    //NSLog(@"%@", ((Forecast *)self.forecastArray[0]).weatherText);
    
    tappedItem.selected =!tappedItem.selected;
    
    
    
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    Helper *tempeHelper = [Helper getInstance];
    
    [tempeHelper loadForecast:tappedItem.cityCode];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.2]];
      */
    
   
    
    /*
    if(self.presentingViewController)
        [self dismissViewControllerAnimated:NO completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
    */
    
}



@end
