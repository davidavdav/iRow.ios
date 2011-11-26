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

@protocol StrokeDelegate <NSObject>
-(void)stroke:(id)sender;
@end

@interface Stroke : NSObject <NSCoding> {
    CMMotionManager * motionManager;
    NSTimer * motionTimer;
    int size, N, ptr;
    Matrix * acc; // current period of data
    NSMutableArray * strokeData; // all stroke data
    CFTimeInterval period, duration;
    int sign;
    Filter * bpx, * bpy;
    int strokes;
    id<StrokeDelegate> delegate;
    float threshold;
    BOOL recording;
}

@property (strong, nonatomic) CMMotionManager * motionManager;
@property (strong, nonatomic) Matrix * acc;
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

-(Vector*)accData:(NSInteger)dim;

@end
