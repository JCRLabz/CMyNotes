//
//  AppDelegate.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/7/13.
//  Copyright (c) 2013 JCR. All rights reserved.
//

#import "AppDelegate.h"

#import "ApplicationSettingsController.h"
#import "CMyNotesLibraryViewController.h"
#import "DrawingController.h"
#import "CollectionViewController.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define CMyNotesAppExtnDictionaryFile @"CMyNotesAppExtnDict.plist"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self performSelector:@selector(splashFade) withObject:nil];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    // Override point for customization after application launch.



    [self createApplicationSupportDirectory];

    [self insertHelpFile];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        //CMyNotesLibraryViewController *controller = (CMyNotesLibraryViewController *)navigationController.topViewController;
        //controller.managedObjectContext = self.managedObjectContext;
        CollectionViewController *controller = (CollectionViewController*)navigationController.topViewController;
        controller.managedObjectContext= self.managedObjectContext;
    }
    else
    {
        CMyNotesLibraryViewController *notesViewController = (CMyNotesLibraryViewController*)self.window.rootViewController;
        CMyNotesLibraryViewController *libraryController = (CMyNotesLibraryViewController*)notesViewController.presentedViewController;
        libraryController.managedObjectContext = self.managedObjectContext;
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[self cycleTheGlobalMailComposer];
    //[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}


-(NSURL *)fileAtGroupURLAvailable
{
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.cmynotes.jcrlabz.com"];
    
    NSString *groupDir = [groupURL path];
    
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:groupDir];
    
     NSString *file;
     while ((file = [dirEnum nextObject])) {

     if ([file isEqualToString:CMyNotesAppExtnDictionaryFile]) {
         NSURL *pListURL = [groupURL URLByAppendingPathComponent:file isDirectory:NO];
         NSLog(@"Is it opening the file?");
         NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfURL:pListURL];
         NSLog(@"Dictionary key value pairs = %@", dictionary);
         //groupURL = [groupURL URLByAppendingPathComponent:file isDirectory:NO];
         //NSURL *newURL = [self moveFileItemToApplicationSupportDirectory:groupURL];
         //[self openURL:newURL];
         //now delete the file
         NSError *error;
         
         
          if ( ![[NSFileManager defaultManager] removeItemAtURL:pListURL error:&error])
         {
             NSLog (@"Error = %@", error);
         }
          
         //NSLog(@"Removed file %@", CMyNotesAppExtnDictionaryFile);
         
         if ( [[dictionary valueForKey:@"MimeType"] isEqualToString:@"text/html"])
         {
             //NSURL *newURL = [self moveFileItemToApplicationSupportDirectory:documentURL ];
             [dictionary setValue:[dictionary valueForKey:@"documentURL"]  forKey:@"documentURL"];
         }
         else
         {
             NSURL *newURL = [self moveFileItemToApplicationSupportDirectory:[NSURL URLWithString:[dictionary valueForKey:@"documentURL"]] ];
             [dictionary setValue:[newURL absoluteString]  forKey:@"documentURL"];
         }
         [self openURLWithDictionary:dictionary];
     }
     }
    return groupURL;
    
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
/*
     NSLog(@"Open URL:\t%@\n"
          "From source:\t%@\n"
          "With annotation:%@",
          url, sourceApplication, annotation);
*/
    //close any view if present
    //Move to Application Support Folder
    if (url != nil && [url isFileURL]) {
        NSURL *newURL = [self moveFileItemToApplicationSupportDirectory:url];
        [self openURL:newURL];
    }
//    BOOL FBYes = [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                   openURL:url
//                                         sourceApplication:sourceApplication
//                                                annotation:annotation];
    return YES;
}

-(void)openURLWithDictionary:(NSDictionary *)dictionary
{
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    
    NSMutableDictionary *urlInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [dictionary valueForKey:@"documentName"], @"documentName",
                                    [dictionary valueForKey:@"documentURL"], @"documentURL",
                                    [dictionary valueForKey:@"timestamp"], @"timestamp",
                                    nil];
    
    [appSettingsController insertCoreDataObjectFromOpenIn:urlInfo];
}

-(void)openURL:(NSURL *)url
{
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    NSString *absoluteURLString = [[NSString alloc] initWithFormat:@"%@",[url absoluteString]];
    
    absoluteURLString = [absoluteURLString stringByRemovingPercentEncoding];
    NSMutableDictionary *urlInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [[url path] lastPathComponent], @"documentName",
                                    absoluteURLString, @"documentURL",
                                    [NSDate date], @"timestamp",
                                    nil];
    
    [appSettingsController insertCoreDataObjectFromOpenIn:urlInfo];
}

-(NSURL*)moveFileItemToApplicationSupportDirectory:(NSURL *)sourceURL
{
    NSError *error;
    NSURL *url = [self moveItemAtURLToApplicationSupportDirectory:sourceURL];
    if ( url == nil )
    {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    return url;
}

-(NSURL *)moveItemAtURLToApplicationSupportDirectory:(NSURL*)sourceURL
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];

    NSURL *copyToURL = [NSURL fileURLWithPath:applicationSupportDirectory];
    NSString *fileName = [sourceURL lastPathComponent];
    
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:fileName isDirectory:NO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:copyToURL.path]) {
        
        // Duplicate path
        NSURL *duplicateURL = copyToURL;
        // Remove the filename extension
        copyToURL = [copyToURL URLByDeletingPathExtension];
        // Filename no extension
        NSString *fileNameWithoutExtension = [copyToURL lastPathComponent];
        // File extension
        NSString *fileExtension = [sourceURL pathExtension];
        
        //check for duplicate file name. If exists, extend the file name with "-%i"
        int i=1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:duplicateURL.path]) {
            
            // Delete the last path component
            copyToURL = [copyToURL URLByDeletingLastPathComponent];
            // Update URL with new name
            copyToURL=[copyToURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i",fileNameWithoutExtension,i]];
            // Add back the file extension
            copyToURL =[copyToURL URLByAppendingPathExtension:fileExtension];
            // Copy path to duplicate
            duplicateURL = copyToURL;
            i++;
        }
    }
    
    if ( ![[NSFileManager defaultManager] moveItemAtURL:sourceURL toURL:copyToURL error:&error])
    
    // Feed back any errors
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    return copyToURL;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSLog(@"First here at applicationDidBecomeActive");
    //[FBSDKAppEvents activateApp];

    if ( [self fileAtGroupURLAvailable] )
    {
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
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
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SSO4CC" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SSO4CC.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    //Version 1.1
    /*NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };*/
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    //if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        //version 1.1

        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
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
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.cmynotes.jcrlabz.com"];
}


-(BOOL)insertHelpFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    NSString *txtPath = [applicationSupportDirectory stringByAppendingPathComponent:@"CMyNotesHelp.pdf"];
    
    if ([fileManager fileExistsAtPath:txtPath] == NO)
    {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"CMyNotesHelp" ofType:@"pdf"];
        if ( ![fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error] )
        {
            NSLog(@"%@", error.localizedDescription);
            return FALSE;
        }
        resourcePath = [NSString stringWithFormat:@"file://%@",txtPath ];
        NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        [self openURL:url];
        return TRUE;
    }
    return FALSE;
}

-(BOOL)createApplicationSupportDirectory
{
    //7.1 NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    
    
    
    //Check if Application Support Directory is available
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory isDirectory:NULL])
    {
        NSError *error = nil;
        //Create the folder
        if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"%@", error.localizedDescription);
            return FALSE;
        }
        else
        {
            //Mark it unavailable for Backup
            NSURL *url = [NSURL fileURLWithPath:applicationSupportDirectory];
            
            // If a valid app support directory exists, add the
            // app's bundle ID to it to specify the final directory.
            if (url) {
                NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
                url = [url URLByAppendingPathComponent:appBundleID];
            }
            if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error])
            {
                NSLog(@"ERROR - unable to exclude %@ from backup - %@", [url lastPathComponent], error.localizedDescription);
                return FALSE;
            }
            else
                return TRUE;
        }
    }
    else
        return TRUE;
    
    return FALSE;
}

-(void)cycleTheGlobalMailComposer
{
    // we are cycling the damned GlobalMailComposer... due to horrible iOS issue
    self.globalMailComposer = nil;
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
}

@end
