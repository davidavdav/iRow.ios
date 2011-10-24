//
//  Course.h
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

enum {
    kDirectionForward=0,
    kDirectionBackward
} direction;

@class CourseAnnotation;

@interface Course : NSObject <NSCoding> {
    NSMutableArray * waypoints;
    int direction;
    CLLocationDistance length;
}

// @property (strong, nonatomic) CourseAnnotation * start, * finish;
@property int direction;
@property (readonly) CLLocationDistance length;

-(CourseAnnotation*)addWaypoint:(CLLocationCoordinate2D)loc;
-(void)removeWaypoint:(MKPointAnnotation*)point;
-(void)update;
-(int)count;
-(BOOL)isValid;
-(MKPolyline*)polyline;
-(NSArray*)annotations;
-(double)distanceToStart:(CLLocationCoordinate2D)here;
-(double)distanceToFinish:(CLLocationCoordinate2D)here;
-(BOOL)outsideCourse:(CLLocationCoordinate2D)here;
-(MKCoordinateRegion)region;
-(void)updateTitles:(int)side;
-(void)clear;

@end

@interface CourseAnnotation : MKPointAnnotation <NSCoding> {
    double nx[2];
    double ny[2]; // normals from this point
    CLLocationDistance dist[2]; // distances to either endpoint
}
-(double*) nx;
-(double*) ny;
-(CLLocationDistance*)dist;

-(void)connectingFrom:(CourseAnnotation*)from direction:(int)dir;
-(void)resetDistanceInDirection:(int)dir;
-(void)copyNormalToDirection:(int)dir;
-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here direction:(int)dir;
-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here;
-(void)setSubtitleFromDist:(int)dir;

@end