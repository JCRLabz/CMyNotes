//
//  ApplicationSettingsController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/13/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface ApplicationSettingsController : NSObject <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
- (void)insertCoreDataObjectFromOpenIn:(NSDictionary *)dictionary;

@end
