//
//  CollectionViewController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/22/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingController.h"
#import <CoreData/CoreData.h>



@interface CollectionViewController : UICollectionViewController<NSFetchedResultsControllerDelegate /*, IMNativeDelegate, CLLocationManagerDelegate,FBInterstitialAdDelegate*/>
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
@property (nonatomic, strong) NSIndexPath *indexPathForItemToBeDeleted;
@property bool shouldReloadCollectionView, addWebPage;

@property (nonatomic, strong) NSBlockOperation *blockOperation;

//for native app in mobi
//@property (nonatomic, strong) IMNative *nativeAd;
//@property (nonatomic, strong) UIImage *nativeAdImage;
//@property (nonatomic, strong) NSDate *adDate;
//@property BOOL adPresent;


-(void)initializeFromOpenIn:(NSDate*)date;

@end
