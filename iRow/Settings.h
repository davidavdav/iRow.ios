//
//  Settings.h
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

enum {
    kUnitSystemSI=0,
    kUnitSystemImperial,
} unitSystems;

@interface Settings : NSObject {
    NSUserDefaults * ud;

}

+(Settings*)sharedInstance;
-(void)setObject:(id)object forKey:(NSString*)key;
-(id)loadObjectForKey:(NSString*)key;

-(int)unitSystem;

// a utility function
+(NSString*)dispLength:(CLLocationDistance)l;
+(NSString*)dispLengthOnly:(CLLocationDistance)l;
+(NSString*)dispLengthUnit:(CLLocationDistance)l;


@end
