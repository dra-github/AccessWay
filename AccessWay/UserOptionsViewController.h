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

@interface UserOptionsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

//UI for this ViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *bleInformationLabel;

@end
