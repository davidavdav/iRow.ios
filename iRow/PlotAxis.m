//
//  PlotAxis.m
//  scrollview
//
//  Created by David van Leeuwen on 19-11-10.
//  Copyright 2010 strApps. All rights reserved.
//

#import "PlotAxis.h"

double nicenum(double x, BOOL Round);
CGFloat textlength(CGContextRef c, char * s);

@implementation PlotAxis


- (id)initWithFrame:(CGRect)frame min:(CGFloat)infmin max:(CGFloat)infmax {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		fmin = infmin; fmax = infmax;
		if (self.bounds.size.height>self.bounds.size.width) 
			dir = kDirectionUp;
		else 
			dir = kDirectionRight;
		self.backgroundColor = [UIColor clearColor]; // property does retain
		axisInset=2;
		tickSize=4;
		strcpy(format, "%1.0f"); // default...
    }
								
    return self;
}

// algorithm from Andrew S. Glassner, Graphics Gems, Vol 1, p63--64
double nicenum(double x, BOOL Round) {
	int e=floor(log10(x));
	double f=x/pow(10, e);
	double nf;
	if (Round) {
		if (f<1.5) 
			nf=1;
		else if (f<3)
			nf=2;
		else if (f<7)
			nf=5;
		else 
			nf=10;
	} else {
		if (f<=1)
			nf=1;
		else if(f<=2)
			nf=2;
		else if(f<=5)
			nf=5;
		else 
			nf=10;
	}
	return nf*pow(10, e);
}
	
// this function computes the parameters necessary for axis labels
-(void)loose_label:(int)ntick {
	double range = nicenum(max-min, NO);
	gdelta = nicenum(range/(ntick-1), YES);
	gmin = ceil(min/gdelta)*gdelta;
	gmax = floor(max/gdelta)*gdelta;
	int nfrac = -floor(log10(gdelta));
	if (nfrac<0) nfrac=0;
	sprintf(format, "%%1.%df", nfrac);
//	for (double x=gmin; x<gmax+0.5*d; x+=d) {		
		// plot a label at x, with nfrac digits
//		NSLog(@"%d fractional digits: %f", nfrac, x);
//	}
}

-(void)setLimitsMin:(double)inmin Max:(double)inmax {
	min=inmin;
	max=inmax;
	[self loose_label:10];
}

CGFloat textlength(CGContextRef c, char * s) {
	CGPoint here = CGContextGetTextPosition(c);
	CGContextSetTextDrawingMode(c, kCGTextInvisible);
	CGContextShowText(c, s, strlen(s));
	CGContextSetTextDrawingMode(c, kCGTextFill);
	return CGContextGetTextPosition(c).x - here.x;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
 -(void)drawRect:(CGRect)rect {
    // Drawing code
	 CGContextRef c = UIGraphicsGetCurrentContext();
	 CGContextSetGrayFillColor(c, 0, 1); // axes, black
	 CGContextSetGrayStrokeColor(c, 0, 1); // digits, black
	 CGContextSelectFont(c, "Helvetica", 12, kCGEncodingMacRoman);
	 CGContextSetTextMatrix(c, CGAffineTransformMakeScale(1, -1));
	 char buf[1024];
	 if (dir == kDirectionUp) {
		 BOOL first=YES;
		 double xx = self.bounds.size.width - axisInset;
		 for (double y = gmin; y<gmax+0.5*gdelta; y += gdelta) {
			 double yy = fmax - (y-min)/(max-min)* (fmax-fmin);
			 if (first) {
				CGContextMoveToPoint(c, xx, yy);
				first=NO;
			 } else 
				CGContextAddLineToPoint(c, xx, yy);
			 CGContextAddLineToPoint(c, xx-tickSize, yy);
			 CGContextMoveToPoint(c, xx, yy);
			 sprintf(buf, format, y);
			 CGContextShowTextAtPoint(c, xx-2*tickSize-textlength(c,buf), yy+4, buf, strlen(buf));
		 }
	 }
	 CGContextStrokePath(c);
//	 CGContextFillRect(c, rect);
}


/*
- (void)dealloc {
    [super dealloc];
}
 */

@end
