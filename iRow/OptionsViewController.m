//
//  SettingsViewController.m
//  iRow
//
//  Created by David van Leeuwen on 02-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "OptionsViewController.h"
#import "InfoViewController.h"
#import "CourseViewController.h"
#import "CourseBrowserController.h"
#import "Settings.h"
#import "BoatBrowserController.h"
#import "RowerViewController.h"
#import "RowerBrowserController.h"
#import "TrackViewController.h"
#import "TrackBrowserController.h"
#import "iRowAppDelegate.h"

#define kSectionTitles @"Track", @"Course", @"Help", @"Rowing mates", @"Boats"
enum {
    kSectionTrack=0,
    kSectionCourse,
    kSectionHelp, 
    kSectionRowers, 
    kSectionBoats,
} sectionNumbers;

@implementation OptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        iRowAppDelegate * delegate = (iRowAppDelegate*)[[UIApplication sharedApplication] delegate];        
        evc = (ErgometerViewController*)[delegate.tabBarController.viewControllers objectAtIndex:0];
        self.title = @"Options";
        self.tabBarItem.image = [UIImage imageNamed:@"UIButtonBarInfoDark"];
        sectionTitles = [NSArray arrayWithObjects:kSectionTitles,nil];
        settings = Settings.sharedInstance;
        moc = settings.moc;
        // rower database
        NSFetchRequest * frq = [[NSFetchRequest alloc] init];
        [frq setEntity:[NSEntityDescription entityForName:@"Rower" inManagedObjectContext:moc]];
        NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray * sds = [NSArray arrayWithObject:sd];
        [frq setSortDescriptors:sds];
        NSError * error;
        frcRower = [[NSFetchedResultsController alloc] initWithFetchRequest:frq managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        if (![frcRower performFetch:&error]) {
            NSLog(@"Problem executing fetch request %@", [error localizedDescription]);
        }
        frcRower.delegate = (id)self;

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
    NSError * error;
    [frcRower performFetch:&error];
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
    return sectionTitles.count;
}

-(NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger) section {
    return [sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kSectionTrack:
        case kSectionCourse:
            return 2;
            break;
        case kSectionHelp:
            return 1;
        case kSectionRowers:
            return 2;
        case kSectionBoats:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.detailTextLabel.text = nil;
    switch (indexPath.section) {
        case kSectionTrack:
        case kSectionCourse:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"Save Current %@", [sectionTitles objectAtIndex:indexPath.section]];
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"Browse %@s", [sectionTitles objectAtIndex:indexPath.section]];
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kSectionHelp:
            cell.textLabel.text = @"Quick help";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kSectionRowers:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"You";
                    cell.detailTextLabel.text = Settings.sharedInstance.user.name;
                    break;
                case 1:
                    cell.textLabel.text = @"Others";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",frcRower.fetchedObjects.count - (Settings.sharedInstance.user != nil)];
                    break;
                default:
                    break;
            }
            break;
        case kSectionBoats:
            cell.textLabel.text = @"Boat";
            cell.detailTextLabel.text = Settings.sharedInstance.currentBoat.name;
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
    // Navigation logic may go here. Create and push another view controller.
    switch (indexPath.section) {
        case kSectionTrack:
            switch (indexPath.row) {
                case 0: {
                    if (evc.tracker.track.count<2) {
                        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You must have recorded a track.  You can do that in the Ergometer view." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [a show];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                        break;
                    }
                    TrackViewController * tvc = [[TrackViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:tvc animated:YES];
                    break;
                }
                case 1: {
                    TrackBrowserController * tbc = [[TrackBrowserController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:tbc animated:YES];
                    break;
                }

                default:
                    break;
            }
            break;
        case kSectionCourse:
            switch (indexPath.row) {
                case 0: {
                    if (!Settings.sharedInstance.courseData.isValid) {
                        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You must have a course defined in the Map view.  You can add course by tapping the 'course' button in the Map view and add streched by tapping the '+' button." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [a show]; 
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                        break;
                    }
                    CourseViewController * cvc = [[CourseViewController alloc] initWithStyle:UITableViewStyleGrouped];
//                    if (settings.currentCourse);
                    cvc.course = nil; // we want a new course
                    [self.navigationController pushViewController:cvc animated:YES];
                    break;
                }    
                case 1: {
                    CourseBrowserController * cbc = [[CourseBrowserController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:cbc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        case kSectionHelp:
            switch (indexPath.row) {
                case 0:
                    ;
                    InfoViewController * ivc = [[InfoViewController alloc] init];
                    [self.navigationController pushViewController:ivc animated:YES];
                    break;
            }
            break;
        case kSectionRowers:
            switch (indexPath.row) {
                case 0: {
                    RowerViewController * rvc = [[RowerViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    rvc.title = @"You";
                    [rvc setRower:Settings.sharedInstance.user completion:^(id new) {
                        if (new != nil) Settings.sharedInstance.user = (Rower*)new;
                    }];
                    [self.navigationController pushViewController:rvc animated:YES];
                    break;
                }
                case 1: {
                    RowerBrowserController * rbc = [[RowerBrowserController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:rbc animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        case kSectionBoats: {
            BoatBrowserController * bbc = [[BoatBrowserController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:bbc animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
