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

@interface BLEManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+ (id)sharedBLEManager;

// Things for CoreBluetooth.
@property (nonatomic, strong) CBCentralManager *accesswayCBManager;//CBCentralManager
@property (nonatomic, strong) CBPeripheral *accesswayCBPeripheral;//CBPeriPheral
@property (nonatomic, strong) NSMutableData *accesswayCBData;//Array for holding data

@end
