//
//  Matrix+operations.h
//  iRow
//
//  Created by David van Leeuwen on 21-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Matrix.h"
#import "Vector.h"

@interface Matrix (operations)

-(Vector*)timesV:(Vector*)y;

-(Vector*)biggestEig:(Vector*)initVector tolerance:(double)tol;

@end
