//
//  SaveCourseViewController.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"


@interface SaveCourseViewController : UITableViewController <UITextFieldDelegate> {
    Course * currentCourse;
    NSString * name;
    NSString * waterway;
}

@property (strong, nonatomic) Course * currentCourse;

@end
