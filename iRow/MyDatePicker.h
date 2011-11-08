//
//  MyDatePicker.h
//  iRow
//
//  Created by David van Leeuwen on 07-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyDatePickerDelegate <NSObject>

-(void)dateChanged;

@end

@interface MyDatePicker : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSDateFormatter * dateFormatter;
    NSInteger thisYear;
    NSDateComponents * dc;
    id <MyDatePickerDelegate> dateDelegate;
}

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSDateComponents * dc;
@property (nonatomic, strong) id <MyDatePickerDelegate> dateDelegate;

@end

