//
//  MyGeocoder.m
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

// This is a class to unify the 4.0 MKReverseGeocode and 5.0 CLGeocoder classes. 

#import "MyGeocoder.h"

@implementation MyGeocoder

-(id)init {
    self = [super init];
    if (self) {
        has500 = [[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending;
    }
    return self;
}

-(void)reverseGeocodeLocation:(CLLocation*)location completionHandler:(geocompletion)block {
    if (has500) { // simply copy this to the iOS 5.0 implementation...
        geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:block];
    } else {
        reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
        reverseGeocoder.delegate = self;
        [reverseGeocoder start];
        completionHandler = block;
    }
}

#pragma mark - MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark
{
    NSArray * placemarks = [NSArray arrayWithObject:placemark];
    completionHandler(placemarks, nil);
}

-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    NSLog(@"Couldn't find placemark");
    completionHandler(nil, error);
}

@end
