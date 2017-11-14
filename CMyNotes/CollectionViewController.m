//
//  CollectionViewController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/22/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import "CollectionViewController.h"
#import "CellViewForPDF.h"
#import "ApplicationSettingsController.h"
#import "Utility.h"
@import Foundation;
#import "StorageController.h"


/*
 #import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

FBInterstitialAd *interstitialAd;
*/
@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

/*
- (void)loadInterstitial
{
    interstitialAd=
    [[FBInterstitialAd alloc] initWithPlacementID:@"1760198157601665_1760768817544599"];
    interstitialAd.delegate = self;
    //[FBAdSettings addTestDevice:@"86e249ab7ae5e43886ae9eea614c27a284c855ae"];

    @try{
        [interstitialAd loadAd];
    } @catch (NSException* exception) {
        NSLog(@"Got exception: %@    Reason: %@", exception.name, exception.reason);
    }

}
*/

// Now that you have added the code to load the ad, add the following functions
// to display the ad once it is loaded and to handle loading failures:
/*
 - (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"Interstitial ad is loaded and ready to be displayed");

    // You can now display the full screen ad using this code:
    [interstitialAd showAdFromRootViewController:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd
      didFailWithError:(NSError *)error
{
    NSLog(@"Interstitial ad is failed to load with error: %@", error);
}

*/
/*
#pragma mark Native Ad by inMobi

-(void)nativeDidDismissScreen:(IMNative *)native
{

}

-(void)nativeDidPresentScreen:(IMNative *)native
{


}

-(void)nativeWillPresentScreen:(IMNative *)native
{

}

-(void)userWillLeaveApplicationFromNative:(IMNative *)native
{

}

-(void)nativeWillDismissScreen:(IMNative *)native
{

}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"Interstitial closed.");

    // Optional, Cleaning up.
    interstitialAd = NULL;
}


-(BOOL)insertInMobiAdObject:(NSDictionary *)dict;
{
    StorageController *storeThis = [[StorageController alloc] init];
    storeThis.documentName = @"inMobi.adv";

    self.adDate = [NSDate date];
    storeThis.timestamp = self.adDate;
    //convert the NSURL to string for storage
    storeThis.documentURL = [dict valueForKey:@"landingURL"];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    storeThis.pageData = data;

    if ([storeThis updateCoreDataObjectUsingDocumentName] ) {
        return TRUE;
    }
    
    return FALSE;
}

-(void)deleteInMobiAdObject:(NSString*)adName
{

    StorageController *sc = [[StorageController alloc] init];
    [sc deleteAdObject:adName];
}
*/

/*
-(void)nativeDidFinishLoading:(IMNative *)native
{
    //NSLog(@"Got the native ad = %@", native.adContent);
    NSError *error = nil;

    NSData *nativeContentData = [native.adContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *nativeAdDict = [NSJSONSerialization JSONObjectWithData:nativeContentData options:kNilOptions error:&error];

    if ( nativeAdDict == nil || error != nil )
    {
        //NSLog(@"Native Ad Content is inappropriate");
        return;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:nativeAdDict];

    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"isAd"];

    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    if ( [self insertInMobiAdObject:dict] ) {
        self.adPresent = TRUE;
    }
    else {
        self.adPresent = FALSE;
    }


     //NSDictionary *icon = [dict valueForKey:@"icon"];
     //NSString *url = [icon valueForKey:@"url"];

     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
     //NSData *rawImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
     //self.nativeAdImage = [UIImage imageWithData:rawImage];
     //[self.collectionView reloadData];

     //});

         //dispatch_async(dispatch_get_main_queue(), ^(void) {
             //[self.collectionView reloadData];
         //});

}
 */
/*
-(void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error
{
    //NSLog(@"failed to load ad %@", error);

}
*/
-(void)initializeFromOpenIn:(NSDate*)date
{
    self.itemDateFromOpenIn = date;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    /*NSDate *currentDate = [NSDate date];
    NSTimeInterval secondsElapsed = [currentDate timeIntervalSinceDate:self.adDate];
    if ( secondsElapsed > 30 || self.adDate == nil) {
        [self.nativeAd load];
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    //remove ad if available
    //[self deleteInMobiAdObject:@"inMobi.adv"];

    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayNewFileCreationSheet:)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    isAppLaunchedFirstTime = YES;
    self.addWebPage = NO;

    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    self.collectionView.tintColor = [UIColor redColor];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectObjectFromOpenIn:)
                                                 name:@"ObjectFromOpenIn"
                                               object:nil];


    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = .5; //seconds
    [self.collectionView addGestureRecognizer:longPress];

    self.collectionView.backgroundView = [[UIView alloc] init];
    [self.collectionView.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackgroundRecognized:)]];

    /*
     //initialize location Manager
    locationManager = [[CLLocationManager alloc] init];

    [locationManager requestWhenInUseAuthorization];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
     */
    //load inMobiAd
    //[self loadInMobiAd];
    //self.nativeAd = [[IMNative alloc] initWithPlacementId:1469189015767];
    //self.nativeAd.delegate = self;

    //FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    //likeButton.objectID = @"https://www.facebook.com/CMyNotesApp";

    //likeButton.center = CGPointMake(self.view.bounds.origin.x+(likeButton.bounds.size.width/2.0), self.view.bounds.size.height-(likeButton.bounds.size.height/2.0));
    //[self.view addSubview:likeButton];
    //likeButton.likeControlStyle = FBSDKLikeControlStyleBoxCount;//FBSDKLikeControlStyleStandard;//;
    //[FBSDKAccessToken currentAccessToken];
    // Change the style to box count
    //likeButton.likeControlHorizontalAlignment =
    //FBSDKLikeControlHorizontalAlignmentRight;

/*
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];*/
    //[self loadInterstitial];

    if ([Utility getLaunchCount] < 4)
    {
        [self LaunchHelpBubble ];
    }

}

-(void)LaunchHelpBubble
{
    CGRect rect;

    rect = CGRectMake(self.collectionView.frame.size.width-260, self.navigationController.navigationBar.frame.size.height+
                      self.navigationController.toolbar.frame.size.height+5, 260, 200);


    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    textView.backgroundColor = [UIColor yellowColor];
    textView.textColor = [UIColor blueColor];
    textView.editable = false;
    textView.selectable = false;
    textView.alpha = 0.75;
    textView.attributedText = [self createBubbleText];
    [self.view addSubview:textView];
    [Utility setLaunchCount:true forKey:@"LaunchCount"];
}

-(NSAttributedString *)createBubbleText
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.0];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:@"ShareIcon.png"];

    [textAttachment setBounds:CGRectMake(5, roundf(font.capHeight - font.lineHeight)/2.f, 10, font.lineHeight)];

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];

    NSDictionary *attributesDictionary = @{ NSForegroundColorAttributeName : [Utility CMYNColorDarkBlue],
                                            NSFontAttributeName : font};

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]  initWithString:[ @"Use '+' to \n(a) add new PDF file \n(b) import a document (PDF, DOC/DOCX, PPT/PPTX) into CMyNotes from a safe URL.\n\nYou may use the share extension " description] attributes:attributesDictionary];
    [attributedText appendAttributedString:attachmentString];
    NSMutableAttributedString *attributedText2 = [[NSMutableAttributedString alloc]  initWithString:[ @" of any other application to import PDF/DOC/DOCX/PPT/PPTX into CMyNotes for annotation" description] attributes:attributesDictionary];
    [attributedText appendAttributedString:attributedText2];
    return attributedText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"DrawingControllerViewSegue"])
    {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.drawingController = [segue destinationViewController];
        [self.drawingController initWithCoreData:object];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return 2;
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Configure the cell
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ( [object valueForKey:@"timestamp"] == nil )
    {
        //This should not have happened. just in case :) programmers' fear
        return;
    }
    if ( self.itemDateFromOpenIn != nil)
    {
        if ( [self.itemDateFromOpenIn compare:[object valueForKey:@"timestamp"] ] == NSOrderedSame )

        {
            //[[self collectionView ] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];

            //[[self tableView] selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

            //[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];

            self.itemDateFromOpenIn = nil;
            return;
        }
    }

    //Initialize
    DocumentType docType = [DrawingController getDocumentType:[object valueForKey:@"documentName"]];

    if ( docType == kPDF)
    {
        CellViewForPDF *pdfView  = (CellViewForPDF *)[cell.contentView viewWithTag:1007];
        if ( [pdfView superview] )
            [pdfView removeFromSuperview];
        //get the document url - Application Support URL from the physical app island and not from CoeData
        NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
        NSString *resourcePath = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, [[object valueForKey:@"documentName"] description]];
        NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            pdfView = [[CellViewForPDF alloc] initWithFrame:CGRectMake(5,5,130,170) url:url];
        }
        else
        {
            pdfView = [[CellViewForPDF alloc] initWithFrame:CGRectMake(2.5,2.5,65,85) url:url];
        }
        //set page number
        [pdfView setPageNumber:1];

        pdfView.tag = 1007;
        [cell.contentView addSubview:pdfView];
        pdfView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor colorWithWhite:0.90 alpha:0.2];
    }
    /*
     else if ( docType == kAd )
    {

        if ( [[object valueForKey:@"documentName"]  isEqual: @"inMobi.adv"])
        {

            //convert the NSData to NSDictionary
            NSDictionary *dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[object valueForKey:@"pageData"]];

            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,5,130,170)];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5,2.5,65,85)];
            }
            imageView.tag = 1007;
            [cell.contentView addSubview:imageView];
            imageView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor colorWithWhite:0.90 alpha:0.2];
            NSString *url = [dict valueForKeyPath:@"screenshots.url"];
            NSData *rawImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            //self.nativeAdImage = [UIImage imageWithData:rawImage];
            imageView.image = [UIImage imageWithData:rawImage];

            if ( [dict valueForKey:@"isAd"])
            {
                UILabel *sponsored = [[UILabel alloc] init];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    sponsored.frame = CGRectMake(2.5,75,65,15);
                }
                else
                {
                    sponsored.frame = CGRectMake(5,160,130,15);
                }

                UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:9];
                sponsored.font = font;
                sponsored.text = @"Sponsored";
                sponsored.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
                sponsored.textAlignment = NSTextAlignmentCenter;
                sponsored.textColor = [Utility CMYNColorRed3];
                [cell.contentView addSubview:sponsored];
                if ( self.adDate != nil )
                    [IMNative bindNative:self.nativeAd toView:cell];


            }
        }


    }*/
    else
        cell = nil;

    /*
     DocumentController *documentController = [[DocumentController alloc] init];
     NSString *numberOfModifiedPages;
     int numberOfannotations = 0;

     if ( [object valueForKey:@"pageData"] == NULL)
     numberOfModifiedPages = [NSString stringWithFormat:@"Number of Modified Pages: 0"];
     else
     {
     [documentController constructDictionaryFromCoreData:[object valueForKey:@"pageData"]];
     numberOfModifiedPages = [NSString stringWithFormat:@"Number of Modified Pages: %d", [documentController getDirtyPageCount]];
     int dirtyPageCount  = [documentController getDirtyPageCount];
     for ( int i = 0; i < dirtyPageCount; i++ )
     {
     NSArray *shapes = [documentController getPage:[documentController getDirtyPageNumber:i]];
     //shapes = [documentController getPage:[documentController getDirtyPageNumber:i]];
     numberOfannotations += [shapes count];
     }
     }*/
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    //remove delete button from the cell if available as subview
    [self removeDeleteButtonFromCell];
    //if ([[segue identifier] isEqualToString:@"DrawingControllerViewSegue"])
    //{
    //NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //self.drawingController = [segue destinationViewController];

    //get documentName
    //NSString *documentName = [object valueForKey:@"documentName"];

    if ( [object valueForKey:@"documentURL"] == nil)
    {
        self.indexPathForItemToBeDeleted = indexPath;
        [self deleteItem:nil];

        return;
    }

    /*if ( [documentName isEqualToString:@"inMobi.adv"])
    {

        NSDictionary *dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[object valueForKey:@"pageData"]];

        if ([dict valueForKey:@"isAd"]) {
            [self.nativeAd reportAdClick:dict];
            //[self.nativeAd reportAdClickAndOpenLandingURL:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[object valueForKey:@"documentURL"]]];

        }
        //launch the URL in safari
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[object valueForKey:@"documentURL"]]];

    }
    else
    {
*/
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        self.drawingController = (DrawingController *)[storyboard instantiateViewControllerWithIdentifier:@"DrawingController"];

        //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {

            [self.drawingController initWithCoreData:object];
        }
        [self.navigationController pushViewController:self.drawingController animated:NO];
//    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        return CGSizeMake(70.0, 90.0);
    }

    return CGSizeMake(140.0, 180.0);
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }

 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
 {

 }
 */


#pragma mark -<NSFetchedResultsControllerDelegate>

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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//@"Master"
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

        [self presentViewController:alert animated:YES completion:nil];
    }
    return _fetchedResultsController;
}

- (CAAnimation*)getShakeAnimation
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];

    CGFloat wobbleAngle = 0.03f;

    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];

    animation.autoreverses = YES;
    animation.duration = 0.4;
    animation.repeatCount = HUGE_VALF;

    return animation;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{


    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        return;
    }
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    self.indexPathForItemToBeDeleted = indexPath;

    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //self.drawingController = [segue destinationViewController];

    //get documentName
    NSString *documentName = [object valueForKey:@"documentName"];

    if ( [documentName isEqualToString:@"inMobi.adv"])
    {
        return;
    }

    if (indexPath == nil)
    {
        //NSLog(@"couldn't find index path");
        return;
    }
    else
    {
        //[self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];

        for (UICollectionViewCell *cell in [self.collectionView visibleCells])
        {
            for ( UIView *subView in [cell subviews])
            {
                if ([subView isKindOfClass:[UIButton class]])
                {
                    [subView removeFromSuperview];
                    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];

                    //view = nil;
                }
            }
        }
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        //quiver the cell
        //provide delete button
        //cell.layer.borderColor = [[Utility CMYNColorRed1] CGColor];
        //cell.layer.borderWidth = 0.3;


        [cell addSubview:[self deleteButton:cell.frame]];

        [UIView animateWithDuration:0
                         animations:^{
                             [cell.layer addAnimation:[self getShakeAnimation] forKey:@"rotation"];
                             cell.transform = CGAffineTransformIdentity;
                         }];
    }
}

-(UIButton *)deleteButton:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *attributesNormal = @{ NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:19.0 weight:UIFontWeightLight ]};
    NSAttributedString *titleNormal = [[NSMutableAttributedString alloc]  initWithString:@"X" attributes:attributesNormal];
    [button setAttributedTitle:titleNormal forState:UIControlStateNormal];

    NSDictionary *attributesHilighted = @{ NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName : [UIFont  systemFontOfSize:19.0 weight:UIFontWeightLight]};
    NSAttributedString *titleHilighted = [[NSMutableAttributedString alloc]  initWithString:@"X" attributes:attributesHilighted];
    [button setAttributedTitle:titleHilighted forState:UIControlStateHighlighted];

    button.frame = CGRectMake(frame.size.width-36, 6.0, 30, 30.0);
    button.layer.cornerRadius = button.frame.size.width/2.0;
    button.layer.borderWidth = 2.0;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    //button.showsTouchWhenHighlighted = YES;
    [button setBackgroundImage:[Utility imageWithColor:[Utility CMYNColorRed2] size:button.frame.size] forState:UIControlStateNormal];
    [button setBackgroundImage:[Utility imageWithColor:[Utility CMYNColorRed1] size:button.frame.size] forState:UIControlStateHighlighted];

    return button;
}

-(void) tapOnBackgroundRecognized:(UITapGestureRecognizer *)tap
{
    [self removeDeleteButtonFromCell];
}

-(void)removeDeleteButtonFromCell
{
    for (UICollectionViewCell *cell in [self.collectionView visibleCells])
    {
        for ( UIView *subView in [cell subviews])
        {
            if ([subView isKindOfClass:[UIButton class]])
            {
                [subView removeFromSuperview];
                [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
            }
        }
    }
}
-(void) selectObjectFromOpenIn:(NSNotification*)notification
{
    self.itemDateFromOpenIn = [[notification userInfo] valueForKey:@"ObjectFromOpenIn"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    //[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DrawingControllerViewSegue" sender:self.view];
}

-(void)deleteItem:(id)sender
{
    UIView *button = (UIView*)sender;
    //NSIndexPath *indexPath = [self.collectionView index;
    // get the cell at indexPath (the one you long pressed)

    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:self.indexPathForItemToBeDeleted];
    DocumentController *documentController = [[DocumentController alloc] init];
    [documentController deleteAllThumbnailsFor:[managedObject valueForKey:@"documentURL"]];

    //delete the file too
    [documentController removeFile:[managedObject valueForKey:@"documentName"]];

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:self.indexPathForItemToBeDeleted]];
    [button removeFromSuperview];

    //delete the file too at this path
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

        [self presentViewController:alert animated:YES completion:nil];
    }


    // do stuff with the cell
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }

        case NSFetchedResultsChangeDelete: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }

        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }

        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }

        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }

        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }

        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }

        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    if (self.shouldReloadCollectionView) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//
//    NSMutableDictionary *change = [NSMutableDictionary new];
//
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            change[@(type)] = @[@(sectionIndex)];
//            break;
//        case NSFetchedResultsChangeDelete:
//            change[@(type)] = @[@(sectionIndex)];
//            break;
//    }
//
//    [self.sectionChanges addObject:change];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//
//    NSMutableDictionary *change = [NSMutableDictionary new];
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            change[@(type)] = newIndexPath;
//            break;
//        case NSFetchedResultsChangeDelete:
//            change[@(type)] = indexPath;
//            break;
//        case NSFetchedResultsChangeUpdate:
//            change[@(type)] = indexPath;
//            break;
//        case NSFetchedResultsChangeMove:
//            change[@(type)] = @[indexPath, newIndexPath];
//            break;
//    }
//    [self.objectChanges addObject:change];
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    if ([_sectionChanges count] > 0)
//    {
//        [self.collectionView performBatchUpdates:^{
//
//            for (NSDictionary *change in _sectionChanges)
//            {
//                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
//
//                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//                    switch (type)
//                    {
//                        case NSFetchedResultsChangeInsert:
//                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//                            break;
//                        case NSFetchedResultsChangeDelete:
//                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//                            break;
//                        case NSFetchedResultsChangeUpdate:
//                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//                            break;
//                    }
//                }];
//            }
//        } completion:nil];
//    }
//
//    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
//    {
//        [self.collectionView performBatchUpdates:^{
//
//            for (NSDictionary *change in _objectChanges)
//            {
//                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
//
//                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//                    switch (type)
//                    {
//                        case NSFetchedResultsChangeInsert:
//                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
//                            break;
//                        case NSFetchedResultsChangeDelete:
//                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
//                            break;
//                        case NSFetchedResultsChangeUpdate:
//                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
//                            break;
//                        case NSFetchedResultsChangeMove:
//                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
//                            break;
//                    }
//                }];
//            }
//        } completion:nil];
//    }
//
//    [_sectionChanges removeAllObjects];
//    [_objectChanges removeAllObjects];
//}
- (void)displayNewFileCreationSheet:(id)sender
{
    self.createPDFDocumentSheet = [UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blankPDFFileCreation;
    blankPDFFileCreation = [UIAlertAction actionWithTitle:@"Create a blank PDF" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [self createBlankPDFFile];
                                                  }];

    [self.createPDFDocumentSheet addAction:blankPDFFileCreation];

    UIAlertAction *createPDFFromWebPages = [UIAlertAction actionWithTitle:@"Create PDF File from Web Pages" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self createNewFileFromWebPage];
                                                                  }];

    [self.createPDFDocumentSheet addAction:createPDFFromWebPages];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self.createPDFDocumentSheet dismissViewControllerAnimated:YES completion:nil];

                                 }];
        [self.createPDFDocumentSheet addAction:cancel];
    }

    self.createPDFDocumentSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;

    self.createPDFDocumentSheet.popoverPresentationController.backgroundColor = [Utility CMYNColorRed3];

    UIView *view = self.createPDFDocumentSheet.view.subviews.firstObject;
    view.backgroundColor = [Utility CMYNColorLightYellow];

    [self presentViewController:self.createPDFDocumentSheet animated:YES
                     completion:nil];
}

-(void)createBlankPDFFile
{

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Create a blank PDF file"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //setUpDocument

                                                   if (![self setupPDFDocument:alert] )
                                                   {
                                                       [self presentViewController:alert animated:YES completion:nil];

                                                   }

                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name of the file to be saved";

     }];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)displaySettingsDialog
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Would you like to open settings to enable WiFi connectivity or turn off airplane mode"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //setUpDocument

                                                   //
                                                   if (@available(iOS 10.0, *)) {
                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                                   } else {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];                                                   }

                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    [alert addAction:ok];
    [alert addAction:cancel];


    [self presentViewController:alert animated:YES completion:nil];
}

-(void)createNewFileFromWebPage
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Create a PDF file from WebContent"
                                  message:@"Note:Most URLS are converted into PDF"
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //setUpDocument

                                                   if (![self setupHTTPDocument:alert] )
                                                   {
                                                       //[self presentViewController:alert animated:YES completion:nil];
                                                       [self displaySettingsDialog];


                                                   }


                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name of the file to be saved";
     }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Type or copy the URL here";
     }];

    [self presentViewController:alert animated:YES completion:nil];
}

//-(void)setupHTTPDocument:(NSArray *)array
-(BOOL)setupHTTPDocument:(UIAlertController *)alert
{
    NSArray *array = alert.textFields;
    //check availability of internet connection
    /*
     if ( ![Utility isNetworkAvailable] )
    {
        UITextField *urlField = [array objectAtIndex:1];

        //NSLog(@"Error in the URL");
        urlField.layer.borderColor = [UIColor redColor].CGColor;
        alert.message = @"Internet connection unavailable";


        return FALSE;
    }*/
    
    //Initialize
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];

    UITextField *title = [array objectAtIndex:0];

    //check doc type
    //[self checkDocumentType:title];

    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *trimmedReplacementOfTitle = [[title.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

    if ( [trimmedReplacementOfTitle length] == 0 )
        return FALSE;

    UITextField *urlField = [array objectAtIndex:1];
    if ( ![Utility isValidUrl:urlField.text] )
    {
        //NSLog(@"Error in the URL");
        urlField.layer.borderColor = [UIColor redColor].CGColor;
        alert.message = @"error in the URL";
        return FALSE;
    }
    else
    {
        self.addWebPage = YES;
        NSURL *url = [Utility createItemAtApplicationSupportDirectory:[NSString stringWithFormat:@"%@", trimmedReplacementOfTitle]];
        [objectDictionary setObject:[url lastPathComponent] forKey:@"documentName"];
        [objectDictionary setObject:urlField.text forKey:@"documentURL"];
        [objectDictionary setObject:[NSDate date] forKey:@"timestamp"];
        [appSettingsController insertCoreDataObjectFromOpenIn:objectDictionary];
    }
    return TRUE;
}

-(void)checkDocumentType:(NSString *)url
{
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;

    NSItemProvider *itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.url"
                                        options:nil
                              completionHandler:^(NSURL *url, NSError *error) {
                                  // send url to server to share the link
                                  //[self saveFileItemAtGroupURL:url];
                                  [self.extensionContext completeRequestReturningItems:@[]
                                                                     completionHandler:nil];
                              }];
    }
}

-(BOOL)setupPDFDocument:(UIAlertController *)alert
{
    //Initialize
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];
    NSArray *array = alert.textFields;
    UITextField *title = [array objectAtIndex:0];
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *trimmedReplacementOfTitle = [[title.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

    if ( [trimmedReplacementOfTitle length] == 0 )
        return FALSE;

    self.addWebPage = YES;

    NSURL *url = [Utility createItemAtApplicationSupportDirectory:[NSString stringWithFormat:@"%@", trimmedReplacementOfTitle]];
    if ( url == nil )
        return FALSE;

    [objectDictionary setObject:title.text forKey:@"documentTitle"];
    [objectDictionary setObject:[url lastPathComponent] forKey:@"documentName"];
    [objectDictionary setObject:[url absoluteString] forKey:@"documentURL"];
    [objectDictionary setObject:[NSDate date] forKey:@"timestamp"];

    [appSettingsController insertCoreDataObjectFromOpenIn:objectDictionary];

    [self createBlankPDFDocument:url dictionary:objectDictionary];
    return TRUE;
}

-(NSData *)createBlankPDFDocument:(NSURL *)url dictionary:(NSMutableDictionary *)dictionary
{
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

    //set up PDF reading
    //NSURL *nsURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    //only one page for this release
    int count = 10;

    for ( int i = 0; i < count; i++ )
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        //NSLog(@"Page number = %d", pageNumber);
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, count);
        //const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        CGRect pageFrame = [Utility deviceBounds];
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);

        //	Draw the page (flipped)
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);

        //draw shapes for page
        if ( i == 0 )
        {
            //create the cover page
            [self drawCoverPage:ctx dictionary:dictionary];
        }
        else
            [self drawPageNumber:i];
    }
    UIGraphicsEndPDFContext();

    NSArray* applicationSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES);
    NSString* applicationSupportDirectory = [applicationSupportDirectories objectAtIndex:0];
    NSString* filename = [applicationSupportDirectory stringByAppendingPathComponent:[url lastPathComponent]];

    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:filename atomically:YES];
    CGPDFDocumentRelease(pdf);
    return (pdfData);
}

- (void)drawCoverPage:(CGContextRef)ctx dictionary:(NSMutableDictionary *)dictionary
{

    CGRect deviceSize = [Utility deviceBounds];

    CGRect rect = CGRectMake(20.0,5.0,deviceSize.size.width-40,deviceSize.size.height-80);
    //CGContextAddRect(ctx, rect);
    //CGContextSetLineWidth(ctx, 0.25);
    CGContextSetAlpha(ctx, 1.0);

    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
    CGContextDrawPath(ctx, kCGPathFillStroke);

    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont boldSystemFontOfSize:30];

    [[dictionary objectForKey:@"documentTitle"] drawInRect:rect  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];


    //rect = CGRectMake(20.0,deviceSize.size.height-40.0, deviceSize.size.width-40,80);
    //textStyle.alignment = NSTextAlignmentCenter;
    //textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    //NSString *timestamp = [NSDateFormatter localizedStringFromDate:[dictionary  valueForKey:@"timestamp"] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    //NSString *fileDetails = [NSString stringWithFormat:@"File name: %@ \nDate of Creation: %@", [dictionary objectForKey:@"documentName"], timestamp ];
    //[fileDetails drawInRect:rect  withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:8], NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:[Utility CMYNColorLightBlue]}];


}

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"-%ld-", (long)pageNum];
    CGRect deviceSize = [Utility deviceBounds];

    CGRect rect = CGRectMake(20.0,
                             deviceSize.size.height-70,
                             deviceSize.size.width-40,
                             deviceSize.size.height-40);

    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [pageString drawInRect:rect  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
    
}

//AD should be deleted on entry, if available

@end
