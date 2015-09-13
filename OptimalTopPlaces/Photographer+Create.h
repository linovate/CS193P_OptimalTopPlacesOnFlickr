//
//  Photographer+Create.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName: (NSString *) name
                inManagedObjectContext: (NSManagedObjectContext *) context;
@end
