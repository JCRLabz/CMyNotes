//
//  AppDelegate.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/7/13.
//  Copyright (c) 2013 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIImageView *imageView;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSFetchedResultsController *)fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;


@end
