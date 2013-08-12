//
//  WiFiManager.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/11/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

#import "WiFiManager.h"

@implementation WiFiManager

@synthesize isConnectionAvailable;//synthesize things to keep track of internet connection

// Setup the dispatch queues
dispatch_queue_t backgroundQueueWiFi;//for WiFi/Cellular Internet

#pragma mark Singleton Methods

+ (id)sharedWiFiManager {
    static WiFiManager *sharedMyWiFiManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyWiFiManager = [[self alloc] init];
    });
    return sharedMyWiFiManager;
}

- (id)init {
    if (self = [super init]) {
        //backgroundQueueWiFi = dispatch_queue_create("com.ard.wifi", NULL);//Create queue for CoreLocation
        //dispatch_sync(backgroundQueueWiFi, ^{
            [self checkForInternetConnection];
        //});
    }
    return self;
}

#pragma mark - Class Methods
//Method to check whether internet connection is available
-(void)checkForInternetConnection{
    NSLog(@"in checkForInternetConnection");
    //NSURL *scriptUrl = [NSURL URLWithString:@"www.google.com/m"];
    //NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    
    
    /*if (data){
        NSLog(@"in yes");
        isConnectionAvailable=@"YES";
        //Add notification when there is internet connection
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:isConnectionAvailable forKey:@"InternetStatusString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"internetAvailabilityNotification" object:nil userInfo:dictionary];
    }
    else{
        NSLog(@"in no");
        isConnectionAvailable=@"NO";
        //Add notification when there is no internet connection
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:isConnectionAvailable forKey:@"InternetStatusString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"internetAvailabilityNotification" object:nil userInfo:dictionary];
        
    }*/
}


@end
