//
//  FirstViewController.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/10/13.
//  Copyright (c) 2013 Rajan Ayakkad,Robin Chou, Kristin Loeb. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize deviceDirectionLabel;//sythesize things related to UI for this ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FirstViewController methods
-(IBAction)startButtonAction:(id)sender{
    BLEManager *sharedBLEManager = [BLEManager sharedBLEManager];//start scanning for BLE tags
    CoreLocationManager *sharedCoreLocationManager = [CoreLocationManager sharedCoreLocationManager];//start updating device direction
    [[NSNotificationCenter defaultCenter]addObserver:self
                                        selector:@selector(updatedHeadingNotification:)
                                        name:@"HeadingUpdated"
                                        object:nil];
}

#pragma mark - Methods for all NSNotifications
//A method that gets the current direction of the device when the heading changes are detected in CoreLocationManager
- (void)updatedHeadingNotification:(NSNotification *)notification //use notification method and logic
{
    NSString *key = @"HeadingStringValue";
    NSDictionary *dictionary = [notification userInfo];
    NSString *headingValueToUse = [dictionary valueForKey:key];
    self.deviceDirectionLabel.text = headingValueToUse;
}

@end
