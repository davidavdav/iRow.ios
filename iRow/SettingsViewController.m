//
//  SettingsViewController.m
//  iRow
//
//  Created by David van Leeuwen on 19-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//
// in this controller I declare the spcial accessoryviews statically, i.e., as ivars.  

#import "SettingsViewController.h"
#import "utilities.h"
// #import "ErgometerViewController.h"

#define kLogSensMin (0)
#define kLogSensMax (2)

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Settings";
        settings = Settings.sharedInstance;
        unitSystem = settings.unitSystem;
        logSensitivity = settings.logSensitivity;
        unitSystems = [NSArray arrayWithObjects:@"Metric", @"Imperial", nil];
        unitSystemTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];
        speedUnitTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];
        strokeViewSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        strokeViewSwitch.on = settings.showStrokeProfile;
        [strokeViewSwitch addTarget:self action:@selector(strokeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        trackingInBackgroundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        trackingInBackgroundSwitch.on = settings.backgroundTracking;
        [trackingInBackgroundSwitch addTarget:self action:@selector(trackBackgroundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        hundredHzSamplingSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        hundredHzSamplingSwitch.on = settings.hundredHzSampling;
        [hundredHzSamplingSwitch addTarget:self action:@selector(hundredHzSamplingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        autoOrientationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        autoOrientationSwitch.on = settings.autoOrientation;
        [autoOrientationSwitch addTarget:self action:@selector(autoOrientationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        autoSaveSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        autoSaveSwitch.on = settings.autoSave;
        [autoSaveSwitch addTarget:self action:@selector(autoSaveSwitchChanged:) forControlEvents:UIControlEventValueChanged];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
//    id delegate = [[UIApplication sharedApplication] delegate];
//    ErgometerViewController * e = [[[delegate tabBarController] viewControllers] objectAtIndex:0];
//    hundredHzSamplingSwitch.enabled = e.trackingState == kTrackingStateStopped;
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
        case 0:
            return @"Stroke Sensitivity";
            break;
        case 1:
            return @"Distances and speed";
            break;
        case 2:
            return @"Background updating";
            break;
        case 3:
            return @"Extra";
            break;
        default:
            break;
    }
    return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"A setting more to the right makes it more likely that a stroke is correctly picked up from the accelerometers"; 
            break;
        case 1:
            return @"The speed unit can also be changed by tapping the speed from the ergometer tab."; 
            break;
        case 3:
            return @"The following settings are experimental: The stroke profile is available from the 'inspect track' selection while browsing stored tracks.  You can see the acceleration profile for three consecutive strokes.  The 100Hz sampling sets the hardware acceleration sampling to 100Hz instead of 10 Hz, the samples are still recorded at 10Hz.  Auto orientation means that you do not need to position the iPhone along the leng direction.";
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    static int nsec[4] = {1, 2, 1, 4};
    return nsec[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifiers[] = { @"Slider", @"Cell"};
    NSString * CellIdentifier = CellIdentifiers[indexPath.section>0];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 0: {
//            cell.textLabel.text = nil;
//            cell.accessoryView = nil;
            UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width-40, cell.bounds.size.height)];
            slider.value = (logSensitivity - kLogSensMin) / (kLogSensMax - kLogSensMin);
            [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
            [slider addTarget:self action:@selector(sliderDone:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:slider];
            break;
        }
        case 1: {
            UIPickerView * pickerView = [[UIPickerView alloc] init];
            pickerView.tag = indexPath.row;
            pickerView.delegate = self;
            pickerView.dataSource = self;
            pickerView.showsSelectionIndicator = YES;
            switch (indexPath.row) {
                case 0: 
                    cell.textLabel.text = @"Unit system";
                    cell.accessoryView = unitSystemTextField;
                    unitSystemTextField.text = [unitSystems objectAtIndex:unitSystem];
                    unitSystemTextField.textAlignment = UITextAlignmentRight;
                    [pickerView selectRow:unitSystem inComponent:0 animated:YES];
                    unitSystemTextField.inputView = pickerView;
                    break;
                case 1: 
                    cell.textLabel.text = @"Speed unit";
                    cell.accessoryView = speedUnitTextField;
                    speedUnitTextField.text = dispSpeedUnit(settings.speedUnit, NO);
                    speedUnitTextField.textAlignment = UITextAlignmentRight;
                    [pickerView selectRow:settings.speedUnit inComponent:0 animated:YES];
                    speedUnitTextField.inputView = pickerView;
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            cell.textLabel.text = @"Track position while off";
            cell.accessoryView = trackingInBackgroundSwitch;
            break;
        }
            
        case 3: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Auto save tracks";
                    cell.accessoryView = autoSaveSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Stoke profile support";
                    cell.accessoryView = strokeViewSwitch;
                    break;
                case 2:
                    cell.textLabel.text = @"100Hz sampling";
                    cell.accessoryView = hundredHzSamplingSwitch;
                    break;
                case 3:
                    cell.textLabel.text = @"Auto orientation";
                    cell.accessoryView = autoOrientationSwitch;
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

-(void)unitsChanged:(NSNotification*)notification {
    NSLog(@"notification");
    // This doesn't work, it takes the keyboard down. 
//    [self.tableView reloadData];
    unitSystemTextField.text = [unitSystems objectAtIndex:settings.unitSystem];
    speedUnitTextField.text = dispSpeedUnit(settings.speedUnit, NO);
    [(UIPickerView*)speedUnitTextField.inputView reloadComponent:0];
    [(UIPickerView*)unitSystemTextField.inputView reloadComponent:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UI events

-(void)sliderChanged:(UISlider*)slider {
    logSensitivity = kLogSensMin + (kLogSensMax - kLogSensMin)*slider.value;
    self.title = [NSString stringWithFormat:@"%3.2f", strokeSensitivity(logSensitivity)];
    
}

-(void)sliderDone:(id)sender {
    settings.logSensitivity = logSensitivity;
    self.title = @"Settings";
}

-(void) strokeSwitchChanged:(id)sender {
    settings.showStrokeProfile = strokeViewSwitch.on;
}

-(void) trackBackgroundSwitchChanged:(id)sender {
    settings.backgroundTracking = trackingInBackgroundSwitch.on;
}

-(void) hundredHzSamplingSwitchChanged:(id)sender {
    settings.hundredHzSampling = hundredHzSamplingSwitch.on;
}


-(void)autoOrientationSwitchChanged:(id)sender {
    settings.autoOrientation = autoOrientationSwitch.on;
}

-(void)autoSaveSwitchChanged:(id)sender {
    settings.autoSave = autoSaveSwitch.on;
}

#pragma mark UIPickerViewDatasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2 + pickerView.tag;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 100*(1+pickerView.tag);
}

#pragma mark UIPickerViewDelegate

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSLog(@"%d %@", pickerView.tag, pickerView);
    switch (pickerView.tag) {
        case 0:
            return [unitSystems objectAtIndex:row];
            break;
        case 1:
            return dispSpeedUnit(row, NO);
            break;
        default:
            break;
    }
    return nil;
}

//
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
    switch (pickerView.tag) {
        case 0:
            unitSystemTextField.text = [unitSystems objectAtIndex:row];
            settings.unitSystem = row;
            if (settings.speedUnit==kSpeedDistanceUnitPerHour) speedUnitTextField.text = dispSpeedUnit(settings.speedUnit, NO);
            [(UIPickerView*)speedUnitTextField.inputView reloadComponent:0];
            break;
        case 1:
            speedUnitTextField.text = dispSpeedUnit(row, NO);
            settings.speedUnit = row;
            break;
        default:
            break;
    }
    
}

@end
