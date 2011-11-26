//
//  Plot.m
//  scrollview
//
//  Created by David van Leeuwen on 18-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import "Plot.h"


@implementation Plot

@synthesize plotArea;
@synthesize plotAreaBackgroundColor, graphColor, axesColor;
@synthesize barColor, gradientColor;
// @synthesize gradientColor;
@synthesize showXaxis, showYaxis, showXlabels, showYlabels;
@synthesize lineWidth;
@synthesize xaxis, yaxis;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		CGRect b=[self bounds];
		fxmin=CGRectGetMinX(b); fxmax=CGRectGetMaxX(b);
		fymin=CGRectGetMinY(b); fymax=CGRectGetMaxY(b);
		self.backgroundColor = [UIColor clearColor]; 
		plotArea=nil;
		xaxis=yaxis=nil;
		[self setMarginLeft:20 right:0 bottom:20 top:0];
		showXaxis = showYaxis = showXlabels = showYlabels = YES;
		graphColor = [UIColor blackColor]; 
		axesColor = graphColor;
		plotAreaBackgroundColor = self.backgroundColor;
    }
    return self;
}

-(void)setMarginLeft:(CGFloat)left right:(CGFloat)right bottom:(CGFloat)bottom top:(CGFloat)top {
	CGRect f=CGRectMake(fxmin+left, fymin+top, fxmax-left-right, fymax-top-bottom);
	if (plotArea==nil) {
		plotArea = [[PlotArea alloc] initWithFrame:f];
		plotArea.backgroundColor = plotAreaBackgroundColor; 
		[self addSubview:plotArea];
	} else 
		plotArea.frame = f;
}

-(void)setLimitsXmin:(double)inxmin Xmax:(double)inxmax Ymin:(double)inymin Ymax:(double)inymax {
	[plotArea setLimitsXmin:inxmin Xmax:inxmax Ymin:inymin Ymax:inymax];
}

-(void)setGradientColor:(UIColor*)c {
//	NSLog(@"setting gradient color from plot");
	plotArea.gradientColor = c.CGColor;
}

-(void)setBarColor:(UIColor *)c {
	plotArea.barColor = c.CGColor;
}

// -(UIColor*)barColor{ return barColor;};

-(void)setup {
	plotArea.backgroundColor = plotAreaBackgroundColor;
//	plotArea.graphColor = graphColor.CGColor;
	plotArea.lineWidth = lineWidth;
	if (showYaxis && yaxis==nil) {
		CGRect f = CGRectMake(fxmin, fymin, plotArea.frame.origin.x-fxmin, fymax-fymin);
		yaxis = [[PlotAxis alloc] initWithFrame:f min:CGRectGetMinY(plotArea.frame) max:CGRectGetMaxY(plotArea.frame)];
		[self addSubview:yaxis];
		[yaxis setLimitsMin:plotArea.ymin Max:plotArea.ymax];
	}
}

-(void)reset {
	[plotArea reset];
}

-(void)plotX:(double)x Y:(double)y {
	[plotArea plotX:x Y:y];
}

-(void)barX:(double)x Y:(double)y {
	[plotArea barX:x Y:y];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/*
- (void)dealloc {
//	[yaxis removeFromSuperview];
//	[plotArea removeFromSuperview];
    [super dealloc];
}
 */

@end
