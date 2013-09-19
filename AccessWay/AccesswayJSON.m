//
//  AccesswayJSON.m
//  Accessway070713_Directions
//
//  Created by Rajan Ayakkad on 7/17/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import "AccesswayJSON.h"

@implementation AccesswayJSON
@synthesize accesswayJSONDictionary,currentStationDictionary,allStationInformationArray;//synthesize object for hold the data from the JSON object

//Objects for holding current station
NSString *currentStation = @"Unknown";

-(void)prepareJSON{
    @try {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        // SUMMARY: All the editing can happen only when the files exist in the Documents folder of the app.
        //          If the file does not exist in the Documents folder, then it has to be copied from the Bundle path to the
        //          Documents path.
        //
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"accesswayJSON.json"]];
        NSString * bundlePath = [[[NSBundle mainBundle] resourcePath]
                                 stringByAppendingPathComponent:@"accesswayJSON.json"];
        
        if ( ![fileMgr fileExistsAtPath:filePath] ) {
            NSLog(@"JSON object copied");
            [fileMgr copyItemAtPath:bundlePath toPath:filePath error:nil];
        }else{
            NSLog(@"JSON object not copied since File Already Exists");
        }
        
        //parse out the json data
        NSError* error;
        NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        NSDictionary* jsonDictionary = [NSJSONSerialization
                              JSONObjectWithData:data 
                              
                              options:kNilOptions
                              error:&error];
        /*
        NSArray* accesswayArray = [jsonDictionary objectForKey:@"accessway"];
        NSDictionary *stationInformationDictionary = [accesswayArray objectAtIndex:0];
        NSArray* stationArray = [stationInformationDictionary objectForKey:@"stationInformation"];
        NSDictionary *currentStationDictionary = [stationArray objectAtIndex:0];
        */
        
        //Get information about the current station. In the actual app, there will be more stations. Information about the stations will have to processed before getting current station.
        self.currentStationDictionary = [[[[jsonDictionary objectForKey:@"accessway"] objectAtIndex:0] objectForKey:@"stationInformation"] objectAtIndex:0];
        
        self.allStationInformationArray = [[[jsonDictionary objectForKey:@"accessway"] objectAtIndex:0] objectForKey:@"stationInformation"];
        
        NSLog(@"accessway: %@", currentStationDictionary);
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occured: %@", [exception reason]);
    }
    @finally {
        NSLog(@"JSON object prepared properly");
    }
}

/*  Function to get the name of the station whose tag is detected for the first time
 PARAMETERS:NSString tagName: name of the tag that is detected
 RETURNS:NONE
 */
- (void) getStationName:(NSString*) tagName{
    NSString *stationName = @"Unknown";
    
    BOOL isBLECommonNameFound = FALSE;
    
    //Loop through all the stations whose information is available
    for (int i=0; i<self.allStationInformationArray.count && !(isBLECommonNameFound); i++) {
        //the current station is found
        if ([tagName isEqualToString:[self.currentStationDictionary objectForKey:@"bleCommonName"]]) {
            stationName=[currentStationDictionary objectForKey:@"name"];
            currentStation=stationName;//Set the currentStation
            isBLECommonNameFound=TRUE;
            //NSLog(@"ble common name found");
        }
    }
    
    [self.delegate didFindCurrentStation:self theStationName:stationName];//call delegate method
}

/*  Function to get the common BLE name of the tag
 PARAMETERS:NSString tagName: name of the tag that is detected
 RETURNS:NSMutableArray tagsInStationArray: all the tags in the station
 */
- (NSArray*) getUUIDofTagsInStation:(NSString*) tagLocalAdvertisementName{
    NSArray *UUIDofTagsInStationArray;
    
    BOOL isBLECommonNameFound = FALSE;
    
    //Loop through all the stations whose information is available
    for (int i=0; i<self.allStationInformationArray.count && !(isBLECommonNameFound); i++) {
        //the current station is found
        if ([tagLocalAdvertisementName isEqualToString:[self.currentStationDictionary objectForKey:@"bleCommonName"]]) {
            
            NSLog(@"bleCommonName found");
            
            NSArray *tagsInStationArray=[currentStationDictionary objectForKey:@"tagsInStation"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:0];//a temporary array
            
            //Create the UUID Array
            for (int i=0; i<tagsInStationArray.count; i++) {
                [tempArray addObject:[CBUUID UUIDWithString:[tagsInStationArray objectAtIndex:i]]];
            }
            
            UUIDofTagsInStationArray = [[NSArray alloc]initWithArray:tempArray];
            isBLECommonNameFound=TRUE;
        }
    }
    
    //NSLog(@"UUIDofTagsInStationArray %@",UUIDofTagsInStationArray);
    
    //If a match is found, retun array with UUID object else return an array with unknown
    if (UUIDofTagsInStationArray.count>0) {
        return UUIDofTagsInStationArray;
    }else{
        UUIDofTagsInStationArray = [[NSArray alloc]initWithObjects:@"unknown", nil];
        return UUIDofTagsInStationArray;
    }
    
}

/*Function to get location information based on tag service and current direction
 PARAMETERS:CBUUID serviceUUID: service UUID of the connected tag, NSString deviceDirection: the current device direction
 RETURNS:NONE
 */
- (void)getLocationInformationFromTagWithService:(CBUUID *)serviceUUID theDeviceDirection:(NSString *)deviceDirection{
    //NSLog(@"in getlocationinfo");
    NSString *locationInformation = @"unknown";
    NSString *selectedTagID = @"unknown";
    NSArray *tagsInStationArray=[currentStationDictionary objectForKey:@"tagsAvailable"];
    
    //Search for relevant information
    for (int i=0; i<tagsInStationArray.count; i++) {
        NSString *tagID = [[tagsInStationArray objectAtIndex:i] objectForKey:@"tagID"];
        //find match for serviceUUID
        if ([serviceUUID isEqual:[CBUUID UUIDWithString:tagID]]) {
            NSLog(@"tagID is %@",[[tagsInStationArray objectAtIndex:i] objectForKey:@"tagID"]);

            locationInformation = [[[[tagsInStationArray objectAtIndex:i]objectForKey:@"information"] objectAtIndex:0] objectForKey:deviceDirection];
            NSLog(@"loca info %@",locationInformation);
        }
    }
    
    [self.delegate didFindLocationInformation:self theLocationInformation:locationInformation theStationName:currentStation theTagID:selectedTagID];
}


/*Function to get complete route information based on nearest tag and end destination
 PARAMETERS:CBUUID serviceUUID: service UUID of the connected tag
 RETURNS:NONE
 */
/*- (void)getCompleteRouteInformationFromTagWithService:(CBUUID *)serviceUUID destination:(NSString *)destination{
    NSLog(@"in getlocationinfo");
    NSArray *completeRouteInformation;
    
    NSArray *routeInformationArray=[currentStationDictionary objectForKey:@"routeInformation"];
    
    //Search for relevant information
    for (int i=0; i<routeInformationArray.count; i++) {
        NSString *tagID = [[routeInformationArray objectAtIndex:i] objectForKey:@"tagID"];
        NSString *endPoint = [[routeInformationArray objectAtIndex:i] objectForKey:@"endPoint"];
        //find match for serviceUUID
        if ([serviceUUID isEqual:[CBUUID UUIDWithString:tagID]] && [endPoint isEqualToString:destination]) {
            
            completeRouteInformation = [[routeInformationArray objectAtIndex:i] objectForKey:@"completeInformation"];
            //NSLog(@"loca info %@",completeRouteInformation);
        }
    }
    
    [self.delegate didFindCompleteRouteInformation:self theRouteInformation:completeRouteInformation];
}*/

@end
