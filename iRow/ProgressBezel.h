//
//  ProgressBezel.h
//  iRow
//
//  Created by David van Leeuwen on 10/2/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBezel : UIView {
    UIProgressView * progressView;
}

@property (nonatomic) float progress;

@end
