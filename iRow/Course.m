//
//  Course.m
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Course.h"
#import <MapKit/MapKit.h>

// minimum span of the map region, in meters.
#define kMinMapSize (250)
#define kMargin (1.1)

@implementation Course

@synthesize start, finish, length;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        waypoints = [NSMutableArray arrayWithCapacity:10];
        waypointNr = 0;
//        normals = [NSMutableArray arrayWithCapacity:11];
    }
    
    return self;
}

-(void) update {
    if (waypoints.count < 2) return;
    [[waypoints objectAtIndex:0] resetDistanceInDirection:0];
    for (int i=1; i<waypoints.count; i++) {
        [[waypoints objectAtIndex:i] connectingFrom:[waypoints objectAtIndex:i-1] direction:0];
//        NSLog(@"%f", [(CourseAnnotation*) [waypoints objectAtIndex:i] dist][0]);
    }
    [[waypoints lastObject] resetDistanceInDirection:1];
    for (int i=waypoints.count-1; i>0; i--) {
        [[waypoints objectAtIndex:i-1] connectingFrom:[waypoints objectAtIndex:i] direction:1];
//        NSLog(@"%f", [(CourseAnnotation*) [waypoints objectAtIndex:i-1] dist][1]);
    }        
    [[waypoints objectAtIndex:0] copyNormalToDirection:0];
    [[waypoints lastObject] copyNormalToDirection:1];
    length = [(CourseAnnotation*)[waypoints lastObject] dist][1];
    return;
}

-(CourseAnnotation*)addWaypoint:(CLLocationCoordinate2D)loc {
    CourseAnnotation * new = [[CourseAnnotation alloc] init];
    new.coordinate = loc;
    waypointNr++;
    new.title = [NSString stringWithFormat:@"%d",waypointNr];
    [waypoints addObject:new];
    [self update];
    return new;
}

-(void)removeWaypoint:(MKPointAnnotation*)point {
    [waypoints removeObject:point];
}

-(int)count {
    return waypoints.count;
}

-(BOOL)isValid {
    return waypoints.count>1;
}

-(MKPolyline*)polyline {
    CLLocationCoordinate2D * points = (CLLocationCoordinate2D*) calloc(sizeof(CLLocationCoordinate2D), waypoints.count);
    for (int i=0; i<waypoints.count; i++) points[i] = [[waypoints objectAtIndex:i] coordinate];
    MKPolyline * p = [MKPolyline polylineWithCoordinates:points count:waypoints.count];
    free(points);
    return p;
}

-(NSArray*)annotations {
    return (NSArray*)waypoints;
}

-(double)distanceToStart:(CLLocationCoordinate2D)here  {
    if (waypoints.count<2) return 0;
    double d = [[waypoints objectAtIndex:0] distanceFrom:here direction:0];
//    NSLog(@"%f", d);
    return d;
}

-(double)distanceToFinish:(CLLocationCoordinate2D)here  {
    if (waypoints.count<2) return 0;
    for (int i=0; i<waypoints.count; i++) {
        CourseAnnotation * a = [waypoints objectAtIndex:i];
        CLLocationDistance d = [a distanceFrom:here direction:0];
//        NSLog(@"%f", d);
        if (d>0) return a.dist[0] + d;
    }
    return 0;
}

// This tells us where we are w.r.t. the start- and finishline. 
// <0: before start >0: after finish. 
-(BOOL)outsideCourse:(CLLocationCoordinate2D)here {
    double ds = [[waypoints objectAtIndex:0] distanceFrom:here direction:0];
    double df = [[waypoints lastObject] distanceFrom:here direction:1];
//    NSLog(@"%f %f", ds, df);
    return df>0 ? 1 : ds>0 ? -1 : 0;
}

-(MKCoordinateRegion)region {
    if (waypoints.count == 0) return MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(90, 360));
    CLLocationDegrees left = 180, right = -180, top = -90, bottom = 90;
    for (MKPointAnnotation * a in waypoints) {
            left = MIN(left, a.coordinate.longitude);
            right = MAX(right, a.coordinate.longitude);
            top = MAX(top, a.coordinate.latitude);
            bottom = MIN(bottom, a.coordinate.latitude);
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((top+bottom)/2, (left+right)/2), 
    leftC = CLLocationCoordinate2DMake((top+bottom)/2, left), 
    topC = CLLocationCoordinate2DMake(top, (left+right)/2);
    CLLocationDistance width = MKMetersBetweenMapPoints(MKMapPointForCoordinate(center), MKMapPointForCoordinate(leftC))*2*kMargin,
    height = MKMetersBetweenMapPoints(MKMapPointForCoordinate(center), MKMapPointForCoordinate(topC)) * 2 * kMargin;
    return MKCoordinateRegionMakeWithDistance(center, MAX(height, kMinMapSize), MAX(width, kMinMapSize));

}

-(id)initWithCoder:(NSCoder*)dec {
    self = [super init];
    if (self) {
        waypoints = (NSMutableArray*) [dec decodeObjectForKey:@"waypoints"];
        waypointNr = [dec decodeIntForKey:@"waypointNr"];
        start = (CourseAnnotation*) [dec decodeObjectForKey:@"start"];
        finish = (CourseAnnotation*) [dec decodeObjectForKey:@"finish"];
//        startNormal = [[Normal alloc] init];
//        normals = [NSMutableArray arrayWithCapacity:11];
        [self update];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)enc {
    [enc encodeObject:waypoints forKey:@"waypoints"];
    [enc encodeInt:waypointNr forKey:@"waypointNr"];
    [enc encodeObject:start forKey:@"start"];
    [enc encodeObject:finish forKey:@"finish"];
}

@end

@implementation CourseAnnotation
-(double*)nx {return nx;};
-(double*)ny {return ny;};
-(double*)dist {return dist;};

// for this to work, the distance from `from' needs to be known...
// d=0: forwad, d=1: backward
-(void)connectingFrom:(CourseAnnotation *)from direction:(int)dir{
    dir = MAX(0, MIN(dir, 1));
    int other = 1-dir;
    MKMapPoint t = MKMapPointForCoordinate(self.coordinate);
    MKMapPoint f = MKMapPointForCoordinate(from.coordinate);
    double x = t.x-f.x;
    double y = t.y-f.y;
    double r = sqrt(x*x+y*y);
    nx[dir] = x/r; ny[dir] = y/r;
    dist[other] = from.dist[other] + MKMetersBetweenMapPoints(f, t);    
}

-(void)resetDistanceInDirection:(int)dir{
    dir = MAX(0, MIN(dir, 1));
    dist[1-dir]=0;
}

-(void)copyNormalToDirection:(int)dir {
    dir = MAX(0, MIN(dir, 1));
    int other = 1-dir;
    nx[dir] = -nx[other];
    ny[dir] = -ny[other];
}

-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here direction:(int)dir {
    dir = MAX(0, MIN(dir, 1));
    MKMapPoint h = MKMapPointForCoordinate(here);
    MKMapPoint p = MKMapPointForCoordinate(self.coordinate);
    double dx = p.x-h.x, dy=p.y-h.y;
    CLLocationDistance d = (dx*nx[dir] + dy*ny[dir]) * MKMetersPerMapPointAtLatitude(self.coordinate.latitude);
    return d;
    
}

-(void)encodeWithCoder:(NSCoder *) enc {
    [enc encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [enc encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [enc encodeObject:self.title forKey:@"title"];
    [enc encodeObject:self.subtitle forKey:@"subtitle"];
}

-(id)initWithCoder:(NSCoder *)dec {
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake([dec decodeDoubleForKey:@"latitude"], [dec decodeDoubleForKey:@"longitude"]);
        self.title = [dec decodeObjectForKey:@"title"];
        self.subtitle = [dec decodeObjectForKey:@"subtitle"];
    }
    return self;
}

@end
