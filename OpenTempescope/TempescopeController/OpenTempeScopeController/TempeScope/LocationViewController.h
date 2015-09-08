/*
 LocationViewController.h
 
 */

#import <UIKit/UIKit.h>

//#import "Helper.h"
@protocol CitySelectionDelegate <NSObject>
-(void)forecastFromOWM:(NSDictionary *) forcast;
-(NSString* )getSearchString;
@end

@interface LocationViewController : UITableViewController //<UITableViewDataSource>

- (IBAction)closeView:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, weak) id<CitySelectionDelegate> delegate;

@end
