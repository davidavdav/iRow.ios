//
//  DBExport.m
//  iRow
//
//  Created by David van Leeuwen on 9/17/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "DBExport.h"

@implementation DBExport

@synthesize items;

-(DBExport*)init {
    self = [super init];
    if (self) {
        items = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

-(void)addItem:(id)item {
    NSString * className = NSStringFromClass([item class]);
    if ([items objectForKey:className] == nil) [items setObject:[NSMutableArray arrayWithCapacity:1] forKey:className];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:item];
    NSString * name = [item name];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:data,@"data",name,@"name",nil];
    [[items objectForKey:className] addObject:dict];
//    NSLog(@"%@", [items description]);
}

-(NSArray*)itemsOfType:(NSString*)type {
    return [items objectForKey:type];
}

-(DBExport*)initWithCoder:(NSCoder *)dec {
    self = [super init];
    if (self) {
        items = [dec decodeObjectForKey:@"items"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeObject:items forKey:@"items"];
}

@end
