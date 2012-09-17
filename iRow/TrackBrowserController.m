//
//  TrackBrowserController.m
//  iRow
//
//  Created by David van Leeuwen on 14-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "TrackBrowserController.h"
#import "Settings.h"
#import "utilities.h"
#import "CourseViewController.h"
#import "TrackViewController.h"
#import "MapViewController.h"
#import "LoadTrackViewController.h"

@implementation TrackBrowserController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Tracks";
        moc = Settings.sharedInstance.moc;
    }
    return self;
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

    frc = fetchedResultController(@"Track", @"date", NO, moc);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStyleDone target:self action:@selector(loadPressed:)];
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
    self.navigationItem.rightBarButtonItem.enabled = NO;    
    NSError * error;
    [frc performFetch:&error];
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
    return 2;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (frc.fetchedObjects.count == 0) return @"You can add a track by pressing 'Save Current Track' from the previous menu.";
            else return @"You can remove tracks from the database by swiping horizontally.";
            break;
        case 1:
            return @"You can import a track though iTunes File Sharing";
            break;
        default:
            break;
    }
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) return frc.fetchedObjects.count;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.section) {
        case 0: {
            Course * c = [frc.fetchedObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = defaultName(c.name, @"unnamed track");
            cell.detailTextLabel.text = dispLength(c.distance.floatValue);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1: 
            cell.textLabel.text = @"Load from iTunes";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && frc.fetchedObjects.count>1 && [frc.fetchedObjects objectAtIndex:indexPath.row] == Settings.sharedInstance.currentCourse) {
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
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
    if (indexPath.section>0) return;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Course * c = [frc.fetchedObjects objectAtIndex:indexPath.row];
        [moc deleteObject:c];
        NSError * error;
        if (![moc save:&error]) {
            NSLog(@"Cannot delete object %@", c);
        } else {
            [frc performFetch:&error];
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
    switch (indexPath.section) {
        case 0: {
            [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
            TrackViewController * tvc = [[TrackViewController alloc] initWithStyle:UITableViewStyleGrouped]; 
            tvc.track = [frc.fetchedObjects objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:tvc animated:YES];
            break;
        }
        case 1: {
            LoadTrackViewController * ltvc = [[LoadTrackViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:ltvc animated:YES];
            break;
        }
        default:
            break;
    }
    
}


#pragma mark - Table view data source



@end
