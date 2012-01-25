//
//  FirstViewController.h
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#import "Tracker.h"
#import "Stroke.h"
#import "MapViewController.h"
#import "Settings.h"

enum {
    kTrackingStateStopped=0,
    kTrackingStateWaiting,
    kTrackingStateTracking
};

@interface ErgometerViewController : UIViewController <TrackerDelegate, StrokeDelegate> {
    // interface
    IBOutlet UIButton * startButton;
    IBOutlet UILabel * curSpeedLabel, * curSpeedUnitLabel;
    IBOutlet UILabel * aveSpeedLabel, * aveSpeedUnitLabel;
    IBOutlet UILabel * strokeFreqLabel;
    IBOutlet UILabel * aveStrokeFreqLabel;
    IBOutlet UILabel * totalStrokesLabel;
    IBOutlet UILabel * timeLabel;
    IBOutlet UILabel * distanceLabel;
    IBOutlet UILabel * distanceUnitLabel;
    IBOutlet UILabel * totalOrLeft;
    UIView * strokeBeat;
    MapViewController * mapViewController;
    // button colors/images
    UIImage * buttonImage[6];
    // location
    int trackingState;
    float dTlocation;
    Tracker * tracker;
    Stroke * stroke;
    float dTmotion;
    CFAbsoluteTime lastStrokeTime;
//    int startStroke; 
    // display values
    CFAbsoluteTime startTime;
    CLLocationSpeed curSpeed, aveSpeed;
    double strokeFreq, aveStrokeFreq;
    int totalStrokes;
    CFTimeInterval totalTime;
    double totalDistance, finishDistance;
    Settings * settings;
    double positionAccuracy;
}

@property (strong, nonatomic) IBOutlet UIButton * startButton;

@property (strong, nonatomic) IBOutlet UILabel * curSpeedLabel, * curSpeedUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel * aveSpeedLabel, * aveSpeedUnitLabel;

@property (strong, nonatomic) IBOutlet UILabel * strokeFreqLabel;
@property (strong, nonatomic) IBOutlet UILabel * aveStrokeFreqLabel;
@property (strong, nonatomic) IBOutlet UILabel * totalStrokesLabel;

@property (strong, nonatomic) IBOutlet UILabel * timeLabel;
@property (strong, nonatomic) IBOutlet UILabel * distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel * distanceUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel * totalOrLeft;

@property (readonly, strong, nonatomic) Stroke * stroke;


@property (strong, nonatomic) Tracker * tracker;
@property (readonly) int trackingState;

@property (strong, nonatomic) MapViewController * mapViewController;

-(IBAction)startPressed:(id)sender;

@end
