//
//  TrackExport.h
//  iRow
//
//  Created by David van Leeuwen on 9/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Track.h"

@interface TrackExport : NSObject <NSCoding> {
    NSDate * date;
    NSNumber * distance;
    NSString * locality;
    NSData * motion;
    NSString * name;
    NSNumber * period;
    NSNumber * strokes;
    NSData * track;
    NSString * waterway;
}

-(id)initWithTrack:(Track*)track;

@property (strong, nonatomic) NSDate * date;
@property (strong, nonatomic) NSNumber * distance;
@property (strong, nonatomic) NSString * locality;
@property (strong, nonatomic) NSData * motion;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSNumber * period;
@property (strong, nonatomic) NSNumber * strokes;
@property (strong, nonatomic) NSData * track;
@property (strong, nonatomic) NSString * waterway;


@end
