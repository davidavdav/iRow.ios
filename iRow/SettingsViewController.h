//
//  SettingsViewController.h
//  iRow
//
//  Created by David van Leeuwen on 19-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface SettingsViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    Settings * settings;
    int unitSystem;
    double logSensitivity;
    NSArray * unitSystems;
    UITextField * unitSystemTextField;
    UISwitch * strokeViewSwitch, *trackingInBackgroundSwitch;
    UITextField * speedUnitTextField;
}

@end