//
//  MySlider.m
//  iRow
//
//  Created by David van Leeuwen on 9/14/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider

@synthesize moveUpTime;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        hind=-1;
        moveUpTime = kMoveUpTime;
        oldValue = self.value;
        [self addTarget:self action:@selector(sliderDone:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

// I have tried to hook onto touchesBegan, Moved, Ended, but this gave spurious results.  Basically, the self.value changed after we had dne with all
// processing.
/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"t begin");
    [super touchesBegan:touches withEvent:event];
}
 */

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
-(void)sliderChanged:(id)sender {
//    [super touchesMoved:touches withEvent:event];
    if (oldValue != self.value) {
        hind = (hind+1) % kHistory;
        oldValue = lastValue[hind] = self.value;
        lastTime[hind] = CFAbsoluteTimeGetCurrent();
    }
}

-(void)sliderDone:(id)sender {
//    UISlider * slider = (UISlider *)sender;
    if (0.05 < self.value && self.value < 0.95) { // didn't hit extremes
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        int max=kHistory;
        double restored = self.value;
        while (lastTime[hind]>0 && now - lastTime[hind] < moveUpTime && max>0) {
            max--;
            hind--;
            if (hind < 0) hind += kHistory;
            restored = lastValue[hind];
        }
        if (restored != self.value) {
            self.value = restored;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

@end
