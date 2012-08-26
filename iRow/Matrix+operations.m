//
//  Matrix+operations.m
//  iRow
//
//  Created by David van Leeuwen on 21-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Matrix+operations.h"

@implementation Matrix (operations)

-(Vector*)timesV:(Vector*)y {
    assert (ncol == y.length);
    Vector * res = [[Vector alloc] initWithLength:nrow];
    for (real_t * mrow = x, * mrowend = x+ncol*nrow, *r = res.x; mrow<mrowend; mrow+=rowstride, r++) 
        for (real_t *m = mrow, * mend = mrow+ncol, *v = y.x; m<mend; m+=colstride, v++)
            *r += *m * *v;
    return res;
}

-(Vector*)biggestEig:(Vector *)initVector tolerance:(double)tol {
    assert(nrow==ncol);
    Vector * y = [[Vector alloc] initWithVector:initVector];
    double sameDirection=0;
    int maxit = 100;
    do {
        Vector * oy = [[Vector alloc] initWithVector:y];
        y = [self timesV:y];
        [y norm];
        sameDirection = fabs([y inner:oy] - 1);
        maxit--;
//        NSLog(@"%f", sameDirection);
    } while (sameDirection > tol && maxit>0);
    return y;
}

@end
