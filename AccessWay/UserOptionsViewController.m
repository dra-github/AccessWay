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
@synthesize tableView,bleInformationLabel;//synthesize all the things for the UI


//Object(s) for holding all the user options on this view
NSMutableArray *userOptionsArray;

//Objects for the device direction
NSString *deviceDirection;

//Things for checking BLE Tags availability
bool areBLETagsAvailable = FALSE;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //Initialize the array that holds all the user information
        userOptionsArray = [[NSMutableArray alloc]initWithObjects:@"Tell Me When The Next Train Arrives", @"Service Changes For This Station", @"Directions To A Train - Disabled", @"Directions To The Exit - Disabled", nil];
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Check for internet connection. ROBIN's CODE TO CHECK FOR WIFI/CELLULAR CONNECTION
    WiFiManager *sharedWifiManager = [WiFiManager sharedWiFiManager];
    
    //Start scanning for BLE tags
    BLEManager *sharedBLEManager = [BLEManager sharedBLEManager];
    [sharedBLEManager setVoiceCommand:@"CURRENT STATION"];//This uses voice commands similar to previous prototype. Can be replaced later.
    
    //Start updating device direction
    CoreLocationManager *sharedCoreLocationManager = [CoreLocationManager sharedCoreLocationManager];
    
    //Add NSNotification for checking the internet connection
    //NEED TO FIX LATER
    /*[[NSNotificationCenter defaultCenter]addObserver:self
     selector:@selector(updatedInternetConnectionNotification:)
     name:@"InternetAvailabilityNotification"
     object:nil];
     */
    
    //Add NSNotification for checking the device direction
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updatedHeadingNotification:)
                                                name:@"HeadingUpdatedNotification"
                                              object:nil];
    
    
    
    //Add NSNotification for checking the device direction
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updatedBLEAvailableNotification:)
                                                name:@"BLETagAvailabilityTagNotification"
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text=[userOptionsArray objectAtIndex:indexPath.row];
    
    //The third cell disabled if there are no beacons
    if (indexPath.row==2 && !areBLETagsAvailable) {
        [cell setUserInteractionEnabled:NO];
    }
    
    //The fourth cell disabled if there are no beacons
    if (indexPath.row==3 && !areBLETagsAvailable) {
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
            //RAJAN'S CODE GOES HERE
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
//A method that checks whether there is an internet connection available
//NEED TO FIX LATER
- (void)updatedInternetConnectionNotification:(NSNotification *)notification //use notification method and logic
{
    NSLog(@"in updatedInternetConnectionNotification");
    NSDictionary *dictionary1 = [notification userInfo];
    NSString *temp = [dictionary1 valueForKey:@"InternetStatusString"];
}

//A method that gets the current direction of the device when the heading changes are detected in CoreLocationManager
- (void)updatedHeadingNotification:(NSNotification *)notification //use notification method and logic
{
    NSLog(@"in updatedHeadingNotification");
    NSDictionary *dictionary = [notification userInfo];
    deviceDirection = [dictionary valueForKey:@"HeadingStringValue"];
    
}


//A method that checks if there is any BLE Tags in the vicinity
- (void)updatedBLEAvailableNotification:(NSNotification *)notification //use notification method and logic
{
    NSLog(@"in updatedBLEAvailableNotification");
    NSDictionary *dictionary = [notification userInfo];
    NSString *bleIsAvailable = [dictionary valueForKey:@"BLEAvailabilityTagStringValue"];
    NSString *theStationName = [dictionary valueForKey:@"stationNameStringValue"];
    
    //If a valid BLE tag is found, show a UI Action Sheet
    if ([bleIsAvailable isEqualToString:@"YES"]) {
        NSLog(@"ble available");
        
        areBLETagsAvailable=TRUE;//ble tags are available
        
        //Change the options available to the user (4 and 5) when beacons are found
        [userOptionsArray replaceObjectAtIndex:2 withObject:@"Directions To A Train"];
        [userOptionsArray replaceObjectAtIndex:3 withObject:@"Directions To The Exit"];
        
        //Update Information
        self.bleInformationLabel.text=theStationName;
        
        //Reload the table with the new options
        [self.tableView reloadData];
        
        //Enable clicking the of the 3 and 4 cells
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]setUserInteractionEnabled:YES];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]setUserInteractionEnabled:YES];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Accessway Beacon Found"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ignore"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Tell Me What It Says", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark - UIActionSheet Methods
// A method sent to the delegate after an action sheet is presented to the user.
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet{
    //Vibrate the phone
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

// A method sent to the delegate when the user clicks a button on an action sheet.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    //Handle action for the case - Tell Me What It Says
    if  ([buttonTitle isEqualToString:@"Tell Me What It Says"]) {
        //Show the data of the nearest BLE
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
