//
//  Stroke.m
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Stroke.h"
#import "utilities.h"

#define kMaxSamples (1000)

@implementation Stroke

@synthesize motionManager;
@synthesize acc;
@synthesize period;
@synthesize delegate;
@synthesize strokes;
@synthesize bpy, threshold;

#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeObject:strokeData forKey:@"strokeData"];
    [enc encodeObject:acc forKey:@"acc"];
    [enc encodeInt:ptr forKey:@"ptr"];
    [enc encodeDouble:period forKey:@"period"];
    [enc encodeDouble:duration forKey:@"duration"];
    [enc encodeInt:strokes forKey:@"strokes"];
}

-(id)initWithCoder:(NSCoder *)dec {
    self = [super init]; 
    if (self) {
        period = [dec decodeDoubleForKey:@"period"];
        duration = [dec decodeDoubleForKey:@"duration"];
        size = lround(duration / period);
        strokeData = [dec decodeObjectForKey:@"strokeData"];
        acc = [dec decodeObjectForKey:@"acc"];
        ptr = [dec decodeIntForKey:@"ptr"];
        strokes = [dec decodeIntForKey:@"strokes"];
        N = strokeData.count * size;
        bpx = [[Filter alloc] initWithFile:@"stroke"];
        bpy = [[Filter alloc] initWithFilter:bpx];
    } 
    return self;
}

- (id)initWithPeriod:(CFTimeInterval)p duration:(CFTimeInterval)d {
    self = [super init];
    if (self) {
        // Initialization code here.
        // acceleration
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];

        period = p;
        duration = d;
        size = lround(duration / period);
        if (N>kMaxSamples) {
            NSLog(@"More than %d samples needed", kMaxSamples);
            return nil;
        }
        acc = [[Matrix alloc] init:size by:4]; // x, y, z, t
        strokeData = [NSMutableArray arrayWithCapacity:1000]; // few hours of stroke data...
        ptr = 0; // next place to be filled
        N = 0; // total number of samples in buffer
        sign = 1;
        bpx = [[Filter alloc] initWithFile:@"stroke"];
        bpy = [[Filter alloc] initWithFilter:bpx];
        strokes = 0;
        motionTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(inspectMotion:) userInfo:nil repeats:YES];
        
    }
    
    return self;
}
    
-(void)add:(CMAcceleration)a {
//    double xacc = [bpx sample:a.x];
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    double yacc = [bpy sample:a.y];
    if (yacc * sign < 0 && fabs(yacc)>threshold) {
        sign = (yacc>0) ? 1 : -1;
        if (sign>0) { // count positive accelerations...
            strokes++;
            if (delegate) [delegate stroke:self];
        }
    }
    if (!recording) return;
    [acc setValue:a.x atRow:ptr atCol:0];
    [acc setValue:a.y atRow:ptr atCol:1];
    [acc setValue:a.z atRow:ptr atCol:2];
    [acc setValue:time atRow:ptr atCol:3];
    ptr++;
    if (ptr>=size) {
        ptr = 0;
        [strokeData addObject:acc];
        self.acc = [[Matrix alloc] init:size by:3]; // should release old structure
    }
    N++;
}

-(void)inspectMotion:(id)sender {
    [self add:motionManager.deviceMotion.userAcceleration];
}

-(void)startRecording {
    recording = YES;
}

-(void)stopRecording {
    recording = NO;
}

-(void)reset {
    strokes = 0;
    ptr = 0;
    N = 0;
    [strokeData removeAllObjects];
}
-(void)setSensitivity:(float)logSens {
    threshold = strokeSensitivity(logSens);
}

-(Vector*)accData:(NSInteger)dim {
    int nx = ptr + size*strokeData.count;
    Vector * ret = [[Vector alloc] initWithLength:nx];
    real_t * x = ret.x;
    for (Matrix * m in strokeData)
        for (int i=0; i<m.nrow; i++) 
            *x++ = [m valueAtRow:i atCol:dim];
    for (int i=0; i<ptr; i++) {
        *x++ = [acc valueAtRow:i atCol:dim];
    }
    return ret;
}

@end
