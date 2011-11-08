//
//  BoatViewController.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Boat.h"
#import "MyDatePicker.h"

@interface BoatViewController : UITableViewController <UITextFieldDelegate, MyDatePickerDelegate> {
    UIBarButtonItem * leftBarItem;
    Boat * boat;
    BOOL editing;
    // local working copies
/*
    NSString * name;
    NSString * type;
    NSDate * year;
    NSNumber * mass;
    NSNumber * dragFactor;
 */
 NSDateFormatter * dateFormatter;
    //
    UITextField * currentTextField;
}

@property (nonatomic, strong) Boat * boat;
@property (nonatomic, strong) UITextField * currentTextField;

@end
