//
//  TopRegionsCDTVC.m
//  OptimalTopPlaces
//
//  Created by lordofming on 6/13/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "TopRegionsCDTVC.h"
#import "Region.h"
#import "Photo.h"
#import "Photographer.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosOfARegionCDTVC.h"

@interface TopRegionsCDTVC ()

@end

@implementation TopRegionsCDTVC

-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    NSLog(@"Notification is received in TopRegionsCDTVC");
}


//Original Version:
-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
//  NSSortDescriptor specifies how to sort.
    NSSortDescriptor* popularitySort = [NSSortDescriptor sortDescriptorWithKey:@"popularity"
                                                                     ascending:NO];
    
    NSSortDescriptor* alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                       ascending:YES
                                                                        selector:@selector(localizedStandardCompare:)];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    
    //can add more NSSortDescriptor, their order in this array below tells the priority.
    request.sortDescriptors = @[popularitySort,alphabeticalSort];

    //To ensure fetch 50 regions from CoreData at most.
      request.fetchLimit=50;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

}

//For testing flushDatabase only:
//-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
//{
//    _managedObjectContext = managedObjectContext;
//    
//    //  NSSortDescriptor specifies how to sort.
//    
//    NSSortDescriptor* alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"name"
//                                                                       ascending:YES
//                                                                        selector:@selector(localizedStandardCompare:)];
//    
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
//    request.predicate = nil;
//    
//    //can add more NSSortDescriptor, their order in this array below tells the priority.
//    request.sortDescriptors = @[alphabeticalSort];
//    
//    //To ensure fetch 50 regions from CoreData at most.
//    //request.fetchLimit=50;
//    
//        [request setIncludesSubentities:NO];
//    
//    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                        managedObjectContext:managedObjectContext
//                                                                          sectionNameKeyPath:nil
//                                                                                   cacheName:nil];
//    NSError *err;
//    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&err];
//
//    NSLog(@"Total Photos fetched in setManagedObjectContext in TopRegionsCDTVC is: %lu", (unsigned long)count);
//    //release might not be necessary/desirable.
//    //    [request release];
//    
//    //Copied from Stack Overflow:
//    
////    NSFetchRequest *request = [[NSFetchRequest alloc] init];
////    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
////    
////    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
////    
////    NSError *err;
////    NSUInteger count = [moc countForFetchRequest:request error:&err];
////    if(count == NSNotFound) {
////        //Handle error
////    }
////    
////    [request release];
//    
//    
//    
//}


//Original Version:
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Cell"];
    
    Region* region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text =[region.popularity intValue] ==1 ?[[region.popularity stringValue] stringByAppendingString:@" Photograher"]:[[region.popularity stringValue] stringByAppendingString:@" Photograhers"];

    return cell;
}


//Modified Version for testing only:
//-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
//
//    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = photo.title;
//    cell.detailTextLabel.text =photo.whereTook.name;
//
//    return cell;
//}



#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"Display Photos Of A Region"]){
                if ([segue.destinationViewController isKindOfClass:[PhotosOfARegionCDTVC class]]){
                
                    ((PhotosOfARegionCDTVC *)segue.destinationViewController).managedObjectContext=self.managedObjectContext;
                    
                    ((PhotosOfARegionCDTVC *)segue.destinationViewController).region=(Region *)[self.fetchedResultsController objectAtIndexPath:indexPath];

                    ((PhotosOfARegionCDTVC *)segue.destinationViewController).title=
            [@"Photo(s) in "stringByAppendingString:((Region *)[self.fetchedResultsController objectAtIndexPath:indexPath]).name];
                    NSLog(@"End of prepareForSegue in TopRegionsCDTVC");
            
                }
            }
        }
    }
}



//Added method:

//-(IBAction)flushDatabase
//{
//    [self.refreshControl beginRefreshing];
//    
// //   [self.managedObjectContext reset];
//    
//    [self.refreshControl endRefreshing];
//    
//    NSLog(@"flushDatabase in TopRegionsCDTVC is called");
////    [_managedObjectContext lock];
////    NSPersistentStoreCoordinator *coordinator = self.managedObjectContext.persistentStoreCoordinator;
////    [coordinator removePersistentStore:store error:nil];
//    
////    NSArray *stores = [NSPersistentStoreCoordinator persistentStores];
//    
////        for(NSPersistentStore *store in stores) {
////            [_persistentStoreCoordinator removePersistentStore:store error:nil];
////            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
////        }
////        [_managedObjectContext unlock];
////        _managedObjectModel    = nil;
////        _managedObjectContext  = nil;
////        coordinator = nil;
////    }
//}

//-(IBAction)flushDatabase
//{
//    NSLog(@"flushDatabase in TopRegionsCDTVC is called");
//    [self.refreshControl beginRefreshing];
//    
//    //   [self.managedObjectContext reset];
//    
////Url related begins:
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    //    This is the old method, abandon. Use NSDocumentDirectory
//    //    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] firstObject];
//    
//    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
//    NSLog(@"documentsDirectory is:%@", documentsDirectory);
//    
//    NSString* documentName = @"FlickrCoreData";
//    NSURL* url = [documentsDirectory URLByAppendingPathComponent:documentName];
////Url related ends:
//    
////delete existing UIManagedDocument here if wanted?
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//    
//    NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
//    
//    [fileCoordinator coordinateWritingItemAtURL:url
//                                        options:NSFileCoordinatorWritingForDeleting
//                                          error:nil
//                                     byAccessor:^(NSURL* writingURL) {
//                                         NSFileManager* fileManager = [[NSFileManager alloc] init];
//                                         [fileManager removeItemAtURL:writingURL error:nil];
//                                     }];
//});
//
//    [self.refreshControl endRefreshing];
//    
//    NSLog(@"Control reaching end of flushDatabase in TopRegionsCDTVC");
//}
@end
