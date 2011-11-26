//
//  Plot.h
//  scrollview
//
//  Created by David van Leeuwen on 18-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlotArea.h"
#import "PlotAxis.h"

@interface Plot : UIView {
	CGFloat fxmin, fxmax, fymin, fymax; // position of frame
	PlotArea * plotArea;
	PlotAxis * xaxis, * yaxis;
	BOOL showXaxis, showYaxis;
	BOOL showXlabels, showYlabels;
	UIColor * plotAreaBackgroundColor, * graphColor, * axesColor;
	UIColor * barColor, * gradientColor;
}

@property (readonly,retain) PlotArea * plotArea;
@property (nonatomic,retain) UIColor * plotAreaBackgroundColor, * graphColor, * axesColor;
@property (nonatomic, retain) UIColor * barColor, * gradientColor;
@property (readwrite) BOOL showXaxis, showYaxis, showXlabels, showYlabels;
@property (readwrite) CGFloat lineWidth;
@property (readonly) PlotAxis * xaxis, * yaxis;

// define usable plot area, reserving space for axes, device coords
-(void)setMarginLeft:(CGFloat)left right:(CGFloat)right bottom:(CGFloat)bottom top:(CGFloat)top;

// define the range of the plot area in user coordinates
-(void)setLimitsXmin:(double)inxmin Xmax:(double)inxmax Ymin:(double)inymin Ymax:(double)inymax;

// setup the plot according to plot parameters
-(void)setup;

-(void)reset;
-(void)plotX:(double)x Y:(double)y;
-(void)barX:(double)x Y:(double)y;

@end
