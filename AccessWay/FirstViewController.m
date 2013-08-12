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
    
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Show the main user options when the user clicks on the "Tell me more about this station" button
    if([segue.identifier isEqualToString:@"userOptionsSegue"])
    {
        //UINavigationController *navigationController =segue.destinationViewController;
		//UserOptionsViewController *userOptionsViewController = [[navigationController viewControllers]objectAtIndex:0];
        UserOptionsViewController *userOptionsViewController = [segue destinationViewController];
        //UINavigationController *navigationController =segue.destinationViewController;
		//MainButtonsViewController *mainButtonsViewController = [[navigationController viewControllers]objectAtIndex:0];
        //mainButtonsViewController.delegate = self;
        
        
    }
    
}





@end
