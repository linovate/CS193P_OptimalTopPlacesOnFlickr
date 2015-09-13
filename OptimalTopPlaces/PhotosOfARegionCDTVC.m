//
//  PhotosOfARegionCDTVC.m
//  OptimalTopPlaces
//
//  Created by lordofming on 6/19/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "PhotosOfARegionCDTVC.h"
#import "Photo.h"
#import "Photographer.h"
#import "ImageViewController.h"
#import "PhotoDatabaseAvailability.h"

@implementation PhotosOfARegionCDTVC

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
//    NSLog(@"Notification is received in viewDidLoad PhotosOfARegionCDTVC");
    NSLog(@"self.region in viewWillAppear in PhotosOfARegionCDTVC: %@",self.region.name);
    NSLog(@"self.managedObjectContext in viewWillAppear is:%@",self.managedObjectContext);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];

//    NSSortDescriptor specifies how to sort.
    NSSortDescriptor* photographerAlphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"whoTook.name" ascending:YES selector:@selector(localizedStandardCompare:)];
    
    NSSortDescriptor* photoAlphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    
    //can add more NSSortDescriptor, their order in this array below tells the priority.
    request.sortDescriptors = @[photographerAlphabeticalSort,photoAlphabeticalSort];
    
    request.fetchBatchSize=20;
    request.fetchLimit=500;
    
    NSLog(@"self.managedObjectContext.name in viewDidLoad right before request.predicate is: %@",self.region.name);
    request.predicate = [NSPredicate predicateWithFormat:@"whereTook.name =%@",self.region.name];
   
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

    
}

//-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
//    _managedObjectContext = managedObjectContext;
//
//}

//2nd solution:
//
//-(void)awakeFromNib{
//    
//    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
//                                                      NSLog(@"self.managedObjectContext in awakeFromNib is:%@",self.managedObjectContext);
//                                                  }];
//    //    NSLog(@"Notification is received in viewDidLoad PhotosOfARegionCDTVC");
//    NSLog(@"self.region in awakeFromNib in PhotosOfARegionCDTVC: %@",self.region);
//    
//
//    
//}
//
//
//-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
//    _managedObjectContext = managedObjectContext;
//    
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
//        //NSSortDescriptor specifies how to sort.
//        NSSortDescriptor* alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
//        request.fetchBatchSize=20;
//        request.fetchLimit=500;
//    
//        NSLog(@"self.managedObjectContext.name in setManagedObjectContext right before request.predicate is: %@",self.region.name);
//        request.predicate = [NSPredicate predicateWithFormat:@"whereTook.name =%@",self.region.name];
//    
//        //can add more NSSortDescriptor, their order in this array below tells the priority.
//        request.sortDescriptors = @[alphabeticalSort];
//    
//        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                            managedObjectContext:self.managedObjectContext
//                                                                              sectionNameKeyPath:nil
//                                                                                       cacheName:nil];
//        if (self.managedObjectContext) {
//            NSLog(@"self.managedObjectContext is NOT nil at end of setManagedObjectContext, it is: %@ ", self.managedObjectContext);
//        }else{
//           NSLog(@"self.managedObjectContext is nil at end of setManagedObjectContext ");
//        }
//}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"photo is: %@",photo);
    cell.textLabel.text = photo.title;
//    cell.detailTextLabel.text = photo.subtitle;
    cell.detailTextLabel.text = photo.whoTook.name;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];

    return cell;
}


#pragma mark -UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail=self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail=[((UINavigationController *) detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail forPhoto:[self.fetchedResultsController objectAtIndexPath:indexPath]];    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show a Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController forPhoto:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                }
            }
        }
    }
}

-(void)prepareImageViewController:(ImageViewController*)ivc forPhoto:(Photo*)photo{
    ivc.title = photo.title;
    ivc.imgURL = [NSURL URLWithString:photo.imageURL];
}
@end



