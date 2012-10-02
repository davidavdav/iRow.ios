//
//  ProgressBezel.m
//  iRow
//
//  Created by David van Leeuwen on 10/2/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "ProgressBezel.h"

@implementation ProgressBezel

@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.center = self.center;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

-(void)setProgress:(float)progress {
    progressView.progress = progress;
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
