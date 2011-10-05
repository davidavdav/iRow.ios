//
//  Track.m
//  iRow
//
//  Created by David van Leeuwen on 19-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Track.h"

// minimum span of the map region, in meters.
#define kMinMapSize (250)
#define kMargin (1.1)

@implementation Track

@synthesize locationManager;
@synthesize delegate;
@synthesize locations, pins;

- (id)initWithPeriod:(double)p
{
    self = [super init];
    if (self) {
        // Initialization code here.
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        period = p;
        locations = [NSMutableArray arrayWithCapacity:1000];
        pins = [NSMutableArray arrayWithCapacity:10];
        [self startTimer];
    }
    
    return self;
}

-(void)inspectLocation:(id)sender {
    if (delegate) [delegate locationUpdate:self];
}

-(void)add:(CLLocation*)loc {
    if (loc != nil) [locations addObject:loc];
}

-(void)addPin:(NSString*)name atLocation:(CLLocation *)loc {
    MKPointAnnotation * p = [[MKPointAnnotation alloc] init];
    if (loc==nil) return;
    p.coordinate = loc.coordinate;
    p.title = name;
    if (loc!= nil) [pins addObject:p];
}

-(void)startTimer {
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(inspectLocation:) userInfo:nil repeats:YES];    
}

-(void)stopTimer {
    [locationTimer invalidate];
}

-(void)reset {
    [locations removeAllObjects];
    [pins removeAllObjects];
}

// trivial distance calculation
-(CLLocationDistance)totalDistance {
    if (locations.count < 2) return 0;
    CLLocation * last = nil;
    CLLocationDistance d=0;
    for (CLLocation * l in locations) {
        if (l.horizontalAccuracy > 0) {
            if (last != nil) {
                d += [l distanceFromLocation:last];
            }
            last = l;
        }
    }
    return d;
}

// This computes average GPS speed.  We could also try to integrate the location, bu the path has to be smoothed first...
-(CLLocationSpeed)averageSpeed {
    CLLocationSpeed s = 0;
    int n=0;
    for (CLLocation * l in locations) {
        if (l.speed>=0) {
            s += l.speed;
            n++;
        }
    }
    if (n) return s/n;
    else return 0;
}

-(int)newTrackData:(CLLocationCoordinate2D **)trackdataPtr {
    CLLocationCoordinate2D * trackdata = (CLLocationCoordinate2D*) calloc(sizeof(CLLocationCoordinate2D), locations.count);
    int n=0;
    for (CLLocation * l in locations) {
        if (l.horizontalAccuracy>0) {
            trackdata[n++] = l.coordinate;
        }
    }
    *trackdataPtr = trackdata;
    return n;
}

-(MKPolyline*)trackData {
    CLLocationCoordinate2D * trackdata = (CLLocationCoordinate2D*) calloc(sizeof(CLLocationCoordinate2D), locations.count);
    int n=0;
    for (CLLocation * l in locations) {
        if (l.horizontalAccuracy>0) {
            trackdata[n++] = l.coordinate;
        }
    }
    MKPolyline * polyline = [MKPolyline polylineWithCoordinates:trackdata count:n];
    free(trackdata);
    return polyline;
}

-(NSArray*)pinData {
    return pins;
}

-(CLLocation*)startLocation {
    if (locations.count) return [locations objectAtIndex:0];
    else return nil;
}

-(CLLocation*)stopLocation {
    if (locations.count) return locations.lastObject;
    else return nil;
}

-(MKCoordinateRegion)region {
    if (locations.count == 0) return MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(90, 360));
    CLLocationDegrees left = 180, right = -180, top = -90, bottom = 90;
    for (CLLocation * l in locations) {
        if (l.horizontalAccuracy>0) {
            left = MIN(left, l.coordinate.longitude);
            right = MAX(right, l.coordinate.longitude);
            top = MAX(top, l.coordinate.latitude);
            bottom = MIN(bottom, l.coordinate.latitude);
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((top+bottom)/2, (left+right)/2), 
        leftC = CLLocationCoordinate2DMake((top+bottom)/2, left), 
        topC = CLLocationCoordinate2DMake(top, (left+right)/2);
    CLLocationDistance width = MKMetersBetweenMapPoints(MKMapPointForCoordinate(center), MKMapPointForCoordinate(leftC))*2*kMargin,
        height = MKMetersBetweenMapPoints(MKMapPointForCoordinate(center), MKMapPointForCoordinate(topC)) * 2 * kMargin;
    return MKCoordinateRegionMakeWithDistance(center, MAX(height, kMinMapSize), MAX(width, kMinMapSize));
}

-(int)count {
    return locations.count;
}

-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeDouble:period forKey:@"period"];
    [enc encodeObject:locations forKey:@"locations"];
    [enc encodeObject:pins forKey:@"pins"];
}

-(id)initWithCoder:(NSCoder *)dec {
	self = [super init];
	if (self != nil) {
		period = [[dec valueForKey:@"period"] doubleValue];
        locations = [dec valueForKey:@"locations"];
        pins = [dec valueForKey:@"pins"];
    }
    return self;
}


@end


@implementation TrackPolyline

@end