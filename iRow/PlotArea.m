//
//  PlotArea.m
//  scrollview
//
//  Created by David van Leeuwen on 19-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import "PlotArea.h"


@implementation PlotArea

@synthesize lineWidth, barWidth;
@synthesize barColor, graphColor;
@synthesize gradientColor;
@synthesize xmin, xmax, ymin, ymax;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setLimitsXmin:0 Xmax:1 Ymin:0 Ymax:1];
		// lineplots
		p = CGPathCreateMutable();
		penup=YES;
		lineWidth = 2;
		barColor = NULL;
		graphColor = NULL;
		gradientColor = NULL;
    }
    return self;
}

-(void)setLimitsXmin:(double)inxmin Xmax:(double)inxmax Ymin:(double)inymin Ymax:(double)inymax {
	xmin=inxmin; xmax=inxmax;
	ymin=inymin; ymax=inymax;
}

// shortcut for CFRelease
void Release(void* object) {
	if (object != NULL) CFRelease(object);
	object=NULL;
}


// this functions computes a new gradient CF object, given 
// gradient color and bar color. 
-(void)setGradient { 
	if (gradientColor != NULL && barColor != NULL) {
		Release(gradient);
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGColorRef colors[] =  {gradientColor, barColor};
		CFArrayRef colorArray = CFArrayCreate(NULL, (const void **)colors, 2, &kCFTypeArrayCallBacks);
		gradient = CGGradientCreateWithColors(colorspace, colorArray, NULL);
		CFRelease(colorArray);
		CFRelease(colorspace);
	} else {
		Release(gradient);
	}

}
	
-(void)setGradientColor:(CGColorRef)col {
//	NSLog(@"setting gradient color from plotarea");
	if (gradientColor != col) {
		Release(gradientColor);
		CFRetain(gradientColor = col);
		[self setGradient];
	}
}

-(void)setBarColor:(CGColorRef)col {
	if (barColor != col) {
		Release(barColor);
		CFRetain(barColor = col);
		[self setGradient];
	}
}

-(void)reset {
	CGPathRelease(p);
	p = CGPathCreateMutable();
}

// functions that give convert user coorinates into UIView coordinates
-(CGFloat) x:(double)x {
	return (x-xmin)/(xmax-xmin)*self.bounds.size.width;
}
	
-(CGFloat)y:(double) y {
	return self.bounds.size.height - (y-ymin)/(ymax-ymin)*self.bounds.size.height;
}

-(void)plotX:(double)x Y:(double)y {
	CGFloat xx = [self x:x];
	CGFloat yy =[self y:y];
	if (penup)
		CGPathMoveToPoint(p, NULL, xx, yy);
	else
		CGPathAddLineToPoint(p, NULL, xx, yy);
	penup=NO;
}

-(void)barX:(double)x Y:(double)y {
	CGFloat xx = [self x:x];
	CGFloat yy = [self y:y], y0=[self y:0];
	CGAffineTransform I = CGAffineTransformIdentity;
	CGRect r = CGRectMake(xx-0.5*barWidth, y0, barWidth, yy-y0);
	CGPathAddRect(p, &I, r);
//	CGPathMoveToPoint(p, NULL, xx, [self y:0]);
//	CGPathAddLineToPoint(p, NULL, xx, [self y:y]);
}

-(void)penup { penup=YES; };

-(void)drawRect:(CGRect)rect {
	if (CGPathIsEmpty(p)) return;
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(c, lineWidth);
	if (gradient != NULL) {
		CGPoint end = CGPointMake(0, [self bounds].size.height);
		CGContextAddPath(c, p);
		CGContextClosePath(c);
		CGContextSaveGState(c);
		CGContextClip(c);
		CGContextDrawLinearGradient(c, gradient, CGPointZero, end, 0);
		CGContextRestoreGState(c);
	} else {
		CGContextSetStrokeColorWithColor(c, graphColor);
		CGContextSetFillColorWithColor(c, barColor);
//		CGContextAddPath(c, p);
//		CGContextFillPath(c);
		CGContextAddPath(c, p);
		CGContextStrokePath(c);
	}
}

- (void)dealloc {
	Release(gradient);
	Release(barColor);
	Release(gradientColor);
	Release(graphColor);
	Release(p);
//    [super dealloc];
}


@end
