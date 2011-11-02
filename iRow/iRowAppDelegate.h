//
//  iRowAppDelegate.h
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ErgometerViewController.h"
#import "MapViewController.h"


@interface iRowAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    ErgometerViewController * ergometerViewController;
    MapViewController * mapViewController;
    NSManagedObjectContext * managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

// core data, this almost looks like a protocol, but no such thing is declared
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;


@end
