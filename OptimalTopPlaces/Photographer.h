//
//  Photographer.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photosOfThePhotographer;
@property (nonatomic, retain) NSSet *whichRegionsPhotographerTookPhotosIn;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosOfThePhotographerObject:(Photo *)value;
- (void)removePhotosOfThePhotographerObject:(Photo *)value;
- (void)addPhotosOfThePhotographer:(NSSet *)values;
- (void)removePhotosOfThePhotographer:(NSSet *)values;

- (void)addWhichRegionsPhotographerTookPhotosInObject:(Region *)value;
- (void)removeWhichRegionsPhotographerTookPhotosInObject:(Region *)value;
- (void)addWhichRegionsPhotographerTookPhotosIn:(NSSet *)values;
- (void)removeWhichRegionsPhotographerTookPhotosIn:(NSSet *)values;

@end
