//
//  iRowAppDelegate.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "iRowAppDelegate.h"
#import "OptionsViewController.h"
#import "LoadDBViewController.h"
#import "MBProgressHUD.h"

#import "Settings.h"

@implementation iRowAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"Launch options %@", launchOptions);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    ergometerViewController = [[ErgometerViewController alloc] initWithNibName:@"ErgometerViewController" bundle:nil];
    mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    ergometerViewController.mapViewController = mapViewController;
    mapViewController.ergometerViewController = ergometerViewController;
    OptionsViewController * settingsViewController = [[OptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:ergometerViewController, mapViewController, nav, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    iCloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iCloud"]];
    iCloudView.center = CGPointMake(self.tabBarController.tabBar.bounds.size.width-10, 20);
    iCloudView.alpha = 1;
    [self.tabBarController.tabBar addSubview:iCloudView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreReady:) name:kNotificationPersistentStoreSetup object:nil];
    /*
    // deal with old settings bundle...
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
     NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]; // May contain Root.plist and en.lproj
    BOOL dir;
    // remove old settings bundle
    if ([[NSFileManager defaultManager] fileExistsAtPath:settingsBundle isDirectory:&dir] && dir) {
        NSError * error;
        NSString * old = [NSString stringWithFormat:@"%@.old",settingsBundle];
        if (![[NSFileManager defaultManager] moveItemAtPath:settingsBundle toPath:old error:&error]) {
              NSLog(@"Error moving defaults: to %@ -- %@", old, error.localizedDescription);
        } else {
            UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"The external settings (in the iPhone settings App) have been removed, and replaced with setting available from the options tab" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
    }
     */
    // empty inbox
    NSURL * inbox = [[self applicationDocumentsDirectory:YES] URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
    NSError * error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:inbox.path]) [[NSFileManager defaultManager] removeItemAtURL:inbox error:&error];
    return YES;
}

// this will fire for _any_ change in settings, including the ones we write ourselves...
-(void)settingsChanged:(id)sender {
    // change of unit system?
//    Settings * settings = Settings.sharedInstance;
//    int oldUnitSystem = settings.unitSystem, oldSpeedUnit = settings.speedUnit;
    [Settings.sharedInstance reloadUserDefaults];
//    if (oldUnitSystem != settings.unitSystem) 
    // we choose to do this because this is sort-of a notification for the viewcontrollers...
//  ergometerViewController.stroke.sensitivity = Settings.sharedInstance.logSensitivity;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if (ergometerViewController.trackingState==kTrackingStateStopped) 
        [ergometerViewController.tracker.locationManager stopUpdatingLocation];
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    if (!Settings.sharedInstance.backgroundTracking) {
        [ergometerViewController.tracker.locationManager stopUpdatingLocation];
        [ergometerViewController.tracker stopTimer];
    }
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    if (!Settings.sharedInstance.backgroundTracking) {
        if (ergometerViewController.trackingState != kTrackingStateStopped) 
            [ergometerViewController.tracker.locationManager startUpdatingLocation];
        [ergometerViewController.tracker startTimer];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [ergometerViewController.tracker.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self saveContext];
}

-(void)animateIcloud:(BOOL)on {
    iCloudView.alpha = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (!on) {
        [UIView animateWithDuration:2.0 animations:^{
            iCloudView.alpha = 0;
        } completion:^(BOOL finished){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];    
    }
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"I am very sorry.  An error occurred in saving data.  We suggest you close the application, removing it from running in the background as well, and re-starting it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext * moc = [NSManagedObjectContext alloc];
        if ([moc respondsToSelector:@selector(initWithConcurrencyType:)]) {
            [moc initWithConcurrencyType:NSMainQueueConcurrencyType];
            [moc performBlockAndWait:^{
                [moc setPersistentStoreCoordinator:coordinator];
                // even the post initialization needs to be done within the Block
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudUpdate:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }];
        } else { // pre-iOS 5.0
            [moc init];
            [moc setPersistentStoreCoordinator:coordinator];
        }
        managedObjectContext_ = moc;
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
	// this is for versioned systems
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    //	NSLog(@"%@", modelURL);
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];  
	// this no longer works with verisioning...
    //	managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    BOOL hideDB = YES; // if yes: sqlite DB moving to Library/ insread of Documents/
    NSURL * oldURL = [[self applicationDocumentsDirectory:hideDB] URLByAppendingPathComponent:@"iRow.sqlite"];
	NSURL * storeURL = [[self applicationDocumentsDirectory:!hideDB] URLByAppendingPathComponent:@"iRow.sqlite"];
    
    BOOL oldExists = [[NSFileManager defaultManager] fileExistsAtPath:[oldURL path]];
    BOOL storeExists = [[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]];
    
    if (!storeExists && oldExists) {
        NSError * error;
        [[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:storeURL error:&error];
        NSLog(@"simply moved, error: %@", [error localizedDescription]);
        oldExists = [[NSFileManager defaultManager] fileExistsAtPath:[oldURL path]];
        storeExists = [[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]];
    }
    
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    // do this asynchronously since if this is the first time this particular device is syncing with preexisting
    // iCloud content it may take a long long time to download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * options;
        NSURL * iCloudURL;
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError * error = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
            hud.labelText = @"initializing iCloud";
        });
        if ([fm respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)] && (iCloudURL = [fm URLForUbiquityContainerIdentifier:nil]) != nil) {
//            NSURL * iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//            [[NSFileManager defaultManager] removeItemAtPath:iCloudURL.path error:&error];
//            NSLog(@"Removed iCloudURL %@", [error localizedDescription]);
            NSLog(@"ubiquity URL %@, content:\n %@", iCloudURL, [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[iCloudURL path] error:&error]);
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                       @"iRow", NSPersistentStoreUbiquitousContentNameKey,
                       iCloudURL, NSPersistentStoreUbiquitousContentURLKey,
                       nil];
        } else {    
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                       nil];
        }
        [persistentStoreCoordinator_ lock];
        if (! storeExists && oldExists) {
            NSLog(@"Moving store from %@ to %@", oldURL, storeURL);
            NSPersistentStore * oldStore = [persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:oldURL options:options error:&error];
            NSLog(@"1: Error %@", [error localizedDescription]);
            NSPersistentStore * newStore = [persistentStoreCoordinator_ migratePersistentStore:oldStore toURL:storeURL options:options withType:NSSQLiteStoreType error:&error];
            NSLog(@"2: Error %@", [error localizedDescription]);
            NSLog(@"new store now %@", newStore);
        } else if ([persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            // this should be the second time, and presumably without problems
            if (oldExists && ![[NSFileManager defaultManager] removeItemAtURL:oldURL error:&error])
                NSLog(@"3: Error %@", [error localizedDescription]);
        } else {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            NSString * message = @"I am very sorry.  I cannot initialize the database, it is likely due to an upgrade of the iRow app, and somehow the old data model cannot be migrated to the new one.  The only way out seems to be removal of this application, and reinstall from iTunes.  Please proceed by removing this app and re-installing.";
            UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
        [persistentStoreCoordinator_ unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPersistentStoreSetup object:nil];
            [MBProgressHUD hideAllHUDsForView:self.tabBarController.view animated:YES];
            [self animateIcloud:NO];
        });
    });
    return persistentStoreCoordinator_;
}

-(void)persistentStoreReady:(NSNotification*)notification {
    NSLog(@"store OK");
    [self animateIcloud:NO];
    [Settings.sharedInstance readCurrentCoreDataObjects];
}

-(void)iCloudUpdate:(NSNotification*)notification {
    NSLog(@"iCloud triggered");
    NSManagedObjectContext * moc = self.managedObjectContext;
    [moc performBlock:^{
        [self animateIcloud:YES];
        [moc mergeChangesFromContextDidSaveNotification:notification];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationICloudUpdate object:notification];        
        [self animateIcloud:NO];
    }];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) return;
    NSURL *storeURL = [NSURL URLWithString:@"iRow.sqlite" relativeToURL:[self applicationDocumentsDirectory:NO]];
    NSError *error = nil;
    NSURL * destURL = [storeURL URLByAppendingPathExtension:@"old"];
    [[NSFileManager defaultManager] removeItemAtURL:destURL error:nil]; //  first remove old old version
    [[NSFileManager defaultManager] moveItemAtURL:storeURL toURL:destURL error:nil]; // then move current to old
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
 		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"I am very sorry.  This didn't help.  The only way out now seems to be to delete the App entirely from your iOS device, and re-install from iTunes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory:(BOOL)old
{
    return [[[NSFileManager defaultManager] URLsForDirectory:(old ? NSDocumentDirectory : NSLibraryDirectory) inDomains:NSUserDomainMask] lastObject];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"got URL %@ from %@", url, sourceApplication);
    self.tabBarController.selectedIndex = 2;
    LoadDBViewController * ldbvc = [[LoadDBViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ldbvc.URL = url;
    UINavigationController * nav = (UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:2];
    nav.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:nil action:nil];
    [nav pushViewController:ldbvc animated:YES];
    return YES;
}

@end
