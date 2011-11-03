//
//  MyGeocoder.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef void(^geocompletion) (NSArray* placemarks, NSError* error);

@interface MyGeocoder : NSObject <MKReverseGeocoderDelegate> {
    BOOL has500;
    CLGeocoder * geocoder;
    MKReverseGeocoder * reverseGeocoder;
    geocompletion completionHandler;
}

// like iOS 5.0...  Argh, this took we a while to find out...
// http://pragmaticstudio.com/blog/2010/9/15/ios4-blocks-2
-(void)reverseGeocodeLocation:(CLLocation*)location completionHandler:(geocompletion)block;

@end
