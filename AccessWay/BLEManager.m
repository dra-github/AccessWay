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
@synthesize theAccesswayJSONClass;//synthesize things for interacting with AccesswayJSON

// Setup the dispatch queues
dispatch_queue_t backgroundQueueCoreBluetooth;//for CoreBluetooth
dispatch_queue_t backgroundQueueJSON;//for JSON

// Objects used to check for first time runs and event completions
bool locationInformationFirstTime=TRUE;

//Objects for checking voice commands
NSString *voiceCommand;

// Objects used to keep track of discovered peripherals.
NSMutableArray *accesswayDiscoveredPeripherals;

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
        
        //Initialize all things required for processing JSON
        backgroundQueueJSON = dispatch_queue_create("com.ard.accesswayJSON", NULL);//Create queue for SQLLite
        theAccesswayJSONClass =[[AccesswayJSON alloc]init];
        theAccesswayJSONClass.delegate=self;
        dispatch_async(backgroundQueueJSON, ^{
            [theAccesswayJSONClass prepareJSON];
        });
        
        //Initialize CoreBluetooth capability
        backgroundQueueCoreBluetooth = dispatch_queue_create("com.ard.coreBluetooth", NULL);//Create queue for coreBluetooth
        self.accesswayCBManager = [[CBCentralManager alloc] initWithDelegate:self queue:backgroundQueueCoreBluetooth];//Set the delegate of CBCentralManager to self. Note the queue is changed to a background thread
        
        //Scan for peripherals
        [self.accesswayCBManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
    return self;
}

#pragma mark - Class Methods
//Method for setting the voice command
-(void)setVoiceCommand:(NSString *)_voiceCommand{
    voiceCommand=_voiceCommand;
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

// A delegate method invoked when the central manager discovers a peripheral while scanning.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    //Handle the logic depending on the voice command that is received.
    //Handling voice command - CURRENT STATION. Checking for any BLE tags and comparing it with the database to find the current station.
    if([voiceCommand isEqualToString:@"CURRENT STATION"]){
        
        [self.accesswayCBManager stopScan];//stop scanning
        
        //__block NSString *theStationName = [[NSString alloc]init];//Setting variable to hold return string from block
        
        if(![accesswayDiscoveredPeripherals containsObject:peripheral]){//add the peripheral to accesswayDiscoveredPeripherals
            
            NSLog(@"peripheral name %@",[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]);
            
            [accesswayDiscoveredPeripherals addObject:peripheral];
            
            dispatch_async(backgroundQueueJSON, ^{
                NSLog(@"in current station dispatch");
                [theAccesswayJSONClass getStationName:[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]];
            });
        }
    }
}

#pragma mark - AccesswayJSON Delegate Methods
//A delegate method that informs the app that a station matching the BLE tag has been found
-(void)didFindCurrentStation:(AccesswayJSON *)controller theStationName:(NSString *)stationName{
    NSLog(@"in didFindCurrentStation");
    
    NSString *bleTagIsAvailable;//to see if a known BLE Tag is available
    
    //Station name search is unsuccessful
    if ([stationName isEqualToString:@"unknown"]) {
        NSLog(@"unknown");
        
        bleTagIsAvailable=@"NO";
        
        //Continue scanning for BLEs till the timer runs out
        //[self.accesswayCBManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
    //Station name search is successful
    else{
        NSLog(@"station is %@",stationName);
        
        bleTagIsAvailable=@"YES";
        
        //Clear the accesswayDiscoveredPeripherals
        //[accesswayDiscoveredPeripherals removeAllObjects];
    }
    
    //Add notification when the heading is updated
    //NSDictionary *dictionary = [NSDictionary dictionaryWithObject:bleTagIsAvailable forKey:@"BLEAvailabilityTagStringValue"];
    NSArray *tempObjects = [NSArray arrayWithObjects:bleTagIsAvailable,stationName, nil];
    NSArray *tempkeys = [NSArray arrayWithObjects:@"BLEAvailabilityTagStringValue",@"stationNameStringValue", nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:tempObjects forKeys:tempkeys];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLETagAvailabilityTagNotification" object:nil userInfo:dictionary];
}

@end
