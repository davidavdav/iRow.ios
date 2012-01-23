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
#import "CourseData.h"
#import "Boat.h"
#import "Rower.h"
#import "Course.h"

enum {
    kUnitSystemSI=0,
    kUnitSystemImperial,
} unitSystems;

@interface Settings : NSObject {
    NSUserDefaults * ud;
    NSManagedObjectContext * moc;
    CourseData * courseData;
    Course * currentCourse;
    Boat * currentBoat;
    Rower * user;
    int speedUnit;
    double logSensitivity;
    int unitSystem;
    double minSpeed; // minimum speed for autostart/stop
    BOOL showStrokeProfile;
}

@property (nonatomic, readonly) NSManagedObjectContext * moc;
@property (nonatomic, strong) CourseData * courseData;
@property (nonatomic, strong) Course * currentCourse;

@property (nonatomic, strong, setter=setUser:) Rower * user;
@property (nonatomic, strong) Boat * currentBoat;

@property (nonatomic) int speedUnit;
@property (nonatomic) double minSpeed;
@property (nonatomic) BOOL showStrokeProfile;

// from the general settings:
@property int unitSystem;
@property double logSensitivity;

+(Settings*)sharedInstance;
-(void)reloadUserDefaults;
// normal objects
-(void)setObject:(id)object forKey:(NSString*)key;
-(id)loadObjectForKey:(NSString*)key;
// core data objects (i.e., pointers to them)
-(void)setManagedObject:(NSManagedObject*)mo forKey:(NSString*) key;
-(id)loadManagedObject:(NSString*)key;

@end
