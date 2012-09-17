//
//  Stroke.h
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

// needed for filter
#import "Filter.h"
#import "Vector.h"
#import "Matrix.h"
#import "VectorMA.h"

#define kBlockSizeSeconds (100)
#define kBlockArrayStartsize (100)
#define kHardwareSamplingRate (100.0)
#define kNDimAcceldata (4)
// #define kMaxSamples (1000)


@protocol StrokeDelegate <NSObject>
-(void)stroke:(id)sender;
@end

@interface Stroke : NSObject <NSCoding> {
    BOOL live, downsampling, autoOrientation;
    CMMotionManager * motionManager;
    NSTimer * motionTimer;
    int blocksize, N, ptr; // accelleration storage size, total recorded, current point. 
    Matrix * acc; // current period of data
    int covbuffersize; 
    Vector * direction; // current accelleration direction
    VectorMA * ma;
    NSMutableArray * strokeData; // all stroke data
    CFTimeInterval period, hwperiod, duration; // effective sampling period, hardware sampling period, covariance measurement duration
    double hardwareSamplingRate;
    int sign;
    Filter * bpx, * bpy; // bandpass filters for stoke data
    Filter * lowp[3]; // lowpass filter for accelleration data
    int strokes;
    id<StrokeDelegate> delegate;
    float threshold;
    BOOL recording;
    FILE * file;
}

@property (strong, nonatomic) CMMotionManager * motionManager;
@property (strong, nonatomic) Matrix * acc;
@property (strong, nonatomic) Vector * direction;
@property (readonly) int strokes;
@property (readonly) CFTimeInterval period;
@property (strong, nonatomic) id<StrokeDelegate> delegate;
@property (readonly) Filter * bpy;
@property (readonly) float threshold;


-(id)initWithPeriod:(CFTimeInterval)period duration:(CFTimeInterval)duration;
-(void)add:(CMAcceleration)acc;
-(void)reset;
-(void)setSensitivity:(float)logSens;
-(void)startRecording;
-(void)stopRecording;
-(void)hundredHzSampling:(BOOL)yes;

-(Vector*)accData:(NSInteger)dim;
-(BOOL)hasAccData;
-(NSUInteger)accDataSize;

@end
