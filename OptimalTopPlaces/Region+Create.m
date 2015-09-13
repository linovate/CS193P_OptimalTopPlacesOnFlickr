//
//  Region+Create.m
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "Region+Create.h"

@implementation Region (Create)

+ (Region *)regionWithName: (NSString *) name
                inManagedObjectContext: (NSManagedObjectContext *) context
{
    Region *region=nil;
    
    if ([name length]){
        
        NSFetchRequest *request= [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate=[NSPredicate predicateWithFormat:@"name= %@",name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count]>1)){
            //handle error.
        }else if (![matches count]){
            region=[NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
            region.name = name;
            //This(setting popularity) is most likely unnecessary!!!
            //region.popularity= [NSNumber numberWithInt:1];
            //region.popularity= [NSNumber numberWithUnsignedLong:[region.photographersOfTheRegion count]];
        }else{
            region = [matches lastObject];
            region.popularity= [NSNumber numberWithUnsignedLong:[region.photographersOfTheRegion count]];
        }
    }
    return region;
}

@end
