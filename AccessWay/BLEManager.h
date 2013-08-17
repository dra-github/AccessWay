//
//  BLEManager.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

//Singleton class for checking the Bluetooth connection

#import <Foundation/Foundation.h>

//Importing all the headers required for CoreBluetooth
#import <CoreBluetooth/CoreBluetooth.h>

//Importing headers required for processing JSON
#import "AccesswayJSON.h"

//Importing all the headers required for CoreLocationManager
#import "CoreLocationManager.h"

@interface BLEManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,AccesswayJSONDelegate>

+ (id)sharedBLEManager;

// Things for CoreBluetooth.
@property (nonatomic, strong) CBCentralManager *accesswayCBManager;//CBCentralManager
@property (nonatomic, strong) CBPeripheral *accesswayCBPeripheral;//CBPeriPheral
@property (nonatomic, strong) NSMutableData *accesswayCBData;//Array for holding data

// Things and methods for processing CoreBluetooth data.
-(void)startScanForBLETags;//method to start scanning for BLE Tags
-(void)stopScanForBLETags;//method to stop scanning for BLE Tags
-(int)findAverageRSSIandGetNearestTag;//function to get the average RSSI value of the discovered tags and get the nearest tag;
-(int)findAverageRSSI;//function to get the average RSSI value of the discovered tags to check for range

//Things for interacting with AccesswayJSON
@property(nonatomic,strong)AccesswayJSON *theAccesswayJSONClass;

//Method for setting the voice commands
-(void)setVoiceCommand:(NSString *)voiceCommand;

@end
