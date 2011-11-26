//
//  PlotAxis.h
//  scrollview
//
//  Created by David van Leeuwen on 19-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

enum direction_t {
	kDirectionUp,
	kDirectionRight
};
typedef enum direction_t direction_t;

@interface PlotAxis : UIView {
	direction_t dir;
	CGFloat fmin, fmax; // frame position of corresponding plotarea
	double min, max; // user coordinates of plotarea
	double gmin, gmax, gdelta;
	char format[1024];
	CGFloat axisInset, tickSize;
	double major, minor; // ticks
}

- (id)initWithFrame:(CGRect)frame min:(CGFloat)infmin max:(CGFloat)infmax;

-(void)setLimitsMin:(double)min Max:(double)max;

@end
