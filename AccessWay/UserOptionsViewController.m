//
//  UserOptionsViewController.m
//  AccessWay
//
//  Created by Rajan Ayakkad on 8/12/13.
//  Copyright (c) 2013 Rajan Ayakkad. All rights reserved.
//

#import "UserOptionsViewController.h"

@interface UserOptionsViewController ()

@end

@implementation UserOptionsViewController
@synthesize audioPlayerStart;//sythesize all the things for sound
@synthesize tableView,bleInformationLabel;//synthesize all the things for the UI


//Object(s) for holding all the user options on this view
NSMutableArray *userOptionsArray;

//Objects for the device direction
NSString *deviceDirection;

//Objects for storing current station name
NSString *theCurrentStation=@"Unknown";

//Objects for storing current location information from the nearest BLE tag
NSString *theCurrentLocationInformation=@"Unknown";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //Initialize the array that holds all the user information
        userOptionsArray = [[NSMutableArray alloc]initWithObjects:@"Tell Me When The Next Train Arrives", @"Service Changes For This Station", @"Directions To Train - Disabled", @"Directions To The Exit - Disabled", nil];
        self.navigationItem.backBarButtonItem=nil;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton = YES;//hide the back button
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Initialize the sound
    NSURL* audioFile2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                pathForResource:@"beep-7"
                                                ofType:@"mp3"]];
    self.audioPlayerStart = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFile2 error:nil];
    self.audioPlayerStart.delegate=self;
    
    //Start scanning for BLE tags
    BLEManager *sharedBLEManager = [BLEManager sharedBLEManager];
    [sharedBLEManager setVoiceCommand:@"LOCATION INFORMATION"];//This uses voice commands similar to previous prototype. Can be replaced later.
    
    //Add NSNotification for checking for local information
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updatedLocationInformationNotification:)
                                                name:@"LocationInformationNotification"
                                              object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [userOptionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccesswayCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text=[userOptionsArray objectAtIndex:indexPath.row];
    
    //The third cell disabled if there are no beacons
    if (indexPath.row==2) {
        [cell setUserInteractionEnabled:NO];
    }
    
    //The fourth cell disabled if there are no beacons
    if (indexPath.row==3) {
        [cell setUserInteractionEnabled:NO];
    }

    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            //ROBIN'S CODE GOES HERE
            //Next train arrives
            break;
            
        case 1:
            //ROBIN'S CODE GOES HERE
            //Service changes
            break;
        
        case 2:
            //Directions to train
            
            break;
            
        case 3:
            //RAJAN'S CODE GOES HERE
            //Directions to Exit
            break;
            
        default:
            break;
    }
}

// A delegate method that gets the height to use for a row in a specified location.
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [userOptionsArray objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [self getSizeOfText:text withFont:font];
    
    return (size.height + 20); // I put some padding on it.
}*/

#pragma mark - Methods for this ViewController
/*Function to get the size of the text depending on the font
 PARAMETERS:NSString text, UIFont:font
 RETURNS:CGSize text: text with particular size
 */
/*- (CGSize)getSizeOfText:(NSString *)text withFont:(UIFont *)font
{
    return [text sizeWithFont:font constrainedToSize:CGSizeMake(280, 500)];
}*/

#pragma mark - Methods for all NSNotifications
//A method that gets called if there is local information available from the nearest BLE
- (void)updatedLocationInformationNotification:(NSNotification *)notification //use notification method and logic
{
    NSLog(@"in updatedLocationInformationNotification");
    NSDictionary *dictionary = [notification userInfo];
    theCurrentLocationInformation = [dictionary valueForKey:@"LocationInformationString"];
    theCurrentStation = [dictionary valueForKey:@"StationNameString"];
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    //Change the options available to the user (4 and 5) when beacons are found
    [userOptionsArray replaceObjectAtIndex:2 withObject:@"Directions To Train"];
    [userOptionsArray replaceObjectAtIndex:3 withObject:@"Directions To The Exit"];
    
    //Reload the table with the new options
    [self.tableView reloadData];
    
    //Enable clicking the of the 3 and 4 cells
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]setUserInteractionEnabled:YES];
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]setUserInteractionEnabled:YES];
    
    //Send notification to resume scanning
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeScanningNotification" object:nil userInfo:nil];
}


#pragma mark - performSelector methods
//Method to alert the user and update the information available
-(void)updateUI{
    self.bleInformationLabel.text=theCurrentLocationInformation;//Update information
    [audioPlayerStart play];//Playsound
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//Vibrate device
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
