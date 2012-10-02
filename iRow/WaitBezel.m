//
//  WaitBezel.m
//  iRow
//
//  Created by David van Leeuwen on 10/2/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "WaitBezel.h"

@implementation WaitBezel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:activityView];
        activityView.center = self.center;
        [activityView startAnimating];
        // Initialization code
    }
    return self;
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
