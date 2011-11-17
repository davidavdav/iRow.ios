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
#import "BoatBrowserController.h"

enum {
    kSecDetail=0,
    kSecID,
    kSecStats,
    kSecRelations
};

enum {
    kTrackDate=0,
    kTrackDistance,
    kTrackTime,
    kTrackAveSpeed,
    kTrackStrokeFreq,
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
        NSFetchRequest * frq = [[NSFetchRequest alloc] init];
        [frq setEntity:[NSEntityDescription entityForName:@"Boat" inManagedObjectContext:settings.moc]];
        NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray * sds = [NSArray arrayWithObject:sd];
        [frq setSortDescriptors:sds];
        frcBoats = [[NSFetchedResultsController alloc] initWithFetchRequest:frq managedObjectContext:settings.moc sectionNameKeyPath:nil cacheName:nil];
        NSError * error;
        if (![frcBoats performFetch:&error]) {
            NSLog(@"Error fetching Course");
        };
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
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)] animated:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
    if (track == nil) {
        track = (Track*)[NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:settings.moc];
        if (trackData) {
            track.track = [NSKeyedArchiver archivedDataWithRootObject:trackData];
            track.distance = [NSNumber numberWithFloat:trackData.totalDistance];
            track.locality = trackData.locality;
            track.boat = settings.currentBoat;
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
        if (tf.tag<100) {
            tf.clearButtonMode = e ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
            tf.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
        }
    } 
}

-(void)setTitleToTrackName {
    self.title = defaultName(track.name, @"Track");
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
    [self setTitleToTrackName];
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
    return 4;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kSecID:
            return @"Identification";
            break;
        case kSecStats:
            return @"Statistics";
            break;
        case kSecRelations:
            return @"Composition";
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kSecDetail:
            return 1;
            break;
        case kSecID:
            return 2;
            break;
        case kSecStats:
            return kTrackStrokeFreq+1;
            break;
        case kSecRelations:
            return 2;
            break;
        default:
            break;
    };
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifiers[2] = {@"Cell", @"Editable"};
    
    int celltype = indexPath.section==kSecID || indexPath.section==kSecRelations;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifiers[celltype]];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifiers[celltype]];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case kSecDetail:
            cell.textLabel.text = @"Inspect track";
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
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
                    textField.placeholder = @"track name";
                    break;
                case 1:
                    cell.textLabel.text = @"Location";
                    textField.text = track.locality;
                    textField.placeholder = @"track location";
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
                default:
                    break;
            }
            break;
        case kSecRelations: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];   
            textField.delegate = self;
            textField.textAlignment = UITextAlignmentRight;
            textField.tag = 100+indexPath.row;
            textField.enabled = editing;
            textField.borderStyle = UITextBorderStyleNone;
            textField.clearButtonMode = UITextFieldViewModeNever;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"Boat";
                    textField.text = track.boat.name;
                    textField.placeholder = @"pick a boat";
                    UIPickerView * pickerView = [[UIPickerView alloc] init];
                    pickerView.showsSelectionIndicator = YES;
                    pickerView.delegate = self;
                    pickerView.dataSource = self;
                    NSInteger current = [frcBoats.fetchedObjects indexOfObject:track.boat];
                    if (current==NSNotFound) current=frcBoats.fetchedObjects.count; // unknown
                    [pickerView selectRow:current inComponent:0 animated:YES];
                    textField.inputView = pickerView;
                    boatTextView = textField; // for the picker to give a chance to rewrite the text
                    break;
                }
                case 1:
                    cell.textLabel.text = @"Rowers";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",track.rowers.count];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
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
    switch (indexPath.section) {
        case kSecDetail: {
            InspectTrackViewController * itvc = [[InspectTrackViewController alloc] init];
            itvc.track = track;
            [self.navigationController pushViewController:itvc animated:YES];
            break;
        }
/*        case kSecRelations: 
            switch (indexPath.row) {
                case 0: {
                    BoatBrowserController * bbc = [[BoatBrowserController alloc] initWithStyle:UITableViewStylePlain];
                    break;
                }
                default:
                    break;
            } */
        default:
            break;
    }
}

#pragma mark UITextFieldDelegte

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
            [self setTitleToTrackName];
            break;
        case 1:
            track.locality = textField.text;
            break;
        default:
            break;
    }
}

#pragma mark UIPickerViewDelegate

// we encode row = #boats for "unknown" option.

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row>=frcBoats.fetchedObjects.count) return @"unknown";
    return [[frcBoats.fetchedObjects objectAtIndex:row] name];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    track.boat = (row<frcBoats.fetchedObjects.count) ? [frcBoats.fetchedObjects objectAtIndex:row] : nil;    
    boatTextView.text = track.boat.name;
}

#pragma mark UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return frcBoats.fetchedObjects.count+1;
}

@end
