//
//  Settings.m
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ud = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

+(Settings*)sharedInstance {
	static Settings * settings = nil;
	if (settings==nil) {
		settings = [[Settings alloc] init];
	}
	return settings;
}

-(void)setObject:(id)object forKey:(NSString *)key {
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:key];
    [ud synchronize];
}

-(id)loadObjectForKey:(NSString *)key {
    NSData * data = [ud objectForKey:key];
    if (data==nil) return nil;
    id res=nil;
    @try {
        res = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException * exception) {
        res = nil;
    }
    return res;
}

-(int)unitSystem {
    return [[ud valueForKey:@"unit_system"] intValue];
}

-(double)logSensitivity {
    return [[ud valueForKey:@"stroke_sensitivity"] doubleValue];
}



@end
