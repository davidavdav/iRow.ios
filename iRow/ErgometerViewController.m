//
//  FirstViewController.m
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "ErgometerViewController.h"
#import "utilities.h"
#import "Track+New.h"

#define kStrokeAveragingDuration (5.0)

enum {
    kCurrentLocation=0x1,
    kCurrentStroke=0x2,
    kCumulatives=0x4
};


@implementation ErgometerViewController

@synthesize startButton;
@synthesize curSpeedLabel, aveSpeedLabel, curSpeedUnitLabel, aveSpeedUnitLabel;
@synthesize strokeFreqLabel, aveStrokeFreqLabel, totalStrokesLabel;
@synthesize timeLabel, distanceLabel, distanceUnitLabel, totalOrLeft;

@synthesize tracker, trackingState;

@synthesize stroke;

@synthesize mapViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    NSLog(@"Nibname %@", nibBundleOrNil);
   if (self) {
//        NSLog(@"Ergometer height %4.1f", self.view.frame.size.height);
        self.title = NSLocalizedString(@"Ergometer", @"Ergometer");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        settings = Settings.sharedInstance;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensitivityChanged:) name:@"sensitivityChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitsChanged:) name:@"unitsChanged" object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


// this updates the values of the ergometer display
-(void)updateValues:(uint)mask {
    CFTimeInterval dur=totalTime;
    if (mask & kCurrentLocation) {
        curSpeedLabel.text = dispSpeedOnly(curSpeed, settings.speedUnit);
        aveSpeed = totalDistance / totalTime;
        aveSpeedLabel.text = dispSpeedOnly(aveSpeed, settings.speedUnit);
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
        timeLabel.text = hms(dur);
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

-(void)changeSpeedUnit {
    [self updateValues:kCurrentLocation];
    int index=settings.speedUnit + (settings.speedUnit==kSpeedDistanceUnitPerHour) * settings.unitSystem;
    aveSpeedUnitLabel.text = curSpeedUnitLabel.text = dispSpeedUnit(index, NO);
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
    [self changeSpeedUnit];
    [self updateValues:kCurrentStroke|kCurrentLocation|kCumulatives];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreReady:) name:kNotificationPersistentStoreSetup object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudUpdate:) name:kNotificationICloudUpdate object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPersistentStoreSetup object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationICloudUpdate object:nil];
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


-(void)changeSpeedUp:(id)sender {
    settings.speedUnit = (settings.speedUnit+1) % 3;
    [self changeSpeedUnit];
}

-(void)changeSpeedDown:(id)sender {
    settings.speedUnit = (settings.speedUnit+2) % 3;
    [self changeSpeedUnit];
}

-(void)locationUpdate:(id)sender {
    CLLocation * here = tracker.locationManager.location;
    if (here==nil) return;
    // current speed
    curSpeed = here.speed;
    unsigned int mask = kCurrentLocation;
    CourseData * cc = mapViewController.courseData;
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
    CourseData * cc = mapViewController.courseData;
    int outsideCourse = [cc outsideCourse:tracker.locationManager.location.coordinate];
    switch (trackingState) {
        case kTrackingStateStopped:
            if (mapViewController.courseMode && cc.isValid && outsideCourse) {
                trackingState = kTrackingStateWaiting;
                cc.direction = outsideCourse>0;
                [mapViewController.courseData updateTitles:outsideCourse];
                // user interface changes
                totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = [UIColor redColor];
                totalOrLeft.text = @"Still to go…";
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                startTime = CFAbsoluteTimeGetCurrent();
//                startStroke = stroke.strokes;
                break;
            } // else fall through
        case kTrackingStateWaiting:
            trackingState = kTrackingStateTracking;
            startTime = CFAbsoluteTimeGetCurrent();
//            startStroke = stroke.strokes;
            [tracker.track reset];
            [stroke reset];
            [stroke startRecording];
            [self locationUpdate:self];
            // userinterface changes
            totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = (mapViewController.validCourse) ? [UIColor blueColor] : [UIColor blackColor];
            [tracker.track addPin:@"start" atLocation:tracker.track.startLocation];
            [mapViewController copyTrackPins];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        case kTrackingStateTracking:
            trackingState = kTrackingStateStopped;
            [stroke stopRecording];
            totalTime = CFAbsoluteTimeGetCurrent() - startTime;
//            totalStrokes = stroke.strokes - startStroke;
            totalStrokes = stroke.strokes;
            totalDistance = tracker.track.totalDistance;
            // user interface changes
            [tracker.track addPin:@"finish" atLocation:tracker.track.stopLocation];
            totalStrokesLabel.textColor = timeLabel.textColor = distanceLabel.textColor = [UIColor blackColor];
            totalOrLeft.text = @"Total";
            [mapViewController copyTrackPins];
            [[Settings sharedInstance] setObject:tracker.track forKey:@"lastTrack"];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            if (settings.autoSave) {
                Track * newTrack = [Track newTrackWithTrackdata:tracker.track stroke:stroke inManagedObjectContext:settings.moc];
                newTrack.boat = settings.currentBoat;
                newTrack.period = [NSNumber numberWithFloat:tracker.period];
                if (mapViewController.courseMode && cc.isValid) newTrack.course = settings.currentCourse;
                NSError * error;
                if ([settings.moc save:&error]) {
                    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Saved" message:[NSString stringWithFormat:@"This track has been saved with name %@",newTrack.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self performSelector:@selector(dismissMessage:) withObject:a afterDelay:2.0];
                    [a show];
                } else {
                    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, I could not save this track" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [a show];
                }
            }
            break;
        default:
            break;
    }
    
    [self setButtonAppearance];
}

-(void)dismissMessage:(UIAlertView *)alertView {
    if (alertView != nil) [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)sensitivityChanged:(NSNotification*)notification {
     stroke.sensitivity = settings.logSensitivity;
}

-(void)unitsChanged:(NSNotification*)notification {
    [self changeSpeedUnit];
}

#pragma mark StrokeDelegate
-(void)stroke:(id)sender {
    if (trackingState) totalStrokes = stroke.strokes; // - startStroke;
//    NSLog(@"%d %d", totalStrokes, startStroke);
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (lastStrokeTime>0) {
        CFTimeInterval period = now - lastStrokeTime;
        strokeFreq = 60.0 / period;
        [self updateValues:kCurrentStroke];
    }
    lastStrokeTime = now;
    strokeBeat.alpha = 1;
//    float brightness = [[UIScreen mainScreen] brightness];
//    [[UIScreen mainScreen] setBrightness:brightness+0.2];
    [UIView animateWithDuration:1.0 animations:^{
        strokeBeat.alpha = 0;
    } completion:^(BOOL finished) {
//        [[UIScreen mainScreen] setBrightness:brightness];
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
