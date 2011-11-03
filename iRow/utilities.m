//
//  utilities.c
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "utilities.h"
#import "Settings.h"

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
