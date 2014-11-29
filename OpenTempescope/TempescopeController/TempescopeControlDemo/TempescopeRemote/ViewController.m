/*
 ViewController.m
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

#import "ViewController.h"
#import "TempescopeProxy.h"
#import "Weather.h"

@interface ViewController ()

@property (strong)		TempescopeProxy*	tempescope;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempescope=[[TempescopeProxy alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//////////////////////////////////////////////////////////////
//  connect
//////////////////////////////////////////////////////////////
-(void)connect{
    
    [self.tempescope connect];
    [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
}

//------------------------------------------------------------------------------------------
//	disconnectボタンを押したとき
//------------------------------------------------------------------------------------------
- (void)disconnect {
    [self.tempescope disconnect];
    [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    
}

- (IBAction)doConnectDisconnect:(id)sender {
    NSLog(@"pressed!");
    
    if([self.tempescope isConnected]){
        //do connect
        [self disconnect];
    }else{
        //do disconnect
        [self connect];
    }
}

- (IBAction)updateWeather:(id)sender {
    Weather *weather= [[Weather alloc] initWithPNoon:self.sliderTime.value weatherType:(int)self.btnWeatherType.selectedSegmentIndex lightning:self.btnLightning.on];
    
    [self.tempescope playWeather:weather];
}

- (IBAction)saveWeather:(id)sender {
    NSLog(@"do save");
    
    [self.tempescope saveWeather:[TempescopeProxy createDefaultWeathers] withDuration:5000];
}

- (IBAction)playDemo:(id)sender {
    [self.tempescope playDemo];
}
- (IBAction)playDefaultDemo:(id)sender {
    [self.tempescope playDefaultDemo];
}

- (IBAction)debug1:(id)sender{
    uint8_t	buf[2];
    buf[0]='z';
    buf[1]=(int)[self.sliderDebug1 value];
    NSLog(@"send: %d",buf[1]);
    [self.tempescope sendData:buf withLength:2];
}


@end
