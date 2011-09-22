//
//  Filter.m
//  iRow
//
//  Created by David van Leeuwen on 20-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Filter.h"

@implementation Filter

-(Filter*)initWithFile:(NSString*)file {
	self = [super init];
	if (self != nil) {
		NSString * path = [[NSBundle mainBundle] pathForResource:file ofType:@"filt"];
		FILE * fd = fopen([path UTF8String], "rb");
		if (fd==NULL) return nil;
		char buf[4];
		fread(buf, sizeof(char), 4, fd); 
		if (strncmp(buf, "filt", 4)) {
			NSLog(@"Wrong type of file %4s\n", buf);
			return nil;
		}
		// we're going to ignore errors for a while..
		UInt32 header_size;
		fread(&header_size, sizeof(header_size), 1, fd);
		UInt32 number_a, number_b;
		fread(&number_a, sizeof(number_a), 1, fd); Na=number_a;
		fread(&number_b, sizeof(number_b), 1, fd); Nb=number_b;
		// this is where the data starts, I suppose
		a = [[Vector alloc] initWithLength:Na];
		b = [[Vector alloc] initWithLength:Nb];
		// read in the data one by one, copying, for type conversion purposes
		for (int i=0; i<Na; i++) {
			double c;
			fread(&c, sizeof(c), 1, fd); a.x[i]=c; a.x[i] /= a.x[0];
		}
		for (int i=0; i<Nb; i++) {
			double c;
			fread(&c, sizeof(c), 1, fd); b.x[i]=c; b.x[i] /= a.x[0];
		}
		double odd=0;
		for (int i=1; i<Nb; i+=2) odd += fabs(b.x[i]);
		cheby = odd<1e-7; 
		state = [[Vector alloc] initWithLength:Na-1];
	}
	return self;
}


// This function simply copies an existing filter
-(Filter*)initWithFilter:(Filter*)f {
	self = [super init];
	Na = f->Na; a = f->a; // use the same a and b array
	Nb = f->Nb; b = f->b; 
	cheby = f->cheby;
	// but keep our own copy of the state variables. 
	state = [[Vector alloc] initWithVector:f->state];
	return self;
}

-(void)reset {
	[state clear];
}

// this is a direct form II implementation
// Note Na and Nb must probably be the same for this!
-(sample_t)sample:(sample_t)x {
	// history of intermediate output is reversed in state_y, i.e., 0 is the most recent
	real_t * s = state.x;
	coef_t * aend = a.x+Nb, *bend = b.x+Nb;
	for (coef_t * ai = a.x+1; ai<aend; ai++, s++) x -= *ai * *s; // Nb-1 states. 
	sample_t y = x*b.x[0];
	s = state.x+cheby;
	int step=1+cheby;
	for (coef_t * bi=b.x+1+cheby; bi<bend; bi+=step, s+=step) y += *bi * *s;
	[state shiftRight];
	state.x[0] = x;
	return y;
}

@end
