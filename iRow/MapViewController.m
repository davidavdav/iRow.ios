//
//  SecondViewController.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "MapViewController.h"
#import "ErgometerViewController.h"
#import "Settings.h"

enum {
    kZoomModeHere=0,
    kZoomModeTrack,
    kZoomModeCourse,
    kZoomModeNone
};

@implementation MapViewController

@synthesize ergometerViewController;
@synthesize mapView;
@synthesize trackPins, coursePins;
@synthesize currentTrackPolyLine, currentCoursePolyline;
@synthesize currentCourse, courseMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        mapRegion.center = CLLocationCoordinate2DMake(100, 100); // anything not valid
        NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentCourse"];
        if (data) 
            currentCourse = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        else 
            currentCourse = [[Course alloc] init];
        NSArray * images = [NSArray arrayWithObjects:@"gray-normal", @"gray-highlighted", @"green-normal", @"green-highlighted", nil];
        for (int i=0; i<4; i++) buttonImage[i] = [UIImage imageNamed:[images objectAtIndex:i]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

// copies the track from currentTrack into an overlay
-(int)copyTrackData {
    MKPolyline * old = currentTrackPolyLine;
    currentTrackPolyLine = [ergometerViewController.track trackData];
    [mapView addOverlay:currentTrackPolyLine];
    if (old!=nil) [mapView removeOverlay:old];
    return currentTrackPolyLine.pointCount;
}

// copies the start/stop pins from the currentTrack into annotations
-(void)copyTrackPins {
    NSArray * new = ergometerViewController.track.pins;
    if ([new isEqualToArray:trackPins]) {
        return;
    }
    [mapView removeAnnotations:trackPins];
    [mapView addAnnotations:new];
    self.trackPins = [new copy];
}

// this is all very metric
-(NSString*)dispLength:(CLLocationDistance)l {
    // metric
    NSString * s;
    if (l>1e4) 
        s = [NSString stringWithFormat:@"4.1 km",l/1000];
    else 
        s = [NSString stringWithFormat:@"%4.0f m",l];
    return s;
}

// this method updates the course polyline and distance label
-(void)updateCourse {
    // first save the current course...
    [[Settings sharedInstance] setObject:currentCourse forKey:@"currentCourse"];
    if (currentCoursePolyline != nil || currentCourse.isValid) {
        MKPolyline * old = currentCoursePolyline;
        
        if (currentCourse.isValid) {
            currentCoursePolyline = [currentCourse polyline];
            [mapView addOverlay:currentCoursePolyline];
            distanceLabel.text = [self dispLength:currentCourse.length];
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
        for (MKPointAnnotation * a in currentCourse.annotations) if (![shown containsObject:a]) 
            [mapView addAnnotation:a];
    } else {
        for (MKPointAnnotation * a in mapView.annotations) if ([a isKindOfClass:[CourseAnnotation class]]) [mapView removeAnnotation:a];
    }
}

-(void)updateButtons {
    [courseButton setBackgroundImage:buttonImage[2*courseMode] forState:UIControlStateNormal];
    [courseButton setBackgroundImage:buttonImage[2*courseMode+1] forState:UIControlStateHighlighted];
    distanceLabel.hidden = !courseMode;
    showCoursePins = courseMode;
    [self updateCoursePins];
    pinButton.hidden = !courseMode;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    CGFloat h = mapView.bounds.size.height;
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
    courseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [courseButton addTarget:self action:@selector(courseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [courseButton setTitle:@"course" forState:UIControlStateNormal];
//    courseButton.center = CGPointMake(w/2, pinHeight/2+10);
    courseButton.frame = CGRectMake((w-84)/2, 10, 84, pinHeight);
    [courseButton addTarget:self action:@selector(courseButtonDown:) forControlEvents:UIControlEventTouchDown];
//    [courseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mapView addSubview:courseButton];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"PLBlueMinus"] forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(w - pinHeight - 10, 10, pinHeight, pinHeight);
    clearButton.hidden = YES;
    [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:clearButton];
     //    NSLog(@"load");
    [mapView addAnnotations:currentCourse.annotations];
    // distance label
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(mapView.bounds.size.width - 100, mapView.bounds.size.height - 20, 100, 20)];
    distanceLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    distanceLabel.textAlignment = UITextAlignmentRight;
    [mapView addSubview:distanceLabel];
    // navigator arrow
    zoomModeControl= [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"UIButtonBarLocate"], @"track", @"course", @"none",nil]];
    zoomModeControl.frame = CGRectMake((w-200)/2, h-60, 200, 30);
    zoomModeControl.tintColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    zoomModeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [zoomModeControl addTarget:self action:@selector(zoomChanged:) forControlEvents:UIControlEventValueChanged];
    [mapView addSubview:zoomModeControl];
    zoomMode = 0;
    [self updateButtons];
    [self updateCourse];
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
    [self copyTrackData];
    [self copyTrackPins];
//    NSLog(@"appear");
}


-(void)pinButtonPressed:(id)sender {
    MKPointAnnotation * new = [currentCourse addWaypoint:mapView.centerCoordinate];
    [mapView addAnnotation:new];
    [self updateCourse];
    courseButton.hidden = currentCourse.count<2;
}

-(void)clearButtonPressed:(id)sender {
    NSArray * selected = mapView.selectedAnnotations;
    NSLog(@"%@", mapView.selectedAnnotations);
    if (selected.count) {
        for (MKPointAnnotation * a in selected) {
            [currentCourse removeWaypoint:a];
            [mapView removeAnnotation:a];
        }
    }
    [self updateCourse];
    courseButton.hidden = currentCourse.count<2;
}

-(void)courseButtonPressed:(id)sender {
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"course" ofType:@"data"];
//    [[Settings sharedInstance] setObject:currentCourse forKey:@"currentCourse"];
    courseMode = !courseMode;
    [self updateButtons];
}

-(void)courseButtonDown:(id)sender {
    NSLog(@"down");
}

-(BOOL)validCourse {
    return courseMode && currentCourse != nil && currentCourse.count>1;
}

-(BOOL)outsideCourse {
    return [self validCourse] && [currentCourse outsideCourse:mapView.userLocation.coordinate];
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
            if (ergometerViewController.track.count > 0) 
                [mapView setRegion:[ergometerViewController.track region] animated:YES];
            break;
        case kZoomModeCourse:
            if (currentCourse.count>0) 
                [mapView setRegion:[currentCourse region] animated:YES];
            break;
        default:
            break;
    }
}

#pragma mark mkmapviewdelegate
// centers the map as soon as location is found
-(void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
    static BOOL centered = NO;
    if (!centered) 
        [mv setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000)];
    centered = YES;
    [self copyTrackData];
    [self zoom];
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
        pin.pinColor = annotation == currentCourse.start || annotation == currentCourse.finish ? MKPinAnnotationColorPurple : MKPinAnnotationColorGreen;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
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

// not even a delegate

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        NSLog(@"Dragging ended: %f %f", view.annotation.coordinate.longitude, view.annotation.coordinate.latitude);
        [currentCourse update];
        [self updateCourse];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[CourseAnnotation class]]) {
        clearButton.hidden = NO;
//        NSLog(@"%@", mapView.selectedAnnotations);
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[CourseAnnotation class]]) {
        clearButton.hidden = YES;        
    }
}

-(void)zoomChanged:(id)sender {
    zoomMode = [sender selectedSegmentIndex];
    [self zoom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}



@end
