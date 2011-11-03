//
//  iRowAppDelegate.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "iRowAppDelegate.h"
#import "OptionsViewController.h"

#import "Settings.h"

@implementation iRowAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    return YES;
}

// this will fire for _any_ change in settings, including the ones we write ourselves...
-(void)settingsChanged:(id)sender {
    // change of unit system?
    int us = Settings.sharedInstance.unitSystem;
    if (us != ergometerViewController.unitSystem)
        ergometerViewController.unitSystem = mapViewController.unitSystem = us;
    ergometerViewController.stroke.sensitivity = Settings.sharedInstance.logSensitivity;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if (ergometerViewController.trackingState==kTrackingStateStopped) 
        [ergometerViewController.tracker.locationManager stopUpdatingLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [ergometerViewController.tracker.locationManager stopUpdatingLocation];
    [ergometerViewController.tracker stopTimer];
    [[Settings sharedInstance] setObject:[NSNumber numberWithInt:ergometerViewController.speedUnit] forKey:@"speedUnit"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    if (ergometerViewController.trackingState != kTrackingStateStopped) 
        [ergometerViewController.tracker.locationManager startUpdatingLocation];
    [ergometerViewController.tracker startTimer];
    ergometerViewController.speedUnit = [[[Settings sharedInstance] loadObjectForKey:@"speedUnit"] intValue];
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
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
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
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
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
    // this is ios 2.0 compatible...
    NSURL *storeURL = [NSURL URLWithString:@"iRow.sqlite" relativeToURL:[self applicationDocumentsDirectory]];
	// NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iRow.sqlite"];
    
    NSError *error = nil;
	
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"I am very sorry.  I cannot initialize the courses/tracks database, it is likely due to an upgrade of the iRow app, and somehow the old data model cannot be migrated to the new one.  One way out is to re-initialize the database." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Initialize",nil];
        [alert show];
    }    
    
    return persistentStoreCoordinator_;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) return;
    NSURL *storeURL = [NSURL URLWithString:@"iRow.sqlite" relativeToURL:[self applicationDocumentsDirectory]];
    NSError *error = nil;
    NSURL * destURL = [storeURL URLByAppendingPathExtension:@".old"];
    [[NSFileManager defaultManager] moveItemAtURL:storeURL toURL:destURL error:nil];
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
- (NSURL *)applicationDocumentsDirectory {
	NSURL * dir;
    // ios 4.0
    dir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return dir;
}


@end
