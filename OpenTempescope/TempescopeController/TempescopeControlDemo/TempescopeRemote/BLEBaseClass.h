//
//  BLEBaseClass.h
//  BLESerial_test_iPhone5
//
//  Created by 石井 孝佳 on 2013/11/12.
//  Copyright (c) 2013年 浅草ギ研. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BLEDeviceClass;

@protocol BLEDeviceClassDelegate
- (void)didUpdateValueForCharacteristic:(BLEDeviceClass*)device Characteristic:(CBCharacteristic *)characteristic;
@end

@interface BLEDeviceClass : NSObject
@property (strong)		id<BLEDeviceClassDelegate>	delegate;
- (CBCharacteristic*)getCharacteristic:(NSString*)service_uuid characteristic:(NSString*)characteristic_uuid;
- (BOOL)writeWithResponse:(CBCharacteristic*)characteristic value:(NSData*)data;
- (BOOL)writeWithoutResponse:(CBCharacteristic*)characteristic value:(NSData*)data;
- (BOOL)readRequest:(CBCharacteristic*)characteristic;
- (BOOL)notifyRequest:(CBCharacteristic*)characteristic;

- (NSString *)deviceID;
@end

@interface BLEBaseClass : NSObject
@property (strong)	NSMutableArray*		Devices;

- (id)init;
- (BOOL)scanDevices:(NSString*)uuid;
- (void)scanStop;
- (BLEDeviceClass*)connectService:(NSString*)uuid;
- (BLEDeviceClass*)connectAny;
- (BOOL)disconnectService:(NSString*)uuid;
- (void)printDevices;
@end
