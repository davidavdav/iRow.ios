//
//  TrackBrowserController.h
//  iRow
//
//  Created by David van Leeuwen on 14-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TrackBrowserController : UITableViewController {
    NSManagedObjectContext * moc;
    NSFetchedResultsController * frc;
}

@end
