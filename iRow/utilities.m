//
//  utilities.c
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "utilities.h"
#import "Settings.h"

#define kSpeedFactorKmph (3.6)
#define kSpeedFactorMph (2.237415)

#define kSpeedLabels @"m:s / 500 m", @"m/s", @"km/h", @"mph"

// these are probably relatively slow methods...
NSString * dispLength(CLLocationDistance l) {
    NSString * s;
    int us = Settings.sharedInstance.unitSystem;
    if (us==kUnitSystemSI) {
        if (l>1e4) 
            s = [NSString stringWithFormat:@"%4.1f km",l/1000];
        else 
            s = [NSString stringWithFormat:@"%4.0f m",l];
    } else {
        if (l>1e4) 
            s = [NSString stringWithFormat:@"%4.1f mi",l/1609.344];
        else 
            s = [NSString stringWithFormat:@"%4.0f yd",l/0.9144];            
    }
    return s;
}

NSString * dispLengthOnly(CLLocationDistance l) {
    int us = Settings.sharedInstance.unitSystem;
    if (us==kUnitSystemSI) {
        if (l>1e4) 
            return [NSString stringWithFormat:@"%3.1f",l/1000];
        else 
            return [NSString stringWithFormat:@"%1.0f",l];
    } else {
        if (l>1e4) 
            return [NSString stringWithFormat:@"%3.1f",l/1609.344];
        else 
            return [NSString stringWithFormat:@"%1.0f",l/0.9144];            
    }
}

NSString * dispLengthUnit(CLLocationDistance l) {
    int us = Settings.sharedInstance.unitSystem;
    if (us==kUnitSystemSI) {
        if (l>1e4) 
            return @"km";
        else 
            return @"m";
    } else {
        if (l>1e4) 
            return @"mi";
        else 
            return @"yd";
    }
}

NSString * hms(NSTimeInterval t) {
    if (t<0) return @"–:––";
    int h = t / 3600;
    t -= h*3600;
    int m = t / 60;
    t -= m*60;
    int s = t;
    if (h) return [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
    else return [NSString stringWithFormat:@"%d:%02d",m,s];
}

NSString * dispSpeedOnly(CLLocationSpeed speed, int speedUnit) {
    if (speed<0 || isnan(speed)) 
        return @"–"; // en-dash
    else {
        int us = Settings.sharedInstance.unitSystem;
        switch (speedUnit) {
            case kSpeedTimePer500m: {
                NSTimeInterval timePer500 = 500.0/speed;
                return speed==0 ? @"––:––" : hms(timePer500);
                break;
            }
            case kSpeedDistanceUnitPerHour:
                speed *= us ? kSpeedFactorMph : kSpeedFactorKmph;
            case kSpeedMeterPerSecond:
                return [NSString stringWithFormat:@"%3.1f",speed];
                break;
            default:
                break;
        }
    }
    return nil;
}

NSString * dispSpeedUnit(int unit, BOOL compact) {
    int us = Settings.sharedInstance.unitSystem;
    static NSArray * labels;
    if (labels == nil) labels = [NSArray arrayWithObjects:kSpeedLabels, nil];
    if (unit == 2 && us==kUnitSystemImperial) unit++;
    if (unit==0 && compact) return @"/500m";
    else return [labels objectAtIndex:unit];
}

NSString * dispSpeed(CLLocationSpeed speed, int speedUnit, BOOL compact) {
    return [NSString stringWithFormat:@"%@ %@", dispSpeedOnly(speed, speedUnit), dispSpeedUnit(speedUnit, compact)];
}

NSString * dispMass(NSNumber * mass, BOOL unit) {
    if (mass == nil) return nil;
    if (unit) 
        return [NSString stringWithFormat:@"%3.1f kg",mass.floatValue];
    else 
        return [NSString stringWithFormat:@"%3.1f",mass.floatValue];
}

NSString * dispPower(NSNumber * power) {
    if (power == nil) return nil;
    return [NSString stringWithFormat:@"%1.0f W",power.floatValue];
}

NSString * dispMem(NSUInteger bytes) {
    if (bytes < 512)
        return [NSString stringWithFormat:@"%d B",bytes];
    else if (bytes < 10 * 1024)
        return [NSString stringWithFormat:@"%3.1f kB", (float)bytes / 1024];
    else if (bytes < 512 * 1024)
        return [NSString stringWithFormat:@"%1.0f kB", (float)bytes / 1024];
    else if (bytes < 10 * 1024 * 1024)
        return [NSString stringWithFormat:@"%3.1f MB", (float)bytes / (1<<20)];
    else
        return [NSString stringWithFormat:@"%1.0f MB", (float)bytes / (1<<20)];
}

NSString * defaultName(NSString * name, NSString * def) {
    return (name == nil || [name isEqualToString:@""]) ? def : name;
}

NSFetchedResultsController * fetchedResultController(NSString * object, NSString * sortKey, BOOL ascending, NSManagedObjectContext * moc) {
    NSFetchRequest * frq = [[NSFetchRequest alloc] init];
    [frq setEntity:[NSEntityDescription entityForName:object inManagedObjectContext:moc]];
    if (sortKey==nil) sortKey=@"name"; // default
//    NSString * cacheName = [NSString stringWithFormat:@"%@-%@-%d",object,sortKey,ascending];
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray * sds = [NSArray arrayWithObject:sd];
    [frq setSortDescriptors:sds];
    [frq setPropertiesToFetch:[NSArray arrayWithObject:sortKey]]; // this will limit what we get back from the fetchedresultscontroller when the objects are large
    NSFetchedResultsController * frc = [[NSFetchedResultsController alloc] initWithFetchRequest:frq managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    NSError * error;
    if (![frc performFetch:&error]) {
        NSLog(@"Error fetching %@", sortKey);
        return nil;
    };
    return frc;
}

double strokeSensitivity(double logSensitivity) {
    return kMaxStrokeSens * pow(kMinStrokeSens/kMaxStrokeSens,logSensitivity/kLogSensRange);
}
