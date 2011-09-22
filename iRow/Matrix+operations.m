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
    if (ncol != y.length) {
        NSLog(@"Inconsisted columns: %lu vs %ld", ncol, y.length);
        return nil;
    }
    Vector * res = [[Vector alloc] initWithLength:nrow];
    for (real_t * mrow = x, * mrowend = x+ncol*nrow, *r = res.x; mrow<mrowend; mrow+=rowstride, r++) 
        for (real_t *m = mrow, * mend = mrow+ncol, *v = y.x; m<mend; m+=colstride, v++)
            *r += *m * *v;
    return res;
}

@end
