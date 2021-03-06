//
//  RowerBrowserController.m
//  iRow
//
//  Created by David van Leeuwen on 07-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "RowerBrowserController.h"
#import "Settings.h"
#import "Rower.h"
#import "RowerViewController.h"
#import "utilities.h"

@implementation RowerBrowserController

@synthesize frc;

-(void)fetchOtherRowers {
    NSError * error;
    if (![frc performFetch:&error]) {
        NSLog(@"Problem executing fetch request %@", [error localizedDescription]);
        return;
    }
    rowers = [NSMutableArray arrayWithArray:frc.fetchedObjects];    
    Rower * user = Settings.sharedInstance.user;
    if (user != nil) [rowers removeObject:user];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Rowing mates";
        moc = Settings.sharedInstance.moc;
        frc = nil;
//        [self fetchOtherRowers];
    }
    return self;
}

-(void)addPressed:(id)sender {
    RowerViewController * rvc = [[RowerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    rvc.rower = nil;
    rvc.title = @"Add somebody";
    [self.navigationController pushViewController:rvc animated:YES];
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
    if (frc==nil) self.frc = fetchedResultController(@"Rower", @"name", YES, moc);


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPressed:)];
}

// when iCloud gives an update
-(void)newData {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// update the rowerslist when we return here. 
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchOtherRowers];
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

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (rowers.count == 0) return @"You can add people by tapping the + button.";
    else return @"You can remove people from the database by swiping horizontally.";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return rowers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Rower * r = [rowers objectAtIndex:indexPath.row];
    cell.textLabel.text = r.name;
    cell.detailTextLabel.text = dispMass(r.mass, YES);
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Rower * r = [rowers objectAtIndex:indexPath.row];
        [moc deleteObject:r];
        NSError * error;
        if (![moc save:&error]) {
            NSLog(@"Cannot delete object %@", r);
        } else {
            [self fetchOtherRowers];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    RowerViewController * rvc = [[RowerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    rvc.rower=[rowers objectAtIndex:indexPath.row];
    rvc.title = [[rowers objectAtIndex:indexPath.row] name];
    [self.navigationController pushViewController:rvc animated:YES];
}

@end
