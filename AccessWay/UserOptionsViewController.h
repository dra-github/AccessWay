//
//  UserOptionsViewController.h
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/12/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import <UIKit/UIKit.h>

//ViewController that has all the main options for the user to interact with. This also does all the initial initializations

#import <UIKit/UIKit.h>

//Importing all the headers required for BLEManager
#import "BLEManager.h"

//Importing all the headers required for AudioToolbox
#import <AudioToolbox/AudioToolbox.h>

//Importing all the headers required for Audio
#import <AVFoundation/AVFoundation.h>

@interface UserOptionsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,AVAudioPlayerDelegate>

// Things for Audio
@property (strong, nonatomic) AVAudioPlayer *audioPlayerStart;

//UI for this ViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *bleInformationLabel;

@end
