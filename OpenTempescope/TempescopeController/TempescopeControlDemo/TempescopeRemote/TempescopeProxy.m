/*
 Tempescope.m
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

#import "TempescopeProxy.h"

#define UUID_VSP_SERVICE					@"569a1101-b87f-490c-92cb-11ba5ea5167c" //VSP
#define UUID_RX                             @"569a2001-b87f-490c-92cb-11ba5ea5167c" //RX
#define UUID_TX								@"569a2000-b87f-490c-92cb-11ba5ea5167c" //TX


@interface TempescopeProxy () <BLEDeviceClassDelegate>


@property (strong)		BLEBaseClass*	BaseClass;
@property (readwrite)	BLEDeviceClass*	Device;

@property (readwrite) NSString* savedDeviceID;

@end

@implementation TempescopeProxy

- (id)init
{
    if(self=[super init]){
        
        self.savedDeviceID=[[NSUserDefaults standardUserDefaults] objectForKey:@"savedDeviceID"];
        
        _BaseClass = [[BLEBaseClass alloc] init];
        [_BaseClass scanDevices:nil];
        _Device = 0;
    }
    return self;
}


//callback from device
- (void)didUpdateValueForCharacteristic:(BLEDeviceClass *)device Characteristic:(CBCharacteristic *)characteristic
{
    if (device == _Device)	{
        //	キャラクタリスティックを扱う為のクラスを取得し
        //	通知されたキャラクタリスティックと比較し同じであれば
        //	bufに結果を格納
        //iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        if (characteristic == rx)	{
            //			uint8_t*	buf = (uint8_t*)[characteristic.value bytes]; //bufに結果が入る
            //            NSLog(@"value=%@",characteristic.value);
            return;
        }
        
        //Device->iPhone
        CBCharacteristic*	tx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_TX];
        if (characteristic == tx)	{
            //            NSLog(@"Receive value=%@",characteristic.value);
            uint8_t*	buf = (uint8_t*)[characteristic.value bytes]; //bufに結果が入る
            unichar cs[characteristic.value.length];
            for(int i=0;i<characteristic.value.length;i++)
                cs[i]=(char)buf[i];
            
            NSString *str=[NSString stringWithCharacters:cs length:characteristic.value.length];
            
            //            NSString *str=[NSString stringWithFormat:@"%d", buf[0]];
            NSLog(@"read: %@",str);
            
            return;
        }
        
    }
}


//////////////////////////////////////////////////////////////
//  connect
//////////////////////////////////////////////////////////////

- (void)connectToDevice:(BLEDeviceClass *)device{
    self.savedDeviceID=[device deviceID];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.savedDeviceID forKey:@"savedDeviceID"];
    
}


-(void)connect{
    [_BaseClass printDevices];
    
    //	UUID_DEMO_SERVICEサービスを持っているデバイスに接続する
//    _Device = [_BaseClass connectService:UUID_VSP_SERVICE];
    _Device = [_BaseClass connectAny];
    NSLog(@"device: %@",_Device);
    if (_Device)	{
        //	接続されたのでスキャンを停止する
        [_BaseClass scanStop];
        //	キャラクタリスティックの値を読み込んだときに自身をデリゲートに指定
        _Device.delegate = self;
        
        //        [_BaseClass printDevices];
        
        //ボタンの状態変更
//        [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
        //		_connectButton.enabled = FALSE;
        //		_disconnectButton.enabled = TRUE;
        //        _ledOnButton.enabled = TRUE;
        //        _ledOffButton.enabled = TRUE;
        
        //	tx(Device->iPhone)のnotifyをセット
        CBCharacteristic*	tx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_TX];
        NSLog(@"here! %@",tx);
        if (tx)	{
            NSLog(@"notifyRequest %@",tx);
            //            [_Device readRequest:tx];
            [_Device notifyRequest:tx];
        }
    }
}

- (NSArray *)devices{
    return [_BaseClass Devices];
}

//------------------------------------------------------------------------------------------
//	disconnectボタンを押したとき
//------------------------------------------------------------------------------------------
- (void)disconnect {
    if (_Device)	{
        //	UUID_DEMO_SERVICEサービスを持っているデバイスから切断する
        [_BaseClass disconnectService:UUID_VSP_SERVICE];
        _Device = 0;
        //ボタンの状態変更
//        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        
        //	周りのBLEデバイスからのadvertise情報のスキャンを開始する
        [_BaseClass scanDevices:nil];
    }
}

- (void)doConnectDisconnect {
    NSLog(@"pressed!");
    
    if(!_Device){
        //do connect
        [self connect];
    }else{
        //do disconnect
        [self disconnect];
    }
}

- (void)playWeather:(Weather *)weather {
//    Weather *weather= [[Weather alloc] initWithPNoon:self.sliderTime.value weatherType:(int)self.btnWeatherType.selectedSegmentIndex lightning:self.btnLightning.on];
    
    if (_Device)	{
        //	iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        
        uint8_t	buf[4];
        buf[0]='r';
        [weather setToArray:buf atIdx:1];
        [_Device writeWithoutResponse:rx value:[NSData dataWithBytes:&buf length:sizeof(buf)]];
    }
}

- (void) sendData:(uint8_t[])buf withLength:(int)length{
    if (_Device)	{
        //	iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        
        [_Device writeWithoutResponse:rx value:[NSData dataWithBytes:buf length:length]];
    }
}

+ (NSArray *)createDefaultWeathers{
    
    NSMutableArray *weathers=[[NSMutableArray alloc]init];
    //    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLEAR lightning:false]];
    //    [weathers addObject:[[Weather alloc] initWithPNoon:0. weatherType:WEATHER_CLEAR lightning:false]];
    
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_CLEAR lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0.5 weatherType:WEATHER_CLEAR lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLOUD lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLEAR lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:1 weatherType:WEATHER_CLEAR lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0.5 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_RAIN lightning:false]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_RAIN lightning:true]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_RAIN lightning:true]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_RAIN lightning:true]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_CLEAR lightning:true]];
    [weathers addObject:[[Weather alloc] initWithPNoon:0 weatherType:WEATHER_CLEAR lightning:false]];
    
    return weathers;
}
- (void)saveWeather:(NSArray *)weathers withDuration:(int)dur {
    NSLog(@"do save");
    
    if (_Device)	{
        //	iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        
        {
            
            uint8_t	buf[2];
            buf[0]='f';
            buf[1]=(int)[weathers count];
            
            NSLog(@"Length: %ld",[weathers count]);
            
            NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
            [_Device writeWithoutResponse:rx value:data];
            
            [NSThread sleepForTimeInterval:0.2];
        }
        
        int idx=0;
        for(Weather *weather in weathers){
            NSLog(@"%d: %@",idx, [weather description]);
            
            uint8_t	buf[7];
            buf[0]='s';
            buf[1]=idx;
            buf[2]=(dur>>8)&0xff;
            buf[3]=dur&0xff;
            [weather setToArray:buf atIdx:4];
            
            NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
            [_Device writeWithoutResponse:rx value:data];
            
            [NSThread sleepForTimeInterval:0.2];
            
            idx++;
        }
        
    }
}

- (void) playDemo {
    
    if (_Device)	{
        //	iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        
        uint8_t	buf[1];
        buf[0]='l';
        
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        [_Device writeWithoutResponse:rx value:data];
    }
}
- (void) playDefaultDemo{
    
    if (_Device)	{
        //	iPhone->Device
        CBCharacteristic*	rx = [_Device getCharacteristic:UUID_VSP_SERVICE characteristic:UUID_RX];
        
        uint8_t	buf[1];
        buf[0]='d';
        
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        [_Device writeWithoutResponse:rx value:data];
    }
}


- (BOOL) isConnected{
    return _Device!=nil;
}


@end
