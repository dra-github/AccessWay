//
//  MainButtonsViewController.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/11/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

//TableViewController that has all the main options for the user to interact with. This also does all the initial initializations

#import <UIKit/UIKit.h>

//Importing all the headers required for BLEManager
#import "BLEManager.h"

//Importing all the headers required for CoreLocationManager
#import "CoreLocationManager.h"

//Importing all the headers required for WiFiManager
#import "WiFiManager.h"

//Importing all the headers required for AudioToolbox
#import <AudioToolbox/AudioToolbox.h>

@interface MainButtonsViewController : UITableViewController<UIActionSheetDelegate>



@end
