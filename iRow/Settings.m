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
    return [NSKeyedUnarchiver unarchiveObjectWithData:[ud objectForKey:key]];
}

@end
