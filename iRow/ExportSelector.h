//
//  ExportSelector.h
//  iRow
//
//  Created by David van Leeuwen on 9/26/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

#import "MySegmentedControl.h"

enum ExportTypes {
    kExportDBitem,
    kExportKML
};
 
@interface ExportSelector : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    MySegmentedControl * segmentedControl;
    NSURL * exportFile;
    id item;
    NSString * itemType;
    enum ExportTypes exportType;
    UIViewController * viewController;
    NSArray * recipients;
}

@property (strong,nonatomic) MySegmentedControl * segmentedControl;
@property (strong, nonatomic) id item;
@property (strong, nonatomic) UIViewController * viewController;
@property (strong, nonatomic) NSArray * recipients;

@end
