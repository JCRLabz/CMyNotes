//
//  AppDelegate.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 11/10/17.
//  Copyright © 2017 JCR Labz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

