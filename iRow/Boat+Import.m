//
//  Boat+Import.m
//  iRow
//
//  Created by David van Leeuwen on 10/1/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Boat+Import.h"
#import "Settings.h"

#define kbuildDate @"buildDate"
#define kdragFactor @"dragFactor"
#define kmass @"mass"
#define kname @"name"
#define ktype @"type"

#define decode(x) self.x = [dec decodeObjectForKey:k ## x]
#define encode(x) [enc encodeObject:self.x forKey:k ## x]

@implementation Boat (Import)

-(Boat*)initWithCoder:(NSCoder*)dec {
    self = (Boat*)[NSEntityDescription insertNewObjectForEntityForName:@"Boat" inManagedObjectContext:Settings.sharedInstance.moc];
    if (self) {
        decode(buildDate);
        decode(dragFactor);
        decode(mass);
        decode(name);
        decode(type);
    }
    return self;
}

// not encoding other Core Data objecs: tracks
-(void)encodeWithCoder:(NSCoder *)enc {
    encode(buildDate);
    encode(dragFactor);
    encode(mass);
    encode(name);
    encode(type);
}

@end
