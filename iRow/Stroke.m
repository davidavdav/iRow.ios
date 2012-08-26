//
//  Stroke.m
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Stroke.h"
#import "utilities.h"
#import "Matrix+operations.h"
#import "Settings.h"


@implementation Stroke

@synthesize motionManager;
@synthesize acc;
@synthesize direction;
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

// When initWithCoder, this object should not be used with live recordings.  See boolean "live". 
-(id)initWithCoder:(NSCoder *)dec {
    self = [super init]; 
    if (self) {
        live = NO;
        period = [dec decodeDoubleForKey:@"period"];
        duration = [dec decodeDoubleForKey:@"duration"];
        blocksize = lround(kBlockSizeSeconds / period);
        strokeData = [dec decodeObjectForKey:@"strokeData"];
        acc = [dec decodeObjectForKey:@"acc"];
        ptr = [dec decodeIntForKey:@"ptr"];
        strokes = [dec decodeIntForKey:@"strokes"];
        N = strokeData.count * blocksize;
        NSString * sFreq = [NSString stringWithFormat:@"%1.0f", 1/period];
        bpx = [[Filter alloc] initWithFile:[NSString stringWithFormat:@"stroke.%@",sFreq]];
        bpy = [[Filter alloc] initWithFilter:bpx];
//        for (int i=0; i<3; i++) lowp[i]=[[Filter alloc] initWithFile:@"lowp-10.100"];
    } 
    return self;
}

- (id)initWithPeriod:(CFTimeInterval)p duration:(CFTimeInterval)d {
    self = [super init];
    if (self) {
        // Initialization code here.
        // acceleration
        live = YES;
        period = p; // effective sampling period
        duration = d; // size of the auto-direction buffer, in seconds. 

        motionManager = [[CMMotionManager alloc] init];
        [motionManager startAccelerometerUpdates];

        covbuffersize = lround(duration / period);
        blocksize = lround(kBlockSizeSeconds / period); // Basic unit of accelleration storage, 100s
        acc = [[Matrix alloc] init:blocksize by:4]; // storage of acceleration information x, y, z, t
        strokeData = [NSMutableArray arrayWithCapacity:kBlockArrayStartsize]; // few hours of stroke data...
        ptr = 0; // next place to be filled
        N = 0; // total number of samples in buffer
        sign = 1;
        NSString * sFreq = [NSString stringWithFormat:@"%1.0f", 1/period];
        bpx = [[Filter alloc] initWithFile:[NSString stringWithFormat:@"stroke.%@",sFreq]];
        bpy = [[Filter alloc] initWithFilter:bpx];
        ma = [[VectorMA alloc] initWithLength:3 capacity:covbuffersize]; // x, y, z
        strokes = 0;
        direction= [[Vector alloc] initWithLength:3];
        [direction setValue:1 atIndex:1]; // y direction
#if TARGET_IPHONE_SIMULATOR
        motionTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(inspectMotionSimulator:) userInfo:nil repeats:YES];
		NSString * path = [[NSBundle mainBundle] pathForResource:@"yacc" ofType:@"10Hz"];
		file = fopen([path UTF8String], "rt");
#else
        // this initializes the filters etc...
        NSString * lowpFileName = [NSString stringWithFormat:@"lowp-%@.%1.0f",sFreq, kHardwareSamplingRate];
//        NSLog(@"%@", lowpFileName);
        for (int i=0; i<3; i++) lowp[i] = [[Filter alloc] initWithFile:lowpFileName];
        [self hundredHzSampling:Settings.sharedInstance.hundredHzSampling];
        autoOrientation = Settings.sharedInstance.autoOrientation;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hardwareSamplingRateChanged:) name:@"hardwareSamplingRateChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoOrientationChanged:) name:@"autoOrientationChanged" object:nil];
#endif
    }
    
    return self;
}

-(void)add:(CMAcceleration)a {
//    double xacc = [bpx sample:a.x];
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    double yacc;
    if (autoOrientation) {
        static int NN=1;
        Vector * curAcc = [[Vector alloc] initWithLength:3];
        [curAcc setValue:a.x atIndex:0];
        [curAcc setValue:a.y atIndex:1];
        [curAcc setValue:a.z atIndex:2];
        [ma add:curAcc];
        if (++NN % 10 == 0) {
            Matrix * c = [ma cov];
            self.direction = [c biggestEig:direction tolerance:1e-8];
        }
        yacc = [bpy sample:[direction inner:curAcc]];
    } else 
        yacc = [bpy sample:a.y];
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
    if (ptr>=blocksize) {
        ptr = 0;
        [strokeData addObject:acc];
        self.acc = [[Matrix alloc] init:blocksize by:4]; // should release old structure
    }
    N++;
}

-(void)inspectMotion:(id)sender {
    static CFTimeInterval phase = 0;
    // This does not work for devices without gyro:
//    [self add:motionManager.deviceMotion.userAcceleration];
    CMAcceleration a = motionManager.accelerometerData.acceleration;
    if (downsampling) {
        a.x = [lowp[0] sample:a.x];
        a.y = [lowp[1] sample:a.y];
        a.z = [lowp[2] sample:a.z];
        phase += hwperiod;
        if (phase >= period) {
            [self add:a];
            phase -= period;
        }
    } else {
        [self add:a];
    }
}

-(void)inspectMotionSimulator:(id)sender {
    double yacc;
    fscanf(file, "%lf", &yacc);
    CMAcceleration accel = {(double)random()/RAND_MAX / 10, yacc, (double)random()/RAND_MAX / 10};    
    [self add:accel];
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

// this set the hardware sampling rate, and initializes the downsampling
-(void)hundredHzSampling:(BOOL)yes {
    hardwareSamplingRate = yes ? kHardwareSamplingRate : 1/period; // valid values 10, 100
    hwperiod = 1/hardwareSamplingRate;
    downsampling = hardwareSamplingRate * period > 1.1;
    if (motionTimer!=nil) [motionTimer invalidate];
    motionTimer = [NSTimer scheduledTimerWithTimeInterval:hwperiod target:self selector:@selector(inspectMotion:) userInfo:nil repeats:YES];
}

-(void)hardwareSamplingRateChanged:(id)sender {
    [self hundredHzSampling:Settings.sharedInstance.hundredHzSampling];
}

-(void)autoOrientationChanged:(id)sender {
    autoOrientation = Settings.sharedInstance.autoOrientation;
}

-(Vector*)accData:(NSInteger)dim {
    int nx = ptr + blocksize*strokeData.count;
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
