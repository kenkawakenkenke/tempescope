/*

 File: LeDataService.m
 
 Abstract: Data Service Code - Connect to a peripheral
 and send and receive data.
 
 
 */


#import "LeDataService.h"
#import "LeDiscovery.h"


@interface LeDataService() <CBPeripheralDelegate> {
@private
    
    NSMutableArray *serviceCBUUIDs;
    NSMutableArray *writeCBUUIDs;
    NSMutableArray *writeWithResponseCBUUIDs;
    NSMutableArray *readCBUUIDs;
    
    CBPeripheral		*servicePeripheral;

    CBCharacteristic    *writeCharacteristic;
    CBCharacteristic    *readCharacteristic;
    
    CBService			*dataService;

    id<LeDataProtocol>	peripheralDelegate;
}
@end


@implementation LeDataService


@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeDataProtocol>)controller{
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        //Load the uuids from plist
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"LE-UUIDs.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"LE-UUIDs" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *LE_UUIDArrays = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!LE_UUIDArrays) {
            NSLog(@"Error reading plist: %@, format: %u", errorDesc, format);
        }

        NSArray *serviceUUIDStrings = [LE_UUIDArrays objectForKey:@"service-uuids"];
        NSArray *writeUUIDStrings = [LE_UUIDArrays objectForKey:@"write-uuids"];

        NSArray *writeWithResponseUUIDStrings = [LE_UUIDArrays objectForKey:@"write-with-response-uuids"];

        NSArray *readUUIDStrings = [LE_UUIDArrays objectForKey:@"read-uuids"];
        
        serviceCBUUIDs=[[NSMutableArray alloc] init];
        writeCBUUIDs=[[NSMutableArray alloc] init];
        writeWithResponseCBUUIDs=[[NSMutableArray alloc] init];

        readCBUUIDs=[[NSMutableArray alloc] init];
        
        for(NSString *uuidString in serviceUUIDStrings){
            [serviceCBUUIDs addObject:[CBUUID UUIDWithString:uuidString]];
        }
        
        for(NSString *uuidString in writeUUIDStrings){
            [writeCBUUIDs addObject:[CBUUID UUIDWithString:uuidString]];
        }
        
        for(NSString *uuidString in writeWithResponseUUIDStrings){
            [writeCBUUIDs addObject:[CBUUID UUIDWithString:uuidString]];
            [writeWithResponseCBUUIDs addObject:[CBUUID UUIDWithString:uuidString]];
        }
        
        for(NSString *uuidString in readUUIDStrings){
            [readCBUUIDs addObject:[CBUUID UUIDWithString:uuidString]];
        }
	}
    return self;
}


- (void) dealloc {
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];

		servicePeripheral = nil;
    }
}


- (void) reset
{
	if (servicePeripheral) {
		servicePeripheral = nil;
	}
}


#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) setController:(id<LeDataProtocol>)controller
{
    peripheralDelegate = controller;
}

- (void) start
{
    //doing this again, as after a connect the Discovery takes peripheral back
    //if we disconnect, then reconnect, we would have lost delegate
    [servicePeripheral setDelegate:self];
    
    [servicePeripheral discoverServices:serviceCBUUIDs];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
    NSMutableArray* uuids = [NSMutableArray arrayWithArray:writeCBUUIDs];
    [uuids addObjectsFromArray: readCBUUIDs];
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return;
	}

	dataService = nil;
    
	for (CBService *service in services) {
		if ([serviceCBUUIDs containsObject:[service UUID]]) {
			dataService = service;
            NSLog(@"services: %@",service);
			break;
		}
	}
    
	if (dataService) {
		[peripheral discoverCharacteristics:uuids forService:dataService];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return;
	}
	
	if (service != dataService) {
		NSLog(@"Wrong Service.\n");
		return;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
		if ([readCBUUIDs containsObject:[characteristic UUID] ]) { // Read
            NSLog(@"Discovered Read Characteristic");
			readCharacteristic = characteristic;
            writeCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"readCharacteristic %@",readCharacteristic);
            NSLog(@"writeCharacteristic %@",writeCharacteristic);
		}
        else if ([writeCBUUIDs containsObject:[characteristic UUID]]) { // Write
            NSLog(@"Discovered Write Characteristic");
			writeCharacteristic = characteristic;
            readCharacteristic = characteristic;
		}
        
	}
    
    //check if we've found all services we need for this device and call delegate
    if(readCharacteristic && writeCharacteristic)
    {
        [peripheralDelegate serviceDidReceiveCharacteristicsFromService:self];
    }
}


#pragma mark -
#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
- (void) write:(NSData *)data
{
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
		return;
    }

    if (!writeCharacteristic) {
        NSLog(@"No valid write characteristic");
        return;
    }
    
    if (!data) {
        NSLog(@"Nothing to write");
        return;
    }

    //if([writeWithResponseCBUUIDs containsObject:writeCharacteristic])
        if(YES)
    {
        NSLog(@"writeValue %@",data);
        [servicePeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        [peripheralDelegate didWriteFromService:self withError:nil];
    }
    else{
        [servicePeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
        [peripheralDelegate didWriteFromService:self withError:nil];
    }
}

/** If we're connected, we don't want to be getting read change notifications while we're in the background.
 We will want read notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([serviceCBUUIDs containsObject:[service UUID]]) {
            
            // Find the read characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [writeCBUUIDs containsObject:[characteristic UUID]] ) {
                    
                    // And STOP getting notifications from it
                    [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the read changes */
- (void)enteredForeground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([serviceCBUUIDs containsObject:[service UUID]]) {
            
            // Find the read characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [writeCBUUIDs containsObject:[characteristic UUID]] ) {
                    
                    // And START getting notifications from it
                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return;
	}
    
    /* Data to read */
    if ([readCBUUIDs containsObject:[characteristic UUID]]) {
        [peripheralDelegate serviceDidReceiveData:[readCharacteristic value] fromService:self];
        return;
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheralDelegate didWriteFromService:self withError:error];
}
@end
