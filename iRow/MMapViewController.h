//
//  MMapViewController.h
//  iRow
//
//  Created by David van Leeuwen on 10/15/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class ErgometerViewController;

#import "Tracker.h"
#import "CourseData.h"
#import "ShiftButton.h"
#import "CrossHair.h"
#import "MySegmentedControl.h"
#import "Settings.h"


@interface MMapViewController : UIViewController <MKMapViewDelegate> {
    MKMapView * mapView;
    ShiftButton * courseButton;
    UIButton *pinButton, *clearButton;
    UIImage * buttonImage[4];
    Settings * settings;
    ErgometerViewController * ergometerViewController;
    MKCoordinateRegion mapRegion;
    NSArray * trackPins, * coursePins;
    MKPolyline * currentTrackPolyLine;
    CourseData * courseData;
    MKPolyline * currentCoursePolyline;
    UILabel * distanceLabel;
    MySegmentedControl * zoomModeControl;
    int zoomMode;
    BOOL courseMode;
    BOOL showCoursePins;
    int mySelectionCount;
    MKPointAnnotation * selectedPin;
    CrossHair * crossHair;
}

@property (strong, nonatomic) ErgometerViewController * ergometerViewController;
@property (strong, nonatomic) MKMapView * mapView;
@property (strong, nonatomic) NSArray * trackPins, * coursePins;
@property (strong, nonatomic) MKPolyline * currentTrackPolyLine, * currentCoursePolyline;
@property (strong, nonatomic) CourseData * courseData;
@property (readonly) BOOL courseMode;

-(BOOL)validCourse;
-(BOOL)outsideCourse;
-(void)copyTrackPins;
-(void)refreshTrack;

@end
