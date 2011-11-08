//
//  MyDatePicker.m
//  iRow
//
//  Created by David van Leeuwen on 07-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "MyDatePicker.h"

@implementation MyDatePicker

@synthesize dateDelegate;
@synthesize dc;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        thisYear = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]] year];
        dc = [[NSDateComponents alloc] init];
        self.date = nil;
        self.showsSelectionIndicator = YES;
    }
    return self;
}

-(void)setDate:(NSDate *)date {
    BOOL dateSet = date!=nil;
    if (!dateSet) date = [NSDate date];
    self.dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    dc.year += !dateSet; // scroll to unset entry
    [self selectRow:600+dc.month-1 inComponent:0 animated:dateSet];
    [self selectRow:dc.year-thisYear+100 inComponent:1 animated:dateSet];
}

-(NSDate*)date {
    if (thisYear<dc.year) return nil;
    dc.day=2; // we're always one hour back...
    return [[NSCalendar currentCalendar] dateFromComponents:dc];
}

#pragma mark UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 1200;
            break;
        case 1:
            return 102; // one century + unknown
        default:
            break;
    }
    return 0;
}

#pragma mark UIPickerViewDelegate

-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [dateFormatter.monthSymbols objectAtIndex:row % 12];
            break;
        case 1:
            if (row==101) return @"unknown";
            else return [NSString stringWithFormat:@"%d", thisYear-100+row];
        default:
            break;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            dc.month = (row % 12)+1;
            break;
        case 1:
            dc.year = thisYear-100+row;
        default:
            break;
    }
    if (dateDelegate != nil) [dateDelegate dateChanged];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
