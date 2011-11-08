//
//  Boat.h
//  iRow
//
//  Created by David van Leeuwen on 04-11-11.
//  Copyright (c) 2011 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Boat : NSManagedObject

@property (nonatomic, retain) NSDate * buildDate;
@property (nonatomic, retain) NSNumber * dragFactor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * mass;
@property (nonatomic, retain) NSSet *tracks;
@end

@interface Boat (CoreDataGeneratedAccessors)

- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;
@end
