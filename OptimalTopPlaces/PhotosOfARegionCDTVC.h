//
//  PhotosOfARegionCDTVC.h
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Region.h"

@interface PhotosOfARegionCDTVC : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) Region *region;

@end
