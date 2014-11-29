//
//  BLEBaseClass.m
//  BLESerial_test_iPhone5
//
//  Created by 石井 孝佳 on 2013/11/12.
//  Copyright (c) 2013年 浅草ギ研. All rights reserved.
//
/*
 BLEの管理と通信を行う２つのクラス
 
 BLEBaseクラス     ：スキャン、接続、切断、スキャン情報の表示など
 BLEDeviceクラス   ：接続した周辺機器の実態を保持し、受信と送信を行う
 
 */

#import "BLEBaseClass.h"

@interface BLEDeviceClass() <CBPeripheralDelegate>
- (id)initWithPeripheral:(CBPeripheral*)peripheral advertisement:(NSDictionary*)advertisementData RSSI:(NSNumber*)rssi;
@property (readwrite)	enum {disconnected, connected, other}	state;
@property (strong)		CBPeripheral*							peripheral;
@property (strong)		NSDictionary*							advertisementData;
@property (strong)		NSNumber*								RSSI;
@end

@implementation BLEDeviceClass
- (id)initWithPeripheral:(CBPeripheral*)peripheral advertisement:(NSDictionary*)advertisementData RSSI:(NSNumber*)rssi
{
    self = [super init];
	_state = disconnected;
	_peripheral = peripheral;
	_advertisementData = advertisementData;
	_RSSI = rssi;
    return self;
}

- (NSString *)deviceID{
    return self.peripheral.identifier.UUIDString;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	_peripheral = peripheral;
	for (CBService* service in _peripheral.services)	{
		[_peripheral discoverCharacteristics:nil forService:service];
	}
}

- (CBCharacteristic*)getCharacteristic:(NSString*)service_uuid characteristic:(NSString*)characteristic_uuid
{
	if (_state == connected)	{
		for (int i = 0; i < 100; i++)	{
			for (CBService* service in _peripheral.services)	{
				if ([service.UUID isEqual:[CBUUID UUIDWithString:service_uuid]])	{
					for (int i = 0; i < 100; i++)	{
						for (CBCharacteristic* characteristic in service.characteristics)	{
							if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristic_uuid]])	{
								return characteristic;
							}
						}
						[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
					}
					return nil;
				}
			}
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
	}
	return nil;
}

- (BOOL)writeWithResponse:(CBCharacteristic*)characteristic value:(NSData*)data
{
	if (characteristic)	{
		[_peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
		return TRUE;
	}
	return FALSE;
}

- (BOOL)writeWithoutResponse:(CBCharacteristic*)characteristic value:(NSData*)data
{
	if (characteristic)	{
		[_peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
		return TRUE;
	}
	return FALSE;
}

- (BOOL)readRequest:(CBCharacteristic*)characteristic
{
	if (characteristic)	{
		[_peripheral readValueForCharacteristic:characteristic];
		return TRUE;
	}
	return FALSE;
}

- (BOOL)notifyRequest:(CBCharacteristic*)characteristic
{
	if (characteristic)	{
		[_peripheral setNotifyValue:TRUE forCharacteristic:characteristic];
		return TRUE;
	}
	return FALSE;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	[_delegate didUpdateValueForCharacteristic:self Characteristic:characteristic];
}

@end






@interface BLEBaseClass() <CBCentralManagerDelegate>
@property (strong)	CBCentralManager*	CentralManager;
@end

@implementation BLEBaseClass

- (id)init
{
    self = [super init];
    
	_CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	//	wait for startup
	while ([_CentralManager state] == CBCentralManagerStateUnknown)	{
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	_Devices = [NSMutableArray array];
    
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
}

- (BOOL)scanDevices:(NSString*)uuid
{
	if ([_CentralManager state] == CBCentralManagerStatePoweredOn)	{
		//	scan start
		NSArray*	services = nil;
		if (uuid != nil)	{
			services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuid], nil];
		}
		[_CentralManager scanForPeripheralsWithServices:services options:nil];
		return TRUE;
	}
	return FALSE;
}

- (void)scanStop
{
	if ([_CentralManager state] == CBCentralManagerStatePoweredOn)	{
		[_CentralManager stopScan];
	}
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	//	scan result
	BLEDeviceClass*	newDevice = [[BLEDeviceClass alloc] initWithPeripheral:peripheral advertisement:advertisementData RSSI:RSSI];
	for (BLEDeviceClass* Device in _Devices)	{
				if (memcmp((__bridge const void *)(Device.peripheral), (__bridge const void *)(peripheral), 16) == 0)	{
			[_Devices removeObject:Device];
		}
	}
	[_Devices addObject:newDevice];
}

- (void)printDevices
{
	NSLog(@"printDevices");
	for (BLEDeviceClass* Device in _Devices)	{
		NSLog(@"peripheral=%@ RSSI=%@ advertisementData%@", Device.peripheral, Device.RSSI, Device.advertisementData);
		for (CBService* service in Device.peripheral.services)	{
			NSLog(@"  service: %@", service.UUID);
			for (CBCharacteristic* characteristic in service.characteristics)	{
				NSLog(@"    characteristic: %@", characteristic.UUID);
			}
		}
	}
}

- (BLEDeviceClass*)connectService:(NSString*)uuid
{
	if ([_CentralManager state] == CBCentralManagerStatePoweredOn)	{
		for (BLEDeviceClass* Device in _Devices)	{
            NSArray*	services = Device.peripheral.services;
			if (services == nil)	{
				services = [Device.advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
            }
            NSLog(@"dev cand: %@",services);
			if ([services containsObject:[CBUUID UUIDWithString:uuid]])	{
				//	connect
				Device.state = disconnected;
				[_CentralManager connectPeripheral:Device.peripheral options:nil];
				while (Device.state == disconnected) {
					[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
				}
				return (Device.state == connected) ? Device : nil;
			}
		}
	}
	return FALSE;
}
- (BLEDeviceClass*)connectAny
{
    if ([_CentralManager state] == CBCentralManagerStatePoweredOn)	{
        for (BLEDeviceClass* Device in _Devices)	{
            NSArray*	services = Device.peripheral.services;
            if (services == nil)	{
                services = [Device.advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
            }
            NSLog(@"dev cand: %@",services);
            {
                //	connect
                Device.state = disconnected;
                [_CentralManager connectPeripheral:Device.peripheral options:nil];
                while (Device.state == disconnected) {
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                }
                return (Device.state == connected) ? Device : nil;
            }
        }
    }
    return FALSE;
}

- (BOOL)disconnectService:(NSString*)uuid
{
	if ([_CentralManager state] == CBCentralManagerStatePoweredOn)	{
		for (BLEDeviceClass* Device in _Devices)	{
			NSArray*	services = [Device.advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
			if ([services containsObject:[CBUUID UUIDWithString:uuid]])	{
				//	disconnect
				[_CentralManager cancelPeripheralConnection:Device.peripheral];
				while (Device.state == connected)	{
					[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
				}
				return TRUE;
			}
		}
	}
	return FALSE;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	NSLog(@"Connect Success!");
    for (BLEDeviceClass* Device in _Devices)	{
		if (memcmp((__bridge const void *)(Device.peripheral), (__bridge const void *)(peripheral), 16) == 0)	{
			[Device.peripheral setDelegate:Device];
			if (Device.peripheral.services == nil)	{
				//	未だサービス一覧を取得していないのでサービス一覧を取得する
				[Device.peripheral discoverServices:nil];
			}
			Device.state = connected;
			return;
		}
	}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"Connect Fail...");
    for (BLEDeviceClass* Device in _Devices)	{
				if (memcmp((__bridge const void *)(Device.peripheral), (__bridge const void *)(peripheral), 16) == 0)	{
			Device.state = other;
			return;
		}
	}
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	for (BLEDeviceClass* Device in _Devices)	{
				if (memcmp((__bridge const void *)(Device.peripheral), (__bridge const void *)(peripheral), 16) == 0)	{
			Device.state = disconnected;
			return;
		}
	}
}


@end