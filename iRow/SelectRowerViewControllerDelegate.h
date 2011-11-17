//
//  SelectRowerViewControllerDelegate.h
//  iRow
//
//  Created by David van Leeuwen on 17-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rower.h"

@protocol SelectRowerViewControllerDelegate <NSObject>

-(void)selectedRowers:(NSSet*)rowers;
-(void)selectedCoxswain:(Rower*)rower;

@end
