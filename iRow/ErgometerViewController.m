//
//  FirstViewController.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "ErgometerViewController.h"
#import "Settings.h"
#import "utilities.h"

#define kStrokeAveragingDuration (10.0)

enum {
    kCurrentLocation=0x1,
    kCurrentStroke=0x2,
    kCumulatives=0x4
};

#define kSpeedFactorKmph (3.6)
#define kSpeedFactorMph (2.237415)

#define kSpeedLabels @"m:s / 500 m", @"m/s", @"km/h", @"mph"

@implementation ErgometerViewController

@synthesize startButton;
@synthesize curSpeedLabel, aveSpeedLabel, curSpeedUnitLabel, aveSpeedUnitLabel;
@synthesize strokeFreqLabel, aveStrokeFreqLabel, totalStrokesLabel;
@synthesize timeLabel, distanceLabel, distanceUnitLabel, totalOrLeft;

@synthesize tracker, trackingState;

@synthesize speedUnit, unitSystem, stroke;

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
        tracker = [[Tracker alloc] initWithPeriod:dTlocation];
        tracker.delegate = self;
        // warning: this potentially leads to a bug because we changed Track to Trackdata...
        id lastTrack = [[Settings sharedInstance] loadObjectForKey:@"lastTrack"];
        if ([lastTrack isKindOfClass:[TrackData class]]) tracker.track = lastTrack;
        // stroke counting
        dTmotion = 0.1;
        stroke = [[Stroke alloc] initWithPeriod:dTmotion duration:kStrokeAveragingDuration];
        stroke.delegate=self;
        stroke.sensitivity = Settings.sharedInstance.logSensitivity;
        // init of vars
        trackingState = kTrackingStateStopped;
        speedUnit = [[[Settings sharedInstance] loadObjectForKey:@"speedUnit"] intValue];
        curSpeed = -1; // invalid
        aveSpeed = -1;
        strokeFreq = 0;
        aveStrokeFreq = 0;
        totalStrokes = 0;
        totalTime = 0;
        NSArray * imageNames = [NSArray arrayWithObjects:@"start-button", @"start-button-highlighted", @"wait-button", @"wait-button-highlighted", @"stop-button", @"stop-button-highlighted", nil];
        for (int i=0; i<6; i++) buttonImage[i] = [UIImage imageNamed:[imageNames objectAtIndex:i]];
//        NSLog(@"%f %f", buttonImage[0].size.width, buttonImage[0].size.height);
        // mapviewcontroller must be set from appdelegate
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(NSString*)hms:(NSTimeInterval) t {
    if (t<0) return @"–:––";
    int h = t / 3600;
    t -= h*3600;
    int m = t / 60;
    t -= m*60;
    int s = t;
    if (h) return [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
    else return [NSString stringWithFormat:@"%d:%02d",m,s];
}

-(void)displaySpeed:(CLLocationSpeed)speed atLabel:(UILabel*)label {
    if (speed<0 || isnan(speed)) 
        label.text = @"–"; // en-dash
    else 
        switch (speedUnit) {
        case kSpeedTimePer500m:
            ;
            NSTimeInterval timePer500 = 500.0/speed;
                label.text = speed==0 ? @"––:––" : [self hms:timePer500];
            break;
        case kSpeedDistanceUnitPerHour:
            speed *= unitSystem ? kSpeedFactorMph : kSpeedFactorKmph;
        case kSpeedMeterPerSecond:
            label.text = [NSString stringWithFormat:@"%3.1f",speed];
            break;
        default:
            break;
    }
    
}

// this updates the values of the ergometer display
-(void)updateValues:(uint)mask {
    CFTimeInterval dur=totalTime;
    if (mask & kCurrentLocation) {
        [self displaySpeed:curSpeed atLabel:curSpeedLabel];
        aveSpeed = totalDistance / totalTime;
        [self displaySpeed:aveSpeed atLabel:aveSpeedLabel];
        double distance;
        switch (trackingState) {
            case kTrackingStateStopped:
                distance = totalDistance;
                 break;
            case kTrackingStateWaiting:
                distance = -finishDistance;
                dur = (mapViewController.validCourse && curSpeed>0) ? finishDistance / curSpeed : 0;
                break;
            case kTrackingStateTracking:
                if (mapViewController.validCourse) {
                    distance = finishDistance;
                    dur = totalTime>2.0 && aveSpeed > 0 ? distance / aveSpeed : -1; 
                } else {
                    distance = totalDistance;
                }
                break;
        }
        distanceLabel.text = [dispLengthOnly(distance) stringByReplacingOccurrencesOfString:@"-" withString:@"–"];
        distanceUnitLabel.text = [NSString stringWithFormat:@"(%@)    %@",dispLengthOnly(positionAccuracy), dispLengthUnit(distance)];
    }
    if (mask & kCurrentStroke) {
        strokeFreqLabel.text = [NSString stringWithFormat:@"%2.0f ", strokeFreq];
        aveStrokeFreqLabel.text = totalTime>0 ? [NSString stringWithFormat:@"%4.1f", 60 * totalStrokes / totalTime] :
        @"–"; // en-dash
        int strokes=totalStrokes;
        switch (trackingState) {
            case kTrackingStateTracking:
                if (mapViewController.validCourse) 
                    strokes = totalDistance>0 ? totalStrokes * finishDistance/totalDistance : -1;
                break;
            case kTrackingStateWaiting:
                if (mapViewController.validCourse)
                    strokes = 0;
            default:
                break;
        }
        totalStrokesLabel.text = strokes<0 ? @"–" : [NSString stringWithFormat:@"%d",strokes];
    }
    if (mask & kCumulatives) {
        timeLabel.text = [self hms:dur];
    }
}

// this updates the button according to the recordingstate
-(void)setButtonAppearance {
    int started=0;
    NSString * title;
    switch (trackingState) {
        case kTrackingStateStopped:
            started=0;
            title = mapViewController.outsideCourse ? @"Prepare for start" : @"Start";
            break;
        case kTrackingStateWaiting:
            started=1;
            title = @"Waiting to cross start line";
            break;
        case kTrackingStateTracking:
            started=2;
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
//    GlassView * speedGlass = [[GlassView alloc] initWithFrame:curSpeedLabel.bounds];
    UIButton * speedGlass = [UIButton buttonWithType:UIButtonTypeCustom];
    speedGlass.frame = curSpeedLabel.bounds;
    speedGlass.backgroundColor = [UIColor clearColor];
    [speedGlass addTarget:self action:@selector(changeSpeedUp:) forControlEvents:UIControlEventTouchUpInside];
    curSpeedLabel.userInteractionEnabled = YES;
    [curSpeedLabel addSubview:speedGlass];
    speedGlass = [UIButton buttonWithType:UIButtonTypeCustom];
    speedGlass.frame = aveSpeedLabel.bounds;
    speedGlass.backgroundColor = [UIColor clearColor];
    [speedGlass addTarget:self action:@selector(changeSpeedDown:) forControlEvents:UIControlEventTouchUpInside];
    aveSpeedLabel.userInteractionEnabled = YES;
    [aveSpeedLabel addSubview:speedGlass];
    strokeBeat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glow-black"]];
    strokeBeat.frame = strokeFreqLabel.bounds;
    [strokeFreqLabel addSubview:strokeBeat];
    strokeBeat.alpha = 0;
    [self updateValues:kCurrentLocation | kCurrentStroke | kCumulatives];
    [self setButtonAppearance];
    [self setUnitSystem:Settings.sharedInstance.unitSystem];
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

-(void)changeSpeedUnit {
    static NSArray * labels = nil;
    if (labels==nil) labels = [NSArray arrayWithObjects:kSpeedLabels, nil];
    [self updateValues:kCurrentLocation];
    int index=speedUnit + (speedUnit==kSpeedDistanceUnitPerHour) * unitSystem;
    aveSpeedUnitLabel.text = curSpeedUnitLabel.text = [labels objectAtIndex:index];
}

-(void)changeSpeedUp:(id)sender {
    speedUnit = (speedUnit+1) % 3;
    [self changeSpeedUnit];
}

-(void)changeSpeedDown:(id)sender {
    speedUnit = (speedUnit+2) % 3;
    [self changeSpeedUnit];
}

-(void)locationUpdate:(id)sender {
    CLLocation * here = tracker.locationManager.location;
    if (here==nil) return;
    // current speed
    curSpeed = here.speed;
    unsigned int mask = kCurrentLocation;
    Course * cc = mapViewController.currentCourse;
    switch (trackingState) {
        case kTrackingStateTracking:
            [tracker.track add:here];
            CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();                
            totalTime = now - startTime;
            totalDistance = tracker.track.totalDistance;
            if (mapViewController.validCourse) {
                finishDistance = [cc distanceToFinish:here.coordinate];
                if (finishDistance==0) [self startPressed:self];
            }
            mask |= kCumulatives;
            if (self.tabBarController.selectedIndex==1) [mapViewController refreshTrack];
            break;
        case kTrackingStateWaiting:
            if (mapViewController.validCourse) {
                finishDistance = [cc distanceToStart:here.coordinate];
                if (finishDistance<=0) {
                    [self startPressed:self];
                    finishDistance = [cc distanceToFinish:here.coordinate];
                }
                mask |= kCumulatives;
            }
            break;
        case kTrackingStateStopped:
            break;
        default:
            break;
    }
    positionAccuracy = here.horizontalAccuracy;
    [self updateValues:mask];
}

-(IBAction)startPressed:(id)sender {
    Course * cc = mapViewController.currentCourse;
    int outsideCourse = [cc outsideCourse:tracker.locationManager.location.coordinate];
    switch (trackingState) {
        case kTrackingStateStopped:
            if (mapViewController.courseMode && cc.isValid && outsideCourse) {
                trackingState = kTrackingStateWaiting;
                cc.direction = outsideCourse>0;
                [mapViewController.currentCourse updateTitles:outsideCourse];
                // user interface changes
                totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = [UIColor redColor];
                totalOrLeft.text = @"Still to go…";
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                startTime = CFAbsoluteTimeGetCurrent();
                startStroke = stroke.strokes;
                break;
            } // else fall through
        case kTrackingStateWaiting:
            trackingState = kTrackingStateTracking;
            startTime = CFAbsoluteTimeGetCurrent();
            startStroke = stroke.strokes;
            [tracker.track reset];
            [self locationUpdate:self];
            // userinterface changes
            totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = (mapViewController.validCourse) ? [UIColor blueColor] : [UIColor blackColor];
            [tracker.track addPin:@"start" atLocation:tracker.track.startLocation];
            [mapViewController copyTrackPins];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        case kTrackingStateTracking:
            trackingState = kTrackingStateStopped;
            totalTime = CFAbsoluteTimeGetCurrent() - startTime;
            totalStrokes = stroke.strokes - startStroke;
            totalDistance = tracker.track.totalDistance;
            // user interface changes
            [tracker.track addPin:@"finish" atLocation:tracker.track.stopLocation];
            totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = [UIColor blackColor];
            totalOrLeft.text = @"Total";
            [mapViewController copyTrackPins];
            [[Settings sharedInstance] setObject:tracker.track forKey:@"lastTrack"];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        default:
            break;
    }
    
    [self setButtonAppearance];
}

-(void)setUnitSystem:(int)us {
    unitSystem = us;
    [self changeSpeedUnit];
    [self updateValues:kCurrentStroke|kCurrentLocation|kCumulatives];
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
    strokeBeat.alpha = 1;
    [UIView animateWithDuration:1.0 animations:^{
        strokeBeat.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
