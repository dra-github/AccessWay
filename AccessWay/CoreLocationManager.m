//
//  CoreLocationManager.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import "CoreLocationManager.h"

@implementation CoreLocationManager

@synthesize accesswayLocationManager;//sythesize things for CoreLocation
@synthesize deviceDirection;//sythesize things for device direction

// Setup the dispatch queues
dispatch_queue_t backgroundQueueCoreLocation;//for CoreLocation

#pragma mark Singleton Methods

+ (id)sharedCoreLocationManager {
    static CoreLocationManager *sharedMyCoreLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyCoreLocationManager = [[self alloc] init];
    });
    return sharedMyCoreLocationManager;
}

- (id)init {
    if (self = [super init]) {
        //Initialize all things required for CoreLocation and run it in the background
        accesswayLocationManager=[[CLLocationManager alloc] init];
        accesswayLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        accesswayLocationManager.headingFilter = 1;
        accesswayLocationManager.delegate=self;
        backgroundQueueCoreLocation = dispatch_queue_create("com.ard.coreLocation", NULL);//Create queue for CoreLocation
        dispatch_async(backgroundQueueCoreLocation, ^{
            [accesswayLocationManager startUpdatingHeading];
        });
    }
    return self;
}

#pragma mark - CoreLocation Delegate Methods
//A delegate method that tells the delegate that the location manager received updated heading information.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    [manager dismissHeadingCalibrationDisplay];//dismiss the figure 8 overlay
    
	//Set the direction in which the device is pointing
    if(newHeading.trueHeading>315 || newHeading.trueHeading<=45)
        deviceDirection=@"North";
    if(newHeading.trueHeading>45 && newHeading.trueHeading<=135)
        deviceDirection=@"East";
    if(newHeading.trueHeading>135 && newHeading.trueHeading<=225)
        deviceDirection=@"South";
    if(newHeading.trueHeading>225 && newHeading.trueHeading<=315)
        deviceDirection=@"West";
    
    //Add notification when the heading is updated
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:deviceDirection forKey:@"HeadingStringValue"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeadingUpdatedNotification" object:nil userInfo:dictionary];
}

//A delegate method that asks the delegate whether the heading calibration alert should be displayed.
-(BOOL)locationManagerShouldDisplayHeadingCalibration : (CLLocationManager *)manager {
    
    //The direction of the compass is not available
    
    deviceDirection=@"Unknown";//set device direction to unknown to give general information
    
    return YES;
}


@end
