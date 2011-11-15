//
//  Course.h
//  iRow
//
//  Created by David van Leeuwen on 15-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rower, Track;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSData * course;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * waterway;
@property (nonatomic, retain) NSSet *author;
@property (nonatomic, retain) NSSet *tracks;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addAuthorObject:(Rower *)value;
- (void)removeAuthorObject:(Rower *)value;
- (void)addAuthor:(NSSet *)values;
- (void)removeAuthor:(NSSet *)values;
- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;
@end
