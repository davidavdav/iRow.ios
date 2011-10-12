//
//  iRowAppDelegate.h
//  iRow
//
//  Created by David van Leeuwen on 18-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ErgometerViewController.h"
#import "MapViewController.h"


@interface iRowAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    ErgometerViewController * ergometerViewController;
    MapViewController * mapViewController;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
