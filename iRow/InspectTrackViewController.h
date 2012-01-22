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
#import "Stroke.h"
#import "Plot.h"

@protocol HereAnnotationViewDelegte <NSObject>

-(void)hereAnnotationMoved:(CLLocationCoordinate2D)coordinate index:(NSInteger)index;
-(void)hereAnnotationPressed:(BOOL)down;

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


@interface InspectTrackViewController : UIViewController <MKMapViewDelegate, HereAnnotationViewDelegte, UIScrollViewDelegate> {
    UIScrollView * scrollView;
    MKMapView * mapView;
    UIView * infoView;
    TrackData * trackData;
    UISlider * slider;
    UILabel * timeLabel, * distLabel, * speedLabel;
    HereAnnotation * here;
    Plot * plot;
    Stroke * stroke;
    int selectedPane;
    // this should probably move to its own object...
    Filter * bpf;
    Vector * yacc;
    int * trigger;
    int Ntrigger;
}

//these must be set form the caller
@property (nonatomic, strong) TrackData * trackData;
@property (nonatomic, strong) Stroke * stroke;

@end
