//
//  InspectTrackViewController.m
//  iRow
//
//  Created by David van Leeuwen on 14-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "InspectTrackViewController.h"

@implementation InspectTrackViewController

@synthesize track;

/*
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

-(id)init {
    self = [super init];
    if (self) {
        // hmm
    
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height - self.tabBarController.tabBar.bounds.size.height;
    mapView = [[MKMapView alloc] initWithFrame:frame];
    [self.view addSubview:mapView];
    mapView.delegate = self;
    if (track != nil) {
        self.title = track.name;
        trackData = [NSKeyedUnarchiver unarchiveObjectWithData:track.track];
        polyLine = trackData.polyLine;
        [mapView addOverlay:polyLine];
        [mapView setRegion:trackData.region];
        [mapView addAnnotations:trackData.pins];
    }
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// this draws the track
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (overlay == polyLine) {
        MKPolylineView * trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.strokeColor = [UIColor purpleColor];
        trackView.lineWidth = 5;
        UIGestureRecognizer * rec = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(trackTouched:)];
        [trackView addGestureRecognizer:rec];
        return trackView;
    }
    return nil;
}

// this draws the pins
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
    pin.pinColor = MKPinAnnotationColorPurple;
    pin.animatesDrop = NO;
    pin.canShowCallout = YES;
    pin.draggable = NO;
    return pin;
}

-(void)trackTouched:(id)sender {
    NSLog(@"Wow, I feel touched!");
}

@end
