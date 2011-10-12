//
//  ShiftButton.m
//  iRow
//
//  Created by David van Leeuwen on 10-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "ShiftButton.h"

#define kShiftThreshold 5

@implementation ShiftButton

@synthesize enableShift;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        // delete button showing when shifting
        delete = [[UILabel alloc] initWithFrame:self.frame]; // is adapted later
        delete.textColor = [UIColor whiteColor];
        delete.textAlignment = UITextAlignmentCenter;
        // shift label
        shiftLabel = [[UILabel alloc] initWithFrame:self.frame]; // is adapted later...
        shiftLabel.text = @"shift button to delete course";
        shiftLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        shiftLabel.textAlignment = UITextAlignmentCenter;
        shiftLabel.textColor = [UIColor whiteColor];
    }
    
    return self;
}

-(void)onShiftTarget:(id)target action:(SEL)action {
    _action = action;
    _target = target;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (enableShift) {
        [self performSelector:@selector(unhide) withObject:nil afterDelay:0.5];
        origCenter = self.center;
        shifted = NO;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unhide) object:nil];
    [shiftLabel removeFromSuperview];
    if (shifted && enableShift) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            if (deleteSelected) self.alpha=0;
            else self.center = origCenter;
        } completion:^(BOOL finished){
            [delete removeFromSuperview];
            if (deleteSelected && _target != nil) [_target performSelector:_action withObject:self];
            if (deleteSelected) {
                self.alpha = 1;
                self.center = origCenter;
            }
        }];
        self.highlighted = NO;
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!enableShift) return;
    if (!shifted) delete.frame = CGRectInset(self.frame, 5, 4);
    for (UITouch * t in touches) {
        CGFloat x = [t locationInView:self].x - [t previousLocationInView:self].x + self.center.x;
        x = MAX(origCenter.x - self.bounds.size.width, MIN(x, origCenter.x + self.bounds.size.width));
        self.center = CGPointMake(x, self.center.y);
    }
    if (!shifted) {
        [shiftLabel removeFromSuperview];
        [self.superview insertSubview:delete belowSubview:self];
//        self.backgroundColor = [UIColor redColor];
    }
    shifted = YES;
//    [shiftLabel removeFromSuperview];
    CGFloat shift = fabs(self.center.x - origCenter.x) / self.bounds.size.width;
    deleteSelected = shift>0.97;
    delete.text = deleteSelected ? @"Yes!" : @"Delete?";
    delete.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:shift];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unhide) object:nil];
}

-(void)unhide {
    NSLog(@"unhide");
    shiftLabel.frame = self.superview.bounds;
    [self.superview addSubview:shiftLabel];
}

@end
