//
//  DBExport.h
//  iRow
//
//  Created by David van Leeuwen on 9/17/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track+Import.h"

@interface DBExport : NSObject <NSCoding> {
    NSMutableDictionary * items;
}

-(void)addItem:(id)item;
-(NSArray*)itemsOfType:(NSString*)type;

@property (readonly)NSMutableDictionary * items;

@end
