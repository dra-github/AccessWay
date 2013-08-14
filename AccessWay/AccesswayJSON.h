//
//  AccesswayJSON.h
//  Accessway070713_Directions
//
//  Created by Rajan Ayakkad on 7/17/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

/* This class is used to get all the station details from the JSON object
 */

#import <Foundation/Foundation.h>

//Importing all the headers required for CoreBluetooth
#import <CoreBluetooth/CoreBluetooth.h>

@class AccesswayJSON;

@protocol AccesswayJSONDelegate <NSObject>
@optional
- (void)didFindCurrentStation:(AccesswayJSON *)controller theStationName:(NSString *)stationName;//A delegate method that informs the app that a station matching the BLE tag has been found
//- (void)didFindLocationInformation:(AccesswayJSON *)controller theLocationInformation:(NSString *)locationInformation;//A delegate method that informs the app that location information corresponding to the nearest tag has been found
- (void)didFindLocationInformation:(AccesswayJSON *)controller theLocationInformation:(NSString *)locationInformation theStationName:(NSString *)stationName theTagID:(NSString *)theSelectedTagID;//A delegate method that informs the app that location information corresponding to the nearest tag has been found along with the station Name and selected TagID
- (void)didFindCompleteRouteInformation:(AccesswayJSON *)controller theRouteInformation:(NSArray *)routeInformationArray;//A delegate method that informs the app that the complete route information from the nearest tag to the destination has been found
@end

@interface AccesswayJSON : NSObject

//Object for the delegate of this class
@property (nonatomic, weak) id <AccesswayJSONDelegate> delegate;

//Object for hold the data from the JSON object
@property(nonatomic,weak)NSDictionary *accesswayJSONDictionary;//might have to be deleted
@property(nonatomic,retain)NSDictionary *currentStationDictionary;//create a dictionary for the current station
@property(nonatomic,retain)NSArray *allStationInformationArray;//create a array for all the station information


//A function to prepare the JSON object when the app is launched. In this we are including the JSON file in the app itself. In the actual app, this will be downloaded from the server.
-(void)prepareJSON;

//Function to get the name of the station whose tag is detected for the first time
- (void) getStationName:(NSString*) tagName;

//Function to get all the tags in the station
- (NSArray *) getUUIDofTagsInStation:(NSString*) tagLocalAdvertisementName;

//Function to get location information based on tag service and current direction
- (void)getLocationInformationFromTagWithService:(CBUUID *)serviceUUID theDeviceDirection:(NSString *)deviceDirection;

//Function to get complete route information based on nearest tag and end destination
//- (void)getCompleteRouteInformationFromTagWithService:(CBUUID *)serviceUUID destination:(NSString *)destination;



@end
