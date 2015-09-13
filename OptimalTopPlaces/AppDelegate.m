//
//  AppDelegate.m
//  OptimalTopPlaces
//
//  Created by lordofming on 6/13/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoDatabaseAvailability.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
//#import "Photo+Create.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument* document;
@property (strong, nonatomic) NSManagedObjectContext* photoDatabaseContext;
@property (strong, nonatomic) NSURLSession* downloadSession;

//All blocks (as a property)need to have "copy" because block need to be copied to the heap ! 
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();
@end

@implementation AppDelegate

#define FLICKR_FETCH @"Flickr Fetch"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self createManagedObjectContext];
    [self startFlickrFetch];
    
    return YES;
}

#pragma mark - Properties

-(void)setDocument:(UIManagedDocument *)document{
    _document = document;
}

-(void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext{
    _photoDatabaseContext = photoDatabaseContext;
    
    // post notification to regions CDTVC whenever the context is updated
    NSDictionary* userInfo = self.photoDatabaseContext? @{PhotoDatabaseAvailabilityContext: self.photoDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
    NSLog(@"Notification is posted from AppDelegate.m");
}

-(NSURLSession*)downloadSession{
    if (!_downloadSession) {
        static dispatch_once_t downloadToken;
        dispatch_once(&downloadToken, ^{
            NSURLSessionConfiguration* urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            _downloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    
    return _downloadSession;
}

#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadPhotosFromLocalURL:localFile
                         intoContext:self.photoDatabaseContext
                 andThenExecuteBlock:^{
                     [self downloadTasksMightBeComplete];
                 }];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error && (session == self.downloadSession)) {
        NSLog(@"Background Download Session has failed: %@",error.localizedDescription);
        [self downloadTasksMightBeComplete];
    }
}

-(void)downloadTasksMightBeComplete{
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        NSLog(@"Download tasks might be completed");
    }
}

#pragma mark - Create Core Data Document

//Original Version
-(void)createManagedObjectContext{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    //    This is the old method, abandon. Use NSDocumentDirectory
    //    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] firstObject];

    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSLog(@"documentsDirectory is:%@", documentsDirectory);

    NSString* documentName = @"FlickrCoreData";
    NSURL* url = [documentsDirectory URLByAppendingPathComponent:documentName];

    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        
        //Original version:
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"Couldn't open document at %@",url);
        }];
    }
    else{
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"Couldn't create document at %@",url);
        }];
    }
}


//For testing flush only:

//-(void)createManagedObjectContext{
//    
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    //    This is the old method, abandon. Use NSDocumentDirectory
//    //    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] firstObject];
//    
//    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
//    NSLog(@"documentsDirectory is:%@", documentsDirectory);
//    
//    NSString* documentName = @"FlickrCoreData";
//    NSURL* url = [documentsDirectory URLByAppendingPathComponent:documentName];
//    
//    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
//        
//        //Original version:
//        [self.document openWithCompletionHandler:^(BOOL success) {
//            if (success) [self documentIsReady];
//            else NSLog(@"Couldn't open document at %@",url);
//        }];
//    }
//    else{
//        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            if (success) [self documentIsReady];
//            else NSLog(@"Couldn't create document at %@",url);
//        }];
//    }
//}


-(void)documentIsReady{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.photoDatabaseContext = self.document.managedObjectContext;
    }
    NSLog(@"(void)documentIsReady in AppDelegate.m is called");
}

#pragma mark - Fetch Regions and Save into Core Data
-(void)startFlickrFetch{
    // URLSession Delegate functions will get called
    [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count]) {
            for (NSURLSessionDownloadTask* task in downloadTasks)
                [task resume];
            NSLog(@" [task resume] in startFlickrFetch (if [downloadTasks count] is NONZERO) in AppDelegate.m is called");
        }
        else{
            NSURLSessionDownloadTask* task = [self.downloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
            NSLog(@" [task resume] in startFlickrFetch (if [downloadTasks count] is ZERO) in AppDelegate.m is called");
        }
    }];
}

//Keep the above methods. Modify the following methods:

-(void)loadPhotosFromLocalURL:(NSURL*)localFile
                  intoContext:(NSManagedObjectContext*)context
          andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
         [self flickrPhotosAtURL:localFile
        //deleted void right after caret
           withCompletionHandler: ^(NSMutableArray * passedInNSMutableArray){
          NSLog(@"Total passedInphotos in block in loadPhotosFromLocalURL: %lu",(unsigned long)[passedInNSMutableArray count]);
          NSLog(@"Photos with region name:%@",passedInNSMutableArray);
          NSLog(@"Fetch completed. About to save into Core Data");
            //All fetching through network need to be done by this point.
          [Photo loadPhotosFromFlickrArray:passedInNSMutableArray intoManagedObjectContext:context];
               
           }];

        if (whenDone) whenDone();
    }
    else{
        if (whenDone) whenDone();
    }
}

-(void)flickrPhotosAtURL:(NSURL*)url withCompletionHandler: (void (^) (NSMutableArray*))completionHandler{
    NSMutableArray* photos ;
    NSData* JSONData = [NSData dataWithContentsOfURL:url];
    if (JSONData){
        NSDictionary* photoPropertyList = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:NULL];
        photos = [photoPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    }
    NSLog(@"%@\n----End of photos without region name----\n\n",photos);
//beginning of added code:
#warning Block Main Thread, which is used by Main queue.
    dispatch_queue_t fetchQ=dispatch_queue_create("Region Name FetchQ", NULL);
    dispatch_async(fetchQ, ^{
            NSString *regionNameInBlock=nil;
            NSMutableArray *photosWithRegionName= [[NSMutableArray alloc] init];
            NSMutableDictionary *mutablePhoto;
            NSURL *urlForRegion;
            for (NSDictionary *photo in photos) {

                urlForRegion= [FlickrFetcher URLforInformationAboutPlace:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID]];
                NSData *jsonResultsForAPlace=[NSData dataWithContentsOfURL:urlForRegion];
                NSDictionary *propertyListResultForAPlace=[NSJSONSerialization JSONObjectWithData:jsonResultsForAPlace
                                                                                          options:0
                                                                                            error:NULL];
                regionNameInBlock=[FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResultForAPlace];
                //NSLog(@"regionName in Region Name FetchQ, %@",regionNameInBlock);
                mutablePhoto= [photo mutableCopy];
                [mutablePhoto setValue:regionNameInBlock forKey:@"Region"];
                [photosWithRegionName addObject:mutablePhoto];
            }
           // NSLog(@"photosWithRegionName after adding region name in fetchQ in flickrPhotosAtURL is: %@", photosWithRegionName);
            //NSLog(@"Size of photosWithRegionName after adding region name in fetchQ in flickrPhotosAtURL is: %lu", (unsigned long)[photosWithRegionName count]);
            dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"photosWithRegionName in main_queue, %@",photosWithRegionName);
                    if (completionHandler) {
                        completionHandler(photosWithRegionName);
                    }
            });
    });
 //End of added code
}

//Added method for flushing database

//-------------------------------------------

//Following are not needed for this app:

//- (void)applicationWillResignActive:(UIApplication *)application {
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}

@end
