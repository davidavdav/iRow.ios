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
    CLLocationSpeed minSpeed; // for computing statistics...
}
@property (strong, readonly) NSMutableArray *  locations;
@property (strong, readonly) NSMutableArray *  pins;
@property (strong, readonly) NSMutableArray * cumDist;
@property (strong, nonatomic) NSString * locality;
@property (nonatomic) CLLocationSpeed minSpeed;

-(void)add:(CLLocation*)loc;
-(void)addPin:(NSString*)name atLocation:(CLLocation*)loc;
-(void)reset;

-(CLLocationDistance)totalDistance;
-(CLLocationDistance)totalRowingDistance;
-(NSTimeInterval)totalTime;
-(NSTimeInterval)rowingTime;
-(CLLocationSpeed)averageSpeed;
-(CLLocationSpeed)averageRowingSpeed;
-(MKPolyline*)polyLine;
-(NSArray*)rowingPolyLines;
-(CLLocation*)startLocation;
-(CLLocation*)stopLocation;
-(MKCoordinateRegion)region;
-(int)count;
-(CLLocation*)interpolate:(double)distance;
-(CLLocation*)interpolateTime:(double)time;
-(NSArray*)rowingLocations;

@end
