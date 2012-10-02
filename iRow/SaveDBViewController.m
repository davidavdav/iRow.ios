//
//  SaveDBViewController.m
//  iRow
//
//  Created by David van Leeuwen on 9/26/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "SaveDBViewController.h"
#import "utilities.h"
#import "Settings.h"
#import "DBExport.h"
#import "RelativeDate.h"
#import "MBProgressHUD.h"

#define kTypes @"Track",@"Course",@"Rower", @"Boat"

@interface SaveDBViewController ()

@end

@implementation SaveDBViewController

@synthesize type;
@synthesize frc;
@synthesize preSelect;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Save items";
        exportSelector = [[ExportSelector alloc] init];
        exportSelector.viewController = self;
//        progressItems = [NSMutableArray arrayWithCapacity:10];
//        progressBezel = [[ProgressBezel alloc] initWithFrame:self.view.bounds];

    }
    return self;
}

// between init and viewDidLoad, you can set self.type to the right class.

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:4]; // dict of arrays
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:4]; // key of dict, in order: the Item classes
    for (NSString * t in [NSArray arrayWithObjects:kTypes,nil])
        if (type == nil || [t isEqualToString:type]) {
            [array addObject:t];
            self.frc = fetchedResultController(t, @"name", YES, Settings.sharedInstance.moc);
            [dict setObject:frc.fetchedObjects forKey:t];
        }
    types = [NSArray arrayWithArray:array];
    items = [NSDictionary dictionaryWithDictionary:dict];
    selected = calloc(types.count,sizeof(BOOL*));
    for (int i=0; i<types.count; i++) {
        int Nj =[[items objectForKey:[types objectAtIndex:i]] count];
        selected[i] = calloc(Nj, sizeof(BOOL));
        for (int j=0; j<Nj; j++) selected[i][j] = preSelect;
    }
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    [self.navigationItem setRightBarButtonItem:saveButton animated:YES];
    saveButton.enabled = preSelect && types.count>0;
}

-(void)dealloc {
    for (int i=0; i<types.count; i++) free(selected[i]);
    free(selected);
}

-(void)savePressed:(id)sender {
    NSURL * dir = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"tmp" isDirectory:YES];
    Rower * user = Settings.sharedInstance.user;
    NSString * baseName = defaultName(type, defaultName(user.name, @"export"));
    NSURL * file = [[dir URLByAppendingPathComponent:baseName] URLByAppendingPathExtension:@"iRow"];
    DBExport * export = [[DBExport alloc] init];
    exportSelector.recipients = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@ <%@>",user.name,user.email]];
    exportSelector.exportFile = file;
    exportSelector.itemType = @"database";
//    [progressItems removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=0; i<types.count; i++) {
            NSArray * array = [items objectForKey:[types objectAtIndex:i]];
            for (int j=0; j<array.count; j++)
                if (selected[i][j]) {
                    id item=[array objectAtIndex:j];
                    //                [progressItems addObject:[export addItem:item]];
                    [export addItem:item];
                }
        }
/*  // This is useless: the writing to disc takes all the time...
    [self.view addSubview:progressBezel];
    NSMutableData * data = [NSMutableData dataWithCapacity:2<<20];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    archiver.delegate = self;
    [archiver encodeRootObject:export];
    [archiver finishEncoding];
    if ([data writeToFile:file.path atomically:YES]) {
 */
        int OK = [NSKeyedArchiver archiveRootObject:export toFile:file.path]; // this takes all the time...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
            if (OK) {
                UIActionSheet * a = [[UIActionSheet alloc] initWithTitle:@"Export database items using" delegate:exportSelector cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"iTunes import",@"email", nil];
                [a showFromTabBar:self.tabBarController.tabBar];
            } else {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, I could not save the items" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
        });
        // xs   [progressBezel removeFromSuperview];
        //    [progressItems removeAllObjects];
    });
}

-(void)dismissBezel:(id)view {
    [view removeFromSuperview];
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
    return  [[items objectForKey:[types objectAtIndex:section]] count];
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
    
    NSArray * a = [items objectForKey:[types objectAtIndex:indexPath.section]];
    id item = [a objectAtIndex:indexPath.row];
    cell.textLabel.text = [item name];
    cell.accessoryType = selected[indexPath.section][indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected[indexPath.section][indexPath.row] = !selected[indexPath.section][indexPath.row];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    BOOL active = NO;
    for (int i=0; i<types.count; i++) for (int j=0; j<[[items objectForKey:[types objectAtIndex:i]] count]; j++) active |= selected[i][j];
    saveButton.enabled = active;
}

// This doesn't make sense: the archiving goes faster than the writing to disc.  That takes all the time...

/*
-(void)archiver:(NSKeyedArchiver *)archiver didEncodeObject:(id)object {
//    NSLog(@"%@ %lx", NSStringFromClass([object class]), (long int)object);
    if ([progressItems containsObject:object]) {
        itemsDone++;
        float p = (float)itemsDone / progressItems.count;
        NSLog(@"%4.2f", p);
    }
}
*/ 
 
@end
