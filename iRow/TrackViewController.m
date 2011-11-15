//
//  TrackViewController.m
//  iRow
//
//  Created by David van Leeuwen on 13-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "TrackViewController.h"
#import "utilities.h"
#import "RelativeDate.h"
#import "iRowAppDelegate.h"
#import "InspectTrackViewController.h"

enum {
    kSecID=0,
    kSecStats
};

enum {
    kTrackDate=0,
    kTrackDistance,
    kTrackTime,
    kTrackAveSpeed,
    kTrackStrokeFreq,
    kInspectTrack
}; 

@implementation TrackViewController

@synthesize track;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Track";
        settings = Settings.sharedInstance;
        iRowAppDelegate * delegate = (iRowAppDelegate*)[[UIApplication sharedApplication] delegate];        
        evc = (ErgometerViewController*)[delegate.tabBarController.viewControllers objectAtIndex:0];
        unitSystem = evc.unitSystem;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)editPressed:(id)sender {
    leftBarItem = self.navigationController.navigationItem.leftBarButtonItem;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)] animated:YES];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
    if (track == nil) {
        track = (Track*)[NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:settings.moc];
        if (trackData) {
            track.track = [NSKeyedArchiver archivedDataWithRootObject:trackData];
            track.distance = [NSNumber numberWithFloat:trackData.totalDistance];
        }
        if (evc.stroke) track.strokes = [NSNumber numberWithInt:evc.stroke.strokes];
    } 
    self.editing = YES;
}

-(void)restoreButtons {
    [self.navigationItem setLeftBarButtonItem:leftBarItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)] animated:YES];  
    self.editing = NO;
}

-(void)cancelPressed:(id)sender {
    [self restoreButtons];
    [settings.moc rollback];
    [self.tableView reloadData]; // restore old values
}

-(void)savePressed:(id)sender {
    [self restoreButtons];
    NSError * error;
    if (![settings.moc save:&error]) {
        NSLog(@"Error saving changes)");
        //        if (completionBlock != nil) completionBlock(nil);
    } else {
        //        NSLog(@"course saved %@", currentCourse);
        //        if (completionBlock != nil) completionBlock(rower);
    }
    //    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setEditing:(BOOL)e {
    editing = e;
    for (UITableViewCell * c in self.tableView.visibleCells) {
        UITextField * tf = (UITextField*)c.accessoryView;
        tf.enabled = e;
        tf.clearButtonMode = e ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
        tf.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
    } 
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (track==nil) { 
        trackData = evc.tracker.track;
        [self editPressed:self]; // prepare to save this track, create a new instance of track
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];    
        trackData = [NSKeyedUnarchiver unarchiveObjectWithData:track.track];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = track.name ? track.name : @"Track";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Identification";
            break;
        case 1:
            return @"Statistics";
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return kInspectTrack+1;
        default:
            break;
    };
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case kSecID: {
            UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];   
            textField.delegate = self;
            textField.textAlignment = UITextAlignmentRight;
            textField.tag = indexPath.row;
            textField.enabled = editing;
            textField.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.clearButtonMode = editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name";
                    textField.text = track.name;
                    break;
                case 1:
                    cell.textLabel.text = @"Location";
                    textField.text = track.locality;
                    break;
                default:
                    break;
            }
            break;
        }
        case kSecStats:
            switch (indexPath.row) {
                case kTrackDate:
                    cell.textLabel.text = @"Date";
                    cell.detailTextLabel.text = [trackData.startLocation.timestamp relativeDate];
                    break;
                case kTrackDistance:
                    cell.textLabel.text = @"Distance";
                    cell.detailTextLabel.text = dispLength(trackData.totalDistance);
                    break;
                case kTrackTime:
                    cell.textLabel.text = @"Time";
                    cell.detailTextLabel.text = hms(trackData.totalTime);
                    break;
                case kTrackAveSpeed:
                    cell.textLabel.text = @"Average speed";
                    cell.detailTextLabel.text = dispSpeed(trackData.averageSpeed, unitSystem);
                    break;
                case kTrackStrokeFreq:
                    cell.textLabel.text = @"Average stroke frequency";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%3.1f",60*track.strokes.intValue/trackData.totalTime];
                    break;
                 case kInspectTrack:
                    cell.textLabel.text = @"Inspect track";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    // Configure the cell...
    
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    if (indexPath.section==1 && indexPath.row==kInspectTrack) {
        InspectTrackViewController * itvc = [[InspectTrackViewController alloc] init];
        itvc.track = track;
        [self.navigationController pushViewController:itvc animated:YES];
    }
}

// this make return remove the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"ended editing %d", textField.tag);
    switch (textField.tag) {
        case 0:
            track.name = textField.text;
            self.title = track.name ? track.name : @"Track";
            break;
        case 1:
            track.locality = textField.text;
            break;
        default:
            break;
    }
}



@end
