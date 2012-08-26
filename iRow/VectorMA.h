//
//  VectorMA.h
//  iRow
//
//  Created by David van Leeuwen on 8/2/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "Vector.h"

@interface VectorMA : NSObject {
    size_t length, capacity; 
    size_t pos; // last filled position
    size_t N; // # current valid values
	vector_t type;
    Matrix * ma;
    Vector * sx;
	Matrix * sxx;
}

-(VectorMA*)initWithLength:(size_t)length capacity:(size_t)capacity;
-(void)add:(Vector*)v;

// statistics
-(Vector*)mean;
-(Matrix*)cov;

@end
