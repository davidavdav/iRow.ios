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

@implementation Normal
@synthesize point, dist;

// this function places a normal originating in `to', and having direction `to-from', i.e., form `from' to `to' 
-(id)initFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    self = [super init];
    if (self) {
        point = to;
        MKMapPoint t = MKMapPointForCoordinate(to);
        MKMapPoint f = MKMapPointForCoordinate(from);
        x = t.x-f.x;
        y = t.y-f.y;
        double r = sqrt(x*x+y*y);
        x /= r; y /= r;
        dist = 0;
    
    }
    return self;
}

-(CLLocationDistance)distanceFrom:(CLLocationCoordinate2D)here {
    MKMapPoint h = MKMapPointForCoordinate(here);
    MKMapPoint p = MKMapPointForCoordinate(point);
    double dx = p.x-h.x, dy=p.y-h.y;
    CLLocationDistance d = (dx*x + dy*y) * MKMetersPerMapPointAtLatitude(point.latitude);
    return d;
    
}

-(void)reverse {
    x *= -1;
    y *= -1;
}

@end

@implementation Course

@synthesize start, finish, length;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        waypoints = [NSMutableArray arrayWithCapacity:10];
        waypointNr = 0;
        normals = [NSMutableArray arrayWithCapacity:11];
    }
    
    return self;
}

-(void) update {
    if (waypoints.count < 2) return;
    [normals removeAllObjects];
    CLLocationCoordinate2D from = [[waypoints objectAtIndex:0] coordinate];
    // first the odd one out...
    startNormal = [[Normal alloc] initFrom:[[waypoints objectAtIndex:1] coordinate] to:from];
    [startNormal reverse];
    [normals addObject:startNormal];
    for (int i=1; i<waypoints.count; i++) {
        CLLocationCoordinate2D to = [[waypoints objectAtIndex:i] coordinate];
        Normal * n = [[Normal alloc] initFrom:from to:to];
        [normals addObject:n];
        from = to;
    }
    // total course distance
    double d = 0;
    for (int i=waypoints.count-1; i>0; i--) {
        d += MKMetersBetweenMapPoints(MKMapPointForCoordinate([[waypoints objectAtIndex:i] coordinate]), MKMapPointForCoordinate([[waypoints objectAtIndex:i-1] coordinate]));
        [[normals objectAtIndex:i-1] setDist:d];
    }
    length = d;
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
    return [startNormal distanceFrom:here];
}

-(double)distanceToFinish:(CLLocationCoordinate2D)here  {
    if (waypoints.count<2) return 0;
    for (int i=0; i<normals.count; i++) {
        Normal * n = [normals objectAtIndex:i];
        CLLocationDistance d = [n distanceFrom:here];
        if (d>0) return n.dist + d;
    }
    return 0;
}

-(BOOL)outsideCourse:(CLLocationCoordinate2D)here {
    double d = [self distanceToFinish:here];
    return d==0 || d>length;
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
        startNormal = [[Normal alloc] init];
        normals = [NSMutableArray arrayWithCapacity:11];
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
//@synthesize location;

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
