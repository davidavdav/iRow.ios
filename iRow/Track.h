//
//  Track.h
//  iRow
//
//  Created by David van Leeuwen on 15-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Boat, Course, Rower;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * locality;
@property (nonatomic, retain) NSData * motion;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * period;
@property (nonatomic, retain) NSNumber * strokes;
@property (nonatomic, retain) NSData * track;
@property (nonatomic, retain) Boat *boat;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *rowers;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addRowersObject:(Rower *)value;
- (void)removeRowersObject:(Rower *)value;
- (void)addRowers:(NSSet *)values;
- (void)removeRowers:(NSSet *)values;
@end
