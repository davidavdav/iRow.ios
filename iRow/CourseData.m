//
//  Course.m
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "CourseData.h"
#import <MapKit/MapKit.h>
#import "utilities.h"

// minimum span of the map region, in meters.
#define kMinMapSize (250)
#define kMargin (1.1)

@implementation CourseData

//@synthesize start, finish, 
@synthesize length, direction;
@synthesize waterway;

-(void)encodeWithCoder:(NSCoder*)enc {
    [enc encodeObject:waypoints forKey:@"waypoints"];
    if (waterway!=nil) [enc encodeObject:waterway forKey:@"waterway"];
}

-(id)initWithCoder:(NSCoder*)dec {
    self = [super init];
    if (self) {
        waypoints = (NSMutableArray*) [dec decodeObjectForKey:@"waypoints"];
        waterway = (NSString*) [dec decodeObjectForKey:@"waterway"];
        direction=kDirectionForward;
        geoCoder = [[MyGeocoder alloc] init];
        [self update];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        waypoints = [NSMutableArray arrayWithCapacity:10];
        direction=kDirectionForward;
        geoCoder = [[MyGeocoder alloc] init];
    }
    
    return self;
}

-(CourseAnnotation*) first {
    return waypoints.count ? [waypoints objectAtIndex:0] : nil;
}

-(CourseAnnotation*)last {
    return waypoints.count ? [waypoints lastObject] : nil;
}

// this methods updates the metadata about the course
-(void) update {
    if (! waypoints.count) return;
    [[self first] resetDistanceInDirection:kDirectionForward];
    [[self first] setTitle:@"1"];
    [[self first] setSubtitleFromDist:kDirectionForward];
    if (waypoints.count < 2) return;
    for (int i=1; i<waypoints.count; i++) {
        CourseAnnotation * w = [waypoints objectAtIndex:i];
        [w connectingFrom:[waypoints objectAtIndex:i-1] direction:kDirectionForward];
        [w setTitle:[NSString stringWithFormat:@"%d",i+1]];
        [w setSubtitleFromDist:kDirectionForward];
//        NSLog(@"%f", [(CourseAnnotation*) [waypoints objectAtIndex:i] dist][0]);
    }
    [[self last] resetDistanceInDirection:1];
    for (int i=waypoints.count-1; i>0; i--) {
        [[waypoints objectAtIndex:i-1] connectingFrom:[waypoints objectAtIndex:i] direction:kDirectionBackward];
//        NSLog(@"%f", [(CourseAnnotation*) [waypoints objectAtIndex:i-1] dist][1]);
    }        
    [[self first] copyNormalToDirection:kDirectionForward];
    [[self last] copyNormalToDirection:1];
    length = [(CourseAnnotation*)[self last] dist][kDirectionBackward];
    if (waterway==nil) {
        CLLocationCoordinate2D loc = [self.first coordinate];
        [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude]completionHandler:^(NSArray* placemarks, NSError* error){
            NSLog(@"MyGeocoder finished");
            if (placemarks.count>0) 
            placemark = [placemarks objectAtIndex:0];
            waterway = [placemark respondsToSelector:@selector(inlandWater)] ? placemark.inlandWater : placemark.locality;
        }];
    }
    return;
}

-(CourseAnnotation*)addWaypoint:(CLLocationCoordinate2D)loc {
    CourseAnnotation * new = [[CourseAnnotation alloc] init];
    new.coordinate = loc;
    [waypoints addObject:new];
    [self update];
    return new;
}

-(void)removeWaypoint:(MKPointAnnotation*)point {
    [waypoints removeObject:point];
    [self update];
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
    int extremeIndex = direction*(waypoints.count-1);
    double d = [[waypoints objectAtIndex:extremeIndex] distanceFrom:here direction:direction];
//    NSLog(@"%f", d);
    return d;
}

// segments are indexed 0..N-2
// this computes the distance to a line segment, meaning to the segment itself when you are
// parallel to the segments, and the plain distance to the closest endpoint otherwise. 
-(double)distanceFrom:(CLLocationCoordinate2D)here toSegment:(NSInteger)i {
    CourseAnnotation * a1 = [waypoints objectAtIndex:i];
    CourseAnnotation * a2 = [waypoints objectAtIndex:i+1];
    CLLocationDistance D1 = [a1 distanceFrom:here direction:kDirectionBackward];
    if (D1<0) return [[waypoints objectAtIndex:i] distanceFrom:here];
    CLLocationDistance D2 = [a2 distanceFrom:here direction:kDirectionForward];
    if (D2<0) return [a2 distanceFrom:here];
    double rx = -a2.ny[kDirectionForward], ry = a2.nx[kDirectionForward]; // rotated normalized normal
    MKMapPoint h = MKMapPointForCoordinate(here);
    MKMapPoint p = MKMapPointForCoordinate(a2.coordinate);
    double dx = p.x-h.x, dy=p.y-h.y;
    CLLocationDistance d = (dx*rx + dy*ry) * MKMetersPerMapPointAtLatitude(a2.coordinate.latitude);    
    return fabs(d);
}

-(double)distanceToFinish:(CLLocationCoordinate2D)here  {
    if (waypoints.count<2) return 0;
    double min=1e9;
    int mini = -1;
    for (int i=0; i<waypoints.count-1; i++) {
        double d = [self distanceFrom:here toSegment:i];
        if (d<min) {
            min=d;
            mini=i;
        }
    }
    CourseAnnotation * a = [waypoints objectAtIndex:mini+1-direction];
    CLLocationDistance d = [a distanceFrom:here direction:direction];
    if (((direction==kDirectionForward && mini+2==waypoints.count) || (direction == kDirectionBackward && mini==0)) && d<0) return 0;
    return d + a.dist[direction];
    return 0;
    if (direction==kDirectionForward) 
        for (int i=0; i<waypoints.count; i++) {
            CourseAnnotation * a = [waypoints objectAtIndex:i];
            CLLocationDistance d = [a distanceFrom:here direction:direction];
            if (d>0) return a.dist[direction] + d;
        }
    else 
        for (int i=waypoints.count-1; i>=0; i--) {
            CourseAnnotation * a = [waypoints objectAtIndex:i];
            CLLocationDistance d = [a distanceFrom:here direction:direction];
            if (d>0) return a.dist[direction] + d;            
        }
    return 0;
}

// This tells us where we are w.r.t. the start- and finishline. 
// <0: before start >0: after finish. 
-(BOOL)outsideCourse:(CLLocationCoordinate2D)here {
    double ds = [[self first] distanceFrom:here direction:0];
    double df = [[self last] distanceFrom:here direction:1];
//    NSLog(@"%f %f", ds, df);
    if (df>0) {
        return 1;
    } else if (ds>0) {
        return -1;
    } else 
        return 0;
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

-(void)updateTitles:(int)side {
    if (side==0) return;
    int dir = side>0;
    for (CourseAnnotation * a in waypoints) [a setSubtitleFromDist:dir];
    if (side>0) {
        self.first.title = @"finish";
        self.last.title = @"start";        
    } else {
        self.first.title = @"start";
        self.last.title = @"finish";        
    }
}

-(void)clear {
    [waypoints removeAllObjects];
    self.waterway = nil;
//    self.start = self.finish = nil;
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

// this is distance to line perpendicular to line segment
-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here direction:(int)dir {
    dir = MAX(0, MIN(dir, 1));
    MKMapPoint h = MKMapPointForCoordinate(here);
    MKMapPoint p = MKMapPointForCoordinate(self.coordinate);
    double dx = p.x-h.x, dy=p.y-h.y;
    CLLocationDistance d = (dx*nx[dir] + dy*ny[dir]) * MKMetersPerMapPointAtLatitude(self.coordinate.latitude);
    return d;
}
             
-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here {
    MKMapPoint h = MKMapPointForCoordinate(here);
    MKMapPoint p = MKMapPointForCoordinate(self.coordinate);
    return MKMetersBetweenMapPoints(h, p);
}

-(void)setSubtitleFromDist:(int)dir {
    dir = MAX(0, MIN(dir, 1));
    self.subtitle = dispLength(dist[1-dir]);    
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
