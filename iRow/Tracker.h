//
//  Track.h
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TrackData.h"

@protocol TrackerDelegate <NSObject>

-(void)locationUpdate:(id)sender;

@end

@interface Tracker : NSObject {
    CLLocationManager * locationManager;
    NSTimer * locationTimer;
    float period;
    id<TrackerDelegate> delegate;
    TrackData * track;
 }

@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) id<TrackerDelegate> delegate;
@property (strong, nonatomic) TrackData * track;

-(id)initWithPeriod:(double)period;

-(void)startTimer;
-(void)stopTimer;


@end
