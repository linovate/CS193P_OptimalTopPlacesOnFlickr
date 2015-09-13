//
//  Photo.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) Region *whereTook;
@property (nonatomic, retain) Photographer *whoTook;

//for extractRegionName only:
//@property (strong, nonatomic) NSString *regionName;

@end
