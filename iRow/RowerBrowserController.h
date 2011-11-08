//
//  RowerBrowserController.h
//  iRow
//
//  Created by David van Leeuwen on 07-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RowerBrowserController : UITableViewController {
    NSManagedObjectContext * moc;
    NSFetchedResultsController * frc;
    NSMutableArray * rowers;
}

@end
