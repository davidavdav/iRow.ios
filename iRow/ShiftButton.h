//
//  ShiftButton.h
//  iRow
//
//  Created by David van Leeuwen on 10-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiftButton : UIButton {
    UILabel * shiftLabel;
    CGPoint origCenter;
    BOOL shifted;
    BOOL enableShift;
    UILabel * delete;
    BOOL deleteSelected;
    id _target;
    SEL _action;
    BOOL has430;
}

@property BOOL enableShift;

-(void)onShiftTarget:(id)target action:(SEL)action;

@end
