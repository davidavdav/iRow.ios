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

@interface Normal : NSObject {
    CLLocationCoordinate2D point;
    double x, y; // normal
    CLLocationDistance dist; // remaining distance from this point...
}
@property CLLocationDistance dist;
@property CLLocationCoordinate2D point;
-(id)initFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;
-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here;
-(void)reverse;
@end

@class CourseAnnotation;

@interface Course : NSObject <NSCoding> {
    int waypointNr;
    NSMutableArray * waypoints, *normals;
    CourseAnnotation * start, * finish;
    Normal * startNormal, * finishNormal;
    CLLocationDistance length;
}

@property (strong, nonatomic) CourseAnnotation * start, * finish;
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

@end

@interface CourseAnnotation : MKPointAnnotation <NSCoding> {
//    CLLocationCoordinate2D location;
}
//@property CLLocationCoordinate2D location;
@end