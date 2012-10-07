//
//  Track+New.m
//  iRow
//
//  Created by David van Leeuwen on 10/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Track+New.h"
#import "RelativeDate.h"

@implementation Track (New)

+(Track*)newTrackWithTrackdata:(TrackData *)trackData stroke:(Stroke *)stroke inManagedObjectContext:(NSManagedObjectContext *)moc {
    Track * track;
    track = (Track*)[NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:moc];
    if (trackData) {
        track.track = [NSKeyedArchiver archivedDataWithRootObject:trackData];
        track.distance = [NSNumber numberWithFloat:trackData.totalDistance];
        track.locality = trackData.locality;
        track.name = [trackData.startLocation.timestamp mediumshortDateTime];
    }
    if (stroke) {
        track.strokes = [NSNumber numberWithInt:stroke.strokes];
        track.motion = [NSKeyedArchiver archivedDataWithRootObject:stroke];
    }
    track.date = trackData.stopLocation.timestamp;
    return track;
}

@end
