//
//  Track.m
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Tracker.h"

@implementation Tracker

@synthesize locationManager;
@synthesize delegate;
@synthesize track;

- (id)initWithPeriod:(double)p
{
    self = [super init];
    if (self) {
        // Initialization code here.
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        track = [[Track alloc] init];
        period = p;
        [self startTimer];
    }
    
    return self;
}

-(void)inspectLocation:(id)sender {
    if (delegate) [delegate locationUpdate:self];
}


-(void)startTimer {
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(inspectLocation:) userInfo:nil repeats:YES];    
}

-(void)stopTimer {
    [locationTimer invalidate];
}



@end

