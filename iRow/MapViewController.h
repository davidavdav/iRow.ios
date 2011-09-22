//
//  SecondViewController.h
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class ErgometerViewController;

#import "Track.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    MKMapView * mapView;
    ErgometerViewController * ergometerViewController;
    MKCoordinateRegion mapRegion;
    NSArray * shownPins;
}

@property (strong, nonatomic) ErgometerViewController * ergometerViewController;
@property (strong, nonatomic) MKMapView * mapView;
@property (strong, nonatomic) NSArray * shownPins;

-(void)addPin:(CLLocation*)loc;

@end
