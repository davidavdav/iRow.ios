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
#import "Course.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    MKMapView * mapView;
    UIButton * courseButton, *pinButton, *clearButton;
    UIImage * buttonImage[4];
    ErgometerViewController * ergometerViewController;
    MKCoordinateRegion mapRegion;
    NSArray * trackPins, * coursePins;
    MKPolyline * currentTrackPolyLine;
    Course * currentCourse;
    MKPolyline * currentCoursePolyline; 
    UILabel * distanceLabel;
    UISegmentedControl * zoomModeControl;
    int zoomMode;
    BOOL courseMode;
    BOOL showCoursePins;
}

@property (strong, nonatomic) ErgometerViewController * ergometerViewController;
@property (strong, nonatomic) MKMapView * mapView;
@property (strong, nonatomic) NSArray * trackPins, * coursePins;
@property (strong, nonatomic) MKPolyline * currentTrackPolyLine, * currentCoursePolyline;
@property (strong, nonatomic) Course * currentCourse;
@property (readonly) BOOL courseMode;

-(BOOL)validCourse;
-(BOOL)outsideCourse;

@end
