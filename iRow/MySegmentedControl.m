//
//  MySegmentedControl.m
//  iRow
//
//  Created by David van Leeuwen on 16-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

// This segmented control behaves differently from the normal one: 
// - it generates a "value changed" event even if you press the already selected segment control
// - it generates a "touch up inside" when touch-up happens. 

#import "MySegmentedControl.h"

@implementation MySegmentedControl

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
/*
// from http://stackoverflow.com/questions/1620972/uisegmentedcontrol-register-taps-on-selected-segment
- (void)setSelectedSegmentIndex:(NSInteger)toValue {
    // Trigger UIControlEventValueChanged even when re-tapping the selected segment.
    if (toValue==self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [super setSelectedSegmentIndex:toValue];        
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    NSInteger current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (current == self.selectedSegmentIndex) 
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger current = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (current == self.selectedSegmentIndex) {
        for (UITouch * t in touches) {
            if (CGRectContainsPoint(self.bounds, [t locationInView:self])) {
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            } else {
                [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
            }
        }
    }
}

@end
