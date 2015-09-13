//
//  Region.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSSet *photosOfTheRegion;
@property (nonatomic, retain) NSSet *photographersOfTheRegion;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosOfTheRegionObject:(Photo *)value;
- (void)removePhotosOfTheRegionObject:(Photo *)value;
- (void)addPhotosOfTheRegion:(NSSet *)values;
- (void)removePhotosOfTheRegion:(NSSet *)values;

- (void)addPhotographersOfTheRegionObject:(Photographer *)value;
- (void)removePhotographersOfTheRegionObject:(Photographer *)value;
- (void)addPhotographersOfTheRegion:(NSSet *)values;
- (void)removePhotographersOfTheRegion:(NSSet *)values;

@end
