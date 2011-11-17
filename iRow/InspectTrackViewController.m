//
//  InspectTrackViewController.m
//  iRow
//
//  Created by David van Leeuwen on 14-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import "InspectTrackViewController.h"
#import "utilities.h"
#import "Settings.h"

@implementation HereAnnotation
@end

@implementation HereAnnotationView

@synthesize mapView;
@synthesize delegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (delegate && [delegate respondsToSelector:@selector(hereAnnotationPressed:)]) [delegate hereAnnotationPressed:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (delegate && [delegate respondsToSelector:@selector(hereAnnotationPressed:)]) [delegate hereAnnotationPressed:NO];    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch * t in event.allTouches) {
        CLLocationCoordinate2D c = [mapView convertPoint:[t locationInView:self] toCoordinateFromView:self];
//        NSLog(@"moved %f %f", c.longitude, c.latitude);
        MKMapPoint mp = MKMapPointForCoordinate(c);
        MKPolyline * pl = [mapView.overlays objectAtIndex:0];
        CLLocationDistance min = 1e9;
        int mi = -1;
        for (int i=0; i<pl.pointCount; i++) {
            CLLocationDistance d = MKMetersBetweenMapPoints(mp, pl.points[i]);
            if (d<min) {
                min=d;
                mi=i;
            }
        }
        self.annotation.coordinate = MKCoordinateForMapPoint(pl.points[mi]);
        if (delegate) [delegate hereAnnotationMoved:self.annotation.coordinate index:mi];
    }    
}

@end


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

-(void)sliderChanged:(id)sender {
    double dist = slider.value * trackData.totalDistance;
    CLLocation * l = [trackData interpolate:dist];
    here.coordinate = l.coordinate;
    timeLabel.text = [NSString stringWithFormat:@"%@ m:s",hms([l.timestamp timeIntervalSinceDate:[(CLLocation*)[trackData.locations objectAtIndex:0] timestamp]])];
    distLabel.text = dispLength(dist);
    speedLabel.text = [NSString stringWithFormat:@"%@ %@",dispSpeed(l.speed, Settings.sharedInstance.speedUnit),dispSpeedUnit(Settings.sharedInstance.speedUnit)];
    return;
}

#pragma mark HereAnnotationViewDelegate
-(void)hereAnnotationPressed:(BOOL)down {
//    slider.backgroundColor = down ? [UIColor whiteColor] : [UIColor blackColor];
    slider.highlighted = down;
//    slider.thumbTintColor = down ? [UIColor redColor] : [UIColor whiteColor];
}

-(void)hereAnnotationMoved:(CLLocationCoordinate2D)coordinate index:(NSInteger)index {
    CLLocation * l = [trackData.locations objectAtIndex:index];
    timeLabel.text = [NSString stringWithFormat:@"%@ m:s",hms([l.timestamp timeIntervalSinceDate:[(CLLocation*)[trackData.locations objectAtIndex:0] timestamp]])];
    CLLocationDistance d = [[trackData.cumDist objectAtIndex:index] floatValue];
    distLabel.text = dispLength(d);
    speedLabel.text = [NSString stringWithFormat:@"%@ %@",dispSpeed(l.speed, Settings.sharedInstance.speedUnit),dispSpeedUnit(Settings.sharedInstance.speedUnit)];
    slider.value = d/trackData.totalDistance;
    return;   
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    CGRect frame = self.view.bounds;
    CGFloat h = frame.size.height - self.tabBarController.tabBar.bounds.size.height - self.navigationController.navigationBar.bounds.size.height;
    CGFloat w = frame.size.width;
    CGFloat hSlider = 40, hLabel = 40;
    frame.size.height = h - hLabel - hSlider;
    frame.origin.y = hLabel;
    mapView = [[MKMapView alloc] initWithFrame:frame];
    [self.view addSubview:mapView];
    mapView.delegate = self;
    UIView * panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, hSlider)];
    [self.view addSubview:panel];
    slider = [[UISlider alloc] initWithFrame:CGRectMake(10, h - hSlider, w-20, hSlider)];
    [slider setThumbImage:[UIImage imageNamed:@"volume-slider-fat-knob-red"] forState:UIControlStateHighlighted];
    [slider setThumbImage:[UIImage imageNamed:@"volume-slider-fat-knob"] forState:UIControlStateNormal];
   [self.view addSubview:slider];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    distLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 100, 20)];
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-100-10, 10, 100, 20)];
    for (UILabel * l in [NSArray arrayWithObjects:timeLabel,distLabel,speedLabel,nil] ) {
        l.textColor = UIColor.whiteColor;
        l.backgroundColor = UIColor.blackColor;
        l.font = [UIFont systemFontOfSize:20];
    }
    [panel addSubview:timeLabel];
    [panel addSubview:distLabel];
    [panel addSubview:speedLabel];
    if (track != nil) {
        self.title = (track.name == nil || [track.name isEqualToString:@""]) ? @"Track details" : [NSString stringWithFormat:@"Details for %@",track.name];
        trackData = [NSKeyedUnarchiver unarchiveObjectWithData:track.track];
        polyLine = trackData.polyLine;
        [mapView addOverlay:polyLine];
        [mapView setRegion:trackData.region];
        [mapView addAnnotations:trackData.pins];
        // slider 
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        here = [[HereAnnotation alloc] init];
        [self sliderChanged:self];    
        [mapView addAnnotation:here];
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
/* 
  UIGestureRecognizer * rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trackTouched:)];
        [mapView addGestureRecognizer:rec];
        NSLog(@"trackview %f %f", trackView.frame.origin.x, trackView.frame.origin.y);
 */ 
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
    if ([annotation isKindOfClass:[HereAnnotation class]]) {
        HereAnnotationView * image = (HereAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:@"loc"];
        if (image == nil) image = [[HereAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
        else image.annotation = annotation;
        image.mapView = mapView;
        image.delegate = self;
        image.image = [UIImage imageNamed:@"PLCameraButtonRecordOn"];
        return image;
    }
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier: @"pin"];
    if (pin == nil)
    {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"pin"];
    } else {
        pin.annotation = annotation;
    }
    if ([annotation isKindOfClass:[HereAnnotation class]])
        pin.pinColor = MKPinAnnotationColorGreen;
    else 
        pin.pinColor = MKPinAnnotationColorPurple;
    pin.animatesDrop = NO;
    pin.canShowCallout = NO;
    pin.draggable = NO;
    return pin;
}

/*
-(void)trackTouched:(UIGestureRecognizer*)sender {
    CGPoint p = [sender locationInView:mapView];
    NSLog(@"Location %f %f", p.x, p.y);
}

 */

@end
