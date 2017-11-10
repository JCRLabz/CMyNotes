//
//  Thumbnail.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/29/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "Thumbnail.h"


@implementation Thumbnail

@dynamic data;
@dynamic pageNumber;
@dynamic timestamp;

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]



-(id)initWithDate:(NSDate *)timestamp pageData:(NSData *)thumbnail pageNumber:(int)pageNumber
{
    // Get the managedObjectContext from the AppDelegate (for use in CoreData Applications)
    
    //self.managedObjectContext = appdelegate.managedObjectContext;
    
    self.timestamp = timestamp;
    self.data = thumbnail;
    self.pageNumber = [NSNumber numberWithInt:pageNumber];
    
    return self;
    
}

//-(NSArray *)getObjects
//{
//    //return [self.fetchedResultsController fetchedObjects];
//}
//


- (void)insertCoreDataObject
{
    //AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Thumbnail"
                                   inManagedObjectContext:context];
    
    
    
    
    NSManagedObject *newManagedObject = [[NSManagedObject alloc]
                                         initWithEntity:entity
                                         insertIntoManagedObjectContext:context];
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.timestamp forKey:@"timestamp"];
    [newManagedObject setValue:self.data forKey:@"data"];
    [newManagedObject setValue:self.pageNumber forKey:@"pageNumber"];
    
    
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
        //abort();
    }
    
}


-(void) updateCoreDataObject
{
    //AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(timestamp == %@)", self.timestamp];
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
        [managedObject setValue:self.data forKey:@"data"];
        [managedObject setValue:self.pageNumber forKey:@"pageNumber"];
        [managedObject setValue:self.timestamp forKey:@"timestamp"];
    }
    
    
    // Save the context.
    if (![self.managedObjectContext  save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSMutableArray *object = [NSMutableArray array];
        [object addObject:error];
        //NSLog(@"%s:%d StorageController=%@", __func__, __LINE__, object);
        
        
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    /*
     if (![self.fetchedResultsController performFetch:&error]) {
     // Replace this implementation with code to handle the error appropriately.
     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
     message:[error localizedDescription]
     delegate:self
     cancelButtonTitle:@"Cancel!"
     otherButtonTitles:nil];
     [alert show];
     //abort();
     }
     
     NSMutableArray *debugObject = [NSMutableArray array];
     [debugObject addObject:managedObject];
     [debugObject addObject:[NSNumber numberWithInt:counter++]];
     NSLog(@"__func___ = %s:%d \nafter initialization object=%@ - ",  __func__, __LINE__, debugObject);    */
    
}


@end
