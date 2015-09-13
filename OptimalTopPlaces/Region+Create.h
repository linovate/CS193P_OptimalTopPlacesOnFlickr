//
//  Region+Create.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "Region.h"

@interface Region (Create)
+ (Region *)regionWithName: (NSString *) name
                inManagedObjectContext: (NSManagedObjectContext *) context;
@end
