//
//  Track.h
//  iRow
//
//  Created by David van Leeuwen on 13-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyGeocoder.h"

@interface TrackData : NSObject <NSCoding> {
    NSMutableArray * locations;
    NSMutableArray * pins;
    NSMutableArray * cumDist;
    MyGeocoder * geoCoder;
    NSString * locality;
}
@property (strong, readonly) NSMutableArray *  locations;
@property (strong, readonly) NSMutableArray *  pins;
@property (strong, readonly) NSMutableArray * cumDist;
@property (strong, readonly) NSString * locality;

-(void)add:(CLLocation*)loc;
-(void)addPin:(NSString*)name atLocation:(CLLocation*)loc;
-(void)reset;

-(CLLocationDistance)totalDistance;
-(NSTimeInterval)totalTime;
-(CLLocationSpeed)averageSpeed;
-(MKPolyline*)polyLine;
-(CLLocation*)startLocation;
-(CLLocation*)stopLocation;
-(MKCoordinateRegion)region;
-(int)count;
-(CLLocation*)interpolate:(double)distance;

@end
