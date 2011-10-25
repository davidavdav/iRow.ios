//
//  Stroke.m
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Stroke.h"

#define kMaxSamples (1000)

#define kMinStrokeSens (0.05)
#define kMaxStrokeSens (0.5)
#define kLogSensRange (2.0)

@implementation Stroke

@synthesize motionManager;
@synthesize delegate;
@synthesize strokes;

- (id)initWithPeriod:(CFTimeInterval)p duration:(CFTimeInterval)d {
    self = [super init];
    if (self) {
        // Initialization code here.
        // acceleration
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];

        period = p;
        duration = d;
        size = duration / period;
        if (N>kMaxSamples) {
            NSLog(@"More than %d samples needed", kMaxSamples);
            return nil;
        }
        acc = [[Matrix alloc] init:size by:3];
        ptr = 0; // next place to be filled
        N = 0; // number of samples in buffer
        sign = 1;
        bpx = [[Filter alloc] initWithFile:@"stroke"];
        bpy = [[Filter alloc] initWithFilter:bpx];
        strokes = 0;
        motionTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(inspectMotion:) userInfo:nil repeats:YES];
        
    }
    
    return self;
}
    
-(void)add:(CMAcceleration)a {
    double xacc = [bpx sample:a.x];
    double yacc = [bpy sample:a.y];
    [acc setValue:xacc atRow:ptr atCol:1];
    [acc setValue:yacc atRow:ptr atCol:2];
    [acc setValue:a.z atRow:ptr atCol:3];
    ptr++;
    if (ptr>=size) ptr = 0;
    N = MIN(size, N+1);
//    NSLog(@"%f", yacc);
    if (yacc * sign < 0 && fabs(yacc)>threshold) {
        sign = (yacc>0) ? 1 : -1;
        if (sign>0) { // count positive accelerations...
            strokes++;
            if (delegate) [delegate stroke:self];
        }
    }
//    double phi = atan2(xy, (xx-yy)/2+xy) / 2;
//    NSLog(@"phi: %3.0f", phi*180/M_PI);
}

-(void)inspectMotion:(id)sender {
    [self add:motionManager.deviceMotion.userAcceleration];
    //    CMAcceleration a = [stroke gravity];
    //    static int sample=0;
    //    if (++sample % 1 == 0) NSLog(@"%f %f %f", a.x, a.y, a.z);
}


-(void)reset {
    strokes = 0;
}
-(void)setSensitivity:(float)logSens {
    threshold = kMaxStrokeSens * pow(kMinStrokeSens/kMaxStrokeSens,logSens/kLogSensRange);
    NSLog(@"t %f", threshold);
}


// This function specifies the direction of the gravitational aceleration, suggested to be the mean over 
// all collected data points. 
-(CMAcceleration)gravity {
    double x=0, y=0, z=0;
    CMAcceleration g;
    g.x = x/N; 
    g.y = y/N;
    g.z = z/N;
    return g;
}


@end
