//
//  FirstViewController.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "ErgometerViewController.h"

#define kStrokeAveragingDuration (10.0)

enum {
    kCurrentLocation=0x1,
    kCurrentStroke=0x2,
    kCumulatives=0x4
};

@interface ErgometerViewController ()
-(void)inspectLocation:(id)sender;
@end

@implementation ErgometerViewController

@synthesize startButton;
@synthesize curSpeedLabel, aveSpeedLabel;
@synthesize strokeFreqLabel, aveStrokeFreqLabel, totalStrokesLabel;
@synthesize timeLabel, distanceLabel, distanceUnitLabel;

@synthesize track, trackingState;

@synthesize mapViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Ergometer", @"Ergometer");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        // location tracking
        dTlocation = 1.0;
        lastStrokeTime = 0;
        track = [[Track alloc] initWithPeriod:dTlocation];
        track.delegate = self;
        // stroke counting
        dTmotion = 0.1;
        stroke = [[Stroke alloc] initWithPeriod:dTmotion duration:kStrokeAveragingDuration];
        stroke.delegate=self;
        // init of vars
        trackingState = kTrackingStateStopped;
        speedUnit = kSpeedTimePer500m;
        curSpeed = -1; // invalid
        aveSpeed = -1;
        strokeFreq = 0;
        aveStrokeFreq = 0;
        totalStrokes = 0;
        totalTime = 0;
        NSArray * imageNames = [NSArray arrayWithObjects:@"start-button", @"start-button-highlighted", @"stop-button", @"stop-button-highlighted", nil];
        for (int i=0; i<4; i++) buttonImage[i] = [UIImage imageNamed:[imageNames objectAtIndex:i]];
        // mapviewcontroller must be set from appdelegate
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(NSString*)hms:(NSTimeInterval) t{
    int h = t / 3600;
    t -= h*3600;
    int m = t / 60;
    t -= m*60;
    int s = t;
    if (h) return [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
    else return [NSString stringWithFormat:@"%d:%02d",m,s];
}

-(void)displaySpeed:(CLLocationSpeed)speed atLabel:(UILabel*)label {
    NSTimeInterval timePer500 = 500.0/speed;
    label.text = speed>0 ? [self hms:timePer500] : @"––:––"; // en-dash
    
}

-(void)updateValues:(uint)mask {
    if (mask & kCurrentLocation) {
        [self displaySpeed:curSpeed atLabel:curSpeedLabel];
        aveSpeed = distance / totalTime;
        [self displaySpeed:aveSpeed atLabel:aveSpeedLabel];
        distanceLabel.text = [[NSString stringWithFormat:@"%4.0f", distance] stringByReplacingOccurrencesOfString:@"-" withString:@"–"];
        distanceLabel.textColor = distance < 0 ? [UIColor redColor] : mapViewController.validCourse && trackingState==kTrackingStateTracking ? [UIColor blueColor] : [UIColor blackColor];
    }
    if (mask & kCurrentStroke) {
        strokeFreqLabel.text = [NSString stringWithFormat:@"%2.0f ", strokeFreq];
        aveStrokeFreqLabel.text = totalTime>0 ? [NSString stringWithFormat:@"%4.1f", 60 * totalStrokes / totalTime] :
        @"–"; // en-dash
        totalStrokesLabel.text = [NSString stringWithFormat:@"%d",totalStrokes];
    }
    if (mask & kCumulatives) {
        // average speed since start
        timeLabel.text = [self hms:totalTime];
    }
}

// this updates the button according to the recordingstate
-(void)setButtonAppearance {
    int started=0;
    NSString * title;
    switch (trackingState) {
        case kTrackingStateStopped:
            started=0;
            title = mapViewController.outsideCourse ? @"Start at kick-off" : @"Start";
            break;
        case kTrackingStateWaiting:
            started=0;
            title = @"Waiting for start";
            break;
        case kTrackingStateTracking:
            started=1;
            title = @"Finish";
            break;
        default:
            break;
    }
    [startButton setBackgroundImage:buttonImage[2*started] forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImage[2*started+1] forState:UIControlStateHighlighted];  
    [startButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - View lifecycle

// this may also be called after another tab was selected.  Or not. 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateValues:kCurrentLocation | kCurrentStroke | kCumulatives];
    [self setButtonAppearance];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setButtonAppearance];
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

-(void)locationUpdate:(id)sender {
    CLLocation * here = track.locationManager.location;
    if (here==nil) return;
    // current speed
    distanceUnitLabel.text = [NSString stringWithFormat:@"(%1.0f)    m",here.horizontalAccuracy];
    curSpeed = here.speed;
    unsigned int mask = kCurrentLocation;
    Course * cc = mapViewController.currentCourse;
    switch (trackingState) {
        case kTrackingStateTracking:
            [track add:here];
            if (mapViewController.validCourse) {
                distance = [cc distanceToFinish:here.coordinate];
                if (distance==0) [self startPressed:self];
            } else 
                distance = track.totalDistance;
            CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
            totalTime = now - startTime;
            mask |= kCumulatives;
            break;
        case kTrackingStateWaiting:
            if (mapViewController.validCourse) {
                distance = -[cc distanceToStart:here.coordinate];
                if (distance>0) {
                    [self startPressed:self];
                }
            }
            break;
        case kTrackingStateStopped:
            break;
        default:
            break;
    }
    [self updateValues:mask];
}

-(IBAction)startPressed:(id)sender {
    Course * cc = mapViewController.currentCourse;
    BOOL outsideCourse = [cc outsideCourse:track.locationManager.location.coordinate];
    switch (trackingState) {
        case kTrackingStateStopped:
            if (mapViewController.courseMode && cc.isValid && outsideCourse) {
                trackingState = kTrackingStateWaiting;
                break;
            } // else fall through
        case kTrackingStateWaiting:
            trackingState = kTrackingStateTracking;
            startTime = CFAbsoluteTimeGetCurrent();
            startStroke = stroke.strokes;
            [track reset];
            [self locationUpdate:self];
            [track addPin:@"start" atLocation:track.startLocation];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        case kTrackingStateTracking:
            trackingState = kTrackingStateStopped;
            totalTime = CFAbsoluteTimeGetCurrent() - startTime;
            totalStrokes = stroke.strokes - startStroke;
            distance = track.totalDistance;
            [track addPin:@"finish" atLocation:track.stopLocation];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        default:
            break;
    }
    
    [self setButtonAppearance];
}



#pragma mark StrokeDelegate
-(void)stroke:(id)sender {
    if (trackingState) totalStrokes = stroke.strokes - startStroke;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (lastStrokeTime>0) {
        CFTimeInterval period = now - lastStrokeTime;
        strokeFreq = 60.0 / period;
        [self updateValues:kCurrentStroke];
    }
    lastStrokeTime = now;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
