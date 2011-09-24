//
//  SecondViewController.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "MapViewController.h"
#import "ErgometerViewController.h"

@implementation MapViewController

@synthesize ergometerViewController;
@synthesize mapView;
@synthesize shownPins;
@synthesize currentTrackPolyLine, currentRoutePolyline;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        mapRegion.center = CLLocationCoordinate2DMake(100, 100);
        pathNr = 0;
        userPath = [NSMutableArray arrayWithCapacity:100];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(int)copyTrackData {
    MKPolyline * old = currentTrackPolyLine;
    currentTrackPolyLine = [ergometerViewController.track trackData];
    [mapView addOverlay:currentTrackPolyLine];
    if (old!=nil) [mapView removeOverlay:old];
    return currentTrackPolyLine.pointCount;
}

-(void)copyPinData {
    NSArray * new = ergometerViewController.track.pins;
    if ([new isEqualToArray:shownPins]) {
        return;
    }
    [mapView removeAnnotations:shownPins];
    [mapView addAnnotations:new];
    self.shownPins = [new copy];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mapView];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    if (CLLocationCoordinate2DIsValid(mapRegion.center)) mapView.region = mapRegion;
    shownPins = nil;
    UIButton * pinButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [pinButton addTarget:self action:@selector(pinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat size = pinButton.bounds.size.width;
    [mapView addSubview:pinButton];
    saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(40, 0, 50, size);
    saveButton.hidden = YES;
    [mapView addSubview:saveButton];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"GKClearButton"] forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(mapView.bounds.size.width - size, 0, size, size);
    clearButton.hidden = YES;
    [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:clearButton];
     //    NSLog(@"load");
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
    if ([self copyTrackData]) 
        [mapView setRegion:[ergometerViewController.track region] animated:YES];
    [self copyPinData];
//    NSLog(@"appear");
}

-(void)updateUserPath {
    if (currentRoutePolyline != nil || userPath.count>1) {
        MKPolyline * old = currentRoutePolyline;
        if (userPath.count>1) {
            CLLocationCoordinate2D * points = (CLLocationCoordinate2D*) calloc(sizeof(CLLocationCoordinate2D), userPath.count);
            for (int i=0; i<userPath.count; i++) points[i] = [[userPath objectAtIndex:i] coordinate];
            currentRoutePolyline = [MKPolyline polylineWithCoordinates:points count:userPath.count];
            free(points);
            [mapView addOverlay:currentRoutePolyline];
        }
        [mapView removeOverlay:old];
    }    
}

-(void)pinButtonPressed:(id)sender {
    PathAnnotation * new = [[PathAnnotation alloc] initWithID:pathNr];
    new.coordinate = mapView.centerCoordinate;
    [mapView addAnnotation:new];
    // keep a copy
    [userPath addObject:new];
    pathNr++;
    [self updateUserPath];
    saveButton.hidden = userPath.count<2;
}

-(void)clearButtonPressed:(id)sender {
    NSArray * selected = mapView.selectedAnnotations;
    NSLog(@"%@", mapView.selectedAnnotations);
    if (selected.count) {
        for (MKPointAnnotation * a in selected) {
            [userPath removeObject:a];
            [mapView removeAnnotation:a];
            NSLog(@"%@", userPath);
        }
    }
    [self updateUserPath];
    saveButton.hidden = userPath.count<2;
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

#pragma mark mkmapviewdelegate
// centers the map as soon as location is found
-(void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
    static BOOL centered = NO;
    if ([self copyTrackData]) 
        [mv setRegion:[ergometerViewController.track region] animated:YES];
    else if (!centered) 
        [mv setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000)];
    centered=YES;
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
    if (overlay == currentRoutePolyline) {
        MKPolylineView * routeView = [[MKPolylineView alloc] initWithPolyline:overlay];
        routeView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
        routeView.lineWidth = 15;
        return routeView;
    }
    return nil;
}

// this adds start/stop points
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
    if ([annotation isKindOfClass:[PathAnnotation class]]) {
        pin.pinColor = MKPinAnnotationColorGreen;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
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
        [self updateUserPath];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PathAnnotation class]]) {
        clearButton.hidden = NO;
        NSLog(@"%@", mapView.selectedAnnotations);
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PathAnnotation class]]) {
        clearButton.hidden = YES;        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}



@end

@implementation PathAnnotation;

-(id)initWithID:(int)i {
    self = [self init];
    if (self) ID = i;
    self.title = [NSString stringWithFormat:@"%d", i+1];
    return self;
}

/* 
 -(void)setCoordinate:(CLLocationCoordinate2D)c {
    NSLog(@"new coordinate");
    coordinate = c;
}
  */ 

@end
