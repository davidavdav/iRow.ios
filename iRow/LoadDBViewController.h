//
//  LoadDBViewController.h
//  iRow
//
//  Created by David van Leeuwen on 9/25/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadDBViewController : UITableViewController {
    NSURL * URL; // if set, this is the file to open
    NSString * type; // if set, filter by this type
    NSMutableArray * types;
    BOOL ** selected;
    NSDictionary * dict;
    UIBarButtonItem * loadButton;
    BOOL preSelect;
}

@property (strong, nonatomic) NSURL * URL;
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSDictionary * dict;
@property BOOL preSelect;

@end
