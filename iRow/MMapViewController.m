//
//  MMapViewController.m
//  iRow
//
//  Created by David van Leeuwen on 10/15/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "MMapViewController.h"
#import "ErgometerViewController.h"
#import "Settings.h"
#import <QuartzCore/QuartzCore.h>
#import "utilities.h"

enum {
    kZoomModeHere=0,
    kZoomModeTrack,
    kZoomModeCourse,
    kZoomModeNone
};

@implementation MMapViewController

@synthesize ergometerViewController;
@synthesize mapView;
@synthesize trackPins, coursePins;
@synthesize currentTrackPolyLine, currentCoursePolyline;
@synthesize courseData, courseMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    NSLog(@"Map height %4.1f", self.view.frame.size.height);
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        mapRegion.center = CLLocationCoordinate2DMake(100, 100); // anything not valid
        settings = Settings.sharedInstance;
        //        if (courseData==nil) courseData = [[CourseData alloc] init];
        NSArray * images = [NSArray arrayWithObjects:@"gray-normal", @"gray-highlighted", @"green-normal", @"green-highlighted", nil];
        for (int i=0; i<4; i++) buttonImage[i] = [UIImage imageNamed:[images objectAtIndex:i]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitsChanged:) name:@"unitsChanged" object:nil];
    }
    return self;
}

//-(void)loadView {
//    NSLog(@"loadview");
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

// copies the track from currentTrack into an overlay
-(int)copyTrackData {
    MKPolyline * old = currentTrackPolyLine;
    currentTrackPolyLine = [ergometerViewController.tracker.track polyLine];
    [mapView addOverlay:currentTrackPolyLine];
    if (old!=nil) [mapView removeOverlay:old];
    return currentTrackPolyLine.pointCount;
}

// copies the start/stop pins from the currentTrack into annotations
-(void)copyTrackPins {
    NSArray * new = ergometerViewController.tracker.track.pins;
    // first remove old pins
    for (MKPointAnnotation * p in trackPins) if (![new containsObject:p]) [mapView removeAnnotation:p];
    // then add new ones
    for (MKPointAnnotation * p in new) if (![trackPins containsObject:p]) [mapView addAnnotation:p];
    // and register which annotations we have in the view...
    self.trackPins = [new copy];
}


// this method updates the course polyline and total distance label
-(void)updateCourse {
    // first save the current course...
    settings.courseData = courseData;
    if (currentCoursePolyline != nil || courseData.isValid) {
        MKPolyline * old = currentCoursePolyline;
        
        if (courseData.isValid) {
            currentCoursePolyline = [courseData polyline];
            [mapView addOverlay:currentCoursePolyline];
            distanceLabel.text = dispLength(courseData.length);
            //            distanceLabel.hidden = NO;
        } else {
            //            distanceLabel.hidden = YES;
            distanceLabel.text = @"";
        }
        [mapView removeOverlay:old];
    }
}

-(void)updateCoursePins {
    if (showCoursePins) {
        NSMutableArray * shown = [NSMutableArray arrayWithArray:[mapView annotations]];
        for (MKPointAnnotation * a in mapView.annotations) if (![a isKindOfClass:[CourseAnnotation class]]) [shown removeObject:a];
        // shown now is the collection of annotations in mapView of type CourseAnnotation
        // remove pins that are no longer in the currentCourse
        for (MKPointAnnotation * a in shown) if (![courseData.annotations containsObject:a]) [mapView removeAnnotation:a];
        // then add the missing pins
        for (MKPointAnnotation * a in courseData.annotations) if (![shown containsObject:a])
            [mapView addAnnotation:a];
    } else {
        // simply remove all pins of type CourseAnnotation
        for (MKPointAnnotation * a in mapView.annotations) if ([a isKindOfClass:[CourseAnnotation class]]) [mapView removeAnnotation:a];
    }
}

-(void)updateButtons {
    [courseButton setBackgroundImage:buttonImage[2*courseMode] forState:UIControlStateNormal];
    [courseButton setBackgroundImage:buttonImage[2*courseMode+1] forState:UIControlStateHighlighted];
    courseButton.enableShift = courseMode;
    distanceLabel.hidden = !courseMode;
    showCoursePins = courseMode;
    [self updateCoursePins];
    pinButton.hidden = !courseMode;
}

// called from notification, triggered when setttings changed...
-(void)unitsChanged:(NSNotification*)notification {
    //    NSLog(@"map set units");
    [courseData update]; // update annotation distances, in the labels
    distanceLabel.text = dispLength(courseData.length);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    CGFloat h = mapView.bounds.size.height;
//    NSLog(@"%f", self.tabBarController.tabBar.bounds.size.height);
//    h -= self.tabBarController.tabBar.bounds.size.height;
    h -= 40; // height of tabbar?
    CGFloat w = mapView.bounds.size.width;
    [self.view insertSubview:mapView atIndex:0];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    if (CLLocationCoordinate2DIsValid(mapRegion.center)) mapView.region = mapRegion;
    trackPins = nil;
    // add Pin button
    pinButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [pinButton addTarget:self action:@selector(pinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat pinHeight = pinButton.bounds.size.height;
    pinButton.center = CGPointMake(10+pinHeight/2, 10+pinHeight/2);
    [mapView addSubview:pinButton];
    // course button
    courseButton = [ShiftButton buttonWithType:UIButtonTypeCustom];
    [courseButton addTarget:self action:@selector(courseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [courseButton setTitle:@"course" forState:UIControlStateNormal];
    //    courseButton.center = CGPointMake(w/2, pinHeight/2+10);
    courseButton.frame = CGRectMake((w-84)/2, 10, 84, pinHeight);
    [courseButton onShiftTarget:self action:@selector(deleteCourse:)];
    [mapView addSubview:courseButton];
    // clear
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"PLBlueMinus"] forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(w - pinHeight - 10, 10, pinHeight, pinHeight);
    clearButton.hidden = YES;
    [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:clearButton];
    //    NSLog(@"load");
    [mapView addAnnotations:courseData.annotations];
    // distance label
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(mapView.bounds.size.width - 100, mapView.bounds.size.height - 20, 100, 20)];
    distanceLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    distanceLabel.textAlignment = UITextAlignmentRight;
    [mapView addSubview:distanceLabel];
    // navigator arrow
    zoomModeControl= [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"UIButtonBarLocate"], @"track", @"course", @"none",nil]];
    zoomModeControl.frame = CGRectMake((w-250)/2, h-70, 250, 40);
    zoomModeControl.tintColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    zoomModeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [zoomModeControl addTarget:self action:@selector(zoomChanged:) forControlEvents:UIControlEventValueChanged];
    zoomModeControl.selectedSegmentIndex = kZoomModeHere;
    //    zoomModeControl.alpha = 0.9;
    [mapView addSubview:zoomModeControl];
    zoomMode = kZoomModeHere;
    [self unitsChanged:nil]; // initialize...
    crossHair = [[CrossHair alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    crossHair.center = mapView.center;
    crossHair.hidden = YES;
    [mapView addSubview:crossHair];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    mapRegion = mapView.region;
    self.mapView = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    courseData = settings.courseData;
    [self updateCourse];
    [self updateCoursePins];
    [self copyTrackData];
    [self copyTrackPins];
    [self updateButtons];
    //    NSLog(@"appear");
}


-(void)pinButtonPressed:(id)sender {
    CourseAnnotation * new = [courseData addWaypoint:mapView.centerCoordinate];
    [mapView addAnnotation:new];
    [self updateCourse];
}

-(void)clearButtonPressed:(id)sender {
    /*
     NSArray * selected = mapView.selectedAnnotations;
     NSLog(@"%@", mapView.selectedAnnotations);
     if (selected.count) {
     for (MKPointAnnotation * a in selected) {
     [currentCourse removeWaypoint:a];
     [mapView removeAnnotation:a];
     }
     }
     */
    if (selectedPin) {
        [courseData removeWaypoint:selectedPin];
        [mapView removeAnnotation:selectedPin];
        [self updateCourse];
    }
}

-(void)courseButtonPressed:(id)sender {
    //    NSString * path = [[NSBundle mainBundle] pathForResource:@"course" ofType:@"data"];
    //    [[Settings sharedInstance] setObject:currentCourse forKey:@"currentCourse"];
    courseMode = !courseMode;
    [self updateButtons];
}

-(void)deleteCourse:(id)sender {
    [courseData clear];
    [self updateCourse];
    [self updateCoursePins];
}

-(BOOL)validCourse {
    return courseMode && courseData != nil && courseData.count>1;
}

-(BOOL)outsideCourse {
    return [self validCourse] * [courseData outsideCourse:mapView.userLocation.coordinate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void)zoom {
    MKUserLocation * here = mapView.userLocation;
    switch (zoomMode) {
        case kZoomModeHere:
            if (here.location.horizontalAccuracy>0)
                [mapView setCenterCoordinate:here.coordinate animated:YES];
            break;
        case kZoomModeTrack:
            if (ergometerViewController.tracker.track.count > 0)
                [mapView setRegion:[ergometerViewController.tracker.track region] animated:YES];
            break;
        case kZoomModeCourse:
            if (courseData.count>0)
                [mapView setRegion:[courseData region] animated:YES];
            break;
        default:
            break;
    }
}

-(void)refreshTrack {
    [self copyTrackData];
    if (zoomMode == kZoomModeTrack) [self zoom];
}


#pragma mark MKMapViewDelegate
// centers the map as soon as location is found
-(void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
    static BOOL centered = NO;
    if (!centered)
        [mv setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000)];
    centered = YES;
    [self copyTrackData];
    if (zoomMode==kZoomModeHere) [self zoom];
}

// this draws the track
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (overlay == currentTrackPolyLine) {
        MKPolylineView * trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.strokeColor = [UIColor purpleColor];
        trackView.lineWidth = 5;
        return trackView;
    }
    if (overlay == currentCoursePolyline) {
        MKPolylineView * routeView = [[MKPolylineView alloc] initWithPolyline:overlay];
        routeView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
        routeView.lineWidth = 15;
        return routeView;
    }
    return nil;
}

// this adds start/stop points, and the course pins
- (MKAnnotationView *) mapView: (MKMapView *) mv viewForAnnotation:(id<MKAnnotation>) annotation
{
    // the home location
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier: @"pin"];
    if (pin == nil)
    {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"pin"];
    } else {
        pin.annotation = annotation;
    }
    if ([annotation isKindOfClass:[CourseAnnotation class]]) {
        pin.pinColor = MKPinAnnotationColorGreen;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        // this does not work like this...
        //        if ([pin.annotation.title isEqualToString:@"1"])
        //            pin.image = [UIImage imageNamed:@"leftarrow"];
        //        pin.leftCalloutAccessoryView = leftButton;
        //        pin.rightCalloutAccessoryView = rightButton;
    } else {
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = NO;
        pin.canShowCallout = YES;
        pin.draggable = NO;
    }
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        //        NSLog(@"Dragging ended: %f %f", view.annotation.coordinate.longitude, view.annotation.coordinate.latitude);
        [courseData update];
        [self updateCourse];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[CourseAnnotation class]]) {
        clearButton.hidden = NO;
        mySelectionCount++;
        selectedPin = view.annotation;
        //        NSLog(@"%@", mapView.selectedAnnotations);
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[CourseAnnotation class]]) {
        clearButton.hidden = (--mySelectionCount == 0);
        //        selectedPin = nil;
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        crossHair.alpha = 1;
        crossHair.hidden = !courseMode;
        //       zoomModeControl.alpha=1;
    } completion:^(BOOL finished){}];
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        crossHair.alpha = 0;
    } completion:^(BOOL finished){
        if (finished) crossHair.hidden = YES;
        crossHair.alpha = 1;
    }];
    //    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{zoomModeControl.alpha=0.5;} completion:^(BOOL finished){}];
}

-(void)zoomChanged:(id)sender {
    zoomMode = [sender selectedSegmentIndex];
    [self zoom];
    // this makes the bezel unsharp...
    //    zoomModeControl.alpha=1;
    //    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{zoomModeControl.alpha=0.9;} completion:^(BOOL finished){}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}



@end
