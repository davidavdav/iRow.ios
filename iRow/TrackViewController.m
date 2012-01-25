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
#import "SelectRowerViewController.h"

enum {
    kSecDetail=0,
    kSecID,
    kSecStats,
    kSecRelations
};

enum {
    kTrackDistance=0,
    kTrackTime,
    kTrackAveSpeed,
    kSlider,
    kTrackStrokeFreq,
    kTrackDate,
    kTotalMass,
    kTotalPower,
}; 

// range of min speed slider, in m/s
#define kMinSpeed (0)
#define kMaxSpeed (24.0/3.6)

@implementation TrackViewController

@synthesize track;
@synthesize distanceLabel, timeLabel, aveStrokeFreqLabel, aveSpeedLabel, minSpeedLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Track";
        settings = Settings.sharedInstance;
        iRowAppDelegate * delegate = (iRowAppDelegate*)[[UIApplication sharedApplication] delegate];        
        evc = (ErgometerViewController*)[delegate.tabBarController.viewControllers objectAtIndex:0];
        frcBoats = fetchedResultController(@"Boat", @"name", YES, settings.moc);
        frcRowers = fetchedResultController(@"Rower", @"name", YES, settings.moc);
        minSpeed = settings.minSpeed;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitsChanged:) name:@"unitsChanged" object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unitsChanged" object:nil];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setRightBarButtons:(BOOL)edit {
/*
 if ([self.navigationItem respondsToSelector:@selector(setRightBarButtonItems:animated:)]) {
        UIBarButtonItem * actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPressed:)];
        if (edit)
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)],actionItem,nil] animated:YES];
        else
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)],actionItem,nil] animated:YES];
    } else {
 */ 
    if (edit) 
            [self.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)] animated:YES];
        else
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
//    }
}

/*
-(void)actionPressed:(id)sender {
    slider.hidden = !slider.hidden;
}
*/
 
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
            track.name = [trackData.startLocation.timestamp mediumshortDateTime];
        }
        if (evc.stroke) {
            track.strokes = [NSNumber numberWithInt:evc.stroke.strokes];
            track.motion = [NSKeyedArchiver archivedDataWithRootObject:evc.stroke];
        }
        track.boat = settings.currentBoat;
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
        if ([c.accessoryView isKindOfClass:[UITextField class]]) {
            UITextField * tf = (UITextField*)c.accessoryView;
            if (tf!=nil) {
                tf.enabled = e;
                if (tf.tag<100) // not for boat...
                    tf.clearButtonMode = e ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
                tf.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
            }
        }
        if (c == rowersCell) {
            c.detailTextLabel.backgroundColor = [UIColor whiteColor];
        }
    }
    NSMutableIndexSet * is = [NSMutableIndexSet indexSetWithIndex:kSecDetail];
    [is addIndex:kSecStats];
    [self.tableView reloadSections:is withRowAnimation:UITableViewRowAnimationTop];
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
        stroke = evc.stroke;
        [self editPressed:self]; // prepare to save this track, create a new instance of track
    } else {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];    
        [self setRightBarButtons:YES];
        trackData = [NSKeyedUnarchiver unarchiveObjectWithData:track.track];
        stroke = [NSKeyedUnarchiver unarchiveObjectWithData:track.motion];
    }
    trackData.minSpeed = minSpeed;
    [self setTitleToTrackName];
 /*
    CGRect f = self.tableView.bounds;
    UIView * sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height - 120, f.size.width, 40)];
    slider = [[UISlider alloc] initWithFrame:sliderView.bounds];
    slider.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [sliderView addSubview:slider];
    [self.tableView.superview addSubview:sliderView];
    slider.hidden = NO;
 */
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
            return 1 * (1-editing);
            break;
        case kSecID:
            return 2;
            break;
        case kSecStats:
            return 8 * (1-editing);
            break;
        case kSecRelations:
            return 3;
            break;
        default:
            break;
    };
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifiers[4] = {@"Cell", @"Editable", @"Sliding", @"Updateable"};
    
    int celltype = indexPath.section==kSecID || (indexPath.section==kSecRelations && indexPath.row == 0);
    if (indexPath.section == kSecStats && indexPath.row == kSlider) celltype = 2;
    if (indexPath.section == kSecStats && indexPath.row < kSlider) celltype = 3;
    
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
                    cell.detailTextLabel.text = dispLength(trackData.totalRowingDistance);
                    self.distanceLabel = cell.detailTextLabel;
                    break;
                case kTrackTime:
                    cell.textLabel.text = @"Time";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ m:s",hms(trackData.rowingTime)];
                    self.timeLabel = cell.detailTextLabel;
                    break;
                case kTrackAveSpeed:
                    cell.textLabel.text = @"Average speed";
                    cell.detailTextLabel.text = dispSpeed(trackData.averageRowingSpeed, settings.speedUnit, NO);
                    self.aveSpeedLabel = cell.detailTextLabel;
                    break;
                case kTrackStrokeFreq:
                    cell.textLabel.text = @"Average stroke freq.";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%3.1f s/m",60*track.strokes.intValue/trackData.totalTime];
                    self.aveStrokeFreqLabel = cell.detailTextLabel;
                    break;
                case kTotalMass: {
                    float mass = 0;
                    for (Rower * r in track.rowers) mass += r.mass.floatValue;
                    mass += track.coxswain.mass.floatValue + track.boat.mass.floatValue;
                    cell.textLabel.text = @"Total mass in boat";
                    cell.detailTextLabel.text = dispMass([NSNumber numberWithFloat:mass], YES);
                    break;
                }
                case kTotalPower: {
                    float power = 0;
                    for (Rower * r in track.rowers) power += r.power.floatValue;
                    cell.textLabel.text = @"Total power at oars";
                    cell.detailTextLabel.text = dispPower([NSNumber numberWithFloat:power]);
                    break;
                }
                case kSlider: {
                    UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//                    slider.value = log(minSpeed/kMinSpeed) / log(kMaxSpeed/kMinSpeed);
                    slider.value = (minSpeed-kMinSpeed) / (kMaxSpeed-kMinSpeed);
                    cell.accessoryView = slider;
                    cell.textLabel.text = @"min";
                    cell.detailTextLabel.text = dispSpeedOnly(minSpeed, settings.speedUnit);
                    self.minSpeedLabel = cell.detailTextLabel;
                    [slider addTarget:self action:@selector(minSpeedChanged:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(minSpeedReleased:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                }
                default:
                    break;
            }
            break;
        case kSecRelations: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"Boat";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];   
                    textField.delegate = self;
                    textField.textAlignment = UITextAlignmentRight;
                    textField.tag = 100+indexPath.row;
                    textField.enabled = editing;
                    textField.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
                    textField.clearButtonMode = UITextFieldViewModeNever;
                    cell.accessoryView = textField;
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
                case 1: {
                    cell.textLabel.text = @"Rowers";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",track.rowers.count];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    rowersCell = cell;
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Coxswain";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.detailTextLabel.text = defaultName(track.coxswain.name, @"none");
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    break;
                }                    
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


-(void)minSpeedChanged:(id)sender {
    UISlider * s = (UISlider*)sender;
    // return kMaxStrokeSens * pow(kMinStrokeSens/kMaxStrokeSens,logSensitivity/kLogSensRange);
//    minSpeed = kMinSpeed * pow(kMaxSpeed/kMinSpeed, s.value);
//    if (minSpeed < 1.1 * kMinSpeed) minSpeed = 0;
    minSpeed = kMinSpeed + s.value * (kMaxSpeed - kMinSpeed);
    trackData.minSpeed = minSpeed;
    distanceLabel.text = dispLength(trackData.totalRowingDistance);
    minSpeedLabel.text = dispSpeedOnly(minSpeed, settings.speedUnit);
    timeLabel.text = [NSString stringWithFormat:@"%@ m:s",hms(trackData.rowingTime)];
    aveSpeedLabel.text = dispSpeed(trackData.averageRowingSpeed, settings.speedUnit, NO);
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSecStats] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)minSpeedReleased:(id)sender {
    settings.minSpeed = minSpeed;
}

-(void)unitsChanged:(NSNotification*)notification {
    aveSpeedLabel.text = dispSpeed(trackData.averageRowingSpeed, settings.speedUnit, NO);
    minSpeedLabel.text = dispSpeedOnly(minSpeed, settings.speedUnit);
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
            if (trackData.count<2) break;
            InspectTrackViewController * itvc = [[InspectTrackViewController alloc] init];
            itvc.trackData = trackData;
            itvc.stroke = stroke;
            itvc.title = (track.name == nil || [track.name isEqualToString:@""]) ? @"Track details" : [NSString stringWithFormat:@"Details for %@",track.name];
            [self.navigationController pushViewController:itvc animated:YES];
            break;
        }
/*        case kSecStats:
            switch (indexPath.row) {
                case 1: {
//                    sliding = YES;
                    [self.tableView reloadData];
                    break;
                }
                default:
                    break;
            }
            break;
 */        case kSecRelations: 
            switch (indexPath.row) {
                case 2: if (!editing) break; 
                case 1: {
                    SelectRowerViewController * srvc = [[SelectRowerViewController alloc] initWithStyle:UITableViewStylePlain];
                    if (editing) {
                        srvc.rowers = frcRowers.fetchedObjects;
                        if (indexPath.row==1) 
                            srvc.selected = [NSMutableSet setWithSet:track.rowers];
                        else
                            [srvc setCoxswain:track.coxswain];
                    } else {
                        NSSortDescriptor * sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                        srvc.rowers = [track.rowers sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
                    }
                    srvc.editing = editing;
                    srvc.delegate = self;
                    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:srvc];
                    [self.navigationController presentModalViewController:nav animated:YES];
                    break;
                }
                default:
                    break;
            } 
        default:
            break;
    }
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (sliding && indexPath.section == kSecStats && indexPath.row==1) 
        return 80;
    else 
        return 40;
}
*/
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

#pragma mark SelectRowerViewControllerDelegate

-(void)selectedRowers:(NSSet *)rowers {
    track.rowers = rowers;
    [self.tableView reloadData];
}

-(void)selectedCoxswain:(Rower *)rower {
    track.coxswain = rower;
    [self.tableView reloadData];
}

@end
