//
//  ApplicationSettingsController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/13/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "ApplicationSettingsController.h"
#import "AppDelegate.h"
#import "CMyNotesLibraryViewController.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

@implementation ApplicationSettingsController

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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"documentName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //@"Master"
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"1-Unresolved error %@, %@", error, [error  userInfo]);
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


- (void)insertCoreDataObjectFromOpenIn:(NSDictionary *)dictionary
{
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    //check for null objects
    if ( [dictionary valueForKey:@"timestamp"] == nil)
    {
        //do not insert. Something wrong. This should not happen
        return;
    }
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    //NSLog(@"URL = %@", [dictionary valueForKey:@"url"]);
    [newManagedObject setValue:[dictionary valueForKey:@"documentName"] forKey:@"documentName"];
    [newManagedObject setValue:[dictionary valueForKey:@"documentURL"] forKey:@"documentURL"];
    [newManagedObject setValue:[dictionary valueForKey:@"timestamp"] forKey:@"timestamp"];
    [newManagedObject setValue:[dictionary valueForKey:@"timestamp"] forKey:@"lastModifiedDate"];

    // Save the context.
    NSError *error = nil;
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

    }
    
    //Alert the masterview controller about this new addition and ask it to launch this page
    [self broadcastNewObjectAdded:[dictionary valueForKey:@"timestamp"]];
}

-(NSData *)createBookmarkURL:(NSString *)resourceURL
{
    
    NSError* theError = nil;
    
    NSURL *url = [NSURL URLWithString:[resourceURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&theError];
    if (theError || (bookmark == nil)) {
        // Handle any errors.
        return nil;
    }
    return bookmark;
}


- (NSURL*)urlForBookmark:(NSData*)bookmark
{
    BOOL bookmarkIsStale = NO;
    NSError* theError = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        // Handle any errors
        return nil;
    }
    return bookmarkURL;
}

-(void)broadcastNewObjectAdded:(NSDate*)date
{
    NSDictionary *objectFromOpenIn = [NSDictionary dictionaryWithObject:date forKey:@"ObjectFromOpenIn"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ObjectFromOpenIn" object:self userInfo:objectFromOpenIn];
}

@end
