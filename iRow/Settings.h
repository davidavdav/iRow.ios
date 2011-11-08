//
//  Settings.h
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Boat.h"
#import "Rower.h"

enum {
    kUnitSystemSI=0,
    kUnitSystemImperial,
} unitSystems;

@interface Settings : NSObject {
    NSUserDefaults * ud;
    NSManagedObjectContext * moc;
    Boat * currentBoat;
    Rower * user;
}

@property (nonatomic, strong, setter=setUser:) Rower * user;
@property (nonatomic, readonly) NSManagedObjectContext * moc;
@property (nonatomic, strong) Boat * currentBoat;

+(Settings*)sharedInstance;
// normal objects
-(void)setObject:(id)object forKey:(NSString*)key;
-(id)loadObjectForKey:(NSString*)key;
// core data objects (i.e., pointers to them)
-(void)setManagedObject:(NSManagedObject*)mo forKey:(NSString*) key;
-(id)loadManagedObject:(NSString*)key;

// from the general settings:
-(int)unitSystem;
-(double)logSensitivity;


@end
