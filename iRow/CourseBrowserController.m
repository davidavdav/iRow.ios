//
//  CourseBrowserController.m
//  iRow
//
//  Created by David van Leeuwen on 09-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "CourseBrowserController.h"
#import "Settings.h"
#import "utilities.h"
#import "CourseViewController.h"
#import "TrackViewController.h"
#import "MapViewController.h"

@implementation CourseBrowserController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Courses";
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
    
    NSFetchRequest * frq = [[NSFetchRequest alloc] init];
    [frq setEntity:[NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc]];
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray * sds = [NSArray arrayWithObject:sd];
    [frq setSortDescriptors:sds];
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:frq managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    NSError * error;
    if (![frc performFetch:&error]) {
        NSLog(@"Error fetching Course");
    };

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStyleDone target:self action:@selector(loadPressed:)];
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

-(void)loadPressed:(id)sender {
    if (selected!=nil) {
        Course * c = [frc.fetchedObjects objectAtIndex:selected.row];
        if (c != nil) {
            Settings.sharedInstance.currentCourse = c;
            Settings.sharedInstance.courseData = [NSKeyedUnarchiver unarchiveObjectWithData:c.course];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    return frc.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    Course * c = [frc.fetchedObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = defaultName(c.name, @"unnname course");
    cell.detailTextLabel.text = dispLength(c.distance.floatValue);
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([frc.fetchedObjects objectAtIndex:indexPath.row] == Settings.sharedInstance.currentCourse) {
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
    selected = indexPath;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    CourseViewController * scvc = [[CourseViewController alloc] initWithStyle:UITableViewStyleGrouped];
    scvc.course = [frc.fetchedObjects objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:scvc animated:YES];
}    


@end
