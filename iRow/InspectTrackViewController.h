//
//  InspectTrackViewController.h
//  iRow
//
//  Created by David van Leeuwen on 14-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Track.h"
#import "TrackData.h"

@interface InspectTrackViewController : UIViewController <MKMapViewDelegate> {
    MKMapView * mapView;
    UIView * infoView;
    Track * track;
    TrackData * trackData;
    MKPolyline * polyLine;
}

@property (nonatomic, strong) Track * track;

@end
