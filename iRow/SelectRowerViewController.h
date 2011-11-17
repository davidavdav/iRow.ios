//
//  RowerSelectViewController.h
//  iRow
//
//  Created by David van Leeuwen on 17-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectRowerViewControllerDelegate.h"
#import "Rower.h"

@interface SelectRowerViewController : UITableViewController {
    NSArray * rowers;
    NSMutableSet * selected;
    id <SelectRowerViewControllerDelegate> delegate;
    BOOL editing, multiple;
}

@property (nonatomic, copy) NSArray * rowers;
@property (nonatomic, strong) NSMutableSet * selected;
@property (nonatomic, strong) id <SelectRowerViewControllerDelegate> delegate;
@property BOOL editing;
@property BOOL multiple;

-(void)setCoxswain:(Rower*)rower;

@end
