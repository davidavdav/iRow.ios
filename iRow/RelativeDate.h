//
//  RelativeDate.h
//  iSTI
//
//  Created by David van Leeuwen on 08-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate ( RelativeDate )

-(NSString*)relativeDate;
-(NSString*)mediumDate;
-(NSString*)shortTime;
-(NSString*) mediumshortDateTime;

@end
