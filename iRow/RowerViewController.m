//
//  OperatorViewController.m
//  iSTI
//
//  Created by David van Leeuwen on 09-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "RowerViewController.h"
#import "utilities.h"

@implementation RowerViewController

@synthesize rower;

#pragma mark - 

-(void)editPressed:(id)sender {
    leftBarItem = self.navigationController.navigationItem.leftBarButtonItem;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)] animated:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
    if (rower == nil) {
        rower = (Rower*)[NSEntityDescription insertNewObjectForEntityForName:@"Rower" inManagedObjectContext:settings.moc];
    } 
    self.editing = YES;
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Rower information";
        settings = [Settings sharedInstance];
        fields = [NSArray arrayWithObjects:@"Name", @"Weight (kg)", @"Age (year)", @"Email Address",@"Power (Watt)",nil];
//        if (rower==nil) [self editPressed:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    }
    return self;
}

-(void)setRower:(Rower *)r completion:(newObjectMade)block {
    rower=r;
    completionBlock = block;
}

-(void)restoreButtons {
    [self.navigationItem setLeftBarButtonItem:leftBarItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)] animated:YES];  
    self.editing = NO;
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
}

-(void)cancelPressed:(id)sender {
    [self restoreButtons];
    if (rowerChosen) 
            self.rower=nil; // this is the time to cancel the rower info
    else 
        [settings.moc rollback];
    [self.tableView reloadData]; // restore old values
}

-(void)savePressed:(id)sender {
//    NSLog(@"rower now %@", rower);
    [self restoreButtons];
    NSError * error;
    if (![settings.moc save:&error]) {
        NSLog(@"Error saving changes)");
        if (completionBlock != nil) completionBlock(nil);
    } else {
        if (completionBlock != nil) completionBlock(rower);
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

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"will disappear");
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1 + editing;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section==0) return @"The power is the 2km average power that you can produce on an indoor rower.";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	static int nrows[] = {5,2};
    return nrows[section];
}

-(NSInteger)ageFromDate:(NSDate*) date {
    NSDateComponents * dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
    return dc.year;
}

-(NSString*)massAsString {
    return rower.mass ? [NSString stringWithFormat:@"%3.1f", rower.mass.floatValue] : nil;
}

-(NSString*)powerAsString {
    return rower.power ? [NSString stringWithFormat:@"%1.0f",rower.power.floatValue] : nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
		case 0: {
			cell.textLabel.text = [fields objectAtIndex:indexPath.row];
            cell.selectionStyle= UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
//            UILabel * textAndUnit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];
            UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];   
            textField.delegate = self;
            textField.textAlignment = UITextAlignmentRight; 
            textField.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
            textField.tag = indexPath.row;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.clearButtonMode = editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
            textField.enabled = editing;
            cell.accessoryView = textField;
			switch (indexPath.row) {
				case 0:
					textField.text = rower.name;
                    textField.keyboardType = UIKeyboardTypeASCIICapable;
					break;
				case 1:
					textField.text = [self massAsString];
					textField.keyboardType = UIKeyboardTypeDecimalPad;
                    break;
				case 3:
					textField.text = rower.email;
                    textField.keyboardType = UIKeyboardTypeEmailAddress;
                    break;
                case 2: {
                    if (rower.birthDate != nil) {
//                        NSLog(@"setting");
                        textField.text = [NSString stringWithFormat:@"%d",[self ageFromDate:rower.birthDate]];
                    } else 
                        textField.text = nil;
                    UIDatePicker * dp = [[UIDatePicker alloc] initWithFrame:CGRectZero];
                    dp.datePickerMode = UIDatePickerModeDate;
                    dp.maximumDate = [NSDate date];
                    [dp addTarget:self action:@selector(inspectDate:) forControlEvents:UIControlEventValueChanged];
                    textField.inputView = dp;
                    UILabel * l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                    l.text = @"Select birthday below";
                    l.textAlignment = UITextAlignmentCenter;
                    l.backgroundColor = [UIColor groupTableViewBackgroundColor];
                    textField.inputAccessoryView = l;
                    ageTextField = textField;
                    break;
                }
                case 4:
                    textField.text = [self powerAsString];
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    break;
				default:
					break;
			}
			break;
        }
		case 1: 
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Choose from addressbook";
                    cell.detailTextLabel.text = @""; // lazy
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                    cell.textLabel.text = @"Choose existing rower";
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    cell.textLabel.text = @"Clear this entry";
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                default:
                    break;
            }
					default:
			break;
	}
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// nice animation if we know the birthDate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag==2 && rower.birthDate != nil) {
        NSLog(@"Setting date cylinders");
        [(UIDatePicker*)textField.inputView setDate:rower.birthDate animated:YES];
    }
}

// These two methods allow the clear button to encode "unknown birthday" (today)
- (BOOL) textFieldShouldClear:(UITextField *)textField{
    if (textField.tag == 2) {
        [(UIDatePicker*)textField.inputView setDate:[NSDate date] animated:YES];
        rower.birthDate = nil;
        NSLog(@"Clearing birthDate");
    }
    return YES;
}

-(void)inspectDate:(id)sender {
    UIDatePicker * dp = (UIDatePicker*)sender;
    NSInteger age = [self ageFromDate:dp.date];
    if (age==0) {
        rower.birthDate = nil;
        ageTextField.text = nil;
    } else {
        rower.birthDate = dp.date;
        ageTextField.text = [NSString stringWithFormat:@"%d",age];
    }
}

// return nil, or a proper NSNumber
-(NSNumber*)numberFromString:(NSString*) s {
    if (s==nil || [s isEqualToString:@""]) return nil;
    return [NSNumber numberWithFloat:s.floatValue];
}

#pragma mark -
#pragma mark UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"ended editing %d", textField.tag);
    switch (textField.tag) {
        case 0:
            rower.name = textField.text;
            break;
        case 1:
            rower.mass = [self numberFromString:textField.text];
            textField.text = [self massAsString];
            break;
        case 2: 
            [self inspectDate:textField.inputView];
            break;
        case 3:
            rower.email = textField.text;
            break;
        case 4:
            rower.power = [self numberFromString:textField.text];
            textField.text = [self powerAsString];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	switch (indexPath.section) {
		case 0:
            
			break;
		case 1:
            switch (indexPath.row) {
                case 0: {
                    ABPeoplePickerNavigationController * ppnc = [[ABPeoplePickerNavigationController alloc] init];
                    ppnc.peoplePickerDelegate = self;
                    [ppnc setDisplayedProperties:[NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonFirstNameProperty],[NSNumber numberWithInt:kABPersonLastNameProperty],[NSNumber numberWithInt:kABPersonEmailProperty],nil]];	
                    [self presentModalViewController:ppnc animated:YES];
                    break;
                }
                case 1: {
                    SelectRowerViewController * srvc = [[SelectRowerViewController alloc] initWithStyle:UITableViewStylePlain];
                    NSFetchedResultsController * frc = fetchedResultController(@"Rower", @"name", YES, settings.moc);
                    srvc.rowers = frc.fetchedObjects;
                    srvc.editing = YES;
                    srvc.multiple = NO;
                    srvc.delegate = self;
                    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:srvc];
                    [self.navigationController presentModalViewController:nav animated:YES];
                    break;
                }
                default:
                    break;
            }
			;
			// this navigation controllew won't be upside down. 
			
			break;
	}
}

#pragma mark -
#pragma mark SelectRowerViewControllerDelegate

// somewhat strange name...
-(void)selectedCoxswain:(Rower *)r {
    if (r) {
        [settings.moc rollback]; // we don't want to create a new entity, really
        self.rower = r;
        [self.tableView reloadData];
        rowerChosen = YES;
    }
}


#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate

// We don't want to continue, as we have everything we want from here
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	CFStringRef first = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef last =  ABRecordCopyValue(person, kABPersonLastNameProperty);
	rower.name = [NSString stringWithFormat:@"%@ %@",first,last];
    CFDateRef birth = ABRecordCopyValue(person, kABPersonBirthdayProperty);
    if (birth!=nil) rower.birthDate = (__bridge_transfer NSDate*)birth;
	ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (emails != NULL && ABMultiValueGetCount(emails)>0) {
        rower.email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails,0); // just the first
    } else {
        rower.email = nil;
    }
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

// this, I suppose, is not used...
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
	CFIndex index = ABMultiValueGetIndexForIdentifier(emails, identifier);
	CFStringRef e = ABMultiValueCopyValueAtIndex(emails, index);
	if (e != NULL) rower.email = (__bridge_transfer NSString*) e;
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

