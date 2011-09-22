//
//  Filter.h
//  iRow
//
//  Created by David van Leeuwen on 20-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

// This is based on iSTI's version of Filter.  That was too specific.  I removed references to sampledata. 

#import <Foundation/Foundation.h>

#import "Vector.h"

@interface Filter : NSObject {
	Vector * a, *b; 
	int Na, Nb; // order of filter
	Vector * state; // state of this instance of the filter
	BOOL cheby;
}

// currently used functionss
-(id)initWithFile:(NSString*)file;
-(id)initWithFilter:(Filter*)f ;
-(sample_t)sample:(sample_t)x; // single sample type II implementation

@end
