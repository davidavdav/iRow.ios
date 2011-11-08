//
//  BoatViewController.m
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "BoatViewController.h"
#import "Settings.h"

@implementation BoatViewController

@synthesize boat;
@synthesize currentTextField;

/*
-(void)setBoat:(Boat *)b {
    boat = b; // where is retain?
    name = b.name;
    type = b.type;
    year = b.buildDate;
    mass = b.mass;
    dragFactor = b.dragFactor;
}
 */

-(void)setEditing:(BOOL)e {
    editing = e;
    for (UITableViewCell * c in self.tableView.visibleCells) {
        UITextField * tf = (UITextField*)c.accessoryView;
        tf.enabled = e;
        tf.clearButtonMode = e ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
        tf.borderStyle = editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
    } 
}

-(void)editPressed:(id)sender {
    leftBarItem = self.navigationController.navigationItem.leftBarButtonItem;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)] animated:YES];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
    if (boat == nil) {
        self.boat = (Boat*)[NSEntityDescription insertNewObjectForEntityForName:@"Boat" inManagedObjectContext:Settings.sharedInstance.moc];
    } 
    self.editing = YES;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Boat details";
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBoat:)];
        currentTextField = nil;
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"MMM YYYY";
        dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    }
    return self;
}

-(void)restoreButtons {
    [self.navigationItem setLeftBarButtonItem:leftBarItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)] animated:YES];  
    self.editing = NO;
}

-(void)cancelPressed:(id)sender {
    [self restoreButtons];
    [Settings.sharedInstance.moc rollback];
    [self.tableView reloadData]; // restore old values
}

-(void)savePressed:(id)sender {
    [self restoreButtons];
   // first end editing the current text field...
    if (currentTextField != nil) {
        [self textFieldDidEndEditing:currentTextField];
        [currentTextField resignFirstResponder];
    }
    NSManagedObjectContext * moc = Settings.sharedInstance.moc;
/*
    boat.name = name;
    boat.type = type;
    boat.buildDate = year;
    boat.mass = mass;
    boat.dragFactor = dragFactor;
 */
 NSError * error;
    if (![moc save:&error]) {
        NSLog(@"Error saving data: %@", [error localizedDescription]);
    }
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
    [self.tableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
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
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Name";
            textField.placeholder = @"name of boat";
            textField.text = boat.name;
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case 1:
            cell.textLabel.text = @"Type";
            textField.placeholder = @"type of boat";
            textField.text = boat.type;
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case 2: {
            cell.textLabel.text = @"Date of build";
            textField.placeholder = @"date of build";
            textField.text = [dateFormatter stringFromDate:boat.buildDate];
            MyDatePicker * datePicker = [[MyDatePicker alloc] init];
            textField.inputView = datePicker;
            break;
        }
        case 3:
            cell.textLabel.text = @"Mass (kg)";
            textField.placeholder = @"mass in kg";
            textField.text = boat.mass ? [NSString stringWithFormat:@"%3.1f",boat.mass.floatValue] : nil;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
           break;
        case 4:
            cell.textLabel.text = @"Drag factor";
            textField.placeholder = @"drag factor";
            textField.text = boat.dragFactor ? [NSString stringWithFormat:@"%3.1f",boat.dragFactor.floatValue] : nil;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
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
}

# pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldClear:(UITextField *)textField{
    if (textField.tag == 2) {
        boat.buildDate = nil;
        [(MyDatePicker*)textField.inputView setDate:nil];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    currentTextField = textField;
    if (textField.tag==2) {
        MyDatePicker * dp = (MyDatePicker*)textField.inputView;
        dp.date=boat.buildDate;
        dp.dateDelegate = self;
    }
}

// return nil, or a proper NSNumber
-(NSNumber*)numberFromString:(NSString*) s {
    if (s==nil || [s isEqualToString:@""]) return nil;
    return [NSNumber numberWithFloat:s.floatValue];
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            boat.name = textField.text;
            break;
        case 1:
            boat.type = textField.text;
            break;
        case 2: {
            MyDatePicker * dp = (MyDatePicker*)textField.inputView;           
            boat.buildDate = dp.date;
            textField.text = [dateFormatter stringFromDate:boat.buildDate];
            dp.dateDelegate = nil;
             break;
        }
        case 3:
            boat.mass = [self numberFromString:textField.text];
            break;
        case 4:
            boat.dragFactor = [self numberFromString:textField.text];
            break;
        default:
            break;
    }
}

# pragma mark - MyDateDelegate
-(void)dateChanged {
    boat.buildDate = [(MyDatePicker*)currentTextField.inputView date];
    currentTextField.text = [dateFormatter stringFromDate:boat.buildDate];    
}

@end
