//
//  CoreLocationManager.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

#import <Foundation/Foundation.h>

//Importing all the headers required for CoreLocation
#import <CoreLocation/CoreLocation.h>

@interface CoreLocationManager : NSObject<CLLocationManagerDelegate>

+ (id)sharedCoreLocationManager;

// Things for CoreLocation
@property (nonatomic,retain) CLLocationManager *accesswayLocationManager;

// Things to keep track of device directions
@property (nonatomic,strong) NSString *deviceDirection;

@end
