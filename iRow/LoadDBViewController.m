//
//  LoadDBViewController.m
//  iRow
//
//  Created by David van Leeuwen on 9/25/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "LoadDBViewController.h"
#import "DBExport.h"
#import "Settings.h"

#define kTypes @"Track",@"Course",@"Rower", @"Boat"

@interface LoadDBViewController ()

@end

@implementation LoadDBViewController

@synthesize URL;
@synthesize type;
@synthesize dict;
@synthesize preSelect;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        types = [NSMutableArray arrayWithCapacity:4];
        self.title = @"Load items";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DBExport * import;
    BOOL problem = NO;
    NSString * problemFile = nil;
    if (URL!=nil) { // load from alternative application, delete afterwards
        @try {
            import = [NSKeyedUnarchiver unarchiveObjectWithFile:URL.path];
        } @catch (NSException * ex) {
            problem=YES;
            problemFile = URL.lastPathComponent;
        }
        self.dict = import.items; // dict of array of dict
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:URL.path error:&error];
    } else { // load from Documents directory for iTunes
        NSURL * dir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//        NSLog(@"Listing %@", [dir path]);
        NSError * error;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*\\.iRow'"];
        NSArray * files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[dir path] error:&error] filteredArrayUsingPredicate:predicate];
        NSMutableDictionary * merged = [NSMutableDictionary dictionaryWithCapacity:4];
        for (NSString * f in files) {
            NSString * path = [[dir URLByAppendingPathComponent:f] path];
            @try {
                import = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            }@catch (NSException * ex) {
                problem=YES;
                problemFile = [f copy];
            }
            for (NSString * key in import.items.allKeys) {
                if (type==nil || [type isEqualToString:key]) {
                    if ([merged objectForKey:key] == nil) [merged setObject:[NSMutableArray arrayWithCapacity:10] forKey:key];
                    [[merged objectForKey:key] addObjectsFromArray:[import.items objectForKey:key]];
                }
            }
        }
        self.dict = [NSDictionary dictionaryWithDictionary:merged];
    }
    if (problem) {
        NSString * message = [NSString stringWithFormat:@"I could not import all data, perhaps the file “%@” is corrupted?", problemFile];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    // now copy the data structure
    NSArray * orderedTypes = [NSArray arrayWithObjects:kTypes, nil];
    for (NSString * t in orderedTypes) if ([dict objectForKey:t] != nil) [types addObject:t];
    selected = calloc(types.count, sizeof(BOOL*));
    for (int i=0; i<types.count; i++) {
        int N = [[dict objectForKey:[types objectAtIndex:i]] count];
        selected[i] = calloc(N, sizeof(BOOL));
        for (int j=0; j<N; j++) selected[i][j] = preSelect;
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    loadButton = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStyleDone target:self action:@selector(loadSelected:)];
    [self.navigationItem setRightBarButtonItem:loadButton animated:YES];
    loadButton.enabled = preSelect;
}

-(void)dealloc {
    for (int i=0; i<types.count; i++) free(selected[i]);
    free(selected);
}

-(void)loadSelected:(id)sender {
    for (int i=0; i<types.count; i++) {
        NSString * t = [types objectAtIndex:i];
        NSArray * array = [dict objectForKey:t];
        for (int j=0; j<array.count; j++) if (selected[i][j]) {
            NSData * data = [[array objectAtIndex:j] objectForKey:@"data"];
            id item = [NSKeyedUnarchiver unarchiveObjectWithData:data]; // this inserts the item in the store
            NSLog(@"New item loaded named %@",  [item name]);
        }
    }
    NSError * error;
    if (![Settings.sharedInstance.moc save:&error]) {
        NSString * message = [NSString stringWithFormat:@"I'm sorry, I could not save all items, system message: %@", [error localizedDescription]];
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    };
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return types.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray * a = [dict objectForKey:[types objectAtIndex:section]];
    return a.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [types objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray * a = [dict objectForKey:[types objectAtIndex:indexPath.section]];
    NSDictionary * d = [a objectAtIndex:indexPath.row];
    cell.textLabel.text = [d objectForKey:@"name"];
    cell.accessoryType = selected[indexPath.section][indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    selected[indexPath.section][indexPath.row] = !selected[indexPath.section][indexPath.row];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    BOOL active = NO;
    for (int i=0; i<types.count; i++) for (int j=0; j<[[dict objectForKey:[types objectAtIndex:i]] count]; j++) active |= selected[i][j];
    loadButton.enabled = active;
}

@end
