//
//  SettingsViewController.h
//  iRow
//
//  Created by David van Leeuwen on 02-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Settings.h"

@interface OptionsViewController : UITableViewController {
    NSArray * sectionTitles;
    NSManagedObjectContext * moc;
    NSFetchedResultsController * frcRower;
    Settings * settings;
}

@end
