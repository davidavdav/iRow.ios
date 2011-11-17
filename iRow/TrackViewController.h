//
//  TrackViewController.h
//  iRow
//
//  Created by David van Leeuwen on 13-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Settings.h"
#import "Track.h"
#import "TrackData.h"
#import "ErgometerViewController.h"
#import "SelectRowerViewControllerDelegate.h"


@interface TrackViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, SelectRowerViewControllerDelegate> {
    UIBarButtonItem * leftBarItem;
    Settings * settings;
    TrackData * trackData;
    Track * track;
    ErgometerViewController * evc;
    int speedUnit;
    BOOL editing;
    NSFetchedResultsController * frcBoats, *frcRowers;
    UITextField * boatTextView;
    UITableViewCell * rowersCell;
}

@property (strong, nonatomic) Track * track;

@end
