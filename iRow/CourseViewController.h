//
//  SaveCourseViewController.h
//  iRow
//
//  Created by David van Leeuwen on 03-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "Course.h"
#import "Settings.h"

@interface CourseViewController : UITableViewController <UITextFieldDelegate> {
    UIBarButtonItem * leftBarItem;
    Settings * settings;
    Course * currentCourse;
    CourseData * courseData;
    BOOL editing;
    NSString * name;
    NSString * waterway;
}

@property (strong, nonatomic) Course * currentCourse;

@end
