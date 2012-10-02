//
//  Rower+Import.m
//  iRow
//
//  Created by David van Leeuwen on 10/1/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Rower+Import.h"
#import "Settings.h"

#define kbirthDate @"birthDate"
#define kemail @"email"
#define kmass @"mass"
#define kname @"name"
#define kpower @"power"

#define decode(x) self.x = [dec decodeObjectForKey:k ## x]
#define encode(x) [enc encodeObject:self.x forKey:k ## x];

@implementation Rower (Import)

-(Rower*)initWithCoder:(NSCoder *)dec {
    self=(Rower*)[NSEntityDescription insertNewObjectForEntityForName:@"Rower" inManagedObjectContext:Settings.sharedInstance.moc];
    if (self) {
        decode(birthDate);
        decode(email);
        decode(mass);
        decode(name);
        decode(power);
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)enc {
    encode(birthDate);
    encode(email);
    encode(mass);
    encode(name);
    encode(power);
}

@end
