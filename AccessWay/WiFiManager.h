//
//  WiFiManager.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/11/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

// Singleton class for checking the WiFi connection

//NEED TO FIX LATER

#import <Foundation/Foundation.h>

@interface WiFiManager : NSObject

+ (id)sharedWiFiManager;

// Methods for checking whether internet conenction is available
- (void)checkForInternetConnection;

// Things to keep track of internet connection
@property (nonatomic,retain) NSString *isConnectionAvailable;

@end
