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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        mapRegion.center = CLLocationCoordinate2DMake(100, 100);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(int)copyTrackData {
    CLLocationCoordinate2D * trackData;
    int n = [ergometerViewController.track newTrackData:&trackData];
    MKPolyline * trackPolyline = [MKPolyline polylineWithCoordinates:trackData count:n];
    NSArray * old = mapView.overlays;
    [mapView addOverlay:trackPolyline];
    [mapView removeOverlays:old];
    free(trackData);
    return n;
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
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView * trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.strokeColor = [UIColor purpleColor];
        trackView.lineWidth = 5;
        return trackView;
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
    pin.pinColor = MKPinAnnotationColorRed;
    pin.animatesDrop = NO;
    pin.canShowCallout = YES;
    return pin;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}



@end
