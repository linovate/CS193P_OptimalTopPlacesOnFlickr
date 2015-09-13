//
//  Photo+Flickr.m
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Region+Create.h"

@implementation Photo (Create)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo* photo = nil;
    NSError* error;
    
    // Start fetching photos
    NSString* photo_id = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",photo_id];
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    // Analyze fectch request
    if (error || !matches || [matches count] > 1) {
        NSLog(@"Something went wrong with entity Photo in Core Data");
    }
    else if ([matches count]){
        photo = [matches firstObject];
    }
    else{
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = photo_id;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.longitude = [NSNumber numberWithDouble:[photoDictionary[FLICKR_LONGITUDE] doubleValue]];
        photo.latitude = [NSNumber numberWithDouble:[photoDictionary[FLICKR_LATITUDE] doubleValue]];
        
        
        NSString *photographerName= [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        NSString *regionName= [photoDictionary valueForKeyPath:@"Region"];
        
        photo.whoTook= [Photographer photographerWithName:photographerName inManagedObjectContext:context];
        
        photo.whereTook= [Region regionWithName:regionName inManagedObjectContext:context];
        
        [photo.whereTook addPhotographersOfTheRegionObject:photo.whoTook];
        
        photo.whereTook.popularity=[NSNumber numberWithUnsignedLong:[photo.whereTook.photographersOfTheRegion count]];
        
        
        
//        NSLog(@"photo.whereTook.name is : %@",photo.whereTook.name);
//        NSLog(@"photo.whoTook.name is : %@",photo.whoTook.name);
//        NSLog(@"photo.whereTook.popularity is : %@\n\n",photo.whereTook.popularity);
//        
    }
    
    return photo;
}


//+(void)getRegionNameOfAPhoto:(NSDictionary *)photo withCompletionHandler: (void (^) (NSString*))completionHandler
//{
//    __block NSString *regionNameInBlock=nil;
//    
//    NSURL *urlForRegion= [FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]];
//    
//#warning Block Main Thread, which is used by Main queue.
//    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
//    dispatch_async(fetchQ, ^{
//        NSData *jsonResultsForAPlace=[NSData dataWithContentsOfURL:urlForRegion];
//        NSDictionary *propertyListResultForAPlace=[NSJSONSerialization JSONObjectWithData:jsonResultsForAPlace
//                                                                                  options:0
//                                                                                    error:NULL];
//        regionNameInBlock=[FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResultForAPlace];
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
////            [photo setObject:regionNamedInBlock forKey:@"region"];
////            NSLog(@"regionName in main_queue, %@",regionNamedInBlock);
//
//            if (completionHandler) {
//                completionHandler(regionNameInBlock);
//            }
//            
//        });
//        NSLog(@"regionName in fetchQ, %@",regionNameInBlock);
//    });
//    
//}


//+(NSString *)getRegionNameOfAPhoto:(NSDictionary *)photo
//{
//    NSString *regionName=nil;
//    
//    NSURL *urlForRegion= [FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]];
//    
//        
//    NSData *jsonResultsForAPlace=[NSData dataWithContentsOfURL:urlForRegion];
//    NSDictionary *propertyListResultForAPlace=[NSJSONSerialization JSONObjectWithData:jsonResultsForAPlace
//                                                                              options:0
//                                                                                error:NULL];
//    
//    regionName=[FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResultForAPlace];
//    
//   // NSLog(@"regionName inside getRegionNameOfAPlace before return is: %@",regionName);
//    
//    return regionName;
//}
   

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary* photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}



@end
