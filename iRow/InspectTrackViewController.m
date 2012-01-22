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
#import "Vector.h"
#import "Filter.h"

enum {
    kPaneMap=0,
    kPaneStroke
} selectedPaneType;

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
        CLLocationDistance min = 1e9;
        int mi = -1, offset=0, minoffset=-1;
        MKPolyline * minp;
        for (MKPolyline * pl in mapView.overlays) {
            for (int i=0; i<pl.pointCount; i++) {
                CLLocationDistance d = MKMetersBetweenMapPoints(mp, pl.points[i]);
                if (d<min) {
                    min=d;
                    mi=i;
                    minp=pl;
                    minoffset=offset;
                }
            }
            offset += pl.pointCount;
        }
        self.annotation.coordinate = MKCoordinateForMapPoint(minp.points[mi]);
        if (delegate) [delegate hereAnnotationMoved:self.annotation.coordinate index:minoffset+mi];
    }    
}

@end


@implementation InspectTrackViewController

@synthesize trackData;
@synthesize stroke;

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

-(void)updateStroke:(CFTimeInterval)t {
    // find out the relevant trigger moments for this time
    int ti = lround(t/stroke.period); // time index
    int a=0, b=Ntrigger-1;
    while (b-a>1) {
        int m = (b+a)/2;
        if (trigger[m] > ti) 
            b=m;
        else
            a=m;
    } // trigger[a] <= ti <= trigger[b]
    [plot reset];
    int A = MAX(0,a-2), B = MIN(Ntrigger-2, a-1+2);
    NSLog(@"%d - %d", A, B);
    for (; A<B; A++) {
        [plot.plotArea penup];
        float length = trigger[A+1]-trigger[A];
        for (int j=trigger[A]; j<trigger[A+1]; j++) {
            [plot plotX:(j-trigger[A])/length Y:yacc.x[j]];
        }
    }
    [plot.plotArea setNeedsDisplay];
}

-(void)sliderChanged:(id)sender {
//    double dist = slider.value * trackData.totalDistance;
    double time = slider.value * trackData.totalTime;
    CLLocation * l = [trackData interpolateTime:time];
    here.coordinate = l.coordinate;
//    CFTimeInterval dt = [l.timestamp timeIntervalSinceDate:[(CLLocation*)[trackData.locations objectAtIndex:0] timestamp]];
    timeLabel.text = [NSString stringWithFormat:@"%@ m:s",hms(time)];
    distLabel.text = dispLength(l.altitude); // special encoding
    speedLabel.text = [NSString stringWithFormat:@"%@ %@",dispSpeedOnly(l.speed, Settings.sharedInstance.speedUnit),dispSpeedUnit(Settings.sharedInstance.speedUnit)];
    if (selectedPane == kPaneStroke) [self updateStroke:time];
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
    speedLabel.text = [NSString stringWithFormat:@"%@ %@",dispSpeedOnly(l.speed, Settings.sharedInstance.speedUnit),dispSpeedUnit(Settings.sharedInstance.speedUnit)];
    slider.value = d/trackData.totalDistance; // FIXME must be based on a truncated cumdist
    return;   
}

-(void)setTrigger {
    float threshold = stroke.threshold;
    int sign=1;
    if (trigger != NULL) free(trigger);
    MALLOC(int, trigger, yacc.length/2); // _should_ be big enough
    int N=0;
    for (int i=0; i<yacc.length; i++) {
        float yf = [bpf sample:yacc.x[i]];
        if (yf * sign < 0 && fabs(yf)>threshold) {
            sign = (yf>0) ? 1 : -1;
            if (sign>0) { // count positive accelerations...
                trigger[N++] = i;
            }
        }
    }
    trigger = realloc(trigger, N*sizeof(int));
    Ntrigger = N;
}

-(void)loadPlot:(UIView*)view {
    plot = [[Plot alloc] initWithFrame:view.bounds];
    [plot setMarginLeft:40 right:10 bottom:20 top:20]; // inset for the bars themselves
    [plot setLimitsXmin:0 Xmax:1 Ymin:-1 Ymax:1];
    plot.showXaxis = YES;
    plot.lineWidth = 1;
    [plot setup];
    [view addSubview:plot];
    if (stroke == nil) return;
    bpf = [[Filter alloc] initWithFilter:stroke.bpy];
    yacc = [stroke accData:1]; // 1: Y accel
    // this follows the same algorithm as in stroke:
    [self setTrigger];
    [self updateStroke:0];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [super loadView];
//    NSLog(@"%f super", CFAbsoluteTimeGetCurrent()-start);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"switch" style:UIBarButtonItemStylePlain target:self action:@selector(switchPressed:)];
    CGFloat h = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - self.navigationController.navigationBar.bounds.size.height;
    CGFloat w = self.view.frame.size.width;
    CGFloat hSlider = 60, hLabel = 40, hScrollView = h-hLabel-hSlider;
    // scrollview: underlying all other views
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, hLabel, w, hScrollView)];    
    scrollView.contentSize = CGSizeMake(2*w, hScrollView);
    scrollView.pagingEnabled = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
//    NSLog(@"%f scrollView", CFAbsoluteTimeGetCurrent()-start);    
    // mapview on the first pane
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, w, hScrollView)];
    [scrollView addSubview:mapView];
    mapView.delegate = self;
//    NSLog(@"%f mapView", CFAbsoluteTimeGetCurrent()-start);
    //slider below, fixed
    slider = [[UISlider alloc] initWithFrame:CGRectMake(10, h - hSlider, w-20, hSlider)];
    [slider setThumbImage:[UIImage imageNamed:@"volume-slider-fat-knob-red"] forState:UIControlStateHighlighted];
    [slider setThumbImage:[UIImage imageNamed:@"volume-slider-fat-knob"] forState:UIControlStateNormal];
    [self.view addSubview:slider];
//    NSLog(@"%f slider", CFAbsoluteTimeGetCurrent()-start);
    //labels above, fixed
    UIView * panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, hSlider)];
    [self.view addSubview:panel];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    distLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-100-10, 10, 100, 20)];
    for (UILabel * l in [NSArray arrayWithObjects:timeLabel,distLabel,speedLabel,nil] ) {
        l.textColor = UIColor.whiteColor;
        l.backgroundColor = UIColor.blackColor;
        l.font = [UIFont systemFontOfSize:20];
    }
    distLabel.textAlignment = UITextAlignmentCenter;
    speedLabel.textAlignment = UITextAlignmentRight;
    [panel addSubview:timeLabel];
    [panel addSubview:distLabel];
    [panel addSubview:speedLabel];
//    NSLog(@"%f labels", CFAbsoluteTimeGetCurrent()-start);
    // graph on the second scrollview pane
    UIView * graphView = [[UIView alloc] initWithFrame:CGRectMake(w, 0, w, hScrollView)];    
    graphView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:graphView];
    [self loadPlot:graphView];
//    [self performSelector:@selector(loadPlot:) withObject:graphView afterDelay:0.1];
//    [NSThread detachNewThreadSelector:@selector(loadPlot:) toTarget:self withObject:graphView];
//    NSLog(@"%f plot", CFAbsoluteTimeGetCurrent()-start);
    if (trackData != nil) {
        for (MKPolyline * p in trackData.rowingPolyLines) {
//            NSLog(@"%@ %d", polyLine, polyLine.pointCount);
            NSLog(@"%@", p.title);
            [mapView addOverlay:p];
        }
        [mapView setRegion:trackData.region];
        [mapView addAnnotations:trackData.pins];
        // slider 
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        here = [[HereAnnotation alloc] init];
        [self sliderChanged:self];    
        [mapView addAnnotation:here];
//        NSLog(@"%f annotations", CFAbsoluteTimeGetCurrent()-start);
    }
}

-(void)switchPressed:(id)sender {
    CGPoint o = selectedPane ? CGPointZero : CGPointMake(scrollView.contentSize.width/2, 0);
    if (selectedPane == kPaneMap) 
        [self updateStroke:slider.value * trackData.totalTime];
    [scrollView setContentOffset:o animated:YES];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)sv {
    selectedPane = sv.contentOffset.x > sv.contentSize.width/4; 
    self.title = selectedPane==kPaneMap ? @"Track map" : @"Stroke profile";
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
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView * trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        NSLog(@"%@", overlay.title);
        trackView.strokeColor = [overlay.title isEqualToString:@"faster"] ? [UIColor purpleColor] : [UIColor redColor];
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
