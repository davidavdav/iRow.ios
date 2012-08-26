//
//  VectorMA.m
//  iRow
//
//  Created by David van Leeuwen on 8/2/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "VectorMA.h"

@implementation VectorMA

-(VectorMA*)initWithLength:(size_t)inlength capacity:(size_t)incapacity {
    self = [super init];
    if (self) {
        length = inlength;
        capacity = incapacity;
        ma = [[Matrix alloc] init:capacity by:length];
        sx = [[Vector alloc] initWithLength:length];
        sxx = [[Matrix alloc] init:length by:length];
        N = 0;
        pos = -1;
    }
    return self;
}

-(void)add:(Vector*)v {
    assert(v.length == length);
    pos = (pos+1) % capacity;
    if (N>=capacity) {
        Vector * old = [ma rowAtIndex:pos];
        [sx subtractVector:old];
        [sxx subtractMatrix:[old outerSelf]];
    } else 
        N++;
    [ma setRow:pos toVector:v];
    [sx addVector:v];
    [sxx addMatrix:[v outerSelf]];
}

-(Vector*)mean {
    Vector * mean = [[Vector alloc] initWithVector:sx];
    if (N>0) {
        for (real_t * mi = mean.x; mi<mean.x+length; mi++) {
            *mi /= N;
        }
    }
    return mean;
}

-(Matrix*) cov {
    Matrix * cov = [[Matrix alloc] initWithMatrix:sxx];
    Matrix * sxs = [sx outerSelf];
    if (N>1) {
        for (real_t * ci = cov.x, * si = sxs.x; ci < cov.x + length*length; ci++, si++) *ci = (*ci - *si/N) / (N-1);
    } else 
        [cov clear];
    return cov;
}

@end
