//
//  RowerSelectViewController.m
//  iRow
//
//  Created by David van Leeuwen on 17-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "SelectRowerViewController.h"
#import "utilities.h"
#import "Rower.h"

@implementation SelectRowerViewController

@synthesize rowers;
@synthesize selected;
@synthesize delegate;
@synthesize editing, multiple;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
       // Custom initialization
        selected = [NSMutableSet setWithCapacity:10]; // no more than 10 in a boat...
        multiple = YES;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)] animated:YES];
    if (editing) [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)] animated:YES];
    self.title = editing ? @"Select rowers" : @"Rowers";
}

-(void)setCoxswain:(Rower *)rower {
    [selected removeAllObjects];
    if (rower != nil) [selected addObject:rower];
    multiple = NO;
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
    return 1;
    
}

-(void)savePressed:(id)sender {
    if (multiple) {
        if ([delegate respondsToSelector:@selector(selectedRowers:)]) [delegate selectedRowers:selected];
    } else {
        if ([delegate respondsToSelector:@selector(selectedCoxswain:)]) [delegate selectedCoxswain:selected.anyObject];        
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)cancelPressed:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Rower * rower = [rowers objectAtIndex:indexPath.row];
    cell.textLabel.text = defaultName(rower.name, @"anonymous");
    if (editing) {
        cell.accessoryType = [selected containsObject:rower] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;        
    } else {
        cell.detailTextLabel.text = defaultName(dispPower(rower.power), defaultName(dispMass(rower.mass), @"−"));
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if (!editing) return;
    Rower * r = [rowers objectAtIndex:indexPath.row];
    NSMutableArray * indexPaths = [NSMutableArray arrayWithObject:indexPath];
    if ([selected containsObject:r]) {
        [selected removeObject:r];
     } else {
        if (!multiple && selected.count) {
            for (Rower * r in selected) {
                NSIndexPath * ip = [NSIndexPath indexPathForRow:[rowers indexOfObject:r] inSection:0];
                [indexPaths addObject:ip];
            }
            [selected removeAllObjects];
        }
        [selected addObject:r];
//        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
//        NSLog(@"%@", selected);
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

@end
