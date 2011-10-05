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

#import "Track.h"
#import "Stroke.h"
#import "MapViewController.h"

enum {
    kSpeedTimePer500m,
    kSpeedMeterPerSecond,
    kSpeedKMPerHour,
    kSpeedMilesPerHour,
} speedUnit;

enum {
    kTrackingStateStopped=0,
    kTrackingStateWaiting,
    kTrackingStateTracking
};

@interface ErgometerViewController : UIViewController <TrackDelegate, StrokeDelegate> {
    // interface
    IBOutlet UIButton * startButton;
    IBOutlet UILabel * curSpeedLabel;
    IBOutlet UILabel * aveSpeedLabel;
    IBOutlet UILabel * strokeFreqLabel;
    IBOutlet UILabel * aveStrokeFreqLabel;
    IBOutlet UILabel * totalStrokesLabel;
    IBOutlet UILabel * timeLabel;
    IBOutlet UILabel * distanceLabel;
    IBOutlet UILabel * distanceUnitLabel;
    MapViewController * mapViewController;
    // button colors/images
    UIImage * buttonImage[4];
    // location
    int trackingState;
    float dTlocation;
    Track * track;
    Stroke * stroke;
    float dTmotion;
    CFAbsoluteTime lastStrokeTime;
    int startStroke; 
    int speedUnit;
    // display values
    CFAbsoluteTime startTime;
    CLLocationSpeed curSpeed, aveSpeed;
    double strokeFreq, aveStrokeFreq;
    int totalStrokes;
    CFTimeInterval totalTime;
    double distance;
}

@property (strong, nonatomic) IBOutlet UIButton * startButton;

@property (strong, nonatomic) IBOutlet UILabel * curSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel * aveSpeedLabel;

@property (strong, nonatomic) IBOutlet UILabel * strokeFreqLabel;
@property (strong, nonatomic) IBOutlet UILabel * aveStrokeFreqLabel;
@property (strong, nonatomic) IBOutlet UILabel * totalStrokesLabel;

@property (strong, nonatomic) IBOutlet UILabel * timeLabel;
@property (strong, nonatomic) IBOutlet UILabel * distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel * distanceUnitLabel;


@property (strong, nonatomic) Track * track;
@property (readonly) int trackingState;

@property (strong, nonatomic) MapViewController * mapViewController;


-(IBAction)startPressed:(id)sender;

@end
