//
//  BoatBrowserController.m
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "BoatBrowserController.h"
#import "Settings.h"
#import "BoatViewController.h"
#import "utilities.h"

@implementation BoatBrowserController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Boats";
        moc = Settings.sharedInstance.moc;
        NSFetchRequest * frq = [[NSFetchRequest alloc] init];
        [frq setEntity:[NSEntityDescription entityForName:@"Boat" inManagedObjectContext:moc]];
        NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray * sds = [NSArray arrayWithObject:sd];
        [frq setSortDescriptors:sds];
        NSError * error;
        frc = [[NSFetchedResultsController alloc] initWithFetchRequest:frq managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        if (![frc performFetch:&error]) {
            NSLog(@"Problem executing fetch request %@", [error localizedDescription]);
        }
//        frc.delegate = (id) self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)addBoat:(id)sender {
    BoatViewController * bvc = [[BoatViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:bvc animated:YES];
}

-(void)setCurrentBoat:(id)sender {
    if (selected!=nil) {
        Boat * b = [frc.fetchedObjects objectAtIndex:selected.row];
        if (b != nil) {
            Settings.sharedInstance.currentBoat = [frc.fetchedObjects objectAtIndex:selected.row];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    loadButton = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStyleDone target:self action:@selector(setCurrentBoat:)];
    if ([self.navigationItem respondsToSelector:@selector(setRightBarButtonItems:)]) 
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBoat:)], loadButton, nil];
    else 
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBoat:)];
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
    loadButton.enabled = NO;
    NSError * error;
    if (![frc performFetch:&error]) {
        NSLog(@"Problem executing fetch request %@", [error localizedDescription]);
    }
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
    if (frc.fetchedObjects.count == 0) return @"You can add boats to your personal fleet by tapping the + button.";
    else return @"You can remove boats from the database by swiping horizontally.";
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
    
    // Configure the cell...
    Boat * b = [frc.fetchedObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = defaultName(b.name, @"unnamed boat");
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.detailTextLabel.text = defaultName(b.type, @"−"); // minus sign
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([frc.fetchedObjects objectAtIndex:indexPath.row] == Settings.sharedInstance.currentBoat) {
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
        Boat * b = [frc.fetchedObjects objectAtIndex:indexPath.row];
        [moc deleteObject:b];
        NSError * error;
        if (![moc save:&error]) {
            NSLog(@"Cannot delete object %@", b);
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

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    BoatViewController * bvc = [[BoatViewController alloc] initWithStyle:UITableViewStyleGrouped];
    bvc.boat = [frc.fetchedObjects objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:bvc animated:YES];
}    

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = indexPath;
    loadButton.enabled = YES;
}

@end
