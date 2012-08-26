//
//  PlotArea.h
//  scrollview
//
//  Created by David van Leeuwen on 19-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlotArea : UIView {
	double xmin, xmax, ymin, ymax; // user limits of plotArea
	CGMutablePathRef p;
	BOOL penup;
	CGFloat lineWidth, barWidth;	
	CGColorRef graphColor;
	CGColorRef barColor, gadientColor;
	CGGradientRef gradient;
}

@property (readwrite) CGFloat lineWidth, barWidth;
@property (readwrite) CGColorRef graphColor, gradientColor;
@property (readwrite) CGColorRef barColor;
@property (readonly) double xmin, xmax, ymin, ymax;

-(void)setLimitsXmin:(double)inxmin Xmax:(double)inxmax Ymin:(double)inymin Ymax:(double)inymax;

-(void)reset;

-(void)plotX:(double)x Y:(double)y;

-(void)barX:(double)x Y:(double)y;

-(void)penup;


@end
