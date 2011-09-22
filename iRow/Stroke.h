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

@interface Stroke : NSObject {
    CMMotionManager * motionManager;
    NSTimer * motionTimer;
    int size, N, ptr;
    Matrix * acc;
    CFTimeInterval period, duration;
    int sign;
    Filter * bpx, * bpy;
    int strokes;
    id<StrokeDelegate> delegate;
}

@property (strong, nonatomic) CMMotionManager * motionManager;
@property (readonly) int strokes;
@property (strong, nonatomic) id<StrokeDelegate> delegate;


-(id)initWithPeriod:(CFTimeInterval)period duration:(CFTimeInterval)duration;
-(void)add:(CMAcceleration)acc;
-(void)reset;

-(CMAcceleration)gravity;

@end
