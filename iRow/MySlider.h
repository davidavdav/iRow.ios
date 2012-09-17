//
//  MySlider.h
//  iRow
//
//  Created by David van Leeuwen on 9/14/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

// This slider inherits from UISlider, it is almost identical, but it allows for a `snap back' to a moved position
// when the finger leaves the screen. 

#import <UIKit/UIKit.h>

#define kHistory 10
#define kMoveUpTime 0.1


@interface MySlider : UISlider {
    double lastValue[kHistory];
    double oldValue;
    CFAbsoluteTime lastTime[kHistory];
    int hind;
    float moveUpTime;
}

@property float moveUpTime;

@end
