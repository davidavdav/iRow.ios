//
//  BoatBrowserController.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BoatBrowserController : UITableViewController {
    NSManagedObjectContext * moc;
    NSFetchedResultsController * frc;
    UIBarButtonItem * loadButton;
    NSIndexPath * selected;
}

-(void)newData;

@end
