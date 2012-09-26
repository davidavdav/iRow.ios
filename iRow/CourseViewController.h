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
#import "ExportSelector.h"


@interface CourseViewController : UITableViewController <UITextFieldDelegate> {
    UIBarButtonItem * leftBarItem;
    Settings * settings;
    Course * course;
    CourseData * courseData;
    BOOL editing;
    ExportSelector * es;
//    NSString * name;
//    NSString * waterway;
}

@property (strong, nonatomic) Course * course;

@end
