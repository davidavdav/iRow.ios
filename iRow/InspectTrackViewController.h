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

@protocol HereAnnotationViewDelegte <NSObject>

-(void)hereAnnotationMoved:(CLLocationCoordinate2D)coordinate index:(NSInteger)index;

@end

@interface HereAnnotation: MKPointAnnotation 
@end

@interface HereAnnotationView : MKAnnotationView {
    MKMapView * mapView;
    id <HereAnnotationViewDelegte> delegate;
}
@property (nonatomic, strong) MKMapView * mapView;
@property (nonatomic, strong) id <HereAnnotationViewDelegte> delegate;
@end

@interface InspectTrackViewController : UIViewController <MKMapViewDelegate, HereAnnotationViewDelegte> {
    MKMapView * mapView;
    UIView * infoView;
    Track * track;
    TrackData * trackData;
    MKPolyline * polyLine;
    UISlider * slider;
    UILabel * timeLabel, * distLabel, * speedLabel;
    HereAnnotation * here;
    
}

@property (nonatomic, strong) Track * track;

@end
