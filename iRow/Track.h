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

@protocol TrackDelegate <NSObject>

-(void)locationUpdate:(id)sender;

@end

@interface Track : NSObject {
    CLLocationManager * locationManager;
    NSTimer * locationTimer;
    float period;
    id<TrackDelegate> delegate;
    NSMutableArray * locations;
    NSMutableArray * pins;
}

@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) id<TrackDelegate> delegate;
@property (strong, readonly) NSMutableArray *  locations;
@property (strong, readonly) NSMutableArray *  pins;

-(id)initWithPeriod:(double)period;
-(void)add:(CLLocation*)loc;
-(void)addPin:(NSString*)name atLocation:(CLLocation*)loc;

-(void)reset;
-(CLLocationDistance)totalDistance;
-(CLLocationSpeed)averageSpeed;
-(int)newTrackData:(CLLocationCoordinate2D**)trackdataPtr;
-(CLLocation*)startLocation;
-(CLLocation*)stopLocation;
-(MKCoordinateRegion)region;
-(int)count;

@end
