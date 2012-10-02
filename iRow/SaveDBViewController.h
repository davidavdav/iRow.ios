//
//  SaveDBViewController.h
//  iRow
//
//  Created by David van Leeuwen on 9/26/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ExportSelector.h"


@interface SaveDBViewController : UITableViewController <NSKeyedArchiverDelegate> {
    NSString * type; // type of class to filter
    NSArray * types; // the types to display
    NSDictionary * items;
    NSFetchedResultsController * frc;
    BOOL preSelect;
    BOOL ** selected;
    UIBarButtonItem * saveButton;
    ExportSelector* exportSelector;
//    ProgressBezel * progressBezel;
    //    NSMutableArray * progressItems;
    //    int itemsDone;
}

@property (nonatomic,strong) NSString * type;
@property (nonatomic, strong) NSFetchedResultsController * frc;
@property BOOL preSelect;

@end
