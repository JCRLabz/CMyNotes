//
//  StorageForDrawingObjects.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/12/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "StorageController.h"
#import "AppDelegate.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

@implementation StorageController

-(id)init
{
    self = [super init];
    if (!self )
        return nil;
    // Get the managedObjectContext from the AppDelegate (for use in CoreData Applications)
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appdelegate.managedObjectContext;
    
    return self;
}

-(id)initWithName:(NSString*)documentName pageData:(NSData *)pageData shapes:(NSData *)shapes pageNumber:(NSNumber*)pageNumber
{
    // Get the managedObjectContext from the AppDelegate (for use in CoreData Applications)
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appdelegate.managedObjectContext;
    
    self.documentName = documentName;
    self.pageData = pageData;
     
    return self;

}


#pragma mark - Fetched results controller



- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];


    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    //abort();
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];
        /* deprecated
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
         message:[error localizedDescription]
         delegate:self
         cancelButtonTitle:@"Cancel!"
         otherButtonTitles:nil];
         [alert show];*/
        
        [ROOTVIEW presentViewController:alert animated:YES completion:nil];
    }
    
    return _fetchedResultsController;
}


- (void)insertCoreDataObject
{
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    NSError *error = nil;
    if ( self.documentURL == nil )
    {
     //This condition should never happen in the code
        return;
        
    }
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.documentName forKey:@"documentName"];
    [newManagedObject setValue:self.pageData forKey:@"pageData"];
    [newManagedObject setValue:self.timestamp forKey:@"timestamp"];
    [newManagedObject setValue:self.documentURL forKey:@"documentURL"];

    
    // Save the context.

    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];
        /* deprecated
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
         message:[error localizedDescription]
         delegate:self
         cancelButtonTitle:@"Cancel!"
         otherButtonTitles:nil];
         [alert show];*/
        
        [ROOTVIEW presentViewController:alert animated:YES completion:nil];

        //abort();
    }
    
}

-(void)changeURLFrom:(NSString *)fromURL to:(NSString*)toURL
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(timestamp == %@)",self.timestamp];
    [request setPredicate:predicate];
    
    NSArray  *managedObject = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    
    if ( [managedObject count] == 0 )
    {
        //error. Shouldnot be here
        return;
        
    }
    else if ( [managedObject count] == 1)
    {
        [managedObject setValue:toURL forKey:@"documentURL"];
    }
    
    // Save the context.
    if (![_managedObjectContext  save:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];

        
        [ROOTVIEW presentViewController:alert animated:YES completion:nil];

    }

}

-(void)deleteAdObject:(NSString *)adName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext]];

    NSError *error = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(documentName == %@ )", adName];
    [request setPredicate:predicate];

    NSArray  *managedObject = [self.managedObjectContext executeFetchRequest:request error:&error];

    if([managedObject count] == 1) {
        [self.managedObjectContext deleteObject:[managedObject objectAtIndex:0]];
    }
}


-(BOOL) updateCoreDataObject
{

    if ( self.timestamp == nil || self.documentURL == nil || self.documentName == nil )
    {
        //This condition should not happen
        return FALSE;
    }    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(timestamp == %@ )", self.timestamp];
    [request setPredicate:predicate];
    
    NSArray  *managedObject = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ( [managedObject count] == 0 )
    {
        //[managedObject setValue:self.documentName forKey:@"documentName"];
        //[managedObject setValue:self.timestamp forKey:@"timestamp"];
        [self insertCoreDataObject];

    }
    else
    {//neeed to check whether there is any change --- next version

        [managedObject setValue:self.pageData forKey:@"pageData"];
        [managedObject setValue:self.documentName forKey:@"documentName"];
        [managedObject setValue:self.documentURL forKey:@"documentURL"];
        [managedObject setValue:[NSDate date] forKey:@"lastModifiedDate"];
    }
    
    // Save the context.
    if (![self.managedObjectContext  save:&error]) {

        NSMutableArray *object = [NSMutableArray array];
        [object addObject:error];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];

        [ROOTVIEW presentViewController:alert animated:YES completion:nil];
        return FALSE;

        //abort();
    }
    return TRUE;

}

-(BOOL)updateCoreDataObjectUsingDocumentName
{

    if ( self.timestamp == nil || self.documentURL == nil || self.documentName == nil )
    {
        //This condition should not happen
        return FALSE;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext]];

    NSError *error = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(documentName == %@ )", self.documentName];
    [request setPredicate:predicate];

    NSArray  *managedObject = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ( [managedObject count] == 0 )
    {
        //[managedObject setValue:self.documentName forKey:@"documentName"];
        //[managedObject setValue:self.timestamp forKey:@"timestamp"];
        [self insertCoreDataObject];

    }
    else
    {//neeed to check whether there is any change --- next version

        [managedObject setValue:self.pageData forKey:@"pageData"];
        [managedObject setValue:self.documentName forKey:@"documentName"];
        [managedObject setValue:self.documentURL forKey:@"documentURL"];
        [managedObject setValue:[NSDate date] forKey:@"lastModifiedDate"];
    }

    // Save the context.
    if (![self.managedObjectContext  save:&error]) {

        NSMutableArray *object = [NSMutableArray array];
        [object addObject:error];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];

        [ROOTVIEW presentViewController:alert animated:YES completion:nil];
        return FALSE;
        
        //abort();
    }
    return TRUE;
}

@end
