//
//  SettingsViewController.m
//  iRow
//
//  Created by David van Leeuwen on 02-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "ErgometerViewController.h"
#import "Settings.h"
#import "OptionsViewController.h"
#import "TrackViewController.h"
#import "TrackBrowserController.h"
#import "CourseViewController.h"
#import "CourseBrowserController.h"
#import "InfoViewController.h"
#import "SettingsViewController.h"
#import "RowerViewController.h"
#import "RowerBrowserController.h"
#import "BoatBrowserController.h"
#import "utilities.h"
#import "LoadDBViewController.h"
#import "SaveDBViewController.h"
#import "FeedbackViewController.h"


#define kSectionTitles @"Track", @"Course", @"Help", @"Rowing mates", @"Boats", @"Import/Export"
enum {
    kSectionTrack=0,
    kSectionCourse,
    kSectionHelp, 
    kSectionRowers, 
    kSectionBoats,
    kSectionExport
} sectionNumbers;

@implementation OptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Options";
        self.tabBarItem.image = [UIImage imageNamed:@"UIButtonBarInfoDark"];
        sectionTitles = [NSArray arrayWithObjects:kSectionTitles,nil];
        settings = Settings.sharedInstance;
        moc = settings.moc;
        // rower database
        frcRower = fetchedResultController(@"Rower", @"name", YES, moc);
        frcTrack = fetchedResultController(@"Track", @"date", NO, moc);
        frcCourse = fetchedResultController(@"Course", @"date", NO, moc);
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudUpdate:) name:kNotificationICloudUpdate object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSError * error;
    [frcRower performFetch:&error];
    [frcTrack performFetch:&error];
    [frcCourse performFetch:&error];
    [self.tableView reloadData];
}

-(void)iCloudUpdate:(NSNotification *) notification {
    NSLog(@"Received update");
    NSError * error;
    [frcRower performFetch:&error];
    [frcTrack performFetch:&error];
    [frcCourse performFetch:&error];
    id top = self.navigationController.topViewController;
    if ([top isKindOfClass:[UITableViewController class]] && [top respondsToSelector:@selector(newData)])
        [top performSelector:@selector(newData)];
}

-(void)newData {
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
            return 3;
        case kSectionRowers:
            return 2;
        case kSectionBoats:
            return 1;
        case kSectionExport:
            return 2;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case kSectionTrack:
        case kSectionCourse:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"Save Current %@", [sectionTitles objectAtIndex:indexPath.section]];
                    if (indexPath.section==kSectionTrack && settings.autoSave) cell.detailTextLabel.text = @"Autosaving";
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"Browse %@s", [sectionTitles objectAtIndex:indexPath.section]];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", indexPath.section==kSectionTrack ? frcTrack.fetchedObjects.count : frcCourse.fetchedObjects.count];
                    break;
            }
            break;
        case kSectionHelp:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Settings";
                    break;
                case 1:
                    cell.textLabel.text = @"Quick help";
                    break;
                case 2:
                    cell.textLabel.text = @"Feedback";
                    break;
                default:
                    break;
            }
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
        case kSectionExport:
            cell.textLabel.text = indexPath.row==0 ? @"Import items from iTunes" : @"Export database";
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
                    ErgometerViewController * evc = (ErgometerViewController*)[self.tabBarController.viewControllers objectAtIndex:0];
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
                    tbc.frc = frcTrack;
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
                    cbc.frc = frcCourse;
                    [self.navigationController pushViewController:cbc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        case kSectionHelp:
            switch (indexPath.row) {
                case 0: {
                    SettingsViewController * svc = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:svc animated:YES];
                    break;
                }
                case 1: {
                    ;
                    InfoViewController * ivc = [[InfoViewController alloc] init];
                    [self.navigationController pushViewController:ivc animated:YES];
                    break;
                }
                case 2: {
                    FeedbackViewController * fbvc = [[FeedbackViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:fbvc animated:YES];
                    break;
                }
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
                    rbc.frc = frcRower;
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
        case kSectionExport:
            switch (indexPath.row) {
                case 0: {
                    LoadDBViewController * ldbvc = [[LoadDBViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:ldbvc animated:YES];
                    break;
                }
                case 1: {
                    SaveDBViewController * sdbvc = [[SaveDBViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    sdbvc.preSelect = YES;
                    [self.navigationController pushViewController:sdbvc animated:YES];
                    break;
                }
                default:
                    break;
            }{
            
        }
        default:
            break;
    }
}

@end
