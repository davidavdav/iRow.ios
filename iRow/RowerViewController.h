//
//  OperatorViewController.h
//  iSTI
//
//  Created by David van Leeuwen on 09-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rower.h"
#import "Settings.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>
#import "SelectRowerViewController.h"

typedef void(^newObjectMade) (id new);

@interface RowerViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, SelectRowerViewControllerDelegate> {
	Settings * settings;
    NSArray * fields;
    UIBarButtonItem * leftBarItem;
    UITextField * ageTextField;
    Rower * rower;
    newObjectMade completionBlock;
    BOOL editing;
    BOOL rowerChosen;
}

@property (nonatomic, strong) Rower * rower;
-(void)setRower:(Rower *)rower completion:(newObjectMade)block;

@end
