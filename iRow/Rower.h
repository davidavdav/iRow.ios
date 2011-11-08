//
//  Rower.h
//  iRow
//
//  Created by David van Leeuwen on 06-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rower : NSManagedObject

@property (nonatomic, retain) NSDate * birthDate;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * mass;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) NSSet *courses;
@end

@interface Rower (CoreDataGeneratedAccessors)

- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;
- (void)addCoursesObject:(NSManagedObject *)value;
- (void)removeCoursesObject:(NSManagedObject *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;
@end
