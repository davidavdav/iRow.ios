//
//  Track.m
//  iRow
//
//  Created by David van Leeuwen on 13-10-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "TrackData.h"
#import "MyGeocoder.h"

// minimum span of the map region, in meters.
#define kMinMapSize (250)
#define kMargin (1.1)

@implementation TrackData

@synthesize locations, pins, cumDist, locality;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        locations = [NSMutableArray arrayWithCapacity:1000];
        cumDist = [NSMutableArray arrayWithCapacity:1000];
        pins = [NSMutableArray arrayWithCapacity:2];
        geoCoder = [[MyGeocoder alloc] init];
    }
    
    return self;
}

-(void)add:(CLLocation*)loc {
    if (loc==nil) return;
    float prevDist = (self.count) ? [cumDist.lastObject floatValue] : 0;
    [cumDist addObject:[NSNumber numberWithFloat:prevDist+[loc distanceFromLocation:locations.lastObject]]];
    [locations addObject:loc];
    if (locality == nil && locations.count==1) {
        [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray * placemarks, NSError * error) {
            MKPlacemark * placemark = [placemarks objectAtIndex:0];
            self.locality = placemark.locality;
        }];
    }
}

-(void)addPin:(NSString*)name atLocation:(CLLocation *)loc {
    MKPointAnnotation * p = [[MKPointAnnotation alloc] init];
    if (loc==nil) return;
    p.coordinate = loc.coordinate;
    p.title = name;
    if (loc!= nil) [pins addObject:p];
}

-(void)reset {
    [locations removeAllObjects];
    [cumDist removeAllObjects];
    [pins removeAllObjects];
    self.locality=nil;
}

// trivial distance calculation
-(CLLocationDistance)totalDistance {
    if (locations.count < 2) return 0;
    return [cumDist.lastObject floatValue];
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

-(NSTimeInterval)totalTime {
    if (locations.count<2) return 0;
    return [self.stopLocation.timestamp timeIntervalSinceDate:self.startLocation.timestamp];
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

// this function mallocs data, this should be freed by the caller
/*
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
 */

-(MKPolyline*)polyLine {
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

//-(NSArray*)pinData {
//    return pins;
//}

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

-(CLLocation*)interpolate:(double)distance {
    if (distance<0) return self.startLocation;
    if (distance>self.totalDistance) return self.stopLocation;
    int a=0, b=self.count-1; 
    while (b-a > 1) {
        int m =  (a+b)/2;
        if ([[cumDist objectAtIndex:m] floatValue] > distance)
            b=m;
        else 
            a=m;
    }
    CLLocation * la = [locations objectAtIndex:a];
    CLLocation * lb = [locations objectAtIndex:b];
    double da = [[cumDist objectAtIndex:a] floatValue], db=[[cumDist objectAtIndex:b] floatValue];
    double frac = (distance - da) / (db-da);
    CLLocationCoordinate2D p; 
    p.longitude = (1-frac)*la.coordinate.longitude + frac*lb.coordinate.longitude;
    p.latitude = (1-frac)*la.coordinate.latitude + frac * lb.coordinate.latitude;
    CLLocationSpeed speed = (1-frac)*la.speed + frac*lb.speed;
    CLLocationDirection course = (1-frac)*la.course + frac*lb.course; // potentially wrong arond 360
    CLLocationDistance alt = (1-frac)*la.altitude + frac*lb.altitude;
    CLLocationAccuracy horAcc = (1-frac)*la.horizontalAccuracy + frac*lb.horizontalAccuracy;
    CLLocationAccuracy vertAcc = (1-frac)*la.verticalAccuracy + frac*lb.verticalAccuracy;
    NSTimeInterval t = (1-frac) * la.timestamp.timeIntervalSince1970 + frac*lb.timestamp.timeIntervalSince1970;
    return [[CLLocation alloc] initWithCoordinate:p altitude:alt horizontalAccuracy:horAcc verticalAccuracy:vertAcc course:course speed:speed timestamp:[NSDate dateWithTimeIntervalSince1970:t]];
}

-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeObject:locations forKey:@"locations"];
    [enc encodeObject:locality forKey:@"locality"];
}

-(id)initWithCoder:(NSCoder *)dec {
	self = [super init];
	if (self != nil) {
        geoCoder = [[MyGeocoder alloc] init];        
        locations = [NSMutableArray arrayWithCapacity:1000];
        cumDist = [NSMutableArray arrayWithCapacity:1000];
        locality = [dec decodeObjectForKey:@"locality"];
        for (CLLocation * l in [dec decodeObjectForKey:@"locations"]) [self add:l]; // does cumDist as well...
        pins = [NSMutableArray arrayWithCapacity:2];
        [self addPin:@"start" atLocation:[locations objectAtIndex:0]];
        [self addPin:@"finish" atLocation:[locations lastObject]];
    }
    return self;
}


@end
