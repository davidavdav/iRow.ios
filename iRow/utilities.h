//
//  utilities.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

// constants for the stroke sensitivity
#define kMinStrokeSens (0.05)
#define kMaxStrokeSens (0.5)
#define kLogSensRange (2.0)

enum {
    kSpeedTimePer500m,
    kSpeedMeterPerSecond,
    kSpeedDistanceUnitPerHour,
} speedUnitConstants;

double strokeSensitivity(double logSensitivity);

// some utility functions
NSString * dispLength(CLLocationDistance l);
NSString * dispLengthOnly(CLLocationDistance l);
NSString * dispLengthUnit(CLLocationDistance l);

NSString * hms(NSTimeInterval t);

NSString * dispSpeedOnly(CLLocationSpeed speed, int speedUnit);
NSString * dispSpeedUnit(int unit, BOOL compact);
NSString * dispSpeed(CLLocationSpeed speed, int speedUnit, BOOL compact);

NSString * dispMass(NSNumber * weight, BOOL unit);
NSString * dispPower(NSNumber * power);

NSString * dispMem(NSUInteger bytes);

NSString * defaultName(NSString * name, NSString * def);

NSFetchedResultsController * fetchedResultController(NSString * object, NSString * sortKey, BOOL ascending, NSManagedObjectContext * moc);
