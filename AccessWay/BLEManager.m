//
//  BLEManager.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import "BLEManager.h"

@implementation BLEManager

@synthesize accesswayCBManager,accesswayCBPeripheral,accesswayCBData;//sythesize things for CoreBluetooth

// Setup the dispatch queues
dispatch_queue_t backgroundQueueCoreBluetooth;//for CoreBluetooth

#pragma mark Singleton Methods

+ (id)sharedBLEManager {
    static BLEManager *sharedMyBLEManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyBLEManager = [[self alloc] init];
    });
    return sharedMyBLEManager;
}

- (id)init {
    if (self = [super init]) {
        backgroundQueueCoreBluetooth = dispatch_queue_create("com.ard.coreBluetooth", NULL);//Create queue for coreBluetooth
        self.accesswayCBManager = [[CBCentralManager alloc] initWithDelegate:self queue:backgroundQueueCoreBluetooth];//Set the delegate of CBCentralManager to self. Note the queue is changed to a background thread
    }
    return self;
}

#pragma mark - CoreBluetooth Delegate Methods
#pragma mark - CBCentralManager Delegate Methods
// A required delegate method invoked when the central manager’s state is updated. This method ensures that Bluetooth Low Energy is supported and available to use on the central device.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Central Manager is Powered On. Device is Bluetooth LE Compliant.");
            //[self.fliteController say:[NSString stringWithFormat:@"Bluetooth is powered on."] withVoice:self.slt];
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Central Manager is Powered Off.");
            //[self.fliteController say:[NSString stringWithFormat:@"Bluetooth is powered off. Please go to settings and turn Bluetooth on."] withVoice:self.slt];
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

@end
