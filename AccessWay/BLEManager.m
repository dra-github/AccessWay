//
//  BLEManager.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import "BLEManager.h"

@implementation BLEManager

//@synthesize accesswayCBManager;//sythesize things for CoreBluetooth
//@synthesize theAccesswayJSONClass;//synthesize things for interacting with AccesswayJSON

// Objects to keep track of UUID services
NSArray *UUIDArray;//array to store CBUUID objects

// Setup the dispatch queues
dispatch_queue_t backgroundQueueCoreBluetooth;//for CoreBluetooth
dispatch_queue_t backgroundQueueJSON;//for JSON

// Objects used to check for first time runs and event completions
bool locationInformationFirstTime=TRUE;

//Objects for checking voice commands
NSString *voiceCommand;

// Objects used to keep track of discovered peripherals.
NSMutableArray *accesswayDiscoveredPeripherals;

// Objects for processing CoreBluetooth data
NSMutableArray *tagsAverageRSSIArray;
NSMutableArray *RSSIArray;
NSMutableArray *serviceUUIDArray;
CBPeripheral *visitedTag;

// Objects used to keep a count of the number of times RSSI value is recorded
int rssiValueRecordCounter = 0;

//Objects for keeping track of the main station name. Used for displaying minimal information and for changing behavior if the station changes
NSString *currentStation;
bool hasStationNameChanged = TRUE;

//Objects for getting the device directions
NSString *deviceDirection;
NSString *currentDeviceDirection=@"Unknown";

//Things related to the Timer
NSTimer *appTimer;
int appTimerCount=0;

//Objects for the rssiAverageValue
int strongestRSSIAverageValueIndex = -1;

// Defining constants
#define TIMER_INTERVAL 10.0 //timer interval

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
        
        currentStation=@"Unknown";//Initialize currentStation
        deviceDirection=@"Unknown";//Initialize deviceDirection
        
        //Initialize objects used to keep track of discovered peripherals.
        accesswayDiscoveredPeripherals = [[NSMutableArray alloc]initWithCapacity:0];
        
        //Add NSNotification for resuming scanning for tags
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updatedResumeScanningNotification:)
                                                    name:@"ResumeScanningNotification"
                                                  object:nil];
        
        //Initalize objects used to process CoreBluetooth data.
        tagsAverageRSSIArray = [[NSMutableArray alloc]initWithCapacity:0];
        RSSIArray = [[NSMutableArray alloc]initWithCapacity:0];
        serviceUUIDArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        //Initialize all things required for processing JSON
        backgroundQueueJSON = dispatch_queue_create("com.ard.accesswayJSON", NULL);//Create queue for SQLLite
        self.theAccesswayJSONClass =[[AccesswayJSON alloc]init];
        self.theAccesswayJSONClass.delegate=self;
        dispatch_async(backgroundQueueJSON, ^{
            [self.theAccesswayJSONClass prepareJSON];
        });
        
        //Start updating device direction
        [CoreLocationManager sharedCoreLocationManager];
        //Add NSNotification for checking the device direction
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updatedHeadingNotification:)
                                                    name:@"HeadingUpdatedNotification"
                                                  object:nil];
        
        //Timer that clears the visited tags per TIME_INTERVAL. This is to avoid detecting the tags just visited continously
        /*if(appTimer==nil){
         appTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(handleTimerRelatedEvents:) userInfo:nil repeats:YES];
         }*/
        
        //Initialize CoreBluetooth capability
        backgroundQueueCoreBluetooth = dispatch_queue_create("com.ard.coreBluetooth", NULL);//Create queue for coreBluetooth
        self.accesswayCBManager = [[CBCentralManager alloc] initWithDelegate:self queue:backgroundQueueCoreBluetooth];//Set the delegate of CBCentralManager to self. Note the queue is changed to a background thread
        
        //Scan for any peripherals. When a station is found, only those UUIDs of BLEs specific to that station will be scanned for
        [self startScanForBLETags];
    }
    return self;
}

#pragma mark - Class Methods
//Method for setting the voice command
-(void)setVoiceCommand:(NSString *)_voiceCommand{
    voiceCommand=_voiceCommand;
}

//Method for starting scan
-(void)startScanForBLETags{
    if(hasStationNameChanged)
        [self.accesswayCBManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    else
        [self.accesswayCBManager scanForPeripheralsWithServices:UUIDArray options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];//scan for tags with services stored in UUIDArray
}

//Method for stopping scan
-(void)stopScanForBLETags{
    [self.accesswayCBManager stopScan];
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
    
    //Handling voice command - LOCATION INFORMATION. Checking for any BLE tags and comparing it with the database to find the current station.
    if([voiceCommand isEqualToString:@"LOCATION INFORMATION"]){
        
        //Get the name of the station to get minimal information to display and to check if there is a change in the station. Do this every 60 seconds
        
        dispatch_async(backgroundQueueJSON, ^{
            [self.theAccesswayJSONClass getStationName:[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]];
        });
        
        
        
        
        
        //If the station has been found and the station name has changed, get all the UUIDs of the BLE tags in that station
        if (hasStationNameChanged) {
            NSLog(@"station has changed");
            
            hasStationNameChanged=FALSE;
            
            [self stopScanForBLETags];//stop scanning
            
            //Get all the (services) UUIDs of all the tags in the current station. Using dispatch_sync because we need to get the UUIDArray before proceeding ahead.
            dispatch_sync(backgroundQueueJSON, ^{
                NSLog(@"in dispatch");
                
                UUIDArray = [self.theAccesswayJSONClass getUUIDofTagsInStation:[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]];
            });
            
            NSLog(@"UUIDArray %@",UUIDArray);
            
            
            [self startScanForBLETags];
            
            
        }
        
        //If the station has not changed, keep searching for the nearest BLE Tag
        else if(!hasStationNameChanged){
            
            //Find the nearest tag by calculating RSSI values
            
            //Add all discovered peripherals to accesswayDiscoveredPeripherals. If there are visited tags, ignore them for specified time
            if(![accesswayDiscoveredPeripherals containsObject:peripheral]){
                [accesswayDiscoveredPeripherals addObject:peripheral];
                NSLog(@"adding peripheral");
                
                NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:0];
                [tagsAverageRSSIArray addObject:tempArray];
                
                [serviceUUIDArray addObject:[[advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey] objectAtIndex:0]];//get the first service UUID from the peripheral.
            }
            
            //If there is atleast 1 tag available and if it is not part of the visitedTagsArray, find the nearest Tag.
            if (tagsAverageRSSIArray.count>0){
                
                if (rssiValueRecordCounter<5) {
                    rssiValueRecordCounter++;//increment rssiValueRecordCounter
                    [[tagsAverageRSSIArray objectAtIndex:[accesswayDiscoveredPeripherals indexOfObject:peripheral]] addObject:RSSI];//add RSSI value to the array at the index corresponding to the current peripheral
                }else{
                    
                    rssiValueRecordCounter=0;//set rssiValueRecordCounter to 0

                    //Only try to connect if the RSSI is less than -100dB. This is an arbitrary number and we will have to find the correct value to use
                    if (self.findAverageRSSI>-300 && ![visitedTag isEqual:[accesswayDiscoveredPeripherals objectAtIndex:strongestRSSIAverageValueIndex]]){
                        //NSLog(@"nearest tag IS %d",indexOfNearestTag);
                        
                        [self stopScanForBLETags];//stop scanning
                        
                        visitedTag=[accesswayDiscoveredPeripherals objectAtIndex:strongestRSSIAverageValueIndex];
                        
                        //NSLog(@"Visted array======== %@ count ===== %d",visitedTagsArray,visitedTagsArray.count);
                        
                        dispatch_async(backgroundQueueJSON, ^{
                            NSLog(@"device direction %@",deviceDirection);
                            [self.theAccesswayJSONClass getLocationInformationFromTagWithService:[serviceUUIDArray objectAtIndex:strongestRSSIAverageValueIndex] theDeviceDirection:deviceDirection];
                        });
                        
                    }
                    
                }
            }
        }
        
        //No station name is found. Keep scanning for generic BLEs
        else if ([currentStation isEqualToString:@"Unknown"]){
            NSLog(@"No station found");
            
            [self.accesswayCBManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
        
    }
}


#pragma mark - Methods for processing CoreBluetooth Data
/*Function to get the average RSSI value of the discovered tags
 PARAMETERS:NONE
 RETURNS:Strongest RSSI average value
 */
-(int)findAverageRSSI{
    int smallestRSSIAverageValue=-1000;
    strongestRSSIAverageValueIndex=-1;
    for (int i=0; i<tagsAverageRSSIArray.count; i++) {
        int tempAverageNumber = 0;
        for (int j=0; j<[[tagsAverageRSSIArray objectAtIndex:i] count]; j++) {
            tempAverageNumber+=[[[tagsAverageRSSIArray objectAtIndex:i] objectAtIndex:j] integerValue];
        }
        int total = [[tagsAverageRSSIArray objectAtIndex:i] count];
        int average = tempAverageNumber/total;
        
        //NSLog(@"avg %d",(tempAverageNumber/(int)[[tagsAverageRSSIArray objectAtIndex:i] count]));
        if (average>smallestRSSIAverageValue) {
            smallestRSSIAverageValue=average;
            strongestRSSIAverageValueIndex=i;
        }
        NSLog(@"tempavgno %d index %d",(tempAverageNumber/(int)[[tagsAverageRSSIArray objectAtIndex:i] count]),i);
    }
    
    NSLog(@"visited tag %@",visitedTag);
    return smallestRSSIAverageValue;
}

#pragma mark - Methods for all NSNotifications
//A method that gets the current direction of the device when the heading changes are detected in CoreLocationManager
- (void)updatedHeadingNotification:(NSNotification *)notification //use notification method and logic
{
    //NSLog(@"in updatedHeadingNotification");
    NSDictionary *dictionary = [notification userInfo];
    deviceDirection = [dictionary valueForKey:@"HeadingStringValue"];
    
}

#pragma mark - AccesswayJSON Delegate Methods
//A delegate method that informs the app that a station matching the BLE tag has been found
-(void)didFindCurrentStation:(AccesswayJSON *)controller theStationName:(NSString *)stationName{
    if(![currentStation isEqualToString:stationName]){
        NSLog(@"station changed");
        currentStation=stationName;
        hasStationNameChanged=TRUE;
        
        visitedTag=nil;
        [accesswayDiscoveredPeripherals removeAllObjects];//remove all discovered peripherals
        [tagsAverageRSSIArray removeAllObjects];//remove all RSSI average values
    }
    
}

//A delegate method that informs the app that location information corresponding to the nearest tag has been found along with the station name and Tag ID
- (void)didFindLocationInformation:(AccesswayJSON *)controller theLocationInformation:(NSString *)locationInformation theStationName:(NSString *)stationName theTagID:(NSString *)theSelectedTagID{
    //Station name search is unsuccessful
    if ([locationInformation isEqualToString:@"unknown"]) {
        NSLog(@"unknown");
    }
    //Station name search is successful
    else{
        NSLog(@"local information is %@",locationInformation);
        
        //Add notification when location information is found
        NSArray *tempObjectsArray = [[NSArray alloc]initWithObjects:stationName, locationInformation, nil];
        NSArray *tempKeysArray = [[NSArray alloc]initWithObjects:@"StationNameString", @"LocationInformationString", nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:tempObjectsArray forKeys:tempKeysArray];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationInformationNotification" object:nil userInfo:dictionary];
    }
}

#pragma mark - Methods for all NSNotifications
//A method that gets called as soon as the action sheet button is clicked to resume scanning
- (void)updatedResumeScanningNotification:(NSNotification *)notification{
    
    [accesswayDiscoveredPeripherals removeAllObjects];//remove all discovered peripherals
    [tagsAverageRSSIArray removeAllObjects];//remove all RSSI average values
    [serviceUUIDArray removeAllObjects];//remove all the service UUID average values
    
    [self startScanForBLETags];
}

#pragma mark - Timer related Methods
//Timer selector method that handles different conditions and logic
-(void)handleTimerRelatedEvents:(NSTimer *)timer{
    switch (appTimerCount) {
        case 0:
            break;
            
        case 1:
            break;
            
        default:
            break;
    }
    
}

@end
