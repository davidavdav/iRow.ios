//
//  CrossHair.m
//  iRow
//
//  Created by David van Leeuwen on 15-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "CrossHair.h"

@implementation CrossHair

-(void)dealloc {
    CFRelease(color);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        color = UIColor.grayColor.CGColor;
        CFRetain(color);
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, color);
    CGContextMoveToPoint(c, self.bounds.size.width/2, self.bounds.size.height);
    CGContextAddLineToPoint(c, self.bounds.size.width/2, 0);
    CGContextMoveToPoint(c, 0, self.bounds.size.height/2);
    CGContextAddLineToPoint(c, self.bounds.size.width, self.bounds.size.height/2);
    CGContextAddArc(c, self.bounds.size.width/2, self.bounds.size.height/2, MIN(self.bounds.size.width/4, self.bounds.size.height/4), 0, 2*M_PI, 0);
    CGContextStrokePath(c);
    // Drawing code
}


@end
