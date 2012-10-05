//
//  CourseBrowserController.h
//  iRow
//
//  Created by David van Leeuwen on 09-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CourseBrowserController : UITableViewController {
    NSManagedObjectContext * moc;
    NSFetchedResultsController * frc;
    NSIndexPath * selected;
}

-(void)newData;

@property (strong,nonatomic) NSFetchedResultsController * frc;

@end
