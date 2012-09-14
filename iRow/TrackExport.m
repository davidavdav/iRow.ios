//
//  TrackExport.m
//  iRow
//
//  Created by David van Leeuwen on 9/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "TrackExport.h"
#import "XMLWriter.h"
#import "TrackData.h"
#import "RelativeDate.h"

void xml(XMLWriter * x, NSString * element, NSString * chars);

@implementation TrackExport 

@synthesize date;
@synthesize distance;
@synthesize locality;
@synthesize motion;
@synthesize name;
@synthesize period;
@synthesize strokes;
@synthesize track;
@synthesize waterway;

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithTrack:(Track*)orig {
    self = [super init];
    if (self) {
        date = [orig.date copy];
        distance = orig.distance;
        locality = [orig.locality copy];
        motion = orig.motion;
        name = [orig.name copy];
        period = orig.period;
        strokes = orig.strokes;
        track = orig.track;
        waterway = orig.waterway;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *) dec {
    self = [super init]; 
    if (self) {
        date = [dec decodeObjectForKey:@"date"];
        distance = [dec decodeObjectForKey:@"distance"];
        locality = [dec decodeObjectForKey:@"locality"];
        motion = [dec decodeObjectForKey:@"motion"];
        name = [dec decodeObjectForKey:@"name"];
        period = [dec decodeObjectForKey:@"period"];
        strokes = [dec decodeObjectForKey:@"strokes"];
        track = [dec decodeObjectForKey:@"track"];
        waterway = [dec decodeObjectForKey:@"waterway"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeObject:self.date forKey:@"date"];
    [enc encodeObject:self.distance forKey:@"distance"];
    [enc encodeObject:self.locality forKey:@"locality"];
    [enc encodeObject:self.motion forKey:@"motion"];
    [enc encodeObject:self.name forKey:@"name"];
    [enc encodeObject:self.period forKey:@"period"];
    [enc encodeObject:self.strokes forKey:@"strokes"];
    [enc encodeObject:self.track forKey:@"track"];
    [enc encodeObject:self.waterway forKey:@"waterway"];
}

@end
