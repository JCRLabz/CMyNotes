//
//  CMyNotesLibraryViewController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/24/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DrawingController.h"

@interface CMyNotesLibraryViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    int isAppLaunchedFirstTime;

}
//@property (strong, nonatomic) DrawingController *drawingController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSDate *itemDateFromOpenIn;
@property (strong, nonatomic) DrawingController *drawingController;

//@property (strong, nonatomic) UIPopoverController *settingsPopover;
@property (nonatomic, strong) UIAlertController *createPDFDocumentSheet;


@property BOOL addWebPage;

@end
