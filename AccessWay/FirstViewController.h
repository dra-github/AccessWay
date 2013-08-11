//
//  FirstViewController.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

//ViewController that displays inital screen and checks for wi-fi and bluetooth connection

#import <UIKit/UIKit.h>

//Importing all the headers required for BLEManager
#import "BLEManager.h"

//Importing all the headers required for CoreLocationManager
#import "CoreLocationManager.h"

@interface FirstViewController : UIViewController

// UI actions required for interacting with this ViewController.
- (IBAction)startButtonAction:(id)sender;
//- (IBAction)stopButtonAction:(id)sender;

// Things related to UI in this ViewController
@property (weak, nonatomic) IBOutlet UILabel *deviceDirectionLabel;

@end
