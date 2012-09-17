//
//  Track+Import.h
//  iRow
//
//  Created by David van Leeuwen on 9/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Track.h"
#import "TrackExport.h"

@interface Track (Import)

-(void)importFrom:(TrackExport*)orig;
-(BOOL)writeKML:(NSURL *)file;

@end
