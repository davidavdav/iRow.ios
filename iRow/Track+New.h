//
//  Track+New.h
//  iRow
//
//  Created by David van Leeuwen on 10/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Track.h"
#import "TrackData.h"
#import "Stroke.h"
#import <CoreData/CoreData.h>

@interface Track (New)

+(Track*)newTrackWithTrackdata:(TrackData*)trackData stroke:(Stroke*)stroke inManagedObjectContext:(NSManagedObjectContext*)moc;

@end
