//
//  DrawingController.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "DrawingController.h"
#import "MailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorToolViewController.h"
#import "StorageController.h"
#import "ShapeObject.h"
#import "Utility.h"
#import "CellViewForPDF.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@import UIKit;

static CGPoint touchPoint;
CGPoint bzPoints[5];
uint bzCounter = 0;
UIBezierPath *path;;
#define MINIMUM_ZOOM_SCALE 1.0
CGFloat lastScale, lastRotation;
#define MAXIMUM__ZOOM_SCALE 4.0
#define ZOOM_SPEED 0.05

CGPoint translation;

@interface DrawingController () <ColorToolViewControllerDelegate, DrawingSource>
{
    BOOL skipDrawingCurrentShape;
    NSInteger indexOfSelectedShape;
    CGPoint originBeforeTransformation;
    CGPoint endBeforeTransformation;
    UIToolbar* rightToolbar;
    UIToolbar* leftToolbar;
    BOOL textEditMode;
}
@end

// Start implementation
@implementation DrawingController


//end Facebook ad

- (void) dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    _currentShape.textObject = nil;
    _currentShape = nil;
    [self setShapeButton:nil];
    [self setJCRPDFView:nil];
    [self setThumbnailCollectionView:nil];
    [self setWebView:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self saveDocument];
    [self displayInstructions:@" Low Memory Warning \nDon't worry.\nI have saved all your annotations.\nClose some of the unused applications to \ncontinue to work with \nCMyNotes" instructionType:kMemorywarning];
}



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [self setupCollectionView];
    [self setupView];

    if ( [Utility getLaunchCount] < 4 )
    {
        [self LaunchHelpBubble];
    }
/*
    self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, [Utility deviceBounds].size.width, 35) placementId:1466981936192 delegate:self]; //66

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.banner.frame = CGRectMake(0, 0, [Utility deviceBounds].size.width, 35);
    }
    else
    {
        self.banner.frame = CGRectMake(0, 0, [Utility deviceBounds].size.width, 75);
    }
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //initialize location Manager
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
    
    //This instantiates banner of size 320x50
    [self.banner load];
    self.banner.alpha = 0.75;
    [self.view addSubview:self.banner];
    self.banner.delegate = self; */

    //[self setupFacebookAd];
}

-(void)LaunchHelpBubble
{
    CGRect rect;

    rect = CGRectMake(0, self.jCRPDFView.frame.size.height/2-25, self.jCRPDFView.frame.size.width, 50);


    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    textView.backgroundColor = [UIColor yellowColor];
    textView.textColor = [UIColor blueColor];
    textView.editable = false;
    textView.selectable = false;
    textView.alpha = 0.75;
    textView.attributedText = [self createBubbleText];
    textView.layer.cornerRadius = 5;
    textView.layer.masksToBounds = true;
    textView.layer.borderWidth = 3;
    textView.layer.borderColor = [[UIColor blueColor] CGColor];
    textView.layer.shadowColor = [[UIColor blackColor] CGColor];

    [self.jCRPDFView addSubview:textView];

    [UIView animateWithDuration:5.0 delay:2.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        textView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        textView.hidden = YES;
    }];
}

-(NSAttributedString *)createBubbleText
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.0];
    NSDictionary *attributesDictionary = @{ NSForegroundColorAttributeName : [Utility CMYNColorDarkBlue],
                                            NSFontAttributeName : font};

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]  initWithString:[ @"Tap the left, right edge of the screen to navigate to the previous and next page, respectively" description] attributes:attributesDictionary];

    return attributedText;
}

/*
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = locations.firstObject;

    if (currentLocation != nil)
    {
        [IMSdk setLocation:currentLocation];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval secondsElapsed = [currentDate timeIntervalSinceDate:self.adDate];
        if ( secondsElapsed > 30 || self.adDate == nil) {
            self.adDate = [NSDate date];
            [self.banner load];
        }
    }
}
*/
-(void)setupLeftToolbar
{
    
    NSMutableArray* barButtons = [[NSMutableArray alloc] initWithCapacity:6];
    
    [barButtons addObjectsFromArray:[self setupBarButtonItemWithSystemItem:UIBarButtonSystemItemAction tag:kAction action:@selector(displaySocialComposer:)]];
    
    self.navigationItem.leftBarButtonItems = barButtons;
    self.navigationController.navigationBar.tintColor = [Utility CMYNColorDarkBlue];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}


-(void)setupRightToolbar
{
    CGRect frame = self.navigationController.toolbar.frame;
    
    frame.origin.x = frame.origin.x/2 + 30;
    frame.size.width = frame.size.width/2 - 30;
    rightToolbar = [[UIToolbar alloc]
                    initWithFrame:frame];
    
    NSMutableArray* barButtons = [[NSMutableArray alloc] initWithCapacity:6];
    
    [barButtons addObjectsFromArray:[self setupBarButtonItemWithSystemItem:UIBarButtonSystemItemTrash tag:kTrash action:@selector(clearDrawingPad:)]];
    
    [barButtons addObjectsFromArray:[self setupBarButtonItemWithImage:@"ColorPalette" tag:kColorPalette action:@selector(colorTool:)]];
    
    [barButtons addObjectsFromArray:[self setupBarButtonItemWithSystemItem:UIBarButtonSystemItemAdd tag:kShapes action:@selector(showShapes:)]];
    self.navigationItem.rightBarButtonItems = barButtons;
}


-(NSArray *)setupBarButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem tag:(ToolbarButtonTag)tag action:(SEL)action
{
    // create an array for the buttons
    NSMutableArray* barButton = [[NSMutableArray alloc] initWithCapacity:6];
    
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    [spacer setWidth:15];
    spacer.tag = kSpacer;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:systemItem
                               target:self
                               action:action];
    
    //button.style = UIBarButtonItemStylePlain;
    button.tag = tag;
    
    if (tag == kUndo || tag == kTrash)
        button.enabled = NO;
    
    if ( tag == kTrash)
    {
        //[spacer setWidth:5];
        [barButton addObject:spacer];
        
    }
    
    [barButton addObject:button];
    return barButton;
}

-(NSArray *)setupBarButtonItemWithImage:(NSString *)imageName tag:(ToolbarButtonTag)tag action:(SEL)action
{
    // create an array for the buttons
    NSMutableArray* barButton = [[NSMutableArray alloc] initWithCapacity:6];
    
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    [spacer setWidth:15];
    spacer.tag = kSpacer;
    [barButton addObject:spacer];
    
    UIBarButtonItem *button;
    
    if ( imageName != nil)
        
        button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:action];
    else
    {
        button = [[UIBarButtonItem alloc] initWithTitle:@"Page " style:UIBarButtonItemStylePlain target:nil action:nil];
        button.enabled = NO;
    }
    
    button.tag = tag;
    //button.tintColor = [UIColor cognizantDarkBlue];
    
    if (tag == kDelete || tag == kUndo || tag == kTrash | tag == kMail)
        button.enabled = NO;
    
    [barButton addObject:button];
    return  barButton;
}


-(UIBarButtonItem *)getBarButtonForTag:(ToolbarButtonTag)tag side:(Side)side
{
    NSArray *arrayOfBarButtonItems;
    
    if ( side == kRight)
        arrayOfBarButtonItems = self.navigationItem.rightBarButtonItems;//[[rightToolbar items] mutableCopy];
    else
        arrayOfBarButtonItems = self.navigationItem.leftBarButtonItems;//[[rightToolbar items] mutableCopy];
    
    for (int i = 0; i < [arrayOfBarButtonItems count]; i++)
    {
        UIBarButtonItem *barButton = [arrayOfBarButtonItems objectAtIndex:i];
        if ( barButton.tag == tag)
        {
            return barButton;
            //break;
        }
        
    }
    
    return nil;
}

-(void) displayPageNumber:(int)pageNumber
{
    int pageCount = 0;
    if ( self.documentType == kPDF)
    {
        pageCount = (int)[self.jCRPDFView count];
        self.pageSlider.maximumValue = pageCount;
    }
    /*
     else if ( self.documentType == kXLS )
     {
     pageCount = self.xlsSheetCount;
     pageNumber = pageNumber + 1;
     }*/
    [self displayInstructions:[NSString stringWithFormat: @"Page %d", pageNumber] instructionType:kDisplayPageNumber];
    
    //NSString *pageNumberString = [[NSString alloc] initWithFormat:@"(%d/%d)", pageNumber, pageCount];
    //self.navigationItem.title = pageNumberString;
}


-(void)setupView
{
    path = [UIBezierPath bezierPath];
    
    self.currentShape = [[ShapeObject alloc] init];
    self.currentColor = [ColorToolViewController getCurrentColor];
    self.currentBrushSize = 5.0;
    self.shapeButton.selected = YES;
    //[self.shapeButton setImage:[UIImage imageNamed:@"LineSelected.png"] forState:UIControlStateSelected];
    
    skipDrawingCurrentShape = NO;
    textEditMode = NO;
    indexOfSelectedShape = -1;
    originBeforeTransformation = CGPointMake(0, 0);
    endBeforeTransformation = CGPointMake(0, 0);
    
    self.lineWidth = 1.0;
    self.currentAlpha = 1.0;
    self.textBoxCount = 0;
    
    NSString *fontName = @"Helvetica";
    self.currentFont = [UIFont fontWithName:fontName size:12.0];
    //[self broadcastCurrentFont];
    self.textSelectionRange = NSMakeRange(0,0);
    //if(self.shapes == nil) {
    self.shapes = [[NSMutableArray alloc] initWithCapacity:5];
    //}
    
    if ( self.deletedShapes == nil )
    {
        self.deletedShapes = [[NSMutableArray alloc] init];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:app];
    
    //notfication from ShapeViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shapeChanged:)
                                                 name:@"ShapeSelectionChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(colorChanged:)
                                                 name:@"ColorChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontChanged:)
                                                 name:@"FontChanged"
                                               object:nil];
    
    //object selected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shapeSelected:)
                                                 name:@"ShapeSelected"
                                               object:nil];
    
    //object found
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTrashcanState:)
                                                 name:@"IGotShapes"
                                               object:nil];
    
    //thumbnails found
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActionState:)
                                                 name:@"IGotThumbnails"
                                               object:nil];
    
    //webview finished loading
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedLoadingWebView)
                                                 name:@"WebViewFinishedLoading"
                                               object:nil];

    //Messaged from TextEditor
    //TextEditing completed
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TextEditingCompleted" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditingCompleted:) name:@"TextEditingCompleted" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewZoomed:) name:@"PinchAndZoom" object:nil];
    




    //self.shapesViewController = [[ShapesViewController alloc] init];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    //singleTap.delaysTouchesBegan = TRUE;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    
    /*
     UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
     doubleTap.numberOfTapsRequired = 2;
     doubleTap.delegate = self;
     [self.view addGestureRecognizer:doubleTap];
     //[singleTap requireGestureRecognizerToFail:doubleTap];
     */
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(managePan:)];
    [self.view addGestureRecognizer:panRecognizer];
    //panRecognizer.minimumNumberOfTouches = 2;
    
    panRecognizer.delegate = self;
    
    //pich and zoom recognizer
    /*
     UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAndZoomRecognizer:)];
    pinchRecognizer.delegate = self;
    //
    [self.view addGestureRecognizer:pinchRecognizer];
     */
    //[panRecognizer requireGestureRecognizerToFail:pinchRecognizer];
    
    
    //Rotationrecognizer
    //UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationRecognizer:)];
    //rotationRecognizer.delegate = self;
    //
    //[self.view addGestureRecognizer:rotationRecognizer];
    //[panRecognizer requireGestureRecognizerToFail:rotationRecognizer];
    
    /*
     disbling long press as it is disturbing the editing flow
     UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressRecognizer.delegate = self;
    [self.view addGestureRecognizer:longPressRecognizer];
    [singleTap requireGestureRecognizerToFail:longPressRecognizer];
    */
    
    //self.pageSlider.continuous = YES;
    self.pageSlider.minimumValue = 1;
    self.pageSlider.hidden = NO;
    
    //self.eraserButton.enabled = NO;
    //self.undoButton.enabled = NO;
    
    [self setupLeftToolbar];
    [self setupRightToolbar];

    //setup the color bucket color to black
    //UIBarButtonItem *colorBucket = [self getBarButtonForTag:kColorPalette side:kRight];
    [self setSelectedImageForBarButton:kColorPalette color:[UIColor colorWithRed:0.125 green:0.0 blue:1.0 alpha:1.0]];
    _currentColor = [UIColor colorWithRed:0.125 green:0.0 blue:1.0 alpha:1.0];
    
    self.filesToDelete = [[NSMutableArray alloc] initWithCapacity:1];

    [self.jCRPDFView setContentMode:UIViewContentModeScaleToFill];
    
    [self startTheDrawingEngine];
}


-(IBAction)longPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        indexOfSelectedShape = -1;
    if ( !textEditMode )
        [self showShapes:gesture];
    }
}

#pragma mark - page navigation


- (IBAction)nextPage:(id)sender
{
    if ( !textEditMode )
    {
        //clear all selection
        [self clearSelectedShape];
        
        //if ( self.shapeObjectChanged )
        //[self storePage:_pageNumber];
        
        _pageNumber++;
        
        //reset shape related globals
        [self resetShapeRelatedGlobals];
        
        if ( self.documentType == kPDF )
        {
            [self nextPDFPage:sender];
        }
        //animate next/previous page button
        //[self animationForPageNAvigationButtons];
    }
    [self refresh];
}

-(void)animationForPageNAvigationButtons
{
    [UIView transitionWithView:self.previousPageButton
                      duration:1.0
                       options:UIViewAnimationOptionTransitionNone
                    animations:^ { self.previousPageButton.alpha = 1.0; self.previousPageButton.tintColor = [Utility CMYNColorDarkBlue];}
                    completion:^(BOOL finished){self.previousPageButton.alpha = 0.001;}];
    [UIView transitionWithView:self.nextPageButton
                      duration:1.0
                       options:UIViewAnimationOptionTransitionNone
                    animations:^ { self.nextPageButton.alpha = 1.0; self.nextPageButton.tintColor = [Utility CMYNColorDarkBlue];}
                    completion:^(BOOL finished){self.nextPageButton.alpha = 0.001;}];
}

- (IBAction)previousPage:(id)sender
{
    if ( !textEditMode )
    {
        //clear selected shape
        [self clearSelectedShape];
        
        //store the current page first
        //if (  self.shapeObjectChanged )
        //[self storePage:_pageNumber];
        
        //reset shape related globals
        [self resetShapeRelatedGlobals];
        _pageNumber--;
        
        if ( self.documentType == kPDF )
        {
            [self previousPDFPage:sender];
        }
    }
    /*else if ( self.documentType == kXLS )
     [self previousXLSSheet:sender];*/

}

-(void)nextPDFPage:(id)sender
{
    //hide controls
    BOOL thumbnailCollectionViewState = [self.thumbnailCollectionView isHidden];
    //BOOL navigationControllerState = self.navigationController.navigationBarHidden;
    BOOL pageSliderState = [self.pageSlider isHidden];


    int count = (int)[self.jCRPDFView count];
    if  (_pageNumber > count)
    {

        UIImageView *imageView = [self displayLogo];
    
        
        [UIView transitionWithView:self.jCRPDFView
                          duration:1.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^
         {
             if ( !thumbnailCollectionViewState )
                 self.thumbnailCollectionView.hidden = TRUE;
             //if ( !navigationControllerState )
             //self.navigationController.navigationBarHidden = TRUE;
             
             if (!pageSliderState)
                 self.pageSlider.hidden = TRUE;
             [self.jCRPDFView addSubview:imageView];
         }
                        completion:^(BOOL finished)
         {
             [UIView transitionWithView:self.jCRPDFView
                               duration:2.0
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^
              {
                  [imageView removeFromSuperview];
                  
              }
                             completion:^(BOOL finished)
              {
                  self.jCRPDFView.alpha = 1.0;
                  self.pageSlider.hidden = pageSliderState;
                  self.thumbnailCollectionView.hidden = thumbnailCollectionViewState;
                  //self.navigationController.navigationBarHidden = navigationControllerState;
                  [self refresh];
                  [ self displayPDF:_pageNumber];
              }
              ];
         }
         ];
        _pageNumber = count ;
    }
    else
    {


        CATransition *transition = [CATransition animation];
        transition.duration = 0.75;
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromRight;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:transition forKey:nil];
        [self refresh];
        self.pageSlider.hidden = pageSliderState;
        self.thumbnailCollectionView.hidden = thumbnailCollectionViewState;
        //[self.view addSubview:self.pdfView];
/* working code
        [UIView transitionWithView:self.pdfView
                          duration:0.75
                           options:UIViewAnimationOptionTransitionNone
                        animations:^ { self.pdfView.alpha = 1.0; }
                        completion:^(BOOL finished){;}];*/
        [ self displayPDF:_pageNumber];

    }
    
    
    // PageFlip
    //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromRight];
    //self.pdfView.layer.anchorPoint = CGPointMake(0.0, 1.0); // hinge around the left edge
    //self.pdfView.layer.anchorPoint = CGPoint(1.0, 0.5); // hinge around the right edge
    //[[self.pdfView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
    //
    
    
    /*Interesting one too DO NOT DELETE
     [UIView animateWithDuration:0.5 animations:^{
     CATransform3D leftTransform = CATransform3DIdentity;
     //leftTransform.m31 = -1.0f/500; //dark magic to set the 3D perspective
     leftTransform = CATransform3DMakeRotation(-M_PI/2, 1, 1, 1); //rotate 90 degrees about the Y axis
     self.pdfView.layer.transform = leftTransform;
     //do the same thing but mirrored for the right door, that probably just means using -M_PI_2 for the angle. If you don't know what PI is, Google "radians"
     
     leftTransform = CATransform3DMakeRotation(0, 0, 1, 0); //rotate 90 degrees about the Y axis
     self.pdfView.layer.transform = leftTransform;
     
     
     }];
     */
}

-(void)previousPDFPage:(id)sender
{
    BOOL thumbnailCollectionViewState = [self.thumbnailCollectionView isHidden];
    BOOL navigationControllerState = self.navigationController.navigationBarHidden;
    BOOL pageSliderState = [self.pageSlider isHidden];
    
    if  (_pageNumber <= 0  )
    {
        UIImageView *imageView = [self displayLogo];
        
        [UIView transitionWithView:self.jCRPDFView
                          duration:1.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^
         {
             if ( !thumbnailCollectionViewState )
                 self.thumbnailCollectionView.hidden = TRUE;
             //if ( !navigationControllerState )
             //self.navigationController.navigationBarHidden = TRUE;
             
             if (!pageSliderState)
                 self.pageSlider.hidden = TRUE;
             [self.jCRPDFView addSubview:imageView];
         }
                        completion:^(BOOL finished)
         {
             [UIView transitionWithView:self.jCRPDFView
                               duration:1.75
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^
              {
                  [imageView removeFromSuperview];
                  
              }
                             completion:^(BOOL finished)
              {
                  self.jCRPDFView.alpha = 1.0;
                  self.pageSlider.hidden = pageSliderState;
                  self.thumbnailCollectionView.hidden = thumbnailCollectionViewState;
                  self.navigationController.navigationBarHidden = navigationControllerState;
              }
              ];
         }
         ];
        _pageNumber = 1 ;
    }
    else
    {

        CATransition *transition = [CATransition animation];
        transition.duration = 0.75;
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:transition forKey:nil];
        [self refresh];

        //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromLeft];
        //[[self.pdfView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
        
        /*[UIView transitionWithView:self.pdfView
                          duration:0.75
                           options:UIViewAnimationOptionTransitionNone
                        animations:^ {  }
                        completion:^(BOOL finished){ }];*/

        [ self displayPDF:_pageNumber];

    }
    
}


-(void)displayPDF:(int)pageNumber
{
    if ( pageNumber < self.pageSlider.minimumValue)
    {
        self.pageSlider.value = 1;
    }
    else
        self.pageSlider.value = pageNumber;
    
    [self displayPageNumber:pageNumber];
    
    
    if ( [self.document containsDirtyKey:pageNumber])
    {
        //delete _shapes of the (previous!) page;
        [self.shapes removeAllObjects];
        //_currentShape = [[ShapeObject alloc] init];
        
        [self resetCurrentShape];
        
        NSArray *shapes = [self.document getPage:pageNumber];
        for(ShapeObject *shape in shapes)
        {
            if ( [shape.textObject.text length] > 0 && [shape.textObject.attributedText length] == 0)
            {
                //convert to attributed String
                //convert legacy text string to attributed string
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:shape.textObject.text attributes:nil];
                shape.textObject.attributedText = [attributedString mutableCopy];
                
                
            }
            [self.shapes addObject:shape];
            
        }
        if ( [shapes count] > 0 )
        {
            [self broadcastMessageIGotShapes:TRUE];
        }
        
        // [self refresh];
    }
    else
    {
        [self broadcastMessageIGotShapes:FALSE];
        
    }
    [self refresh];
}

#pragma mark - gestures
/*
 -(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
 {
 
 if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 [gestureRecognizer addTarget:self action:@selector(managePan:)];
 }
 
 
 if ( [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
 {
 NSLog(@"Swipe gesture suceeded");
 
 NSLog(@"Gesture %@", gestureRecognizer);
 
 }
 else if ( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 [gestureRecognizer addTarget:self action:@selector(singleTap:)];
 }
 
 return YES;
 }
 
 */
-(void)updateTrashcanState:(NSNotification *) notification
{
    BOOL shapesFound = [[[notification userInfo] valueForKey:@"IGotShapes"] boolValue];
    
    //get the undo barbutton handle to enable it
    UIBarButtonItem *trash = [self getBarButtonForTag:kTrash side:kRight];
    
    if ( shapesFound )
    {
        trash.enabled = YES;
    }
    else
    {
        trash.enabled = NO;
    }
    if ( [self.document getDirtyPageCount] == 0)
        [self broadcastMessageIGotThumbnails:NO];
}

-(void)updateActionState:(NSNotification *) notification
{
    BOOL thumbnailsFound = [[[notification userInfo] valueForKey:@"IGotThumbnails"] boolValue];
    
    //get the undo barbutton handle to enable it
    UIBarButtonItem *action = [self getBarButtonForTag:kAction side:kLeft];
    
    if ( thumbnailsFound )
    {
        action.enabled = YES;
    }
    else
    {
        action.enabled = NO;
    }
}



-(void)startTheDrawingEngine
{

    //check for advertisement
    DocumentType docType = [DrawingController getDocumentType:self.documentName];

    if ( docType == kAd )
    {
        NSLog(@"Do something");
    }
    
    else if ( self.documentURL != nil )
    {
        //since the location of the application Support URL changes every time, documentURL may not hold the right URL for direct loading
        //Hence, get the application SupportURL for every launch of this application and then use it open the file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths objectAtIndex:0];
        self.applicationSupportURL = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, self.documentName];
        
        
        //self.applicationSupportURL = [documentsDirectory stringByAppendingPathComponent:self.documentName];
        

        //use fileURL to load the document
        self.documentType = [DrawingController getDocumentType:self.documentURL];

        //[self loadWebView:self.documentURL];
        if ( self.documentType  == kHTTP || self.documentType == kHTML)
        {
            self.webView.scalesPageToFit = YES;
            self.navigationController.navigationBarHidden = NO;
            
            //NSURL *url = [[NSBundle mainBundle] URLForResource:self.documentURL withExtension:@"html"];
            //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.documentURL]]];
            [self loadWebView:self.documentURL];
        }

        else
            [self loadWebView:self.applicationSupportURL];
        
        //[self.view bringSubviewToFront:self.controlView];
        //Why is it failing here
        self.thumbnailCollectionView.hidden = FALSE;
        self.document = [[DocumentController alloc] init];
        if ( [self.pageData length] > 0  ) //then decode it
        {
            //self.document = [[DocumentController alloc] init];
            [self.document constructDictionaryFromCoreData:self.pageData];
            //self.datasource = [[self.document getdirtyIndexArray] mutableCopy];
            //[self centerthumbnailCollectionView]; //first time called
        }

    }

}

-(void)initWithCoreData:(id)object
{
    self.documentName = [object valueForKey:@"documentName"];
    self.documentTimestamp = [object valueForKey:@"timestamp"];
    self.documentURL = [object valueForKey:@"documentURL"];
    self.pageData = [object valueForKey:@"pageData"];
    self.documentType = [DrawingController getDocumentType:self.documentURL];
    
    StorageController *storeThis = [[StorageController alloc] init];
    storeThis.documentName = self.documentName;
    storeThis.timestamp = self.documentTimestamp;
    //convert the NSURL to string for storage
    NSString *urlString = [NSString stringWithFormat:@"%@",self.documentURL];
    storeThis.documentURL = urlString;
    storeThis.pageData = self.pageData;
    [storeThis updateCoreDataObject];
    /*NSMutableArray *debugObject = [NSMutableArray array];
     [debugObject addObject:storeThis];
     NSLog(@"%s:%d object=%@", __func__, __LINE__, debugObject);*/
}


-(void)loadWebView:(NSString *)url
{
    NSURL *absoluteURL = [[NSURL alloc] initWithString: [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                          
                          //[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    /*if (self.documentType == kPDF)
     {
     self.webView.hidden = YES;
     [self configureViewForPDF:url size:CGSizeZero];
     [self loadDocument];
     [self.activityIndicator stopAnimating];
     self.thumbnailCollectionView.hidden = NO;
     }
     else
     {
     */
    self.webView.hidden = FALSE;
    self.webView.delegate = self;
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:absoluteURL];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.webView loadRequest:requestObj];
    });
    //}
}

- (void) setupShadow:(CALayer *)layer
{
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 5);
    CGRect rect = layer.frame;
    //rect.origin = CGPointZero;
    //layer.cornerRadius = 5.0;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:layer.cornerRadius].CGPath;
}

//Each object in this arrary array contains page number and shapeArray in an arrary
//get them in pairs
/*
 -(void)constructDocumentDictionary:(NSMutableArray*)documentArray
 {
 self.shapes = [[NSMutableArray alloc] initWithCapacity:5];
 [documentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
 {
 NSMutableArray *array = (NSMutableArray*)obj;
 int pageNumber = [[array objectAtIndex:0] intValue];
 NSMutableArray *shapesArray = [[NSMutableArray alloc] init];
 [shapesArray addObject:[array objectAtIndex:1]];
 [self.document insertPage:shapesArray atPageNumber:pageNumber];
 [self updateStorageModel];
 
 pdfPage = [self.pdfController getPage:pageNumber];
 
 }];
 }
 */

//setup swipe gestures
/*
 // -(void)setupSwipeGestures:(BOOL)enabled
 //{
 //    //if ( enabled )
 //    {
 //        self.leftGesture.enabled = YES;
 //        self.rightGesture.enabled = YES;
 //
 //        //send subview to back or front
 //        // WORKIN [self.view sendSubviewToBack:self.notesView];
 //        //[self.view sendSubviewToBack:self.documentImage];
 //
 //        ///Swipe Left for next page
 //        [self.leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
 //        [self.leftGesture addTarget:self action:@selector(nextPage:)];
 //        self.leftGesture.numberOfTouchesRequired = 1;
 //        self.leftGesture.delegate  = self;
 //
 //        //Swipe up for next page
 //        [self.upGesture setDirection:UISwipeGestureRecognizerDirectionUp];
 //        [self.upGesture addTarget:self action:@selector(nextPage:)];
 //        self.upGesture.numberOfTouchesRequired = 1;
 //        self.upGesture.delegate  = self;
 //
 //        //Swipe right for previous page
 //        [self.rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
 //        [self.rightGesture addTarget:self action:@selector(previousPage:)];
 //        self.rightGesture.numberOfTouchesRequired = 1;
 //        self.rightGesture.delegate  = self;
 //
 //        //Swipe down for previous page
 //        [self.downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
 //        [self.downGesture addTarget:self action:@selector(previousPage:)];
 //        self.downGesture.numberOfTouchesRequired = 1;
 //        self.downGesture.delegate  = self;
 //
 //        [self.view addGestureRecognizer:self.leftGesture];
 //        [self.view addGestureRecognizer:self.rightGesture];
 //        [self.view addGestureRecognizer:self.upGesture];
 //        [self.view addGestureRecognizer:self.downGesture];
 //    }
 //
 //}
 
 -(void)configureViewForPPT:(UIWebView*)view withHTML:(NSString*)html //withScrollHeight:(float)scrollHeight
 {
 _pageNumber = -1;
 
 //initialize document that will hold all the pages
 self.document = [[DocumentController alloc] init];
 //dirtyPageNumberSet = [[NSMutableOrderedSet alloc] initWithCapacity:5];
 self.documentType = kPPT;
 //self.webView = view;
 //self.webView.scrollView.bounces = NO;
 //_webView.scalesPageToFit = TRUE;
 self.pptController = [[PPTController alloc] init];
 [self.pptController initialize:view withHTML:html];
 self.pptSlides = [self.pptController getSlides];
 
 //]withScrollHeight:scrollHeight];
 //self.pptView = [[PPTView alloc] initWithFrame:self.notesView.frame];
 if ( [self.pageData length] > 0  ) //then decode it
 {
 //self.document = [[DocumentController alloc] init];
 [self.document constructDictionaryFromCoreData:self.pageData];
 //NSMutableArray *decodedArray = [self.document decodeDocumentData:self.pageData];
 //[self constructDocumentDictionary:decodedArray];
 _pageNumber = [self.document getDirtyPageNumber:0];
 }
 
 }
 */

-(void)saveAsPDF:(NSData *)pdfData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileURL = [documentsDirectory stringByAppendingPathComponent:self.documentName];
    //remove the source document - no longer required
    //remove the source file - no longer required
    
    //NSString *destinationPath = [NSString stringWithFormat:@"file://%@",fileURL ];
    
    //[self.document removeFile:[[NSURL alloc] initWithString:[destinationPath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [self.document removeFile:self.documentName];
    
    
    //update the URL in COREData
    StorageController *storethis = [[StorageController alloc] init];
    storethis.timestamp = self.documentTimestamp;
    //add file protocol
    if ( self.documentType != kHTTP)
        fileURL = [NSString stringWithFormat:@"file://%@.pdf", fileURL];
    else
        fileURL = [NSString stringWithFormat:@"file://%@.pdf", fileURL];
    self.documentURL = fileURL;
    
    if ( self.documentType != kPDF /*& self.documentType != kHTTP*/ )
        self.documentName = [NSString stringWithFormat:@"%@.pdf",self.documentName];
    storethis.documentName = self.documentName;
    storethis.documentURL = fileURL;
    NSURL *absoluteURL = [[NSURL alloc] initWithString: [fileURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                          //[fileURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [pdfData writeToURL:absoluteURL atomically:YES];
    
    [storethis updateCoreDataObject];
    
    
}


-(void)configureViewForOfficeDocuments
{
    //initialize document that will hold all the pages
    self.document = [[DocumentController alloc] init];
    //dirtyPageNumberSet = [[NSMutableOrderedSet alloc] initWithCapacity:5];
    self.documentType = kPDF;
    
    //save this PDF file in the document folder and update the url in the core data
    //[self saveAsPDF:(__bridge NSData *)(pdfData)];
    
    //self.pdfController = [[PDFController alloc] init];
    //NSURL *absoluteURL = [[NSURL alloc] initWithString:[self.documentURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    //[self.pdfController initializeWithURL:absoluteURL];
    //[self.pdfController initializeWithData:pdfData];
    
    //NSMutableArray *debugObject = [NSMutableArray array];
    //NSLog(@"__func___ = %s:%d \nafter initialization object=%@ - ",  __func__, __LINE__, debugObject);
    
    if ( [self.pageData length] > 0  ) //then decode it
    {
        //self.document = [[DocumentController alloc] init];
        [self.document constructDictionaryFromCoreData:self.pageData];
        
        //NSMutableArray *decodedArray = [self.document decodeDocumentData:self.pageData];
        //[self constructDocumentDictionary:decodedArray];
        if ( [self.document getDirtyPageCount] > 0 )
            _pageNumber = [self.document getDirtyPageNumber:0];
    }
    
}
/*
 -(void)configureViewForXLS:(NSString *)html
 {
 //initialize document that will hold all the pages
 self.document = [[DocumentController alloc] init];
 //dirtyPageNumberSet = [[NSMutableOrderedSet alloc] initWithCapacity:5];
 self.documentType = kXLS;
 //self.xlsController = [[XLSController alloc] init];
 
 if ( ![self.xlsController isInitialized])
 {
 [self.xlsController initializeWithHTML:html];
 self.xlsSheetCount = [self.xlsController getSheetCount];
 self.xlsSheets = [self.xlsController getSheets];
 self.xlsSheetNames = [self.xlsController getSheetNames];
 
 if ( [self.pageData length] > 0  ) //then decode it
 {
 //self.document = [[DocumentController alloc] init];
 [self.document constructDictionaryFromCoreData:self.pageData];
 
 //NSMutableArray *decodedArray = [self.document decodeDocumentData:self.pageData];
 //[self constructDocumentDictionary:decodedArray];
 _pageNumber = [self.document getDirtyPageNumber:0];
 [self centerthumbnailCollectionView];
 //select the first row by default
 
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
 
 [self.thumbnailCollectionView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
 [self tableView:self.thumbnailCollectionView didSelectRowAtIndexPath:indexPath];
 
 }
 }
 
 }
 
 */


-(void)loadDocument
{
    if ( ![self.webView isHidden] )
        self.webView.hidden = TRUE;
    if ( self.documentType == kPPT)
    {
        self.jCRPDFView.hidden = TRUE;
        //CGRect frame = [self setPPTFrameSize];
        //self.webView.frame = frame;
        //self.pdfView.frame = frame;//notesView
        [self nextPage:nil];
        
    }
    else if ( self.documentType == kPDF )
    {
        self.pageNumber = 1;
        [self refresh];
    }
    
    else if ( self.documentType == kXLS)
    {
        _pageNumber = 0;
        self.jCRPDFView.hidden = TRUE;
        self.webView.hidden = TRUE;
        [self refresh];
    }
    else if ( self.documentType == kHTTP)
    {
        [self refresh];
    }
    

}

-(NSMutableData *)convertImagesToPDF:(CGSize)size scale:(CGFloat)scale
{
    /*
     NSMutableData *pdfData = [self convertImagesToPDF:image.size scale:image.scale];
     NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents/12345.pdf"];
     NSString *path1 = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents/12345.png"];
     [pdfData writeToFile:path atomically:NO];
     [UIImagePNGRepresentation([imageArray objectAtIndex:3]) writeToFile:path1 atomically:YES] ;*/
    //write this to a file
    double pageWidth = size.width * scale * 72 / 300;
    double pageHeight = size.height * scale * 72 / 300;
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    // The page size matches the image, no white borders.
    CGRect mediaBox = CGRectMake(0, 0, pageWidth, pageHeight);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    CGContextBeginPage(pdfContext, &mediaBox);
    /*for ( int i = 0; i < [imageArray count]; i++)
     {
     CGContextDrawImage(pdfContext, mediaBox, [[imageArray objectAtIndex:i ] CGImage]);
     }*/
    CGContextEndPage(pdfContext);
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);
    return pdfFile;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //24-7-2014return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationMaskAll;
    
}


-(BOOL)shouldAutorotate
{
    return YES;//NO-24-07-2014
}


/*- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}*/

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self refresh];
}

-(BOOL)isShapeSelected
{
    if ( indexOfSelectedShape != -1 )
        return TRUE;
    else
        return FALSE;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    if ( self.documentType == kPDF )
        touchPoint = [touch locationInView:self.jCRPDFView];
}


#pragma mark - gesture functions for rotation

-(void)rotationRecognizer:(UIRotationGestureRecognizer*)recognizer
{
    if ( indexOfSelectedShape == -1)
        return;
    else
    {        
        //CGAffineTransform transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
        if ( recognizer.state == UIGestureRecognizerStateBegan )
            lastRotation = /*RADIANS_TO_DEGREES*/(recognizer.rotation);
        else if ( recognizer.state == UIGestureRecognizerStateChanged )
        {
            float rotation = /*RADIANS_TO_DEGREES*/(recognizer.rotation);
            ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
            obj.rotation += rotation - lastRotation;
            if ( obj.rotation > 360.0 )
                obj.rotation = 0.0;
            [self rotateShapeBy:obj.rotation];
            lastRotation = rotation;
        }
       // recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, -recognizer.rotation);
        //recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
        //recognizer.rotation = 0;
        else if (UIGestureRecognizerStateEnded == recognizer.state )
        {
            [self saveShapesToCurrentPage];
            //obj.origin = CGPointApplyAffineTransform(obj.origin, CGAffineTransformMakeRotation(recognizer.rotation));
            //obj.end = CGPointApplyAffineTransform(obj.end, CGAffineTransformMakeRotation(recognizer.rotation));
            //return;
        }
    }
    
}

#pragma mark - gesture functions for Pinch and Zoom


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.view;
    
}
-(void)pinchAndZoomRecognizer:(UIPinchGestureRecognizer*)pinchGesture
{
    float deltaScale;
    if ( indexOfSelectedShape == -1 )
    {
        if (UIGestureRecognizerStateBegan == pinchGesture.state || UIGestureRecognizerStateChanged == pinchGesture.state)
        {
            float currentScale = [[pinchGesture.view.layer valueForKeyPath:@"transform.scale.x"] floatValue];
            //self.zoomOperation = YES;
            // Use the x or y scale, they should be the same for typical zooming (non-skewing)
            // Variables to adjust the max/min values of zoom
            
            deltaScale = pinchGesture.scale;
            
            // You need to translate the zoom to 0 (origin) so that you
            // can multiply a speed factor and then translate back to "zoomSpace" around 1
            deltaScale = ((deltaScale - 1.0) * ZOOM_SPEED) + 1.0;
            // Limit to min/max size (i.e maxScale = 2, current scale = 2, 2/2 = 1.0)
            //  A deltaScale is ~0.99 for decreasing or ~1.01 for increasing
            //  A deltaScale of 1.0 will maintain the zoom size
            deltaScale = MIN(deltaScale, MAXIMUM__ZOOM_SCALE / currentScale);
            deltaScale = MAX(deltaScale, MINIMUM_ZOOM_SCALE / currentScale);
            
            CGAffineTransform zoomTransform = CGAffineTransformScale(pinchGesture.view.transform, deltaScale, deltaScale);
            pinchGesture.view.transform = zoomTransform;
            lastScale = currentScale;
            [self broadcastMessageForPinchAndZooming:lastScale];
            self.zoomOperation = YES;
            self.thumbnailCollectionView.hidden = FALSE;
            //[self.navigationController setNavigationBarHidden:FALSE animated:YES];
            self.pageSlider.hidden = FALSE;
        }
        if ( pinchGesture.state == UIGestureRecognizerStateEnded)
        {
            [self broadcastMessageForPinchAndZooming:lastScale];
            // Reset to 1 for scale delta's
            //  Note: not 0, or we won't see a size: 0 * width = 0
            pinchGesture.scale = 1.0;
            //self.zoomOperation = NO;
        }
    }
    else
    {
        [self zoomShapeBy:pinchGesture.scale];
    }
}

-(void)zoomViewBy:(UIPinchGestureRecognizer*)pinchGesture scale:(CGFloat)scale
{
    //CGAffineTransform zoomTransform = CGAffineTransformScale(pinchGesture.view.transform, scale, scale);
    
    if (scale > 1.0)
    {
        self.navigationController.navigationBarHidden = YES;
        self.jCRPDFView.transform = CGAffineTransformScale(self.jCRPDFView.transform, scale, scale);
    }
    else
    {
        self.navigationController.navigationBarHidden = NO;
        [self resize:self.jCRPDFView scale:1.0];
        lastScale = 1.0;
    }
    
}

-(void)broadcastMessageForPinchAndZooming:(CGFloat)scale
{
    NSDictionary *zoomFactor = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:scale] forKey:@"ScaleFactor"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"PinchAndZoom" object:self userInfo: zoomFactor];
}

-(void)viewZoomed:(NSNotification *) notification
{
    if ( [[notification.userInfo objectForKey:@"ScaleFactor"] doubleValue] > 1.0 )
    {
        self.navigationController.navigationBarHidden = YES;
        lastScale = [[notification.userInfo objectForKey:@"ScaleFactor"] doubleValue];
    }
    else
    {
        self.navigationController.navigationBarHidden = NO;
        self.zoomOperation = FALSE;
        
        [self resize:self.jCRPDFView scale:1.0];
        lastScale = 1.0;
    }
}
-(void)resize:(UIView*)view scale:(CGFloat)scale
{
    /* Interesting animation - DO NOT DELETE
     [UIView animateWithDuration:2 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent
     animations:^{
     self.pdfView.transform = CGAffineTransformScale(CGAffineTransformIdentity, newScale, newScale);
     }
     completion:nil];
     
     if([recognizer state] == UIGestureRecognizerStateEnded)
     {
     [self performSelector:@selector(resize:) withObject:self.pdfView afterDelay:2];
     }
     */
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         view.transform = CGAffineTransformScale(CGAffineTransformIdentity, MINIMUM_ZOOM_SCALE, MINIMUM_ZOOM_SCALE);
                     }
                     completion:nil];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}


#pragma mark - gesture functions for pan

- (void)managePan:(UIPanGestureRecognizer*)recognizer
{
    static CGPoint currentTranslation;
    static CGFloat currentScale = 0;
    
    
    if ( textEditMode )
        return;
    
    path.lineWidth = [ColorToolViewController getBrushSize];
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint tempPoint = (CGPoint){0.0,0.0};
            
            //if ( lastScale <= 1.0 )
            {
                if ( self.documentType == kPDF )
                    tempPoint = [recognizer locationInView:self.jCRPDFView];
                
                _currentShape.origin = touchPoint;
                [self.currentShape.bzPath moveToPoint:touchPoint];
                
                if ( _currentShape.type == kFreeform )
                {
                    bzCounter = 0;
                    bzPoints[0] = [recognizer locationInView:self.jCRPDFView];
                    _currentShape.bzPath = path;
                }
                if ( indexOfSelectedShape != -1  && ([self.shapes count] > 0))
                {
                    ShapeObject *obj = [[ShapeObject alloc] initCopy:[self.shapes objectAtIndex:indexOfSelectedShape]];
                    originBeforeTransformation = obj.origin;
                    endBeforeTransformation = obj.end;
                    //                    originBeforeTransformation = obj.bzPath.bounds.origin;
                    //                    endBeforeTransformation = CGPointMake(obj.bzPath.bounds.origin.x+obj.bzPath.bounds.size.width, obj.bzPath.bounds.origin.y+obj.bzPath.bounds.size.height);
                    if ( obj.type != kFreeform && obj.type != kCloseReading)
                    {
                        if (fabs(tempPoint.x - endBeforeTransformation.x) <= 30.0f && fabs(tempPoint.y - endBeforeTransformation.y) < 30.0f)
                        {
                            self.changingSize = YES;
                        }
                    }
                }
            }
            //else
            {
                currentTranslation = translation;
                currentScale = self.jCRPDFView.frame.size.width / self.jCRPDFView.bounds.size.width;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if ( lastScale <= 1.0 && !self.zoomOperation)
            {
                CGPoint translation = [recognizer translationInView:self.jCRPDFView];//notesview
                
                if ( indexOfSelectedShape == -1)
                    
                    _currentShape.end = CGPointMake(_currentShape.origin.x + translation.x, _currentShape.origin.y + translation.y);
                //[self.currentShape.bzPath addLineToPoint:touchPoint];
                
                if ( _currentShape.type == kFreeform && indexOfSelectedShape == -1)
                {
                    bzCounter++;
                    bzPoints[bzCounter] = [recognizer locationInView:self.jCRPDFView];;
                    if (bzCounter == 4)
                    {
                        bzPoints[3] = CGPointMake((bzPoints[2].x + bzPoints[4].x)/2.0, (bzPoints[2].y + bzPoints[4].y)/2.0);
                        [path moveToPoint:bzPoints[0]];
                        [path addCurveToPoint:bzPoints[3] controlPoint1:bzPoints[1] controlPoint2:bzPoints[2]];
                        //[path closePath];
                        bzPoints[0] = bzPoints[3];
                        bzPoints[1] = bzPoints[4];
                        bzCounter = 1;
                    }
                }
                if(indexOfSelectedShape == -1)
                {
                    skipDrawingCurrentShape = NO;
                    [self setCurrentShapeObjectAttributes];
                    self.newShape = YES;
                }
                else
                {
                    if ( [[self shapes] count] > 0 )
                    {
                        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
                        if ( obj.type == kFreeform)
                        {
                            CGRect originalBounds = obj.shapeBounds;
                            CGRect newBounds = CGRectApplyAffineTransform(originalBounds, CGAffineTransformMakeTranslation(translation.x+obj.bzPath.lineWidth, translation.y+obj.bzPath.lineWidth));
                            CGRect rectToRedraw = CGRectUnion(originalBounds, newBounds);
                            [self refreshShapesinRect:rectToRedraw];
                            [recognizer setTranslation:CGPointZero inView:self.jCRPDFView];
                        }
                    }
                    skipDrawingCurrentShape = YES;
                    if ( self.changingSize )
                    {
                        _currentShape.end = CGPointMake(_currentShape.origin.x + translation.x, _currentShape.origin.y + translation.y);
                        [self changeShape:translation];
                    }
                    else
                    {
                        if (indexOfSelectedShape != -1 )
                        {
                        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
                        if ( obj.type == kFreeform)
                        {
                            CGRect originalBounds = obj.shapeBounds;
                            CGRect newBounds = CGRectApplyAffineTransform(originalBounds, CGAffineTransformMakeTranslation(translation.x, translation.y));
                            CGRect rectToRedraw = CGRectUnion(originalBounds, newBounds);
                            [self translateBy:translation shape:obj];
                            [self refreshShapesinRect:rectToRedraw];
                            [recognizer setTranslation:CGPointZero inView:self.jCRPDFView];
                        }
                        else
                        {
                            [self translateBy:translation shape:obj];
                        }
                        }
                    }
                    self.shapeObjectChanged = TRUE;
                }
                [self refresh];
            }
            else
            {
                CGPoint localTranslation = [recognizer translationInView:self.jCRPDFView];
                /*if ( (fabs(localTranslation.x + currentTranslation.x) < self.pdfView.frame.size.width/2.0) &&
                 (fabs(localTranslation.y + currentTranslation.y) < self.pdfView.frame.size.height/2.0))
                 {
                 translation.x = localTranslation.x + currentTranslation.x;
                 translation.y = localTranslation.y + currentTranslation.y;
                 CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x , translation.y);
                 CGAffineTransform scaleTransform = CGAffineTransformMakeScale(lastScale, lastScale);
                 CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translationTransform);
                 self.pdfView.transform = transform;
                 }*/
                if ( (fabs(localTranslation.x + currentTranslation.x) < self.jCRPDFView.frame.size.width/MAXIMUM__ZOOM_SCALE) &&
                    (fabs(localTranslation.y + currentTranslation.y) < self.jCRPDFView.frame.size.height/MAXIMUM__ZOOM_SCALE))
                {
                    translation.x = localTranslation.x + currentTranslation.x;
                    translation.y = localTranslation.y + currentTranslation.y;
                    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x , translation.y);
                    //CGAffineTransform scaleTransform = CGAffineTransformMakeScale(lastScale, lastScale);
                    //CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translationTransform);
                    self.jCRPDFView.transform = translationTransform;
                }
            }
            break;
            
        }
        case UIGestureRecognizerStateEnded:
        {
            if ( lastScale <= 1.0 && !self.zoomOperation)
            {
                self.changingSize = NO;
                self.rotateShape = NO;
                if(indexOfSelectedShape == -1 ) //not selected and in edit mode add shape objects
                {
                    if ( _currentShape.type == kFreeform)
                    {
                        _currentShape.origin = path.bounds.origin;
                        _currentShape.end = (CGPoint){
                            _currentShape.bounds.origin.x +
                            path.bounds.size.width,
                            _currentShape.origin.y +
                            path.bounds.size.height
                        };
                        _currentShape.bzPath = [path copy];
                        bzCounter = 0;
                        [path removeAllPoints];
                        
                    }
                    //bad code, but a quick swipe create an object with origin (inf, inf)
                    if (( _currentShape.origin.x >= 0.0 || _currentShape.origin.y >= 0.0) && (_currentShape.color != nil) && (!CGRectIsEmpty(_currentShape.bounds)))
                    {
                        if ( _currentShape.type == kText && [_currentShape.textObject.text length] == 0)
                            ;
                        else
                        {
                            [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
                        }
                        
                        self.shapeObjectChanged = TRUE;
                    }
                    
                    [self.document setDocumentType:self.documentType];
                    
                    //save only when there is atleast one shape drawn
                    [self saveShapesToCurrentPage];
                    //indexOfSelectedShape = [self.shapes count] - 1;
                    indexOfSelectedShape = -1;

                    
                    self.newShape = NO;
                }
                else
                {
                    //show context menu
                    //get the object
                    if ( [[self shapes] count] > 0 && indexOfSelectedShape != -1 )
                    {
                        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
                        if ( obj != nil )
                        {
                            if ( self.shapeObjectChanged)
                            {
                                [self storeThumbNails:self.pageNumber];
                                //obj.bzPath = [UIBezierPath bezierPathWithRect:obj.frame];
                            }
                            //[self refresh];
                            indexOfSelectedShape = -1;

                            //[self showContextMenu:CGRectMake(obj.origin.x, obj.origin.y, 1, 1)];
                            
                        }
                    }
                    
                }
            }
            else
            {
                //CGPoint localTranslation = [recognizer translationInView:self.pdfView];
                /*if ( (fabs(localTranslation.x + currentTranslation.x) < self.pdfView.frame.size.width/2.0) &&
                 (fabs(localTranslation.y + currentTranslation.y) < self.pdfView.frame.size.height/2.0))
                 {
                 translation.x = localTranslation.x + currentTranslation.x;
                 translation.y = localTranslation.y + currentTranslation.y;
                 CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x , translation.y);
                 CGAffineTransform scaleTransform = CGAffineTransformMakeScale(lastScale, lastScale);
                 CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translationTransform);
                 self.pdfView.transform = transform;
                 }
                 if ( (fabs(localTranslation.x + currentTranslation.x) < self.pdfView.frame.size.width/3.0) &&
                 (fabs(localTranslation.y + currentTranslation.y) < self.pdfView.frame.size.height/3.0))
                 {
                 translation.x = localTranslation.x + currentTranslation.x;
                 translation.y = localTranslation.y + currentTranslation.y;
                 CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x , translation.y);
                 //CGAffineTransform scaleTransform = CGAffineTransformMakeScale(lastScale, lastScale);
                 //CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translationTransform);
                 self.pdfView.transform = translationTransform;
                 }*/
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
            //[self refresh];
            break;
            
            
        default:
            break;
    }
}
/*
 -(void)panZoomedViewBy:(CGPoint)point
 {
 CGPoint localTranslation = point;
 if ( (fabs(localTranslation.x + currentTranslation.x) < self.pdfView.frame.size.width/3.0) &&
 (fabs(localTranslation.y + currentTranslation.y) < self.pdfView.frame.size.height/3.0))
 {
 translation.x = localTranslation.x + currentTranslation.x;
 translation.y = localTranslation.y + currentTranslation.y;
 CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x , translation.y);
 //CGAffineTransform scaleTransform = CGAffineTransformMakeScale(lastScale, lastScale);
 //CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translationTransform);
 self.pdfView.transform = translationTransform;
 }}
 */

-(UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

-(void)saveShapesToCurrentPage
{
    //1. Store the shapes
    if ( [self.shapes count] > 0 )
    {
        [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
        [self updateStorageModel];
        
        //2.0enable trash can
        [self broadcastMessageIGotShapes:TRUE];
        //3.[self refresh]; This clears the shapes
        [self storeThumbNails:self.pageNumber];
        //If there is more than one shape present in the page, do not redraw thumbnails
        //4.change the location of the thumbnailCollectionView based on the number of thumnails
        if ( [self.shapes count] == 1) //new shape drawn in the page
            [self centerthumbnailCollectionView];

        [self refresh];
    }
}

-(void)rotateShapeBy:(CGFloat)rotation
{
    if ( indexOfSelectedShape != -1 && ([self.shapes  count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        
        obj.rotation = rotation;
        
        //snap at all degrees % 10 == 0
        
        /*if ( obj.type == kFreeform)
         {
         [self refreshShapesinRect:obj.bzPath.bounds];
         }
         else*/
        //[self refresh];
        [self refreshShapesinRect:obj.bzPath.bounds];

        
    }
}

-(void)zoomShapeBy:(CGFloat)scale
{
    if ( indexOfSelectedShape != -1 && ([self.shapes  count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.scale = scale;
        [self refresh];
        
    }
}

-(void)changeShape:(CGPoint)newEndPoint
{
    if ( indexOfSelectedShape != -1 && ([self.shapes  count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        if ( obj.type == kCloseReading)
            return;
        if ( obj.type == kFreeform)
        {
            //[obj.bzPath applyTransform:CGAffineTransformMakeScale(1.8,1.8)];
            //CGContextRef context = UIGraphicsBeginImageContext([obj.bzPath bounds].size);
            //CGContextRef currentContext = UIGraphicsGetCurrentContext();
            
            
            //CGAffineTransform trn = CGAffineTransformMakeScale(2.0,2.0);
            //CGPathRef cgPath = obj.bzPath.CGPath;
            //CGPathRef transformedPath = CGPathCreateCopyByTransformingPath(cgPath,  &trn);
            //CGContextAddPath(context, transformedPath);
            //CGPathRelease(transformedPath);
            
            //CGAffineTransform transform = CGAffineTransformMakeScale(newEndPoint.x, newEndPoint.y);
            //[obj.bzPath applyTransform:transform];
            //obj.origin = CGPointMake(originBeforeTransformation.x+newEndPoint.x, originBeforeTransformation.y+newEndPoint.y);
            //obj.end = CGPointMake(endBeforeTransformation.x+newEndPoint.x, endBeforeTransformation.y+newEndPoint.y);
            
        }
        else if ( obj.type == kText)
        {
            /*CGSize size = CGSizeMake(obj.textObject.textSize.width - (endBeforeTransformation.x - newEndPoint.x), obj.textObject.textSize.height - (obj.origin.y - newEndPoint.y));
             obj.end = CGPointMake(endBeforeTransformation.x+newEndPoint.x, endBeforeTransformation.y+newEndPoint.y);
             
             CGRect textRect = CGRectMake(obj.origin.x, obj.origin.y, size.width, size.height);
             
             // Create text attributes
             NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0]};
             
             // Create string drawing context
             NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
             
             [obj.textObject.text drawWithRect:textRect
             options:NSStringDrawingUsesLineFragmentOrigin
             attributes:textAttributes
             context:drawingContext];
             [self drawSelectionOverlay:obj];
             
             
             
             [self eraserButtonClicked:nil];
             [self createTextAtPoint:obj.origin withSize:size text:obj.textObject.text];
             */
            
            if ( (fabs(endBeforeTransformation.x+newEndPoint.x - obj.origin.x)>32) && (fabs(endBeforeTransformation.y+newEndPoint.y - obj.origin.y) > 36) )
            {
                obj.end = CGPointMake(endBeforeTransformation.x+newEndPoint.x, endBeforeTransformation.y+newEndPoint.y);
                
                obj.textObject.textSize = CGSizeMake(fabs(obj.end.x - obj.origin.x), fabs(obj.end.y - obj.origin.y));
                //change the onject end point to the last changable point
                obj.end = CGPointMake(obj.origin.x+obj.textObject.textSize.width, obj.origin.y+obj.textObject.textSize.height);
            }
            
            
            /*CGRect shapeBounds = [obj.bzPath bounds];
             obj.end = CGPointMake(CGRectGetMaxX(shapeBounds), CGRectGetMaxY(shapeBounds));
             obj.textObject.textSize = CGSizeMake (CGRectGetWidth(shapeBounds), CGRectGetHeight(shapeBounds));*/
            
            
        }
        else if (obj.type == kPhoto)
        {
            obj.end = CGPointMake(endBeforeTransformation.x+newEndPoint.x, endBeforeTransformation.y+newEndPoint.y);
            obj.imageObject.rectangle = CGRectMake(obj.origin.x, obj.origin.y, fabs(obj.end.x - obj.origin.x), fabs(obj.end.y - obj.origin.y));
            
        }
        
        else //if ( obj.type == kLine || obj.type == kHighlighter)
        {
            obj.end = CGPointMake(endBeforeTransformation.x+newEndPoint.x, endBeforeTransformation.y+newEndPoint.y);
            //CGRect shapeBounds = [obj.bzPath bounds];
            //obj.end = CGPointMake(CGRectGetMaxX(shapeBounds)+newEndPoint.x, CGRectGetMaxY(shapeBounds)+newEndPoint.y);
            //[obj.bzPath moveToPoint:obj.end];
            
            //CGFloat scale = 1.02;
            //[obj.bzPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
        }
    }
    
}

-(void)rotateShapeUsing:(CGPoint)translation
{
    //from the rotation handle point to current location with center of the object as the fixed point
    //               (x1,x2) *
    //                       |\
    //                       | \
    //                       |vv\<-----theta
    //                       |   \
    //                       |    \
    //                       |     \
    //                       |      \
    //                       |       * (x2,y2)
    //need to find theta for rotation
    //deltax = x2-x1
    //deltay = y2-y1
    //theta = atan(deltax/deltay)
    if ( indexOfSelectedShape != -1 && ([self.shapes  count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        CGRect bounds = obj.bzPath.bounds;
        self.currentShape.end = CGPointMake(self.currentShape.origin.x + translation.x, self.currentShape.origin.y + translation.y);
        
        CGFloat midX = CGRectGetMidX(bounds);
        CGFloat midY = CGRectGetMidY(bounds);
        
        CGFloat deltaX = self.currentShape.end.x - midX;
        CGFloat deltaY = self.currentShape.end.y - midY;
        
        CGFloat theta = atan2f(deltaY, deltaX);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(theta);
        
        [obj.bzPath applyTransform:transform];
        //CGPoint point = obj.bzPath.currentPoint;
        
        //Length
        CGFloat length = sqrtf( pow((obj.end.x - midX), 2.0) + pow((obj.end.y - midY), 2.0));
        obj.end = CGPointMake(cos(theta)*length + midX, sin(theta)*length + midY);
        
        //obj.end = CGPointMake(point.x, point.y);
        NSLog(@"Theta = %f\n, origin = (%f,%f) end point = (%f, %f)\n",theta, obj.origin.x, obj.origin.y, obj.end.x, obj.end.y );
        
        
    }
    
}

-(void)translateBy:(CGPoint) translation shape:(ShapeObject *)obj
{
    //get the selected object and move its origin and
    /*
     if ( self.lastZoomSize > 1.0 )
     {
     CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
     self.pdfView.transform = transform;
     return;
     //[self.view.tr  applyTransform:transform];
     }
     */
    if ( indexOfSelectedShape != -1 && ([self.shapes count] > 0))
    {
        //ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        
        if ( obj.type == kFreeform )
        {
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
            [obj.bzPath applyTransform:transform];
            obj.origin = CGPointMake(obj.bzPath.bounds.origin.x+translation.x, obj.bzPath.bounds.origin.y+translation.y);
            obj.end = CGPointMake(obj.bzPath.bounds.origin.x+obj.bzPath.bounds.size.width+translation.x, obj.bzPath.bounds.origin.y+obj.bzPath.bounds.size.height+translation.y);
            CGRect shapeBounds = [obj.bzPath bounds];
            obj.origin = CGPointMake(CGRectGetMinX(shapeBounds), CGRectGetMinY(shapeBounds));
            
            obj.end = CGPointMake(CGRectGetMaxX(shapeBounds), CGRectGetMaxY(shapeBounds));
            
        }
        
        else if (obj.type == kPhoto)
        {
            obj.origin = CGPointMake(originBeforeTransformation.x+translation.x, originBeforeTransformation.y+translation.y);
            obj.end = CGPointMake(endBeforeTransformation.x+translation.x, endBeforeTransformation.y+translation.y);
            obj.imageObject.rectangle = CGRectMake(obj.origin.x, obj.origin.y, fabs(obj.end.x - obj.origin.x), fabs(obj.end.y - obj.origin.y));
        }
        else if ( obj.type == kCloseReading)
        {
            obj.origin = CGPointMake(originBeforeTransformation.x+translation.x, originBeforeTransformation.y+translation.y);
            obj.end = CGPointMake(endBeforeTransformation.x+translation.x, endBeforeTransformation.y+translation.y);
            obj.bzPath = [UIBezierPath bezierPathWithRect:CGRectMake(obj.origin.x, obj.origin.y, fabs(obj.origin.x-obj.end.x), fabs(obj.origin.y-obj.end.y))];
        }
        else
        {
            //CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
            //[obj.bzPath applyTransform:transform];
            obj.origin = CGPointMake(originBeforeTransformation.x+translation.x, originBeforeTransformation.y+translation.y);
            obj.end = CGPointMake(endBeforeTransformation.x+translation.x, endBeforeTransformation.y+translation.y);
        }
    }
}


- (void)viewDidUnload
{
    _currentShape.textObject = nil;
    _currentShape = nil;
    _currentShape.imageObject = nil;
    [self setShapeButton:nil];
    [self setJCRPDFView:nil];
    [self setThumbnailCollectionView:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    {
        //if cut has left some object in the fileToRemove, remove the physical file
        if ( [self.filesToDelete count] == 1 )
            [self removeFileArURL:[self getApplicationSupportFolderURLForFile:[self.filesToDelete objectAtIndex:0]]];
        //save the changes in the document
        [self clearSelectedShape];
        [self saveDocument];
    }

}


-(void)applicationWillResignActive:(UIApplication *)application
{
    if ( [self.shapes count] > 0)
    {
        [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
        [self storeThumbNails:self.pageNumber];
        //update pageData
        [self updateStorageModel];
    }
}

-(void)saveDocument
{
    //Store the current document data and the shapes in the persistent store
    //step 1 - store current page
    [self storePage:_pageNumber];
    [self updateStorageModel];
}

//update the pageData everytime when it is added or deleted for consistency
-(void)updateStorageModel
{
    StorageController *storeThis = [[StorageController alloc] init];
    
    //get the encoded data from the documentController
    NSMutableData *data = [self.document encodeDocumentDataForPersistentStore];
    
    storeThis.documentName = self.documentName;
    storeThis.timestamp = self.documentTimestamp;
    storeThis.pageData = data;
    storeThis.documentURL = self.documentURL;
    [storeThis updateCoreDataObject];
}

-(void)refresh
{
    if ( self.documentType == kPDF )
    {
        [self.jCRPDFView refresh:_pageNumber];
    }
}


-(void)refreshShapesinRect:(CGRect )rect
{
    if ( self.documentType == kPDF )
    {
        [self.jCRPDFView refreshShapesinRect:rect];
    }
}

#pragma mark - drawing functions data source

-(int)shapeCount
{
    return (int)[self.shapes count] ;
}


- (void)redrawShapes:(CGContextRef) context
{
    for(ShapeObject *obj in self.shapes)
    {
        [self drawAShape:obj context:context];
        if ( obj.shapeSelected)
        {
            [self drawSelectionOverlay:obj];
        }
    }
    
    if ( self.newShape && (indexOfSelectedShape == -1))
        [self drawAShape:_currentShape context:context];
    //if(!skipDrawingCurrentShape && (indexOfSelectedShape == -1 )) {
    //[self drawAShape:_currentShape context:context];
    //}
    
}

- (void)drawAShape:(ShapeObject *)shapeObject context:(CGContextRef) context
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    //static int i = 0;
    //if ( shapeObject.color == nil)
    //{
    //i++;
    //NSLog(@"color = %d", i);
    //}
    
    
    if ( shapeObject.bzPath != nil && shapeObject.color == nil )
        shapeObject.color = self.currentColor;
    if ( fabs(shapeObject.rotation) > 360.0)
        shapeObject.rotation = 0.0;
    if ( shapeObject.color != nil)
    {
        
        if(shapeObject.type == kLine || shapeObject.type == kHighlighter )
        {
            //path = [[UIBezierPath bezierPath] init];
            [path moveToPoint:shapeObject.origin];
            [path addLineToPoint:shapeObject.end];
            //[path closePath];
            
            shapeObject.bzPath = [path copy];
            [shapeObject.color setStroke];
            [shapeObject.color setFill];
            shapeObject.bzPath.lineWidth = shapeObject.lineWidth;
            //shapeObject.bounds = [shapeObject shapeBounds];
            shapeObject.bounds = [shapeObject.bzPath bounds];
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                CGPoint midPoint = CGPointMake(CGRectGetMidX([shapeObject.bzPath bounds]), CGRectGetMidY([shapeObject.bzPath bounds]));
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
                transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
                [shapeObject.bzPath applyTransform:transform];
                
                
                //reorient the origin and end points
                //[shapeObject resetOriginAndEndPoint:[shapeObject.bzPath bounds]];
            }
            
            if ( shapeObject.type == kHighlighter)
            {
                [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
                [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
            }
            else
            {
                [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
                [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            }
        }
        
        else if(shapeObject.type == kRectangle) //Rectangle
        {
            CGRect rectangle = CGRectMake(shapeObject.origin.x,
                                          shapeObject.origin.y,
                                          fabs(shapeObject.end.x - shapeObject.origin.x),
                                          fabs(shapeObject.end.y - shapeObject.origin.y));
            //rectangle = CGRectStandardize(rectangle);
            
            path = [UIBezierPath bezierPathWithRect:rectangle];
            shapeObject.bzPath = [path copy];
            
            shapeObject.bzPath.lineWidth = shapeObject.lineWidth;
            shapeObject.bounds = [shapeObject shapeBounds];
            [shapeObject.color setStroke];
            [shapeObject.color setFill];
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                if ( fabs(shapeObject.rotation) > 360)
                    shapeObject.rotation = 0.0;
                CGPoint midPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
                transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
                [shapeObject.bzPath applyTransform:transform];
                
                //reorient the origin and end points
                //[shapeObject resetOriginAndEndPoint:[shapeObject.bzPath bounds]];
            }
            /*if ( shapeObject.scale > 0.0 )
             {
             CGPoint midPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
             
             CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
             transform = CGAffineTransformScale(transform, shapeObject.scale, shapeObject.scale);
             transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
             [shapeObject.bzPath applyTransform:transform];
             }*/
            if ( shapeObject.backgroundColor )
            {
                [shapeObject.backgroundColor setFill];
                //[shapeObject.backgroundColor setStroke];
                [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
                
            }
            [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
        }
        
        else if(shapeObject.type == kArrow || shapeObject.type == kDoubleHeadedArrow ) //Rectangle
        {
            path = [self drawArrow:shapeObject];
            shapeObject.bzPath = [path copy];
            shapeObject.bzPath.lineWidth = shapeObject.lineWidth;
            shapeObject.bounds = [shapeObject shapeBounds];
            [shapeObject.color setStroke];
            [shapeObject.color setFill];
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                CGPoint midPoint = CGPointMake(CGRectGetMidX([shapeObject.bzPath bounds]), CGRectGetMidY([shapeObject.bzPath bounds]));
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
                transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
                [shapeObject.bzPath applyTransform:transform];
                
                
                //reorient the origin and end points
                //[shapeObject resetOriginAndEndPoint:[shapeObject.bzPath bounds]];
            }
            /*if ( shapeObject.scale > 0.0 )
             {
             CGPoint midPoint = CGPointMake(CGRectGetMidX([shapeObject.bzPath bounds]), CGRectGetMidY([shapeObject.bzPath bounds]));
             
             CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
             transform = CGAffineTransformScale(transform, shapeObject.scale, shapeObject.scale);
             transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
             [shapeObject.bzPath applyTransform:transform];
             }*/
            
            [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            
        }
        
        else if(shapeObject.type == kCircle) //Circle
        {
            CGRect rectangle = CGRectMake(shapeObject.origin.x,
                                          shapeObject.origin.y,
                                          fabs(shapeObject.end.x - shapeObject.origin.x),
                                          fabs(shapeObject.end.y - shapeObject.origin.y));
            
            path = [UIBezierPath bezierPathWithOvalInRect:rectangle];
            
            shapeObject.bzPath = [path copy];
            
            shapeObject.bzPath.lineWidth = shapeObject.lineWidth;
            shapeObject.bounds = [shapeObject shapeBounds];
            
            [shapeObject.color setFill];
            
            [shapeObject.color setStroke];
            //[shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                CGPoint midPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
                transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
                [shapeObject.bzPath applyTransform:transform];
                //[shapeObject resetOriginAndEndPoint:[shapeObject.bzPath bounds]];
                
            }
            
            if ( shapeObject.backgroundColor )
            {
                [shapeObject.backgroundColor setFill];
                //[shapeObject.backgroundColor setStroke];
                [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
                //[shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            }
            
            [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
        }
        
        else if ( shapeObject.type == kText ) //Text
        {
            CGContextSetFillColorWithColor(context, [shapeObject.textObject.fontColor CGColor]);
            CGContextSetAlpha(context, shapeObject.alpha);
            
            
            //Rotate works CGContextRotateCTM(context, M_PI/4);
            CGRect textRect = CGRectMake(shapeObject.origin.x, shapeObject.origin.y, shapeObject.textObject.textSize.width, shapeObject.textObject.textSize.height);
            //shapeObject.bzPath = [UIBezierPath bezierPathWithRect:textRect];
            //textRect = [shapeObject.bzPath bounds];
            //NSLog(@"Text Rect before = %@", NSStringFromCGRect(textRect));
            
            shapeObject.bzPath = [UIBezierPath  bezierPathWithRect:textRect];
            
            if ( [shapeObject.textObject.attributedText length] > 0)
            {
                if ( fabs(shapeObject.rotation) > 0.0 )
                {

                    CGContextSaveGState(context);
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetMidX(textRect), CGRectGetMidY(textRect));
                    transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                    transform = CGAffineTransformTranslate(transform,-CGRectGetMidX(textRect), -CGRectGetMidY(textRect));
                    CGContextConcatCTM(context, transform);
                    [shapeObject.textObject.attributedText drawInRect:textRect];
                    //shapeObject.origin = CGPointMake(shapeObject.bzPath.bounds.origin.x, shapeObject.bzPath.bounds.origin.y);
                    //shapeObject.end = CGPointMake(shapeObject.bzPath.bounds.origin.x + shapeObject.bzPath.bounds.size.width, shapeObject.bzPath.bounds.origin.y+shapeObject.bzPath.bounds.size.height);

                    CGContextRestoreGState(context);
                    [shapeObject.bzPath applyTransform:transform];

                }
                else
                {
                    [shapeObject.textObject.attributedText drawInRect:textRect];
                }
            }
            
            else if ( [shapeObject.textObject.text length] > 0)
            {
                NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                
                NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
                
                [shapeObject.textObject.text drawInRect:textRect withAttributes:attr];
                
            }
            
            
            if ( shapeObject.fillShape )
            {
                CGContextSetFillColorWithColor(context, [shapeObject.textObject.backgroundColor CGColor]);
                
                [shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
            }
            CGContextDrawPath(context, kCGPathFillStroke);
        }
        else if ( shapeObject.type == kFreeform)
        {
            shapeObject.bzPath.lineWidth = shapeObject.lineWidth;
            shapeObject.bounds = [shapeObject shapeBounds];
            [shapeObject.color setStroke];
            [shapeObject.color setFill];
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                CGPoint midPoint = CGPointMake(CGRectGetMidX([shapeObject.bzPath bounds]), CGRectGetMidY([shapeObject.bzPath bounds]));
                CGAffineTransform transform = CGAffineTransformMakeTranslation(midPoint.x, midPoint.y);
                transform = CGAffineTransformRotate(transform, shapeObject.rotation/100.0);
                transform = CGAffineTransformTranslate(transform,-midPoint.x,-midPoint.y);
                [shapeObject.bzPath applyTransform:transform];
                shapeObject.rotation = 0;
            }
            [shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            //[shapeObject.bzPath fillWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            //[shapeObject.bzPath closePath];
            //NSLog(@"Bzpth = %@", shapeObject.bzPath);
            /*
             CGContextBeginPath(context);
             CGContextSetLineWidth(context, shapeObject.lineWidth);
             shapeObject.bounds = [shapeObject shapeBounds];
             
             CGContextSetStrokeColorWithColor(context, [shapeObject.color  CGColor]);
             CGContextSetAlpha(context, shapeObject.alpha);
             CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);*/
            
            
            /*if ( fabs(shapeObject.rotation) > 0 )
             {
             CGContextSaveGState(context);
             CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetMidX(shapeObject.bzPath.bounds), CGRectGetMidY(shapeObject.bzPath.bounds));
             transform = CGAffineTransformRotate(transform, shapeObject.rotation);
             transform = CGAffineTransformTranslate(transform,-CGRectGetMidX(shapeObject.bzPath.bounds), -CGRectGetMidY(shapeObject.bzPath.bounds));
             CGContextConcatCTM(context, transform);
             shapeObject.bzPath.CGPath = CGPathCreateCopyByTransformingPath(shapeObject.bzPath.CGPath, &transform);
             //shapeObject.origin = CGPointMake(shapeObject.bzPath.bounds.origin.x, shapeObject.bzPath.bounds.origin.y);
             //shapeObject.end = CGPointMake(shapeObject.bzPath.bounds.origin.x + shapeObject.bzPath.bounds.size.width, shapeObject.bzPath.bounds.origin.y+shapeObject.bzPath.bounds.size.height);*/
            //[shapeObject.bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            
            //CGContextRestoreGState(context);
            //}
            //CGContextClosePath(context);
            //[shapeObject.bzPath stroke];
        }
        else if (shapeObject.type == kPhoto)
        {
            //UIImage *newImage = [self compressImage:shapeObject];
            
            UIImage *newImage = [UIImage imageWithCGImage:[[self compressImage:shapeObject] CGImage] scale:1.0 orientation:shapeObject.imageObject.image.imageOrientation];
            
            CGRect rectangle = CGRectMake(shapeObject.origin.x,
                                          shapeObject.origin.y,
                                          shapeObject.end.x - shapeObject.origin.x,
                                          shapeObject.end.y - shapeObject.origin.y);
            
            if ( fabs(shapeObject.rotation) > 0.0 )
            {
                CGContextSaveGState(context);
                CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
                transform = CGAffineTransformRotate(transform, shapeObject.rotation);
                transform = CGAffineTransformTranslate(transform,-CGRectGetMidX(rectangle), -CGRectGetMidY(rectangle));
                CGContextConcatCTM(context, transform);
                [newImage drawInRect:rectangle blendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
                shapeObject.bzPath = [UIBezierPath bezierPathWithRect:rectangle];
                [shapeObject.bzPath applyTransform:transform];
                shapeObject.imageObject.origin = CGPointMake(shapeObject.origin.x, shapeObject.origin.y);
                shapeObject.imageObject.rectangle = rectangle;
                CGContextRestoreGState(context);
            }
            else if ( fabs(shapeObject.rotation) == 0.0 )
            {
                [newImage drawInRect:rectangle blendMode:kCGBlendModeNormal alpha:shapeObject.alpha];
            }
            //shapeObject.end = CGPointMake(shapeObject.origin.x+shapeObject.imageObject.rectangle.size.width, shapeObject.origin.y+shapeObject.imageObject.rectangle.size.height);
            path = [UIBezierPath bezierPathWithRect:rectangle];
            shapeObject.bzPath = [path copy];
            newImage = nil;
        }
        else if (shapeObject.type == kCloseReading)
        {
            CGContextSetFillColorWithColor(context, [shapeObject.textObject.fontColor CGColor]);
            CGContextSetAlpha(context, shapeObject.alpha);
            CGRect textRect = CGRectMake(shapeObject.origin.x, shapeObject.origin.y, shapeObject.textObject.textSize.width+10, shapeObject.textObject.textSize.height+10);
            [shapeObject.textObject.attributedText drawInRect:textRect];
        }
    }
}


- (CGRect) getBoundingRectAfterRotation: (CGRect) rectangle byAngle: (CGFloat) angleOfRotation {
    // Calculate the width and height of the bounding rectangle using basic trig
    CGFloat newWidth = rectangle.size.width * fabs(cosf(angleOfRotation)) + rectangle.size.height * fabs(sinf(angleOfRotation));
    CGFloat newHeight = rectangle.size.height * fabs(cosf(angleOfRotation)) + rectangle.size.width * fabs(sinf(angleOfRotation));
    
    // Calculate the position of the origin
    CGFloat newX = rectangle.origin.x + ((rectangle.size.width - newWidth) / 2);
    CGFloat newY = rectangle.origin.y + ((rectangle.size.height - newHeight) / 2);
    
    // Return the rectangle
    return CGRectMake(newX, newY, newWidth, newHeight);
}

-(UIBezierPath *)drawArrow:(ShapeObject *)shape
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:shape.origin];
    [path addLineToPoint:shape.end];
    [path closePath];
    float y2 = shape.end.y;
    float y1 = shape.origin.y;
    float x2 = shape.end.x;
    float x1 = shape.origin.x;
    
    float phi = atan2(y2 - y1, x2 - x1); // substitute x1, x2, y1, y2 as needed
    float tip1angle = phi - M_PI / 6.0; // -30°
    float tip2angle = phi + M_PI / 6.0; // +30°
    
    float x3 = x2 - 15.0 * cos(tip1angle); // substitute h here and for the following 3 places
    float x4 = x2 - 15.0 * cos(tip2angle);
    float y3 = y2 -  15.0 * sin(tip1angle);
    float y4 = y2 -  15.0 * sin(tip2angle);
    
    UIBezierPath *headPath = [[UIBezierPath alloc] init];
    
    CGPoint arrowEndPoint = CGPointMake(x2, y2);
    CGPoint arrowTip1EndPoint = CGPointMake(x3, y3);
    CGPoint arrowTip2EndPoint = CGPointMake(x4, y4);
    
    //path.lineWidth = 3.0;
    //[headPath moveToPoint:arrowStartPoint];
    [headPath moveToPoint:arrowEndPoint];
    [headPath addLineToPoint:arrowTip1EndPoint];
    [headPath addLineToPoint:arrowEndPoint];
    [headPath addLineToPoint:arrowTip2EndPoint];
    [headPath addLineToPoint:arrowTip1EndPoint];
    [headPath closePath];
    
    if ( shape.type == kDoubleHeadedArrow)
    {
        x3 = x1 + 15.0 * cos(tip1angle); // substitute h here and for the following 3 places
        x4 = x1 + 15.0 * cos(tip2angle);
        y3 = y1 +  15.0 * sin(tip1angle);
        y4 = y1 +  15.0 * sin(tip2angle);
        arrowEndPoint = CGPointMake(x1, y1);
        arrowTip1EndPoint = CGPointMake(x3, y3);
        arrowTip2EndPoint = CGPointMake(x4, y4);
        [headPath moveToPoint:arrowEndPoint];
        [headPath addLineToPoint:arrowTip1EndPoint];
        [headPath addLineToPoint:arrowEndPoint];
        [headPath addLineToPoint:arrowTip2EndPoint];
        [headPath addLineToPoint:arrowTip1EndPoint];
        [headPath closePath];
    }
    
    [path appendPath:headPath];
    //[path fillWithBlendMode:kCGBlendModeNormal alpha:shape.alpha];
    
    return path;
}

-(UIImage *)compressImage:(ShapeObject *)shapeObject
{
    //get the image using the file name
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *resourcePath = [NSString stringWithFormat:@"file://%@/%@",applicationSupportDirectory, shapeObject.imageObject.fileName ];
    NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                  //[resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float currentHeight = shapeObject.imageObject.rectangle.size.height;
    float currentWidth = shapeObject.imageObject.rectangle.size.width;
    float imgRatio = actualWidth/actualHeight;
    float currentRatio = shapeObject.imageObject.rectangle.size.width/shapeObject.imageObject.rectangle.size.height;
    float compressionQuality = 0.35;//50 percent compression
    CGPoint origin = shapeObject.imageObject.rectangle.origin;
    
    if (actualHeight > currentHeight || actualWidth > currentWidth)
    {
        if(imgRatio < currentRatio)
        {
            //adjust width according to maxHeight
            imgRatio = currentHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = currentHeight;
        }
        else if(imgRatio > currentRatio)
        {
            //adjust height according to maxWidth
            imgRatio = currentWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = currentWidth;
        }
        else
        {
            actualHeight = currentHeight;
            actualWidth = currentWidth;
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(actualWidth, actualHeight));
    [image drawInRect:CGRectMake(0,0, actualWidth, actualHeight)];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    
    UIGraphicsEndImageContext();
    
    shapeObject.imageObject.rectangle = CGRectMake(origin.x, origin.y, actualWidth, actualHeight);
    
    return [UIImage imageWithData:imageData];
}

-(void)alternateSelectionOverlay:(ShapeObject*)selectedShape
{
    UIBezierPath *pathCopy = [selectedShape.bzPath copy];
    CGPathRef cgPathSelectionRect = CGPathCreateCopyByStrokingPath(pathCopy.CGPath, NULL, pathCopy.lineWidth, pathCopy.lineCapStyle, pathCopy.lineJoinStyle, pathCopy.miterLimit);
    UIBezierPath *selectionRect = [UIBezierPath bezierPathWithCGPath:cgPathSelectionRect];
    CGPathRelease(cgPathSelectionRect);
    
    CGFloat dashStyle[] = { 5.0f, 2.0f };
    [selectionRect setLineDash:dashStyle count:2 phase:0];
    selectionRect.lineWidth = 2.0;
    //[[UIColor redColor] setStroke];
    [selectionRect stroke];
    if( selectedShape.type != kFreeform)
        [self drawDragHandle:selectedShape];
}

-(void)drawSelectionOverlay:(ShapeObject *)selectedShape
{
    //While coming from the saved mode, selection is on and cutCopy might be nil.
    //We do not need to remember the selection when quitting
    UIBezierPath *selectedShapePath = [selectedShape.bzPath copy];
    UIBezierPath *bzBoundedRectangle;
    
    if ( selectedShapePath != nil )
    {
        /*if ( selectedShape.type == kPhoto )
         {
         bzBoundedRectangle = [UIBezierPath bezierPathWithRect:[self getBoundingRectAfterRotation:selectedShape.imageObject.rectangle byAngle:selectedShape.rotation]];
         }
         else if ( selectedShape.type == kText)
         {
         CGRect textRect = CGRectMake(selectedShape.origin.x, selectedShape.origin.y, selectedShape.textObject.textSize.width, selectedShape.textObject.textSize.height);
         bzBoundedRectangle = [UIBezierPath bezierPathWithRect:textRect];
         }*/
        bzBoundedRectangle = [UIBezierPath bezierPathWithRect:[selectedShapePath bounds]];
        //bzBoundedRectangle = [UIBezierPath bezierPathWithRect:[self getBoundingRectAfterRotation:selectedShape.bzPath.bounds byAngle:selectedShape.rotation]];
        CGFloat dashStyle[] = { 5.0f, 2.0f };
        [bzBoundedRectangle setLineDash:dashStyle count:2 phase:0];
        bzBoundedRectangle.lineWidth = 1.0;
        [[UIColor redColor] setStroke];
        [bzBoundedRectangle stroke];
        //draw drag handle
        if( selectedShape.type != kFreeform && selectedShape.type != kCloseReading)
            [self drawDragHandle:selectedShape];
        //draw rotate handle
        //[self drawRotateHandle:selectedShape];
    }
}


-(void)drawDragHandle:(ShapeObject *)selectedShape
{
    UIBezierPath *dragHandle;// = [[UIBezierPath alloc] init];
    UIBezierPath *dragHandleInner;// = [[UIBezierPath alloc] init];
    CGRect textRect;//= [selectedShape shapeBounds];
    
    if ( selectedShape.type == kText || selectedShape.type == kCloseReading)
    {
        textRect = CGRectMake(selectedShape.origin.x, selectedShape.origin.y, selectedShape.textObject.textSize.width, selectedShape.textObject.textSize.height);
        
        /*if ( selectedShape.textObject.textContainer.size.height > selectedShape.textObject.textSize.height)
         {
         dragHandle = [UIBezierPath bezierPathWithRect:CGRectMake(textRect.origin.x+textRect.size.width - 12.0, textRect.origin.y+textRect.size.height, 24,2)];
         dragHandleInner = [UIBezierPath bezierPathWithRect:CGRectMake(textRect.origin.x+textRect.size.width, textRect.origin.y+textRect.size.height-12.0, 2, 24)];
         
         }
         else*/
        {
            dragHandle = [UIBezierPath bezierPathWithRect:CGRectMake(textRect.origin.x+textRect.size.width - 8.0, textRect.origin.y+textRect.size.height-1, 16,3)];
            dragHandleInner = [UIBezierPath bezierPathWithRect:CGRectMake(textRect.origin.x+textRect.size.width-1, textRect.origin.y+textRect.size.height-8.0, 3, 16)];
            
        }
    }
    
    else
    {
        dragHandle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(selectedShape.end.x-6.0, selectedShape.end.y-6.0, 12.0, 12.0)];
        dragHandleInner = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(selectedShape.end.x-3.0, selectedShape.end.y-3.0, 6.0, 6.0)];
        UIBezierPath *linePath = [[UIBezierPath alloc] init];
        [linePath moveToPoint:CGPointMake(selectedShape.end.x-3.0, selectedShape.end.y-3.0)];
        [linePath addLineToPoint:CGPointMake(CGRectGetMidX(selectedShape.bzPath.bounds), CGRectGetMidY(selectedShape.bzPath.bounds))];
        //dragHandleInner = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(selectedShape.end.x-3.0, selectedShape.end.y-3.0, 6.0, 6.0)];
        
        linePath.lineWidth = 2.0;
        [linePath closePath];
        [[Utility CMYNColorLightBlue] setFill];
        CGFloat dashStyle[] = { 5.0f, 5.0f };
        [linePath setLineDash:dashStyle count:2 phase:2];
        [linePath fill];
        [linePath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
    }
    
    [dragHandle closePath];
    [[UIColor redColor] setFill];
    
    [dragHandle fill];
    [dragHandle closePath];
    
    //[dragHandleInner addArcWithCenter:selectedShape.end radius:4.0 startAngle:0 endAngle:2.0*M_PI clockwise:NO];
    
    
    [dragHandleInner closePath];
    
    [[UIColor blackColor] setFill];
    [dragHandleInner fill];
    
    
    [[UIColor blackColor] setFill];
    [dragHandleInner fill];
}

-(void)drawRotateHandle:(ShapeObject *)selectedShape
{
    
    UIBezierPath *rotateHandle = [[UIBezierPath alloc] init];
    //UIBezierPath *rotateHandleInner = [[UIBezierPath alloc] init];
    
    CGRect rect = [selectedShape shapeBounds];
    if ( !CGRectIsEmpty(rect) )
    {
        //get the center of the rect
        //[rotateHandle moveToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
        //get the height of the rectangle
        CGFloat height = CGRectGetHeight(rect);
        [rotateHandle moveToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)+height/2.0)];
        //[rotateHandle stroke];
        
        [rotateHandle addArcWithCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)+height/2.0) radius:10.0 startAngle:0 endAngle:1.75*M_PI clockwise:YES];
        
        [rotateHandle stroke];
        
    }
}


// Sets the current shape's properties
- (void)setCurrentShapeObjectAttributes
{
    _currentShape.color = _currentColor;
    _currentShape.lineWidth = [ColorToolViewController getBrushSize];
    _currentShape.alpha = [ColorToolViewController getAlpha];
    _currentShape.bzPath.lineWidth = _currentBrushSize;
    //_currentShape.type = [ShapesViewController getCurrentShape];
    
    if ( _currentShape.type == kLine)
    {
        _currentShape.alpha = [ColorToolViewController getAlpha];
        _currentShape.lineWidth = [ColorToolViewController getBrushSize];
    }
    
    else if ( _currentShape.type == kHighlighter )//highlighter
    {
        _currentShape.alpha = 0.50;
        _currentShape.lineWidth = 15;
        //_currentColor = [UIColor colorWithHue:(float)3/16  saturation:1.0 brightness:1.0 alpha:1.0];//get the fluorescent color
    }
    else if ( _currentShape.type == kText)
    {
        _currentShape.textObject.fontColor = [ColorToolViewController getCurrentColor];
    }
    else if ( _currentShape.type == kFreeform )
    {
        _currentShape.bzPath.lineWidth = [ColorToolViewController getBrushSize];
        _currentShape.alpha = [ColorToolViewController getAlpha];
        _currentShape.bzPath.lineCapStyle = kCGLineCapRound;
        _currentShape.bzPath.flatness = 0.4;
        _currentShape.bzPath.lineJoinStyle = kCGLineJoinRound;
        _currentShape.bzPath.miterLimit = 200.0;
        
    }
}


-(void)saveDatatoLocalStorage:(NSString *)filename
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MMM-dd-hh-mm-ss"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.shapes forKey:@"collection"];
    [archiver finishEncoding];
}

- (void)clearSelectedShape
{
    indexOfSelectedShape = -1;
    for(ShapeObject *i in self.shapes)
    {
        i.shapeSelected = FALSE;
    }
    
}

#pragma mark - Alert
- (void)clearDrawingPad:(id)sender
{
    //hide "pop-up" windows, if any
    [self dismissViewControllerAnimated:YES completion:nil];
    
    /*
    if ([self.toolPopoverController isPopoverVisible])
    {
        [self.toolPopoverController dismissPopoverAnimated:YES];
    }
    
    if ([self.shapesPopoverController isPopoverVisible])
    {
        [self.shapesPopoverController dismissPopoverAnimated:YES];
    }
     */
    
    self.deleteActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction;
    deleteAction = [UIAlertAction actionWithTitle:@"Delete All Annotations"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction *action) {
                                              [self deleteAllAnnotations];
                                          }];
    
    [self.deleteActionSheet addAction:deleteAction];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self.deleteActionSheet dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [self.deleteActionSheet addAction:cancel];
    }
    
    UIBarButtonItem *actionButton = [self getBarButtonForTag:kTrash  side:kRight];
    
    self.deleteActionSheet.popoverPresentationController.barButtonItem = actionButton;

    self.deleteActionSheet.popoverPresentationController.backgroundColor = [Utility CMYNColorRed3];
    UIView *view = self.deleteActionSheet.view.subviews.firstObject;
    view.backgroundColor = [Utility CMYNColorLightYellow];

    [self presentViewController:self.deleteActionSheet animated:YES
                     completion:nil];
    
}



- (void)displaySocialComposer:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    //if there is no annotation in the current page, disable tweet button
    if ( [self.document containsDirtyKey:self.pageNumber])
    {
        self.socialActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *emailAction;
        emailAction = [UIAlertAction actionWithTitle:@"Email All Annotated Pages" style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self openEmailComposer];
                                             }];
        
        [self.socialActionSheet addAction:emailAction];
        
        NSString *tweetPageText = [NSString stringWithFormat:@"Tweet Page #%d",self.pageNumber];
        UIAlertAction *tweetAction = [UIAlertAction actionWithTitle:tweetPageText style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self openTweetComposer];
                                                            }];
        
        [self.socialActionSheet addAction:tweetAction];
        
        NSString *facebookPageText = [NSString stringWithFormat:@"Update FaceBook with Page #%d",self.pageNumber];
        UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:facebookPageText style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [self openFacebookComposer];
                                                               }];
        
        [self.socialActionSheet addAction:facebookAction];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self.socialActionSheet dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [self.socialActionSheet addAction:cancel];
        }
        UIBarButtonItem *actionButton = [self getBarButtonForTag:kAction  side:kLeft];
        
        self.socialActionSheet.popoverPresentationController.barButtonItem = actionButton;
        self.socialActionSheet.popoverPresentationController.backgroundColor = [Utility CMYNColorRed3];

        UIView *view = self.socialActionSheet.view.subviews.firstObject;
        view.backgroundColor = [Utility CMYNColorLightYellow];


        [self presentViewController:self.socialActionSheet animated:YES
                         completion:nil];
    }
    else
    {
        self.socialActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *emailAction;
        emailAction = [UIAlertAction actionWithTitle:@"Email All Annotated Pages" style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self openEmailComposer];
                                             }];
        
        [self.socialActionSheet addAction:emailAction];
        
        UIBarButtonItem *actionButton = [self getBarButtonForTag:kAction  side:kLeft];
        
        self.socialActionSheet.popoverPresentationController.barButtonItem = actionButton;
        UIView *view = self.socialActionSheet.view.subviews.firstObject;
        view.backgroundColor = [Utility CMYNColorLightYellow];
        self.socialActionSheet.popoverPresentationController.backgroundColor = [Utility CMYNColorRed3];

        [self presentViewController:self.socialActionSheet animated:YES
                         completion:^
         {
             self.socialActionSheet.view.tintColor = [Utility CMYNColorRed3];
         }];

    }
}

-(void)openEmailComposer
{
    if ( [MFMailComposeViewController canSendMail])
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //[self saveDocument];
        
        MailViewController *mailVC = [[MailViewController alloc] initWithData:[self.document createPdfForEmail:self.documentURL]];
        mailVC.mailComposeDelegate = self;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            
            [self presentViewController:mailVC animated:YES completion:^
             {
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }];
        else
        {
            /*
             dispatch_async(dispatch_get_main_queue(), ^ {
             [self presentViewController:mailVC animated:YES completion:^{
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }];
             });*/
            self.navigationController.navigationBarHidden = YES;
            
            mailVC.definesPresentationContext = YES; //self is presenting view controller
            mailVC.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            mailVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;        //now present this navigation controller modally
            mailVC.navigationBarHidden = NO;
            [self presentViewController:mailVC animated:NO completion: ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultSent:
            //NSLog(@"Result: sent");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Result: saved");
            break;
            
        case MFMailComposeResultCancelled:
            //NSLog(@"Result: canceled");
            break;
            
        case MFMailComposeResultFailed:
            //NSLog(@"Result: failed");
            break;
        default:
            //NSLog(@"Result: not sent");
            break;
    }
    //[controller dismissViewControllerAnimated:YES completion:nil];
    [controller dismissViewControllerAnimated:YES completion:^{
        if ( self.navigationController.navigationBarHidden )
            self.navigationController.navigationBarHidden = NO;
    }];
}

-(void)openTweetComposer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeTweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeTweet setInitialText:@"Refer to my annotations #CMyNotes"];
        
        UIImage *imageForTwitter = [self getImageWithCMyNotesWatermarkFromView:self.jCRPDFView forFrameSize:self.jCRPDFView.bounds forSocialPage:0];
        
        [composeTweet addImage:imageForTwitter];
        [composeTweet setCompletionHandler:^(SLComposeViewControllerResult result) {

            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Tweet Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Successfully tweeted");
                    break;

                default:
                    break;
            }
        }];
        //[self presentViewController:composeTweet animated:YES completion:nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:composeTweet animated:YES completion:^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];}];
        }];
        
    }
    /*
     else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"You cannot send a tweet now!!"
                                                                       message:@"Make sure your device has an internet connection and your Twitter account is setup"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
     */
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)openFacebookComposer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeUpdate4FB = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeUpdate4FB setInitialText:@"Refer to my annotations - powered by @CMyNotes"];
        
        UIImage *imageForTwitter = [self getImageWithCMyNotesWatermarkFromView:self.jCRPDFView forFrameSize:self.jCRPDFView.frame forSocialPage:1];
        
        [composeUpdate4FB addImage:imageForTwitter];

        [composeUpdate4FB setCompletionHandler:^(SLComposeViewControllerResult result) {

            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Successfully posted");
                    break;

                default:
                    break;
            }
        }];

        
        [self presentViewController:composeUpdate4FB animated:YES completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];}];
    }
    /*
     else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"You cannot post this update in your facebook"
                                                                       message:@"Make sure your device is connected to the Internet and your Facebook account is setup"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }*/
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void)removeAllPhotoFiles
{
    //find all photo files from the page and remove them from Application Support Page
    
    for ( ShapeObject *obj in self.shapes)
    {
        if ( [obj getType] == kPhoto )
        {
            [self removeFileArURL:[self getApplicationSupportFolderURLForFile:obj.imageObject.fileName]];
        }
    }
}

-(void)deleteAllAnnotations
{
    //do a check for shape count
    if ( [self.shapes count] > 0)
    {
        [self removeAllPhotoFiles];
        
        [self.shapes removeAllObjects];
        
        skipDrawingCurrentShape = TRUE;
        
        [self resetCurrentShape];
        [self refresh];
        
        
        [self removePageFromthumbnailCollectionView];
        
        //remove all image files if any
        
        //get the undo barbutton handle to enable it
        UIBarButtonItem *trash = [self getBarButtonForTag:kTrash  side:kRight];
        trash.enabled = NO;
        [self updateStorageModel];
        
        //[self storePage:self.pageNumber];
        skipDrawingCurrentShape = FALSE;
        indexOfSelectedShape = -1;
    }
    
    else
    {
        UIBarButtonItem *trash = [self getBarButtonForTag:kTrash  side:kRight];
        trash.enabled = NO;
    }
}


#pragma mark - Buttons & Features

-(void)deleteSelectedShape
{
    if(indexOfSelectedShape != -1 && ([self.shapes  count]))
    {
        self.cutCopyShape = [[self.shapes objectAtIndex:indexOfSelectedShape] copy];
        [self.deletedShapes addObject: [[self.shapes objectAtIndex:indexOfSelectedShape] copy]];
        [self.shapes removeObjectAtIndex:indexOfSelectedShape];
        
        [self resetCurrentShape];
        
        if ( [self.shapes count] == 0)
        {
            [self removePageFromthumbnailCollectionView];
            self.shapes = [[NSMutableArray alloc] init];
            UIBarButtonItem *trash = [self getBarButtonForTag:kTrash side:kRight];
            trash.enabled = NO;
        }
        indexOfSelectedShape = -1;
        
        self.shapeObjectChanged = TRUE;
        
        [self updateStorageModel];
        
        //for undo operation
        UIBarButtonItem *undo = [self getBarButtonForTag:kUndo side:kLeft];
        undo.enabled = YES;
        self.undoOperation = TRUE;
        
        [self refresh];
        
    }
}


-(void)resetCurrentShape
{
    //retain old properties
    ShapeType type = self.currentShape.type;
    UIColor *color = self.currentShape.color;
    float lineWidth = self.currentShape.lineWidth;
    float alpha = self.currentShape.alpha;
    self.currentShape = [[ShapeObject alloc] init];
    //retain shape type, width and color
    self.currentShape.type = type;
    self.currentShape.color = color;
    self.currentShape.lineWidth = lineWidth;
    self.currentShape.alpha = alpha;
}

-(void)broadcastGobackMessage
{
    BOOL dirty = YES;
    
    [self clearSelectedShape];
    //save the chanes in the document
    [self saveDocument];
    //broadcast that the color selection changed
    NSDictionary *drawingPadDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:dirty] forKey:@"BackToHome"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"BackToHome" object:self userInfo: drawingPadDict];
}

- (IBAction)goBack:(id)sender
{
    [self broadcastGobackMessage ];
}

-(void)storeThumbNails:(int)pageNumber
{
    UIImage *thumbnailImage;
    
    //[self.view addSubview:self.notesView];
    //9. get the image of the modified page - IMAGE does not CAPTURE SHAPES
    //thumbnailImage = [self getImageFromView:self.pdfView forFrameSize:self.pdfView.frame];
    thumbnailImage = [self getImageWithCMyNotesWatermarkFromView:self.jCRPDFView forFrameSize:self.jCRPDFView.frame forSocialPage:2];
    //10. save it in the dictionary - Datasource for thumbnail images
    //[self.document insertPage:arrayOfObjects atPageNumber:pageNumber];
    //[dirtyPages setObject:thumbnailImage forKey:pageNumberString];
    //get the time stamp for the thumbnail (for every dirty pages). This is different from document time stamp
    
    if ( thumbnailImage != nil )
    {
        [self.document insertThumbnail:thumbnailImage pageNumber:pageNumber url:self.documentURL];
        [self updateStorageModel];
        [self broadcastMessageIGotThumbnails:YES];
    }
}

-(UIImage *)getImageFromView:(UIView *)view forFrameSize:(CGRect)frame
{
    //to remember the state
    BOOL thumbnailCollectionViewState = [self.thumbnailCollectionView isHidden];
    BOOL navigationControllerState = self.navigationController.navigationBarHidden;
    BOOL pageSliderState = [self.pageSlider isHidden];

    self.previousPageButton.hidden = YES;
    self.nextPageButton.hidden = YES;

    if ( !thumbnailCollectionViewState )
        self.thumbnailCollectionView.hidden = TRUE;
    if ( !navigationControllerState )
        self.navigationController.navigationBarHidden = TRUE;
    
    if (!pageSliderState)
        self.pageSlider.hidden = TRUE;
    
    NSInteger indexSS = indexOfSelectedShape;
    if ( indexSS > -1 )
    {
        indexOfSelectedShape = -1;
        [self clearSelectedShape];
        [self refresh];
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 2.0);
    else
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    
    self.jCRPDFView.layer.frame = frame;
    //UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0.0);
    
    [self.jCRPDFView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    //check for retina
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
        viewImage = [UIImage imageWithCGImage:viewImage.CGImage scale:2 orientation:viewImage.imageOrientation];
    
    
    UIGraphicsEndImageContext();
    //bring back the control and thumbnailCollectionView to original state
    self.thumbnailCollectionView.hidden = thumbnailCollectionViewState;
    self.navigationController.navigationBarHidden = navigationControllerState;
    self.pageSlider.hidden = pageSliderState;

    self.previousPageButton.hidden = NO;
    self.nextPageButton.hidden = NO;

    
    if ( indexSS > -1 )
    {
        indexOfSelectedShape = indexSS;
        [self refresh];
    }
    return viewImage;
}


-(UIImage *)getImageWithCMyNotesWatermarkFromView:(UIView *)view forFrameSize:(CGRect)frame forSocialPage:(int)socialPage
{
    //to remember the state
    BOOL thumbnailCollectionViewState = [self.thumbnailCollectionView isHidden];
    BOOL navigationControllerState = self.navigationController.navigationBarHidden;
    BOOL pageNavigationButtonState = [self.previousPageButton isHidden];
    BOOL pageSliderState = [self.pageSlider isHidden];
    
    if ( !thumbnailCollectionViewState )
        self.thumbnailCollectionView.hidden = TRUE;
    if ( !navigationControllerState )
        self.navigationController.navigationBarHidden = TRUE;
    
    if (!pageSliderState)
        self.pageSlider.hidden = TRUE;
    
    if ( navigationControllerState )
    {
        self.previousPageButton.hidden = YES;
        self.nextPageButton.hidden = YES;
    }

    self.previousPageButton.hidden = YES;
    self.nextPageButton.hidden = YES;

    NSInteger indexSS = indexOfSelectedShape;
    if ( indexSS > -1 )
    {
        indexOfSelectedShape = -1;
        [self clearSelectedShape];
        [self refresh];
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 2.0);
    else
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    self.jCRPDFView.layer.frame = frame;
    [self.jCRPDFView.layer renderInContext:UIGraphicsGetCurrentContext()];
    //first watermark with CMYNotes stamp
    [self drawTextWaterMarkForView:view frame:view.bounds forSocialPage:socialPage];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //check for retina
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
        viewImage = [UIImage imageWithCGImage:viewImage.CGImage scale:2 orientation:viewImage.imageOrientation];
    
    UIGraphicsEndImageContext();
    
    //bring back the control and thumbnailCollectionView to original state
    self.thumbnailCollectionView.hidden = thumbnailCollectionViewState;
    self.navigationController.navigationBarHidden = navigationControllerState;
    self.pageSlider.hidden = pageSliderState;
    self.previousPageButton.hidden = pageNavigationButtonState;
    self.nextPageButton.hidden = pageNavigationButtonState;

    self.previousPageButton.hidden = NO;
    self.nextPageButton.hidden = NO;

    if ( indexSS > -1 )
    {
        indexOfSelectedShape = indexSS;
        [self refresh];
    }
    return viewImage;
}

-(void)drawTextWaterMarkForView:(UIView*)view frame:(CGRect)frame forSocialPage:(int)socialPage
{
    /*
     NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentLeft;
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:8];
    UIColor *textColor = [UIColor yellowColor];
    
    UIColor *backgroundColor =  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    NSMutableAttributedString *text;
    if ( socialPage == 0 )
        text = [[NSMutableAttributedString alloc] initWithString:@"Tweeted using CMyNotes" attributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle,  NSForegroundColorAttributeName:textColor, NSBackgroundColorAttributeName:backgroundColor}]  ;
    else if ( socialPage == 1 )
        text = [[NSMutableAttributedString alloc] initWithString:@"Facebook update with CMyNotes" attributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle,  NSForegroundColorAttributeName:textColor, NSBackgroundColorAttributeName:backgroundColor}] ;
    
    else
        text = [[NSMutableAttributedString alloc] initWithString:@"Annotated using CMyNotes" attributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle,  NSForegroundColorAttributeName:textColor, NSBackgroundColorAttributeName:backgroundColor}] ;
    [text drawInRect:frame];
*/

    UIImage *brushImage = [UIImage imageNamed:@"AppIcon"];

    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, brushImage.size.width, brushImage.size.height);
    imageLayer.contents = (id) brushImage.CGImage;
    imageLayer.opacity = 0.25;
    imageLayer.borderColor = [UIColor redColor].CGColor;
    imageLayer.borderWidth = 2.0;
    /*
     imageLayer.shadowOffset = CGSizeMake(10.0,-5.0);
    imageLayer.shadowColor = [UIColor grayColor].CGColor;
    imageLayer.shadowOpacity = 1.0f;
    //imageLayer.shadowRadius = 15.0;
    //imageLayer.shadowPath = [UIBezierPath bezierPathWithRect:imageLayer.bounds].CGPath;
     */
    imageLayer.cornerRadius = 15.0;
    imageLayer.masksToBounds = YES;

    UIGraphicsBeginImageContext(brushImage.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [roundedImage drawAtPoint:CGPointMake(frame.origin.x+20.0, frame.size.height/2.0)];

    /*UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppIcon"]];
    imageView.alpha = 0.5; //Alpha runs from 0.0 to 1.0
    imageView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    imageView.alpha = 0.25;
    imageView.layer.cornerRadius = 20.0;
    [view addSubview:imageView];*/
    
}


-(void)drawVersionText:(CGRect)frame
{
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont boldSystemFontOfSize:20];
    NSString *text= @"Version 2.0";
    [[UIColor redColor] set];
    
    [text drawInRect:frame  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle, NSStrokeColorAttributeName:[UIColor whiteColor], NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)didPickColor:(UIColor *)color
{
    _currentColor = color;
    
    if(indexOfSelectedShape != -1 && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.color = color;
        [self refreshShapesinRect:[obj frame]] ;//]ShapesinRect:[self getRectForShape:obj]];
        obj = nil;
    }
}

-(void)alphaChanged:(float)alpha
{
    _currentAlpha = alpha;
    if(indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.alpha = alpha;
        [self refresh];//ShapesinRect:[self getRectForShape:obj]];
        obj = nil;
    }
}

//Font properties Delegate
-(void)fontChanged:(NSNotification *) notification
{
    UIFont *font = [[notification userInfo] valueForKey:@"FontChanged"];
    
    self.currentFont = font;
    
    if(indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.textObject.font = font;
        if ( obj.type == kText || obj.type == kCloseReading)
        {
            [obj.textObject.attributedText addAttribute:NSFontAttributeName
                                                  value:font
                                                  range:(NSRange){0, [obj.textObject.attributedText length]}];
            CGRect boundingRect = [obj.textObject.attributedText boundingRectWithSize:CGSizeMake(48, 16) options:NSStringDrawingUsesFontLeading context:nil];
            obj.end = CGPointMake(obj.origin.x+boundingRect.size.width, obj.origin.y+boundingRect.size.height);
            obj.textObject.textSize = CGSizeMake(boundingRect.size.width, boundingRect.size.width);
        }
        [self refresh] ;//]ShapesinRect:[self getRectForShape:obj]];
        
        //obj = nil;
    }
    
    [self broadcastCurrentFont];
}


//Handle TExtEditor notification
-(void)textEditingCompleted:(NSNotification *) notification
{
    TextEditor *textView = [[notification userInfo] valueForKey:@"TextEditingCompleted"];
    
    //NSAttributedString *attributedText = [[notification userInfo] valueForKey:@"TextEditingCompleted"];
    
    if ( [textView.text length] == 0)
    {
        NSArray *gestureRecognizers = [self.view gestureRecognizers];
        
        for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
        {
            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
            {
                gestureRecognizer.enabled = YES;
            }
            if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
            {
                gestureRecognizer.enabled = YES;
            }
        }
        [textView removeFromSuperview];
        textEditMode = FALSE;
        self.navigationController.navigationBarHidden = NO;
        return;
    }
    if(indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        if ( obj.type == kText)
        {
            obj.textObject.attributedText = [textView.attributedText mutableCopy];
            //obj.textObject.textStorage = [[NSTextStorage alloc] initWithAttributedString:[textView.attributedText mutableCopy]];
            obj.textObject.textContainer = textView.textContainer; //[[NSTextContainer alloc] initWithSize:textView.bounds.size];
            obj.textObject.textContainer.size = textView.frame.size;
            obj.textObject.textSize = textView.frame.size;
            obj.origin = CGPointMake(textView.frame.origin.x, textView.frame.origin.y);
            obj.end = CGPointMake(obj.origin.x+textView.frame.size.width, obj.origin.y+textView.frame.size.height);
        }
        [self refreshShapesinRect:[obj frame]] ;//]ShapesinRect:[self getRectForShape:obj]];
    }
    else if ( indexOfSelectedShape == -1 ) //new object
    {
        ShapeObject *shape = [[ShapeObject alloc] init];
        TextObject *textObject = [[TextObject alloc] init] ;//]:[textView.attributedText mutableCopy]];
        
        shape.type = kText;
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[textView.attributedText mutableCopy]];
        NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
        
        // Add layout manager to text storage object
        [textStorage addLayoutManager:textLayout];
        // Create a text container
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:textView.frame.size];
        // Add text container to text layout manager
        [textLayout addTextContainer:textContainer];
        
        textObject.attributedText = [textView.attributedText mutableCopy];
        textObject.textStorage = textStorage;
        textObject.textContainer = textContainer;
        textObject.layoutManager = textLayout;
        textObject.text = textView.text;
        textObject.textSize = textView.frame.size;
        shape.textObject = textObject;
        shape.alpha = [ColorToolViewController getAlpha];
        shape.color = _currentColor;
        shape.origin = CGPointMake(textView.frame.origin.x, textView.frame.origin.y);
        shape.end = CGPointMake(shape.origin.x+textView.frame.size.width, shape.origin.y+textView.frame.size.height);
        _currentShape = shape;
        [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
        [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
        [self refreshShapesinRect:[shape frame]] ;//]ShapesinRect:[self getRectForShape:obj]];
    }
    
    
    NSArray *gestureRecognizers = [self.view gestureRecognizers];
    
    for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
    {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            gestureRecognizer.enabled = YES;
            break;
        }
        if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        {
            gestureRecognizer.enabled = YES;
        }
    }
    [textView removeFromSuperview];
    [self saveShapesToCurrentPage];
    
    //[self clearSelectedShape];
    textEditMode = FALSE;
    self.navigationController.navigationBarHidden = NO;
    _currentShape = [[ShapeObject alloc] init];
    _currentShape.type = kNoShapeSelected;
    [self refresh];
}

/*
 to be used with TextEditorDelegate
 -(void)endTextEditing:(NSDictionary *) dictionary
 {
 TextEditor *textView = [dictionary valueForKey:@"TextEditingCompleted"];
 
 //NSAttributedString *attributedText = [[notification userInfo] valueForKey:@"TextEditingCompleted"];
 
 if ( [textView.text length] == 0)
 {
 [textView resignFirstResponder];
 NSArray *gestureRecognizers = [self.view gestureRecognizers];
 
 for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
 {
 if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 gestureRecognizer.enabled = YES;
 }
 if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 gestureRecognizer.enabled = YES;
 }
 }
 return;
 }
 if(indexOfSelectedShape != -1  && ([self.shapes count] > 0))
 {
 ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
 if ( obj.type == kText)
 {
 obj.textObject.attributedText = [textView.attributedText mutableCopy];
 //obj.textObject.textStorage = [[NSTextStorage alloc] initWithAttributedString:[textView.attributedText mutableCopy]];
 //obj.textObject.textContainer = textView.textContainer; //[[NSTextContainer alloc] initWithSize:textView.bounds.size];
 //obj.textObject.textContainer = textContainer;
 //obj.textObject.textContainer.size = textView.frame.size;
 obj.textObject.textSize = textView.frame.size;
 obj.origin = CGPointMake(textView.frame.origin.x, textView.frame.origin.y);
 obj.end = CGPointMake(obj.origin.x+textView.frame.size.width, obj.origin.y+textView.frame.size.height);
 }
 }
 else if ( indexOfSelectedShape == -1 ) //new object
 {
 ShapeObject *shape = [[ShapeObject alloc] init];
 TextObject *textObject = [[TextObject alloc] init] ;//]:[textView.attributedText mutableCopy]];
 
 
 shape.type = kText;
 
 
 NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[textView.attributedText mutableCopy]];
 NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
 // Add layout manager to text storage object
 [textStorage addLayoutManager:textLayout];
 // Create a text container
 NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:textView.frame.size];
 // Add text container to text layout manager
 [textLayout addTextContainer:textContainer];
 
 textObject.attributedText = [textView.attributedText mutableCopy];
 textObject.textStorage = textStorage;
 textObject.textContainer = textContainer;
 textObject.layoutManager = textLayout;
 textObject.text = textView.text;
 textObject.textSize = textView.frame.size;
 //textObject.font = textView.font;
 shape.textObject = textObject;
 shape.alpha = [ColorToolViewController getAlpha];
 shape.color = _currentColor;
 shape.origin = CGPointMake(textView.frame.origin.x, textView.frame.origin.y);
 shape.end = CGPointMake(shape.origin.x+textView.frame.size.width, shape.origin.y+textView.frame.size.height);
 _currentShape = shape;
 [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
 [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
 }
 
 
 NSArray *gestureRecognizers = [self.view gestureRecognizers];
 
 for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
 {
 if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 gestureRecognizer.enabled = YES;
 }
 if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 gestureRecognizer.enabled = YES;
 }
 }
 [self saveShapesToCurrentPage];
 
 //[self clearSelectedShape];
 textEditMode = FALSE;
 _currentShape = nil;
 [self refresh];
 
 }
 */

-(void)broadcastCurrentFont
{
    //broadcast to that there is a new font available
    NSDictionary *fontInfo = [NSDictionary dictionaryWithObject:self.currentFont forKey:@"CurrentFont"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CurrentFont" object:self userInfo: fontInfo];
}

-(void)chooseHighlighter:(id)sender
{
    _currentShape.type = kHighlighter;
    
    _currentShape.lineWidth = 15;
    _currentShape.textObject = nil;
    _currentShape.alpha = 0.50;
    
}

- (IBAction)textButtonClicked:(id)sender
{
    _currentShape.type = kText;
    TextObject *textObject = [[TextObject alloc] init];
    
    _currentShape.textObject = textObject;
    
    _currentShape.textObject.fontColor = [ColorToolViewController getCurrentColor];
}

- (void)eraserButtonClicked:(id)sender
{
    if ( indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        ShapeObject *shape = [self.shapes objectAtIndex:indexOfSelectedShape];
        [self.deletedShapes addObject: [[ShapeObject alloc] initCopy:shape]];
        
        [self deleteSelectedShape];
        UIBarButtonItem *eraser = [self getBarButtonForTag:kDelete  side:kRight];
        eraser.enabled = NO;
        self.undoOperation = TRUE;
        shape = nil;
        
    }
}

#pragma mark - TextBox creation and operations


-(void)createTextAtPoint:(CGPoint)point textContainer:(NSTextContainer *)textContainer
{
    [self createTextAtPoint:point frame:CGRectZero textContainer:textContainer];
    //disable single and double tap until edit is completed
    NSArray *gestureRecognizers = [self.view gestureRecognizers];
    
    for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
    {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            gestureRecognizer.enabled = NO;
            break;
        }
        if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        {
            gestureRecognizer.enabled = NO;
        }
    }
}

-(void)createTextAtPoint:(CGPoint) point frame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    //if textObject is nil, create a new text view and allow user to edit
    //create with a standard height and width
    //else place the text at the given location
    TextEditor *textEditor;
    
    
    if ( CGRectEqualToRect(frame, CGRectZero))
    {
        frame = CGRectMake(self.jCRPDFView.frame.size.width/5.0,self.jCRPDFView.frame.size.height/2.0, self.jCRPDFView.frame.size.width/2.0, 72);
        textContainer = _currentShape.textObject.textContainer;
        //textEditor = [[TextEditor alloc] initTextEditor:_currentShape.textObject frame:frame];
        textEditor = [[TextEditor alloc] initWithFrame:frame textContainer:textContainer];
        //[textEditor setDelegate:self];
        
    }
    else
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.color = [UIColor clearColor];
        obj.textObject.attributedText = nil;
        obj.textObject.text = @"";
        [self refreshShapesinRect:[obj frame]];
        textEditor = [[TextEditor alloc] initWithFrame:frame textContainer:obj.textObject.textContainer];
        //[textEditor setDelegate:self];
        
    }
    
    [self.jCRPDFView addSubview:textEditor];
    textEditMode = YES;
    self.navigationController.navigationBarHidden = YES;
    [textEditor performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
}


-(void)changeTextColor:(id)sender
{
    [self colorTool:sender];
}

-(void)textEntryDone:(id)sender
{
    UITextView *textView =  (UITextView*)[self.view viewWithTag:10001];
    [textView resignFirstResponder];
    NSArray *gestureRecognizers = [self.view gestureRecognizers];
    
    for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
    {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            gestureRecognizer.enabled = YES;
            break;
        }
    }
}


-(CGRect)getRectForShape:(ShapeObject *)shape
{
    CGRect rect = CGRectMake(shape.origin.x, shape.origin.y, fabs(shape.origin.x-shape.end.x), fabs(shape.origin.y-shape.end.y));
    return rect;
}

- (IBAction)undo:(id)sender
{
    if ( self.deletedShapes.count > 0 )
    {
        //get the last object from the deletedShapes arrary and insert it in the _collection array
        ShapeObject *shape = [[ShapeObject alloc] initCopy:[self getLastObject:self.deletedShapes]];
        
        int oldCount = (int)[self.shapes count ];
        [self.shapes addObject: [[ShapeObject alloc] initCopy:shape]];
        int newCount = (int)[self.shapes count];
        
        if ( oldCount == 0 && newCount == 1 ) //BAD
        {
            
            [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
            [self updateStorageModel];
            
            //[self centerthumbnailCollectionView];
            
            UIBarButtonItem *trash = [self getBarButtonForTag:kTrash  side:kRight];
            trash.enabled = TRUE;
            
            //insert shapes into the database
        }
        [self.deletedShapes removeLastObject ];//: [[ShapeObject alloc] initCopy:_currentShape]];
        
        if ( self.deletedShapes.count == 0 )
        {
            UIBarButtonItem *eraser = [self getBarButtonForTag:kDelete  side:kRight];
            eraser.enabled = NO;
            UIBarButtonItem *undo = [self getBarButtonForTag:kUndo  side:kLeft];
            undo.enabled = NO;
        }
        [self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
        [self updateStorageModel];
        
        //enable trash can
        [self broadcastMessageIGotShapes:TRUE];
        [self centerthumbnailCollectionView];
        
        //4. redraw
        //[self refresh]; This clears the shapes
        [self storeThumbNails:self.pageNumber];
        
        [self clearSelectedShape];
        shape = nil;
    }
    
    //skipDrawingCurrentShape = TRUE;
    //LATER[self refreshShapesinRect:rect];
    [self refresh];
    //skipDrawingCurrentShape = FALSE;
}


//store a page for the document
-(void)storePage:(int)pageNumber
{
    
    //1. get the page number
    [self.document setDocumentType:self.documentType];
    
    //save only when there is atleast one shape drawn
    if ( [self.shapes count] > 0 )
    {
        //1. Store the shapes
        [self.document insertPage:[self.shapes copy] atPageNumber:pageNumber];
        
        //2.remove shapes of the previous page
        [self.shapes removeAllObjects];
        _currentShape = [[ShapeObject alloc] init];
        
        //3. reload thumbnail view
        //[self centerthumbnailCollectionView];
        
        //4. redraw
        //[self storeThumbNails:pageNumber];
        
        //5. update pageData
        [self updateStorageModel];
    }
    
    //10. save it in the dictionary - Datasource for thumbnail images
    //[self.document insertPage:arrayOfObjects atPageNumber:pageNumber];
    //[dirtyPages setObject:thumbnailImage forKey:pageNumberString];
    //if ( self.documentType != kXLS )
}



-(void)resetShapeRelatedGlobals
{
    [self clearSelectedShape];
    
    [self.shapes removeAllObjects];
    
    _currentShape = [[ShapeObject alloc] init];
    _currentShape.type = [ShapesViewController getCurrentShape];
    
    self.shapeObjectChanged = FALSE;
}


-(UIImageView *)displayLogo
{
    NSString *imageName;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        imageName = @"Default.png";
    }
    else
    {
        imageName = @"Default1248x2208@3x.png";
    }
    
    UIImageView *imageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:imageName]];
    //imageView.frame =   CGRectMake(0.0,0.0,imageView.image.size.width, imageView.image.size.height);
    imageView.frame =   CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,self.view.bounds.size.width, self.view.bounds.size.height);
    //imageView.frame =   self.pdfView.frame;
    UILabel *label = [[UILabel alloc ] initWithFrame:imageView.frame];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:35.0];
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowBlurRadius = 3.0;
    textShadow.shadowColor = [UIColor whiteColor];
    textShadow.shadowOffset = CGSizeMake(1.0, -1.0);
    
    //get the CMyNotes Version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:version ];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [attributedString setAttributes:@{NSFontAttributeName:[font fontWithSize:45.0],NSBaselineOffsetAttributeName :@20, NSShadowAttributeName: textShadow, NSStrokeWidthAttributeName:@3} range:NSMakeRange(0, 3)];
    }
    else
    {
        [attributedString setAttributes:@{NSFontAttributeName:[font fontWithSize:25.0],NSBaselineOffsetAttributeName :@20, NSShadowAttributeName: textShadow, NSStrokeWidthAttributeName:@3} range:NSMakeRange(0, 3)];
    }
    
    label.attributedText = attributedString;
    label.textColor = [UIColor yellowColor];
    //label.font = [UIFont boldSystemFontOfSize:35.0];
    label.textAlignment = NSTextAlignmentRight;
    
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView addSubview:label];
    
    
    
    return imageView;
}

-(void)broadcastMessageIGotThumbnails:(BOOL)thumbnailsFound
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:thumbnailsFound] forKey:@"IGotThumbnails"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"IGotThumbnails" object:self userInfo:dictionary];
}


-(void)broadcastMessageIGotShapes:(BOOL)shapesFound
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:shapesFound] forKey:@"IGotShapes"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"IGotShapes" object:self userInfo:dictionary];
}
/*
 -(void)nextPPTSlide:(id)sender
 {
 if ( _pageNumber > [self.pptController.slides count] - 1)
 _pageNumber = (int)[self.pptController.slides count]-1;
 else
 {
 //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromRight];
 //[[self.pptView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
 
 [UIView transitionWithView:self.pptView.webView
 duration:0.01
 options:UIViewAnimationOptionTransitionCrossDissolve
 animations:^ { self.pptView.webView.alpha = 1.0; }
 completion:^(BOOL finished){ ; }];
 }
 
 [self displayPPT:_pageNumber];
 }
 
 -(void)previousPPTSlide:(id)sender
 {
 if ( _pageNumber <= -1  ) //no animation for page flipping
 _pageNumber = 0;
 else
 {
 //animate page flipping
 //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromLeft];
 //[[self.pptView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
 [UIView transitionWithView:self.pptView.webView
 duration:0.01
 options:UIViewAnimationOptionTransitionCrossDissolve
 animations:^ { self.pptView.webView.alpha = 1.0; }
 completion:^(BOOL finished){ ; }];
 
 }
 
 [self displayPPT:_pageNumber];
 }
 
 
 //Check if the page is already dirtied. If so, get it from the documentController. else
 //display from parent document
 -(void)displayPPT:(int)pageNumber
 {
 
 //if ( [dirtyPageNumberSet containsObject:[NSString stringWithFormat:@"%d",pageNumber]] )
 if ([self.document containsDirtyKey:pageNumber])
 {
 //delete _shapes of the current page;
 [self.shapes removeAllObjects];
 _currentShape = [[ShapeObject alloc] init];
 //get the page,
 NSArray *array = [self.document getPage:pageNumber];
 //NSString *page = [array objectAtIndex:1];
 //using PPTView
 [self.pptView refresh:pageNumber];
 //[_webView loadHTMLString:page baseURL:nil];
 NSArray *shapesArray = [array objectAtIndex:2];
 
 for(ShapeObject *shape in shapesArray)
 {
 [self.shapes addObject:shape];
 }
 //[self refresh];
 
 }
 else
 {
 //NSLog(@"previous page -  gesture identified = %d", pageNumber);
 //NSString *page = [self.pptController getSlide:pageNumber];
 //[_webView loadHTMLString:page baseURL:nil];
 //new
 [self.pptView refresh:pageNumber];
 
 }
 }
 
 -(void)nextXLSSheet:(id)sender
 {
 int count = self.xlsSheetCount;
 if  (_pageNumber > count - 1)
 {
 UIImageView *imageView = [self displayLogo];
 
 [UIView transitionWithView:self.xlsView
 duration:1.25
 options:UIViewAnimationOptionTransitionCurlUp
 animations:^
 {
 [self.xlsView addSubview:imageView];
 }
 completion:^(BOOL finished)
 {
 [UIView transitionWithView:self.xlsView
 duration:1.75
 options:UIViewAnimationOptionTransitionCurlDown
 animations:^
 {
 [imageView removeFromSuperview];
 
 }
 completion:^(BOOL finished)
 {
 self.xlsView.alpha = 1.0;
 }
 ];
 }
 ];
 _pageNumber = count-1 ;
 }
 else
 {
 
 [UIView transitionWithView:self.xlsView
 duration:0.75
 options:UIViewAnimationOptionTransitionCurlUp
 animations:^ { self.xlsView.alpha = 1.0; }
 completion:^(BOOL finished){ ; }];
 
 }
 
 [ self displayXLS:_pageNumber];
 //COMMEMTED EARLIER
 
 //COMMEMTED EARLIERif ( _pageNumber > self.xlsSheetCount - 1)
 //COMMEMTED EARLIER{
 //COMMEMTED EARLIER_pageNumber = self.xlsSheetCount-1;
 //COMMEMTED EARLIER[self displayXLS:_pageNumber];
 
 //COMMEMTED EARLIER}
 //COMMEMTED EARLIERelse
 //COMMEMTED EARLIER{
 //       page flipping is slow ND JERKY
 //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromRight];
 //[[self.pptView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
 
 //COMMEMTED EARLIER[UIView transitionWithView:self.xlsView.webView
 //COMMEMTED EARLIERduration:0.75
 //COMMEMTED EARLIERoptions:UIViewAnimationOptionTransitionCurlUp
 //COMMEMTED EARLIERanimations:^ { self.xlsView.webView.alpha = 0.5;[self displayXLS:_pageNumber]; self.xlsView.webView.alpha = 1.0;  }
 //COMMEMTED EARLIERcompletion:^(BOOL finished){;}];
 //COMMEMTED EARLIER }
 
 }
 */
/*
 -(void)previousXLSSheet:(id)sender
 {
 
 if  (_pageNumber <= -1  )
 {
 UIImageView *imageView = [self displayLogo];
 
 [UIView transitionWithView:self.xlsView
 duration:1.25
 options:UIViewAnimationOptionTransitionCurlDown
 animations:^
 {
 [self.xlsView addSubview:imageView];
 }
 completion:^(BOOL finished)
 {
 [UIView transitionWithView:self.xlsView
 duration:1.75
 options:UIViewAnimationOptionTransitionCurlUp
 animations:^
 {
 [imageView removeFromSuperview];
 
 }
 completion:^(BOOL finished)
 {
 self.pdfView.alpha = 1.0;
 }
 ];
 }
 ];
 _pageNumber = 0 ;
 }
 else
 {
 //CATransition  *animation = [self addAnimationForPageFlip:kCATransitionFromLeft];
 //[[self.pdfView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
 
 [UIView transitionWithView:self.pdfView
 duration:0.75
 options:UIViewAnimationOptionTransitionCurlDown
 animations:^ { }
 completion:^(BOOL finished){ }];
 }
 
 [self displayXLS:_pageNumber];
 
 }
 
 */
//Check if the page is already dirtied. If so, get it from the documentController. else
//display from parent document
-(void)displayXLS:(int)pageNumber
{
    [self refresh];
    [self displayPageNumber:pageNumber];
    
    if ( [self.document containsDirtyKey:pageNumber])
    {
        //delete _shapes of the current page;
        [self.shapes removeAllObjects];
        _currentShape = [[ShapeObject alloc] init];
        
        NSArray *shapes = [self.document getPage:pageNumber];
        
        for(ShapeObject *shape in shapes)
        {
            [self.shapes addObject:shape];
        }
        //[self refresh];
        
    }
    
}

/*
 
 -(CGRect)setPPTFrameSize
 {
 CGSize size = [self.pptController getScaledPPTSizeForDisplay];
 CGRect frame = CGRectMake(0, 0, size.width, size.height);
 //self.webView.frame = CGRectMake(0, 60, size.width, size.height);
 self.pdfView.frame = CGRectMake(0, 0, size.width, size.height);//notesView
 //self.documentImage.frame = CGRectMake(0, 0, size.width, size.height);
 
 return frame;
 }
 
 */

-(BOOL)activateSwipe:sender
{
    //get the sender
    UISwipeGestureRecognizer *gestureRecognizer = sender;
    UIView *view = gestureRecognizer.view;
    CGPoint loc = [gestureRecognizer locationInView:view];
    
    //NSArray *subViews = [view subviews];
    for ( UIView * subView in [view subviews])
        if ( [subView isKindOfClass:[UICollectionView class]]) {
            UICollectionView *tView = (UICollectionView*)subView;
            //CGRect frame = tView.frame;
            if ([self pointInside:loc view:tView])
            {
                return FALSE;
            }
        }
    return TRUE;
}

- (BOOL)pointInside:(CGPoint)point view:(UIView *)view
{
    return CGRectContainsPoint(view.frame, point);
}
//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
//{
//    return YES;
//}
-(void) adjustFrames:(UITextView *)textView
{
    CGRect textFrame = textView.frame;
    textFrame.size.height = textView.contentSize.height;
    textView.frame = textFrame;
}


-(id)getLastObject:(NSMutableArray *)array
{
    NSInteger count = [array count];
    if ( count > 0 )
        return [array objectAtIndex:count-1];
    return nil;
}

-(void)didChangeBrushSize:(CGFloat)brushSize
{
    _lineWidth = brushSize;
}


- (IBAction)colorTool:(id)sender
{
    //dismiss popover, if  visible
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        /*
        if ( [self.shapesPopoverController isPopoverVisible] )
        {
            [self.shapesPopoverController dismissPopoverAnimated:YES];
        }
        
        if ([self.toolPopoverController isPopoverVisible])
        {
            [self.toolPopoverController dismissPopoverAnimated:YES];
            return;
        }
         */
    }
    
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        //self.colorToolViewController  = (ColorToolViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ColorToolViewController"];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        //self.toolPopoverController = [[UIPopoverController alloc]initWithContentViewController:tabBarController];
        
        tabBarController.view.backgroundColor = [Utility CMYNColorRed3];
        for (UIViewController *controller in tabBarController.viewControllers)
        {
            if ([controller isKindOfClass:[ColorToolViewController class]])
            {
                self.colorToolViewController = (ColorToolViewController *)controller;
                self.colorToolViewController.delegate = self;
            }
            if ([controller isKindOfClass:[FontPropertiesViewController class]])
            {
                self.fontPropertiesViewController = (FontPropertiesViewController *)controller;
                //self.fontPropertiesViewController.delegate = self;
            }
        }
        
        if ( indexOfSelectedShape != -1 )
        {
            ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
            //set the color, alpha, linewidth and font
            [self.colorToolViewController setAlpha:obj.alpha];
            [self.colorToolViewController setBrushSize:obj.lineWidth];
            [self.colorToolViewController setColor:obj.color];
            if ( obj.type == kText && obj.textObject.font != nil )
                [self.fontPropertiesViewController updateFont:obj.textObject.font];
            
        }
        
        //if from UIBarbutton launch popover, else present it from the location of the shape object
        if([sender isKindOfClass:[UIBarButtonItem class]])
        {
            tabBarController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:tabBarController animated:YES completion:nil];
            
            // configure the Popover presentation controller
            UIPopoverPresentationController *popController = [tabBarController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.barButtonItem = sender;
            popController.backgroundColor = [Utility CMYNColorRed3];

            //popController.delegate = self;
            //[self.toolPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else if ( [sender isKindOfClass:[UIMenuController class]] )
        {
            
            tabBarController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:tabBarController animated:YES completion:nil];
            UIMenuController *menuController = sender;
            UIPopoverPresentationController *popController = [tabBarController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            //popController.delegate = self;
            
            // in case we don't have a bar button as reference
            popController.sourceView = self.jCRPDFView;
            popController.sourceRect = menuController.menuFrame;
            popController.backgroundColor = [Utility CMYNColorRed3];

            //[self.toolPopoverController presentPopoverFromRect:menuController.menuFrame inView:self.pdfView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
   else
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        //self.colorToolViewController  = (ColorToolViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ColorToolViewController"];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        
        
        for (UIViewController *controller in tabBarController.viewControllers)
        {
            if ([controller isKindOfClass:[ColorToolViewController class]])
            {
                self.colorToolViewController = (ColorToolViewController *)controller;
                self.colorToolViewController.delegate = self;
            }
            if ([controller isKindOfClass:[FontPropertiesViewController class]])
            {
                self.fontPropertiesViewController = (FontPropertiesViewController *)controller;
                //self.fontPropertiesViewController.delegate = self;
            }
        }
        
        if ( indexOfSelectedShape != -1 )
        {
            ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
            //set the color, alpha, linewidth and font
            [self.colorToolViewController setAlpha:obj.alpha];
            [self.colorToolViewController setBrushSize:obj.lineWidth];
            [self.colorToolViewController setColor:obj.color];
            if ( obj.type == kText && obj.textObject.font != nil )
                [self.fontPropertiesViewController updateFont:obj.textObject.font];
        }

        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:tabBarController];
        navigationController.definesPresentationContext = YES; //self is presenting view controller
        navigationController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        navigationController.navigationBarHidden = YES;
        //navigationController.view.backgroundColor = [Utility CMYNColorRed3];



        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:navigationController animated:YES completion:nil];
        });

       /*
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
        
        navigationController.definesPresentationContext = YES; //self is presenting view controller
        navigationController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        //navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;       //WORKING //now present this navigation controller modally
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;        //now present this navigation controller modally
        navigationController.providesPresentationContextTransitionStyle = true;
        navigationController.definesPresentationContext = true;
        navigationController.navigationBarHidden = YES;
        navigationController.view.alpha = 0.95;
        
       // UIVisualEffect *blurEffect;
        // blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
         
         //UIVisualEffectView *visualEffectView;
         //visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
         
         //visualEffectView.frame = navigationController.view.bounds;
         //[self.view addSubview:visualEffectView];
        [self presentViewController:navigationController animated:YES completion:nil];
        */
    }
}



- (void)showShapes:(id)sender
{

    if ( ![sender isKindOfClass:[UILongPressGestureRecognizer class]])
    [self dismissViewControllerAnimated:YES completion:nil];

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        self.shapesViewController  = (ShapesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapesViewController"];
        //self.shapesPopoverController = [[UIPopoverController alloc]initWithContentViewController:_shapesViewController];
        
        //UIButton *button = (UIButton *)sender;
        if([sender isKindOfClass:[UIBarButtonItem class]] )
        {
            self.shapesViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:self.shapesViewController animated:YES completion:nil];
            
            // configure the Popover presentation controller
            UIPopoverPresentationController *popController = [self.shapesViewController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.barButtonItem = sender;
            popController.backgroundColor = [Utility CMYNColorRed3];

        }
        else if ([sender isKindOfClass:[UILongPressGestureRecognizer class]] )
        {
            CGPoint location = [sender locationInView:self.jCRPDFView];
            CGRect locationRect = CGRectMake(location.x, location.y, 20.0, 20.0);
            //self.shapesViewController.displayCloseReadingWindow = TRUE;
            
            self.shapesViewController.modalPresentationStyle = UIModalPresentationPopover;
            self.shapesViewController.popoverPresentationController.sourceView = sender;
            [self presentViewController:self.shapesViewController animated:YES completion:nil];
            
            self.shapesViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:self.shapesViewController animated:YES completion:nil];
            //UIMenuController *menuController = sender;
            UIPopoverPresentationController *popController = [self.shapesViewController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            //popController.delegate = self;
            
            // in case we don't have a bar button as reference
            popController.sourceView = self.view;
            popController.sourceRect = locationRect;
            popController.backgroundColor = [Utility CMYNColorRed3];

            //[self.shapesPopoverController presentPopoverFromRect:locationRect inView:self.pdfView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        self.shapesViewController  = (ShapesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapesViewController"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:self.shapesViewController];
        navigationController.definesPresentationContext = YES; //self is presenting view controller
        //navigationController.view.backgroundColor = [Utility CMYNColorRed3];
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        navigationController.navigationBarHidden = YES;

        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:navigationController animated:YES completion:nil];
        });
        //[self presentViewController:navigationController animated:NO completion:nil];
    }
}

-(void)brushSizeChanged:(float)brushSize
{
    _currentBrushSize = brushSize;
    if(indexOfSelectedShape != -1 && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.lineWidth = brushSize;
        obj.bzPath.lineWidth = brushSize;
        [self refresh];
        obj = nil;
    }
    
}

#pragma mark -Message Handling
-(void)colorChanged:notification
{
    UIColor *color = [[notification userInfo] valueForKey:@"ColorChanged"];
    [self setSelectedImageForBarButton:kColorPalette color:color];
    self.currentColor = color;
    
    if(indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        obj.color = color;
        
        
        if ( self.backgroundColorChangeRequested )
        {
            obj.backgroundColor = self.currentColor;
            self.backgroundColorChangeRequested = NO;
            [self refreshShapesinRect:[obj frame]] ;
            return;
        }
        
        if ( obj.type == kText || obj.type == kCloseReading)
        {
            if ( self.textSelectionRange.length > 0 ) //string selected
            {
                //add attribute
                [obj.textObject.attributedText addAttribute:NSForegroundColorAttributeName
                                                      value:color
                                                      range:self.textSelectionRange];
            }
            
        }
        
        [self refresh];
        //[self refreshShapesinRect:[obj frame]] ;//]ShapesinRect:[self getRectForShape:obj]];
        
        //obj = nil;
    }
    //color = nil;
}

-(void)setSelectedImageForBarButton:(ToolbarButtonTag)tag color:(UIColor*)color
{
    UIBarButtonItem *button = [self getBarButtonForTag:tag side:kRight];
    button.tintColor = color;
}


#pragma mark - handle shape selection
-(void)shapeChanged:(NSNotification *) notification
{
    _currentShape.type = [[[notification userInfo] valueForKey:@"ShapeSelectionChanged"] intValue];
    
    [self clearSelectedShape];
    
    switch (_currentShape.type)
    {
        case kLine:
        {
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            //draw a horizontal line at the center with a half the width of device
            [self drawDefaultShape:kLine];
            break;
        }
            
        case kCircle:
        {
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            //draw a circle at the center with a radius equal to 1/5 of the width of the device
            [self drawDefaultShape:kCircle];

            break;
        }
            
        case kRectangle:
        {
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            //draw a square at the center with the side equal to 1/5 of the width of the device
            [self drawDefaultShape:kRectangle];
            break;
        }
        case kArrow:
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            //draw a horizontal arrow  at the center with a 1/3 width of device
            [self drawDefaultShape:kArrow];
            break;
            
        case kDoubleHeadedArrow:
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            //draw a horizontal arrow  at the center with a 1/3  width of device
            [self drawDefaultShape:kDoubleHeadedArrow];
            break;
            
        case kFreeform:
        {
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            break;
        }
            
        case kText:
        {
            TextObject *textObject = [[TextObject alloc] init];
            _currentShape.textObject = textObject;
            _currentShape.imageObject = nil;
            _currentShape.color = [UIColor clearColor];
            _currentShape.textObject.fontColor = [ColorToolViewController getCurrentColor];
            _currentShape.textObject.font = self.currentFont;
            self.newShape = YES;
            _currentShape.color = [Utility CMYNColorDarkBlue];
            NSTextContainer *textcontainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, 44)];
            [self createTextAtPoint:CGPointMake(self.jCRPDFView.frame.size.width/2.0, self.jCRPDFView.frame.size.height/2.0) textContainer:textcontainer];
            break;
        }
            
        case kHighlighter:
        {
            _currentShape.type = kHighlighter;
            _currentShape.textObject = nil;
            _currentShape.imageObject = nil;
            
            _currentShape.lineWidth = 15;
            _currentShape.textObject = nil;
            _currentShape.alpha = 0.50;
            [self drawDefaultShape:kHighlighter];
            break;
        }
            
        case kPhoto:
        {
            _currentShape.type = kPhoto;
            [self setCurrentShapeObjectAttributes];
            [self insertPhoto:[[notification userInfo] valueForKey:@"ShapeImage"]];
            //[self insertPhotoWithURL:[[notification userInfo] valueForKey:@"AssetURL"]];

            break;
        }
        case kHeart :
        case kQuestionMark:
        case kExclamationMark:
        case kStar:
        case kConnection:
        case kEvidence:
        case kCheckMark:
        case kXMark:
        case kAgree:
        case kDisAgree:
        {
            TextObject *textObject = [[TextObject alloc] init];
            _currentShape.textObject = textObject;
            _currentShape.imageObject = nil;
            _currentShape.color = [UIColor clearColor];
            _currentShape.textObject.fontColor = [ColorToolViewController getCurrentColor];
            _currentShape.textObject.font = self.currentFont;
            CGFloat midX = CGRectGetMidX(self.jCRPDFView.frame);
            CGFloat midY = CGRectGetMidY(self.jCRPDFView.frame);
            [self createCloseReadingSymbolAt:CGPointMake(midX, midY) type:_currentShape.type];
            self.newShape = YES;
            _currentShape.color = [Utility CMYNColorDarkBlue];
            break;
        }
        case kURL:
        {
            _currentShape.type = kURL;
            break;
        }
            
        default:
            break;
    }
    
    //[_shapesPopoverController dismissPopoverAnimated:YES];
    _shapeButton.selected = YES;
    _currentShape.lineWidth = [ColorToolViewController getBrushSize];
}


-(void)drawDefaultShape:(ShapeType)type
{
    CGFloat midX = CGRectGetMidX(self.jCRPDFView.frame);
    CGFloat midY = CGRectGetMidY(self.jCRPDFView.frame);
    _currentShape.color = _currentColor;
    
    switch (_currentShape.type)
    {
        case kLine:
        case kArrow:
        case kDoubleHeadedArrow:
        case kHighlighter:
            _currentShape.origin = CGPointMake(midX-(midX/2.0), midY);
            _currentShape.end = CGPointMake(midX+(midX/2.0), midY);
            break;

        case kRectangle:
        case kCircle:
            _currentShape.origin = CGPointMake(midX-100, midY-100);
            _currentShape.end = CGPointMake(midX+100, midY+100);
            break;
    }
    [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
    [self saveShapesToCurrentPage];
    //[self alternateSelectionOverlay:self.shapes.lastObject];
}

-(void)createCloseReadingSymbolAt:(CGPoint)point type:(ShapeType)type
{
    UIFont *font = [UIFont boldSystemFontOfSize:24.0];

    if ( type == kHeart )
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2665" font:font color:self.currentColor];
    else if ( type == kStar)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2605" font:font color:self.currentColor];
    else if ( type == kQuestionMark)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2753" font:font color:self.currentColor];
    else if ( type == kCheckMark)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2714" font:font color:self.currentColor];
    else if ( type == kExclamationMark)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2757" font:font color:self.currentColor];
    else if ( type == kXMark)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u2715" font:font color:self.currentColor];
    else if ( type == kEvidence)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u24BA" font:font color:self.currentColor];
    else if ( type == kConnection)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u221E" font:font color:self.currentColor];
    else if ( type == kAgree)
        [_currentShape.textObject setCloseReadingSysmbol:@"\u271A" font:font color:self.currentColor];
    else if ( type == kDisAgree)
            [_currentShape.textObject setCloseReadingSysmbol:@"\u2796" font:font color:self.currentColor];
    
    //reset the type to close reading
    _currentShape.type = kCloseReading;
    CGRect boundingRect = [_currentShape.textObject.attributedText boundingRectWithSize:CGSizeMake(48, 16) options:NSStringDrawingUsesFontLeading context:nil];
    _currentShape.origin = CGPointMake(point.x+boundingRect.origin.x, point.y+boundingRect.origin.y);

    _currentShape.end = CGPointMake(point.x+boundingRect.size.width, point.y+boundingRect.size.height);
    _currentShape.textObject.textSize = CGSizeMake(fabs(_currentShape.origin.x-_currentShape.end.x), fabs(_currentShape.origin.y-_currentShape.end.y));

    _currentShape.bzPath = [UIBezierPath bezierPathWithRect:CGRectMake(_currentShape.origin.x, _currentShape.origin.y, fabs(_currentShape.origin.x-_currentShape.end.x), fabs(_currentShape.origin.y-_currentShape.end.y))];
    _currentShape.color = [Utility CMYNColorDarkBlue];
    [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
    [self saveShapesToCurrentPage];
    indexOfSelectedShape = [self.shapes count] - 1;
    //[self refreshShapesinRect:boundingRect];
    _currentShape.textObject = nil;
}

-(void)drawInitialPhotoView:(ImageObject *)imageObject
{
    _currentShape.color = [UIColor blackColor];
    _currentShape.origin = imageObject.origin;
    _currentShape.bzPath = [[UIBezierPath alloc] init];
    _currentShape.end = CGPointMake(imageObject.origin.x+imageObject.rectangle.size.width, imageObject.origin.y+imageObject.rectangle.size.height);
    UIBezierPath *bzPath = [UIBezierPath bezierPathWithRect:imageObject.rectangle];
    
    _currentShape.bzPath = [bzPath copy];
    _currentShape.shapeSelected = YES;
    _currentShape.imageObject = [imageObject copy];
    //_currentShape.imageObject.rectangle = imageObject.rectangle;
    //get the image from the ShapeViewController and place it at the specified location
    [self.shapes addObject: [[ShapeObject alloc] initCopy:_currentShape]];
    [self saveShapesToCurrentPage];
    indexOfSelectedShape = [self.shapes count] - 1;
    
    //[self refresh];
    //_currentShape.type = kNoShapeSelected;
}

-(void)insertPhoto:(UIImage* )image
{
    //static int i = 1;
    CGSize imageSize = image.size;
    CGSize viewSize = CGSizeMake(300, 200); // size in which you want to draw
    
    float hfactor = imageSize.width / viewSize.width;
    float vfactor = imageSize.height / viewSize.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = imageSize.width / factor;
    float newHeight = imageSize.height / factor;
    Utility *utility = [[Utility alloc] init];
    
    NSString *imageFileName = [utility saveImage:image];

    CGFloat midX = CGRectGetMidX(self.jCRPDFView.frame);
    CGFloat midY = CGRectGetMidY(self.jCRPDFView.frame);
    CGPoint point = CGPointMake(midX-newWidth/2.0, midY-newHeight/2.0);

    ImageObject *imageObject = [[ImageObject alloc] initWithImageName:imageFileName  atPoint:point withSize:CGSizeMake(newWidth, newHeight) scaleFactor:factor];
    //imageObject.orientation = image.imageOrientation;
    
    [self drawInitialPhotoView:imageObject];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.jCRPDFView setNeedsDisplay];
}

-(void)displayInstructions:(NSString *)instructions instructionType:(InstructionType)instructionType
{
    NSTimeInterval animationDuration = 1.0;
    [[UIDevice currentDevice] playInputClick];
    
    
    //get the text size and increase the width of the text control
    CGSize size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        size = [instructions sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}];
        self.informationLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    else
    {
        size = [instructions sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0f]}];
        self.informationLabel.font = [UIFont systemFontOfSize:8.0];
        
    }
    
    self.informationLabel.text = instructions;
    self.informationLabel.numberOfLines = 0;
    CGPoint offset = self.informationLabel.frame.origin;
    
    //CGSize maximumLabelSize = CGSizeMake(254,CGFLOAT_MAX);
    CGSize requiredSize = [self.informationLabel sizeThatFits:size];
    
    if (instructionType == kMemorywarning)
    {
        self.informationLabel.backgroundColor = [UIColor redColor];
        self.informationLabel.textColor = [UIColor whiteColor];
        offset.y = (self.jCRPDFView.frame.size.height - requiredSize.height)/2.0;
        offset.x = (self.jCRPDFView.frame.size.width - requiredSize.width)/2.0;
        animationDuration = 10.0;
    }
    else
    {
        offset.x = (self.jCRPDFView.frame.size.width - requiredSize.width)/2.0;
        offset.y = self.jCRPDFView.frame.size.height  - 2.0*requiredSize.height;
        self.informationLabel.backgroundColor = [UIColor blueColor];
        self.informationLabel.textColor = [UIColor blueColor];
    }
    
    
    //center the label
    CGRect newFrame = self.informationLabel.frame;
    newFrame.size = size;
    newFrame.size.height = requiredSize.height;
    newFrame.size.width = requiredSize.width;
    newFrame.origin = offset;
    self.informationLabel.frame = newFrame;
    
    self.informationLabel.textColor = [UIColor yellowColor];
    //self.informationLabel.backgroundColor = [UIColor blueColor];

    self.informationLabel.textAlignment = NSTextAlignmentCenter;
    [self.informationLabel.layer setCornerRadius:2.0];

    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^ {
                         self.informationLabel.alpha = 1.0;
                         //self.informationLabel.text = instructions;
                     }
                     completion:^(BOOL finished) {
                         [UILabel animateWithDuration:animationDuration
                                           animations:^{
                                               self.informationLabel.alpha = 0.0;
                                               
                                           }];
                         
                     }];
    
    //erert
    
    //[instructionLabel removeFromSuperview];
    
    
    /*
     instructionLabel.alpha = 0;
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
     
     //don't forget to add delegate.....
     [UIView setAnimationDelegate:self];
     
     [UIView setAnimationDuration:5];
     instructionLabel.alpha = 1;
     
     //also call this before commit animations......
     [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:instructionLabel:)];
     [UIView commitAnimations];
     */
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context label:(UILabel*)label
{
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        label.alpha = 0;
        [UIView commitAnimations];
    }
}

-(void)animatethumbnailCollectionView:(BOOL)show
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [self.thumbnailCollectionView setAlpha:0];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [self.thumbnailCollectionView setHidden:show];
    [self.thumbnailCollectionView setAlpha:0.8];
    
    [UIView commitAnimations];
    
    
}


-(void)showOrHideNavigationControllerAndthumbnailCollectionView:(CGPoint)point
{
    
    if ( ![self pointInside:point view:self.thumbnailCollectionView] )
    {
        /*
         if ( [self.thumbnailCollectionView isHidden] )
         {
         self.thumbnailCollectionView.hidden = FALSE;
         [self animatethumbnailCollectionView:FALSE];
         }
         else
         {
         [self animatethumbnailCollectionView:TRUE];
         self.pageSlider.hidden = TRUE;
         
         }
         */
        self.thumbnailCollectionView.hidden = !self.thumbnailCollectionView.hidden;
        self.pageSlider.hidden = !self.pageSlider.hidden;
        
        /*
         if ( self.navigationController.navigationBar.hidden == TRUE)
         {
         //[self.navigationController setNavigationBarHidden:FALSE animated:YES];
         self.pageSlider.hidden = FALSE;
         }
         else
         {
         //[self.navigationController setNavigationBarHidden:TRUE animated:YES];
         self.pageSlider.hidden = TRUE;
         
         }*/
    }
    
    else
    {
        self.thumbnailCollectionView.hidden = FALSE;
        [self.jCRPDFView bringSubviewToFront:self.thumbnailCollectionView];
        //[self.navigationController setNavigationBarHidden:FALSE animated:YES];
        self.pageSlider.hidden = FALSE;
    }
    
}


-(void)enableSwipes:(BOOL)enabled
{
    self.swipeDown.enabled = enabled;
    self.swipeUp.enabled = enabled;
    self.swipeLeft.enabled = enabled;
    self.swipeRight.enabled = enabled;
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    //touchPoint = [gesture locationInView:self.pdfView];

    if ( !self.zoomOperation )
        if ( !textEditMode )
        {
            //static int sameObject = -1;
            [self displayInstructions:[NSString stringWithFormat: @" Page %d", (int)self.pageNumber] instructionType:kDisplayPageNumber];
            indexOfSelectedShape = [self hitTest:[gesture locationInView:self.jCRPDFView]];//notesview

            if ( indexOfSelectedShape == -1 )
            {
                [self clearSelectedShape];
                [self refresh];
                
                if ( self.cutCopyShape != nil )
                {
                    //[self showContextMenu:CGRectMake([gesture locationInView:self.view].x, [gesture locationInView:self.view].y,1, 1)];
                    [self editActionsForTouch:[gesture locationInView:self.view]];
                }
            }
            else //if ( indexOfSelectedShape != -1 )
            {
                [self clearSelectedShape];
                indexOfSelectedShape = [self hitTest:[gesture locationInView:self.jCRPDFView]];//notesview
                
                if ( indexOfSelectedShape != - 1  && ([self.shapes count] > 0))
                {
                    ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
                    [self showContextMenu:CGRectMake(obj.origin.x, obj.origin.y, 1, 1)];
                }
                
                [self editActionsForTouch:[gesture locationInView:self.jCRPDFView]];//notesview
                [self refresh];
                return;
            }
            
            //touched page navigation area or thumbnail area
            if ( [self touchedNavigationArea:[gesture locationInView:self.view]] )
            {
                return;
            }
            
            else if ([self touchedThumbnailArea:[gesture locationInView:self.view]])//notesview
            {
                if ( indexOfSelectedShape == -1 )
                {
                    return;
                }
            }
            
            /*else
            {
                [self clearSelectedShape];
                indexOfSelectedShape = [self hitTest:[gesture locationInView:self.pdfView]];//notesview
                
                if ( indexOfSelectedShape != - 1  && ([self.shapes count] > 0))
                {
                    ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
                    [self showContextMenu:CGRectMake(obj.origin.x, obj.origin.y, 1, 1)];
                }
               
                [self editActionsForTouch:[gesture locationInView:self.pdfView]];//notesview
                [self refresh];
            }*/
        }
}


//refactor this function
//1. In view/read-only mode, on touching the reading area, the following actions take place
//  (a) show or hide thumbnail and toolbar
//  (b) Inform user, if it received multiple clicks during the read-only mode to select an object

//2. In edit mode, touching the reading area, the following actions take place
//  (a)
//  (b)
//  (c)

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    /*
     [self clearSelectedShape];
     
     if ( readOnlyMode )
     {
     if ( [self touchedPageNavigationArea:[gesture locationInView:self.notesView]])
     return;
     else
     [self readOnlyActionsForOnTouch:[gesture locationInView:self.notesView] ];
     }
     else
     {
     [self editActionsForTouch:[gesture locationInView:self.notesView]];
     if (_currentShape.type == kText && _textBoxCount == 0 && indexOfSelectedShape == -1)
     {
     CGPoint tempPoint = [gesture locationInView:self.notesView];
     
     [self createTextAtPoint:tempPoint];
     }
     
     }
     indexOfSelectedShape = [self hitTest:[gesture locationInView:self.pdfView]];//notesview
     
     if ( indexOfSelectedShape != -1  && ([self.shapes count] > 0))
     {
     ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
     if (  obj.type == kText )
     {
     [self editActionForText:[gesture locationInView:self.pdfView]];//notesview
     }
     }
     else if ( _currentShape.type == kText) {
     //[self createTextAtPoint:[gesture locationInView:self.pdfView]];
     }
     
     [self refresh];
     */
    if ( self.zoomOperation )
    {
        [self resize:self.jCRPDFView scale:1.0];
        self.zoomOperation = NO;
    }
    else
    {
        [self resize:self.jCRPDFView scale:2.0];
        self.zoomOperation = YES;
    }
}

/*
 -(void)readOnlyActionsForOnTouch:(CGPoint) point
 {
 //if touched once, show or hide toolbar and thumbnail
 //if touched more than twice continuously on a shape, assume that he/she is tryingto select the object
 
 static int touchedTheObject = 0;
 //get the object at the touched location
 indexOfSelectedShape = [self hitTest:point];
 
 if ( indexOfSelectedShape != -1 )
 //increment the count for object touched
 {
 touchedTheObject++;
 if ( touchedTheObject > 2 )
 {
 //display message
 touchedTheObject = 0;
 [self performSelector:@selector(displayInstructions:) withObject:nil afterDelay:0.0f];
 }
 }
 else
 {
 //show and hide thumbnail and toolbar
 [self showOrHideNavigationControllerAndthumbnailCollectionView:point];
 indexOfSelectedShape = -1;
 }
 
 
 }
 */
//touched left or right page curl area.
-(BOOL)touchedThumbnailArea:(CGPoint) point
{
    
    //CGRect toolbarRect = CGRectMake(0.0,0.0, self.pdfView.frame.size.width,TOP_BORDER );
    CGRect thumbnailRect = CGRectMake(0.0,self.jCRPDFView.frame.size.height-64.0, self.jCRPDFView.frame.size.width, 64.0);
    
    
    if ( CGRectContainsPoint(thumbnailRect, point))
    {
        [self showOrHideNavigationControllerAndthumbnailCollectionView:point];
        return TRUE;
    }
    
    return FALSE;
}


//touched left or right page curl area.
-(BOOL)touchedNavigationArea:(CGPoint) point
{
    CGFloat pageNavigationWidth = 0.0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        pageNavigationWidth = 40;
    }
    else
    {
        pageNavigationWidth = 30;
    }
    CGRect leftNavigationArea = CGRectMake(0.0,60.0, pageNavigationWidth,self.view.frame.size.height -60.0);
    CGRect rightNavigationArea = CGRectMake(self.view.frame.size.width-pageNavigationWidth,60.0, pageNavigationWidth, self.view.frame.size.height-60.0);
    
    
    if ( CGRectContainsPoint(leftNavigationArea, point))
    {
        [self previousPage:nil];
        return TRUE;
    }
    
    
    if ( CGRectContainsPoint(rightNavigationArea, point))
    {
        [self nextPage:nil];
        return TRUE;
    }
    
    return FALSE;
}
-(void)editActionsForTouch:(CGPoint) point
{
    //touched the navigation area
    if ( [self touchedThumbnailArea:point])
        return;    //did not touch any object
    
    //else touched the object area. Is a shaped touched?
    //indexOfSelectedShape = [self hitTest:point];
    
    //No shape is selected
    if ( indexOfSelectedShape == -1)
    {
        //clear selected object
        //[self enableSwipes:YES];
        
        [self clearSelectedShape];
        //[self refresh]; why refresh
        //check if text option is selected for creating new text
        /*Commented - only double tap for edit action
         if ( self.currentShape.type == kText && self.textBoxCount == 0 )
         {
         [self createTextAtPoint:point];
         //[self refresh]; why refresh
         }
         else
         
         */
        if ( self.cutCopyShape != nil)
        {
            self.currentTappedLocation = point;
            [self showContextMenu:CGRectMake(point.x, point.y, 1, 1)];
            [self showOrHideNavigationControllerAndthumbnailCollectionView:point];
        }
        else
        {
            [self showOrHideNavigationControllerAndthumbnailCollectionView:point];
        }
    }
    else //touched an object
    {
        //check if it is text and touched twice, allow the text to be edited
        if ([self.shapes count] > 0)
        {
            ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
            if (  obj.type == kText )
            {
                //[self editActionForText:point];
            }
            else
            {
                //[self drawSelectionOverlay:obj];
                self.currentTappedLocation = point;
                
            }
        }
        //[self refresh];
        
    }
    
}

-(void)editActionForText:(CGPoint)point
{
    static int sameTextObject = -1; //if the same text object is selected, then enable editing of text
    static int textObjectSelect = 0;
    //BOOL textEditMode = FALSE;
    indexOfSelectedShape = [self hitTest:point];
    if ( indexOfSelectedShape != -1 )
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        /*if ( sameTextObject == -1 )
         sameTextObject = (int)indexOfSelectedShape;*/
        
        if ( obj.type == kText )
        {
            /*textObjectSelect++;
             if ( (textObjectSelect == 2) /&& (sameTextObject != indexOfSelectedShape ))
             {
             textObjectSelect--;
             sameTextObject = (int)indexOfSelectedShape;
             }
             if ( textObjectSelect == 2 && sameTextObject == indexOfSelectedShape)
             {*/
            textObjectSelect = 0;
            if([self.shapes count] > 0)
            {
                //ShapeObject *shape = [self.shapes objectAtIndex:indexOfSelectedShape];
                /* 24062015[self.deletedShapes addObject: [[ShapeObject alloc] initCopy:obj]];
                 
                 [self deleteSelectedShape];
                 self.undoOperation = TRUE;*/
                //shape = nil;
                
                [self createTextAtPoint:obj.origin frame:CGRectMake(obj.origin.x, obj.origin.y, obj.textObject.textSize.width, obj.textObject.textSize.height) textContainer:obj.textObject.textContainer];
                sameTextObject = -1;
                //textEditMode = TRUE;
                [self textButtonClicked:nil];
            }
            /*}
             
             if ( !textEditMode )
             {
             [self refresh];
             }*/
        }
        
    }
}


-(void)showOrHideControlAndthumbnailCollectionViews:(CGPoint)loc
{
    //1. Show or hide controlview and thumbnailCollectionView only when touched on points which are outside of these views
    //2. If these are already hidden and touches happen within their window, then show/hide them
    if ( (loc.y < self.thumbnailCollectionView.frame.origin.y) ||
        ((loc.y < self.thumbnailCollectionView.frame.origin.y) &&
         ( [self.thumbnailCollectionView isHidden]  ) ) )
        
    {
        if ( [self.thumbnailCollectionView isHidden])
        {
            self.thumbnailCollectionView.hidden = FALSE;
            //[self.view bringSubviewToFront:self.thumbnailCollectionView];
        }
        else
        {
            self.thumbnailCollectionView.hidden = TRUE;
            //[self.view sendSubviewToBack:self.thumbnailCollectionView];
        }
        
    }
    else
    {
        [self.view bringSubviewToFront:self.thumbnailCollectionView];
    }
}

-(void)showContextMenu:(CGRect) rectangle
{
    UIMenuController *theMenu = [UIMenuController sharedMenuController];
    
    [self.jCRPDFView becomeFirstResponder];
    
    UIMenuItem *editText = [[UIMenuItem alloc] initWithTitle:@"Edit Text" action:@selector(editText:)];
    UIMenuItem *changeBackgroundColor = [[UIMenuItem alloc] initWithTitle:@"Change BackgroundColor" action:@selector(changeBackgroundColor:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:editText, changeBackgroundColor, nil]];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];;
    
    [theMenu setTargetRect:rectangle inView:self.jCRPDFView];
    [theMenu setMenuVisible:YES animated:YES];
    //NSLog(@"menu width %f, visible %d", theMenu.menuFrame.size.width, theMenu.menuVisible);
}

- (void)editText:(id)sender
{
    if ( indexOfSelectedShape != -1  )
    {
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        if (  obj.type == kText )
        {
            [self editActionForText:obj.origin];
            textEditMode = YES;
            self.navigationController.navigationBarHidden = YES;
        }
    }
}

- (void)changeBackgroundColor:(id)sender
{
    if ( indexOfSelectedShape != -1  )
    {
        /*ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
         if (  obj.type == kCircle || obj.type == kRectangle  || obj.type == kText)
         {
         if ( obj.type == kText)
         obj.textObject.backgroundColor = self.currentColor;
         else if ( obj.type == kCircle || obj.type == kRectangle)
         obj.backgroundColor = self.currentColor;
         [self refreshShapesinRect:[obj frame]];
         }
         */
        self.backgroundColorChangeRequested = YES;
        [self colorTool:sender];
    }
}


-(void)addStickyNote:(id)sender
{
    /*{
     ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
     if (  (obj.type == kCircle || obj.type == kRectangle ) && ![obj getStickyNoteState])
     {
     //create sticky note view
     [self createStickyNoteView];
     obj.stickyNoteAdded = true;
     [self refresh];
     }
     }*/
}

-(void)createStickyNoteView
{
    /*
     StickyNote *stickyNote = [[StickyNote alloc] init];
     stickyNote.text = @"test";
     stickyNote.color = _currentColor;
     
     ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
     CGRect rectangle = CGRectMake(obj.origin.x,
     obj.origin.y,
     obj.end.x - obj.origin.x+20,
     obj.end.y - obj.origin.y+45);
     stickyNote.frame = rectangle;
     obj.stickyNote = stickyNote;
     
     
     UITextView *textView = [[UITextView alloc] initWithFrame:rectangle];
     textView.text = stickyNote.text;
     textView.textColor = stickyNote.color;
     textView.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
     textView.layer.shadowRadius = 2.0;
     textView.layer.cornerRadius = 15.0;
     textView.layer.borderWidth = 2.0;
     textView.layer.borderColor = [[UIColor redColor] CGColor];
     textView.layer.shadowOffset = CGSizeMake(3.0, 2.0);
     textView.layer.opacity = 0.7;
     textView.layer.masksToBounds = YES;
     
     [self.pdfView addSubview:textView];
     */
}

-(void)displayStickyNote:(ShapeObject *)obj
{
    /*
     StickyNote *stickyNote = obj.stickyNote;
     
     
     stickyNote.frame = obj.stickyNote.frame;
     
     UITextView *textView = [[UITextView alloc] initWithFrame:stickyNote.frame];
     textView.text = stickyNote.text;
     textView.textColor = stickyNote.color;
     textView.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
     [self.pdfView addSubview:textView];
     */
}


-(void)deleteStickyNote:(id)sender
{
    /*
     ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
     if (  (obj.type == kCircle || obj.type == kRectangle ) && [obj getStickyNoteState])
     {
     obj.stickyNoteAdded = false;
     obj.stickyNote = nil;
     [self refresh];
     }
     */
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    if (action == @selector(copy:) && indexOfSelectedShape != -1  )
        return YES;
    
    if (action == @selector(cut:) && indexOfSelectedShape != -1 )
    {
        return YES;
    }
    
    if ( action == @selector(paste:) && self.cutCopyShape != nil )
    {
        return YES;
    }
    
    if ( action == @selector(editText:) && indexOfSelectedShape != -1 && [[self.shapes objectAtIndex:indexOfSelectedShape] getType] == kText && !textEditMode)
    {
        ;
        return YES;
    }
    if ( action == @selector(changeBackgroundColor:) && indexOfSelectedShape != -1 && ([[self.shapes objectAtIndex:indexOfSelectedShape] getType] == kRectangle || [[self.shapes objectAtIndex:indexOfSelectedShape] getType] == kCircle ))
    {
        ;
        return YES;
    }
    
    /*if ( action == @selector(changeBackgroundColor:) && indexOfSelectedShape != -1 && ([obj getType] == kRectangle || [obj getType] == kCircle || [obj getType] == kText)  && textEditMode)
     {
     ;
     return YES;
     }
     */
    
    else /*if ( action == @selector(editText:) && indexOfSelectedShape != -1 && self.currentShape.type == kText)*/
        return NO;
    
    // logic to show or hide other things
    return NO;
}

- (void) copy:(id) sender
{
    // called when copy clicked in menu
    //copied object should also be added to deletedObjects array
    if ( indexOfSelectedShape != -1  && ([self.shapes count] > 0))
    {
        self.cutCopyShape = [[self.shapes objectAtIndex:indexOfSelectedShape] copy];
        
        ShapeObject *shape = [self.shapes objectAtIndex:indexOfSelectedShape];
        
        if ( [shape getType] == kText)
        {
            self.cutCopyShape.textObject = [shape.textObject copy];
            self.cutCopyShape.textObject.textSize = shape.textObject.textSize;
        }
        shape.shapeSelected = FALSE;
        indexOfSelectedShape = -1;
        [self clearSelectedShape];
    }
}


- (void) cut:(id) sender
{
    //move the shape to cutCopyShpae for paste use
    if ( indexOfSelectedShape != -1 && ([self.shapes objectAtIndex:indexOfSelectedShape] != nil) && ([self.shapes count] > 0))
    {
        //self.cutCopyShape = [[self.shapes objectAtIndex:indexOfSelectedShape  ] copy];
        //copy the image filename, if the selected object is kPhoto
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfSelectedShape];
        
        if ( [obj getType] == kPhoto )
        {
            //if the fileToDelete arrary is empty, add the image file name
            if ( [self.filesToDelete count] == 1 )
            {
                //remove the file in the fileToDelete from the array
                NSString *imageFileNameToDelete = [self.filesToDelete objectAtIndex:0];
                
                //remove the physical file from the folder
                [self removeFileArURL:[self getApplicationSupportFolderURLForFile:imageFileNameToDelete]];
                //remove from the arrary
                [self.filesToDelete removeLastObject];
            }
            
            [self.filesToDelete addObject:obj.imageObject.fileName];
            
        }
        [self deleteSelectedShape];
        [self saveShapesToCurrentPage];
        //[self enableSwipes:YES];
    }
}

-(NSURL *)getApplicationSupportFolderURLForFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    self.applicationSupportURL = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, fileName];
    NSURL *url = [NSURL URLWithString:[self.applicationSupportURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                  //[self.applicationSupportURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
}


-(BOOL)removeFileArURL:(NSURL *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[url path]] == YES) {
        NSError *error;
        if (![fileManager removeItemAtURL:url error:&error])
        {
            NSLog(@"Error removing file: %@", error);
            return FALSE;
        };
    }
    return TRUE;
}

-(void)paste:(id)sender
{
    [self clearSelectedShape];
    
    if ( self.deletedShapes.count > 0 || (self.cutCopyShape != nil  && self.cutCopyShape.color != nil))
    {
        [self enableSwipes:NO];
        //if ( self.cutCopyShape.type == kFreeform )
        {
            CGPoint translation;
            translation.x = self.currentTappedLocation.x - self.cutCopyShape.origin.x;
            translation.y = self.currentTappedLocation.y - self.cutCopyShape.origin.y;
            
            UIBezierPath *bzPath = [self.cutCopyShape.bzPath copy];
            //[self.cutCopyShape.bzPath removeAllPoints];
            
            [bzPath applyTransform:CGAffineTransformMakeTranslation(translation.x, translation.y)];
            self.cutCopyShape.bzPath = bzPath;
            
            self.cutCopyShape.origin = [bzPath bounds].origin;
            self.cutCopyShape.end = CGPointMake([bzPath bounds].origin.x + [bzPath bounds].size.width, [bzPath bounds].origin.y + [bzPath bounds].size.height);
            
            if (self.cutCopyShape.type == kPhoto)
            {
                self.cutCopyShape.imageObject.origin = [bzPath bounds].origin;
                self.cutCopyShape.imageObject.rectangle = [bzPath bounds];
                self.cutCopyShape.imageObject.image = [UIImage imageWithCGImage:self.cutCopyShape.imageObject.image.CGImage];
                
            }
            
        }
        /*else
         {
         
         double slope = (self.cutCopyShape.origin.y - self.cutCopyShape.end.y)/(self.cutCopyShape.origin.x - self.cutCopyShape.end.x);
         double distance = sqrt(pow((self.cutCopyShape.end.x - self.cutCopyShape.origin.x),2 ) + pow((self.cutCopyShape.end.y - self.cutCopyShape.origin.y),2) );
         
         self.cutCopyShape.origin = self.currentTappedLocation;
         self.cutCopyShape.end = [self getEndPointWithOrigin:self.currentTappedLocation slope:slope distance:distance];
         //CGRect bzPathBounds = [self.cutCopyShape.bzPath bounds];
         
         //self.cutCopyShape.end = CGPointMake(self.cutCopyShape.origin.x + size.width, self.cutCopyShape.origin.y + size.height);
         }*/
        
        //OLDCODE[self.shapes addObject: [[ShapeObject alloc] initCopy:self.cutCopyShape]];
        [self.shapes addObject: self.cutCopyShape];
        
        
        ShapeObject *obj = [self.shapes lastObject];
        obj.shapeSelected = YES;
        
        self.cutCopyShape.shapeSelected = YES;
        self.shapeObjectChanged = YES;
        indexOfSelectedShape = [self.shapes count] - 1;
        
        self.cutCopyShape = nil;
        
        //remove the object file the fileToDelete arrary,
        //if the previous operation is cut, else leave it - THIS IS NOT IMPLEMENTED
        [self.filesToDelete removeLastObject];
        
        //1. Store the shapes
        /*[self.document insertPage:[self.shapes copy] atPageNumber:self.pageNumber];
         [self storeThumbNails:self.pageNumber];
         [self updateStorageModel];
         
         //enable trash can
         [self broadcastMessageIGotShapes:TRUE];
         [self centerthumbnailCollectionView];
         
         //4. redraw
         //[self refresh]; This clears the shapes
         [self storeThumbNails:self.pageNumber];*/
        
        
        [self refresh];
        [self saveShapesToCurrentPage ];
        
        [self refresh];
        
        //[self showContextMenu:CGRectMake(obj.origin.x, obj.origin.y, 1, 1)];
        
        
    }
    
    
    //skipDrawingCurrentShape = TRUE;
    //LATER[self refreshShapesinRect:rect];
    //indexOfSelectedShape = [self hitTest:self.currentTappedLocation];
    //[self refresh];
    //skipDrawingCurrentShape = FALSE;
}


-(CGPoint)getEndPointWithOrigin:(CGPoint)origin slope:(double)slope distance:(double)distance
{
    CGPoint end;
    
    double theta = atan(slope);
    end.x = origin.x + distance*cos(theta);
    end.y = origin.y + distance*sin(theta);
    
    return end;
}

//simultaneous gectures allowed
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    /*if (self.controlView.superview != nil) {
     if ([touch.view isDescendantOfView:_controlView]) {
     // we touched our control surface
     return NO; // ignore the touch
     }
     }*/
    if ( self.thumbnailCollectionView.superview != nil )
        if ([touch.view isDescendantOfView:self.thumbnailCollectionView]) {
            return NO;
        }
    
    /*
     if (self.pageSlider.superview !=nil )
     if ( [touch.view isDescendantOfView:self.pageSlider.superview])
     // If it is, prevent all of the delegate's gesture recognizers
     // from receiving the touch
     return NO;*/
    
    return YES;
}


- (NSUInteger)hitTest:(CGPoint)point
{
    
    /* NSUInteger indexOfShapeFound = -1;
     int index = 0;
     
     for(ShapeObject *shapeObject in self.shapes)
     {
     if ([shapeObject containsPoint:point])
     {
     indexOfShapeFound = index;
     shapeObject.shapeSelected = TRUE;
     return indexOfShapeFound;
     }
     else
     {
     shapeObject.shapeSelected = FALSE;
     }
     index++;
     }*/
    NSInteger indexOfShapeFound = -1;
    NSUInteger index = 0;
    NSMutableDictionary *shapesCloserToTouchPoint = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSMutableDictionary *distance = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    for(ShapeObject *shapeObject in self.shapes)
    {
        if ([shapeObject containsPoint:point])
        {
            //indexOfShapeFound = index;
            [shapesCloserToTouchPoint setObject:shapeObject forKey:[NSString stringWithFormat:@"%ld",(unsigned long)index]];
            //[distance setObject:[NSString stringWithFormat:@"%ld",(unsigned long)index] forKey:[NSString stringWithFormat:@"%f",[self lineToPointDistance2D:shapeObject.end pointB:shapeObject.origin pointC:point]]];
            [distance setObject:[NSString stringWithFormat:@"%ld",(unsigned long)index] forKey:[NSString stringWithFormat:@"%f",distanceToSegment(point, shapeObject.origin, shapeObject.end)]];
        }
        else
        {
            shapeObject.shapeSelected = FALSE;
        }
        index++;
    }
    
    //now find the nearest shape to the
    //get all keys
    if ( [shapesCloserToTouchPoint count ] > 0 )
    {
        NSMutableArray *keys = [[NSMutableArray alloc] initWithArray:[distance allKeys]];
        //NSMutableArray *values = [[NSMutableArray alloc] initWithArray:[distance allValues]];
        
        if ([keys count] > 1 )
            [keys
             sortUsingComparator:(NSComparator)^
             (NSString* obj1, NSString* obj2)
             {
                 return [obj1 compare:obj2 options:NSNumericSearch];
             }
             ];
        
        indexOfShapeFound = [[distance objectForKey:[keys firstObject]] integerValue];
        
        
        ShapeObject *obj = [self.shapes objectAtIndex:indexOfShapeFound];
        obj.shapeSelected = TRUE;
    }
    return indexOfShapeFound;
}

CGFloat sqr(CGFloat x)
{
    return x*x;
}

CGFloat dist2(CGPoint v, CGPoint w)
{
    return sqr(v.x - w.x) + sqr(v.y - w.y);
}

CGFloat distanceToSegmentSquared(CGPoint p, CGPoint v, CGPoint w)
{
    CGFloat l2 = dist2(v, w);
    if (l2 == 0.0f) return dist2(p, v);
    
    CGFloat t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
    if (t < 0.0f) return dist2(p, v);
    if (t > 1.0f) return dist2(p, w);
    return dist2(p, CGPointMake(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y)));
}

CGFloat distanceToSegment(CGPoint point, CGPoint segmentPointV, CGPoint segmentPointW)
{
    return sqrtf(distanceToSegmentSquared(point, segmentPointV, segmentPointW));
}

- (void)broadcaseShapeSelected:(ShapeObject *)shapeObject
{
    
    NSDictionary *selectedShape = [NSDictionary dictionaryWithObject:shapeObject forKey:@"ShapeSelected"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ShapeSelected" object: self userInfo: selectedShape];
}


-(void)shapeSelected:(NSNotification *) notification
{
    //get the delete button and enable it
    UIBarButtonItem *button = [self getBarButtonForTag:kDelete side:kRight];
    button.enabled = YES;
    
    
}

//SCrollview related
// Use layoutSubviews to center the PDF page in the view.
- (void)layoutSubviews
{
    [super.view layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen.
    
    CGSize boundsSize = self.view.bounds.size;
    CGRect frameToCenter = self.jCRPDFView.frame;//notesView
    
    // Center horizontally.
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // Center vertically.
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.jCRPDFView.frame = frameToCenter;//notesView
    self.jCRPDFView.frame = frameToCenter;//notesView
    
    /*
     To handle the interaction between CATiledLayer and high resolution screens, set the tiling view's contentScaleFactor to 1.0.
     If this step were omitted, the content scale factor would be 2.0 on high resolution screens, which would cause the CATiledLayer to ask for tiles of the wrong scale.
     */
    self.jCRPDFView.contentScaleFactor = 2.0;//notesView
}



#pragma mark - related to PDF
-(void)configureViewForPDF:(NSString *)url size:(CGSize)size
{
    //page number starts with 1;
    self.pageNumber = 1;
    
    self.document = [[DocumentController alloc] init];
    //self.pdfController = [[PDFController alloc] init];
    //NSURL *absoluteURL = [[NSURL alloc] initWithString:
    //[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURL *absoluteURL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    //NSLog(@"URL IS %@", absoluteURL);
    
    //initialize PDFView
    [self.jCRPDFView setURL:absoluteURL];
    
    
    //[self.pdfController initializeWithURL:absoluteURL];
    
    if ( [self.pageData length] > 0  ) //then decode it
    {
        [self.document constructDictionaryFromCoreData:self.pageData];
        [self displayPDF:1];
        [self broadcastMessageIGotThumbnails:YES];
    }
    else
    {
        [self broadcastMessageIGotThumbnails:NO];
    }
    //[self refresh];
    
}


#pragma mark - for PDFView -Darasource
/*
 -(CGPDFPageRef)getPDFPage:(int)pageNumber
 {
 //for PDF, counting starts with 1;
 //use the dirtyPage set to decide whether the page should be brought from original document or from dirtied document
 //if ( ![dirtyPageNumberSet containsObject:[NSString stringWithFormat:@"%d",pageNumber]] )
 //if (![self.document containsDirtyKey:pageNumber])
 pdfPage = [self.pdfController getPage:pageNumber];
 return pdfPage;
 }
 
 -(int)getPageNumber
 {
 int count = [self.pdfController count];
 if ( _pageNumber >= count )
 _pageNumber = count;
 else if ( _pageNumber <1 )
 _pageNumber = 1;
 return _pageNumber;
 }
 
 
 -(CGRect)pageFrame:(CGPDFPageRef)page
 {
 CGRect rect = [self.pdfController pageFrameFor:page andPageNumber:_pageNumber];
 return rect;
 }
 
 -(DocumentType)getDocumentType
 {
 return self.documentType;
 }
 */

#pragma mark - PPT Data source
-(int)getSlideNumber:(PPTView*)view
{
    return _pageNumber;
}
/*
 -(CGRect)slideFrameSize
 {
 //ORIGINALCGRect frame = [self.notesView frame];
 CGSize size = [self.pptController getScaledPPTSizeForDisplay];
 CGRect frame = CGRectMake(0,0, size.width, size.height);
 //[self.pptController frame];
 return frame;
 //return self.notesView.frame;
 }
 */
-(BOOL)isWebviewActive
{
    /*  NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
     NSLog(@"HTML=%@", html);
     if ( [html length] == 0)
     return FALSE;*/
    return TRUE;
    
}

-(NSString *)getSlide:(int)slideIndex
{
    return [self.pptSlides objectAtIndex:slideIndex];
}


#pragma mark - XLS data source
-(int)getsheetIndex
{
    return _pageNumber;
}

-(int)getSheetCount
{
    return self.xlsSheetCount;
}
/*
 -(NSString *)getSheetName:(int)index
 {
 return [[self.xlsController getSheetNames] objectAtIndex:index];
 }
 */
-(CGRect)sheetFrameSize
{
    return self.jCRPDFView.frame;//notesView
}

-(NSString *)getSheet:(int)index
{
    return [self.xlsSheets objectAtIndex:index];
}

-(BOOL)xlsDrawingMode
{
    return FALSE;
}

#pragma mark - animation

-(CATransition *)addAnimationForPageFlip:(NSString*)transition
{
    CATransition *animation = [CATransition animation];
    //[animation setDelegate:self];
    [animation setDuration:1.0f];
    animation.startProgress = 0.0;
    animation.endProgress   = 1.0;
    [animation setType:@"pageCurl"]; //@"pageCurl"//kCATransitionFade is good
    [animation setSubtype:@"fromRight"];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode: @"extended"];
    [animation setRemovedOnCompletion: NO];
    
    //[animation setType:kcat];
    [animation setSubtype:transition];
    
    
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode: kCAFillModeBackwards];//kCAFillModeForwards
    
    //[animation setRemovedOnCompletion: NO];
    //if ( readOnly )
    //[[self.webView layer] addAnimation:animation forKey:@"pageFlipAnimation"];
    return animation;
    
}


#
#pragma mark - Thumbnail views - removing UITableView
/*
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 
 
 if ( ![self.thumbnailCollectionView isInitialized] )
 {
 //CGRect frame;
 
 //self.thumbnailCollectionView.frame = self.thumbnailCollectionView.frame;
 [self.thumbnailCollectionView initializeView:self.thumbnailCollectionView.bounds];
 
 self.thumbnailCollectionView.rowHeight = 64;
 //self.thumbnailCollectionView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"FilmStrip.png"]];
 self.thumbnailCollectionView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
 // Rotates the view.
 //CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
 //self.thumbnailCollectionView.transform = transform;
 // Repositions and resizes the view.
 //CGRect contentRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 64); //175
 //self.thumbnailCollectionView.frame = contentRect;
 self.thumbnailCollectionView.pagingEnabled = YES;
 self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
 self.thumbnailCollectionView.bounces = NO;
 
 self.thumbnailCollectionView.dataSource = self;
 self.thumbnailCollectionView.delegate = self;
 //self.thumbnailCollectionView.layer.borderWidth = 1.0;
 //self.thumbnailCollectionView.layer.borderColor = [UIColor clearColor].CGColor;
 self.thumbnailCollectionView.clipsToBounds = YES;
 
 //self.thumbnailCollectionView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
 
 
 }
 
 return [self.document getDirtyPageCount];
 }
 
 
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 //static NSString *CellIdentifier = @"Cell";
 //REusing the cell retains old drawing
 //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;
 cell.frame = CGRectMake(5,5,54,54);Storyboard
 }
 
 [self setupCellForDrawing:cell cellForRowAtIndexPath:indexPath];
 
 //[tableView scrollToRowAtIndexPath:[indexPath lastRow]];
 
 return cell;
 }
 
 -(void)setupCellForDrawing:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 //NSNumber *index = [dirtyPageNumberSet objectAtIndex:indexPath.row];
 if ( [self.document getDirtyPageCount] > 0 )
 {
 int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row];
 cell.contentMode = UIViewContentModeRedraw;
 if ([self.document containsDirtyKey:pageNumber])
 {
 
 if ( self.documentType == kPDF )
 {
 CellViewForPDF *pdfView  = (CellViewForPDF *)[cell.contentView viewWithTag:1007];
 if ( [pdfView superview] )
 [pdfView removeFromSuperview];
 
 
 pdfView = [[CellViewForPDF alloc] initWithFrame:CGRectMake(5,5,54,54)]; //82
 pdfView.tag = 1007;
 [cell.contentView addSubview:pdfView];
 pdfView.layer.borderColor = [UIColor redColor].CGColor;
 pdfView.layer.borderWidth = 1;
 
 //set URL
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
 NSString *applicationSupportDirectory = [paths objectAtIndex:0];
 self.applicationSupportURL = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, self.documentName];
 NSURL *url = [NSURL URLWithString:[self.applicationSupportURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
 
 
 [pdfView setURL:url];
 
 //[pdfView setURL:[[NSURL alloc] initWithString:[self.documentURL
 //stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
 [pdfView  setPageNumber:pageNumber];
 //pdfView.transform = CGAffineTransformMakeRotation(1.5707963);
 pdfView.contentMode = UIViewContentModeScaleAspectFill;
 //[self.thumbnailCollectionView setNeedsDisplay];
 pdfView = nil;
 }
 else if ( self.documentType == kXLS )
 {
 //get the thumbnail and show
 }
 
 UILabel *label = (UILabel *)[cell.contentView viewWithTag:1005];
 
 if ( [label superview] )
 [label removeFromSuperview];
 
 label = [[UILabel alloc] initWithFrame:CGRectMake(5,5,54,54)];
 label.tag = 1005;
 [cell addSubview:label];
 
 label.contentMode = UIViewContentModeRedraw;
 //if ( self.documentType == kXLS )
 //{
 //label.text = [NSString stringWithFormat:@"%@\n%i",[self.xlsSheetNames objectAtIndex:pageNumber],  pageNumber+1];make it human readable number :)
 // }
 // else
 
 label.text = [NSString stringWithFormat:@"%i", self.documentType == kPPT? pageNumber+1:pageNumber];//make it human readable number :)
 label.center = CGPointMake(12,31);//87
 label.textAlignment = NSTextAlignmentRight;
 label.backgroundColor = [UIColor clearColor];
 label.textColor = [UIColor redColor];
 
 NSDictionary *fontAttributes = @{
 NSForegroundColorAttributeName:[UIColor redColor],
 NSFontAttributeName:[UIFont systemFontOfSize:12.0]
 };
 NSMutableAttributedString *attributedText =
 [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",self.documentType == kPPT? pageNumber+1:pageNumber] attributes:fontAttributes];
 
 label.attributedText = attributedText;
 
 //label.transform = CGAffineTransformMakeRotation(1.5707963);
 }
 cell.contentView.backgroundColor = [UIColor clearColor];
 cell.backgroundColor = [UIColor clearColor];
 }
 }
 
 #pragma mark - Table view delegate
 //- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
 //
 //    return indexPath.row*96;
 //}
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
 
 
 int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row ];
 
 if ( [self.document containsDirtyKey:pageNumber] )
 //if ( [dirtyPageNumberSet containsObject:[NSString stringWithFormat:@"%d",pageNumber] ] )
 {
 // NSLog(@"Selected Page = %d", pageNumber);
 [self clearSelectedShape];
 
 if ( self.documentType == kPDF )
 {
 _pageNumber = pageNumber;
 [self displayPDF:pageNumber];
 tableView.transform = CGAffineTransformMakeRotation(1.5707963);
 }
 else if ( self.documentType == kXLS )
 {
 _pageNumber = pageNumber;
 [self displayXLS:pageNumber];
 }
 
 }
 }
 
 */

#pragma mark - WORD protocol methods
/*
 -(NSString *)getPage:(int)pageNumber
 {
 return [self.wordController getPage:1];
 }
 */
#pragma mark - PDF renderer
//convert doc/docx into PDF before annotating, as webview renders it as a long page

-(void)convertDocumentToPDF:(CGSize)size pages:(int)count view:(UIWebView*)view
{
    //CGPDFDocumentRef pdfDocument = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.documentType == kPPT)
    {
        [self convertPowerPointToPDF:size pages:count view:view];
        //[self convertPPTToPDF:size pages:count];
        //[self convertPowerPointToPDF:size pages:count view:view];
    }
    else if ( self.documentType == kDOC)
    {
        [self convertWordToPDF:size pages:count];
    }
    else if ( self.documentType == kHTTP)
    {
        [self convertWebContentsToPDF:size pages:count];
    }
    
    else if ( self.documentType == kXLS)
    {
        //pdfDocument = [self convertXLSToPDF:size pageIndex:count view:view ];
    }
    
    else if ( self.documentType == kHTML)
    {
        [self convertWebContentsToPDF:size pages:count];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //Now document is converted. Set type as PDF
    self.documentType = kPDF;
    //return pdfDocument;
}

-(void)convertWordToPDF:(CGSize)size pages:(int)count
{
    int height, width, header, leftMargin, rightMargin;
    //Letter size
    height = 544;
    width = 512;
    header = 2;
    leftMargin = 12;
    rightMargin = 12;
    
    //set margins, header and footer
    UIEdgeInsets pageInset = UIEdgeInsetsMake(header, leftMargin, header, rightMargin);
    //self.webView.viewPrintFormatter.contentInsets = pageInset; contentInsets deprecated
    self.webView.viewPrintFormatter.perPageContentInsets = pageInset;

    UIViewPrintFormatter *formatter = [self.webView viewPrintFormatter];
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pageSize = CGSizeMake(width,height); //letter size
    CGRect paperRect = CGRectMake(0,0, pageSize.width, pageSize.height);
    
    CGRect printableRect = CGRectMake(pageInset.left,
                                      pageInset.top,
                                      pageSize.width - pageInset.left - pageInset.right,
                                      pageSize.height - pageInset.top - pageInset.bottom);
    
    
    [renderer setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    renderer.headerHeight = 12;
    renderer.footerHeight = 12;
    [renderer prepareForDrawingPages:NSMakeRange(0, renderer.numberOfPages)];
    UIGraphicsBeginPDFContextToData(pdfData, paperRect, [self getPDFDictionary]);
    
    for (int i = 0; i < renderer.numberOfPages ; i++)
    {
        
        
        
        UIGraphicsBeginPDFPage();
        
        [renderer drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
        
        /*
         CFMutableDictionaryRef pageDictionary = NULL;
         CFDataRef boxData = NULL;
         CGContextRef currentContext = UIGraphicsGetCurrentContext();
         
         
         pageDictionary = CFDictionaryCreateMutable(NULL, 0,
         &kCFTypeDictionaryKeyCallBacks,
         &kCFTypeDictionaryValueCallBacks);
         
         boxData = CFDataCreate(NULL,(const UInt8 *)&paperRect, sizeof (CGRect));
         CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
         CFDictionarySetValue(pageDictionary, CFSTR("DA"), CFSTR("/Helvetica 22 Tf 0 g"));
         CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault,0, &kCFTypeArrayCallBacks);
         CFArrayInsertValueAtIndex(array, i, pageDictionary);
         
         UIGraphicsBeginPDFPage();
         
         CGContextTranslateCTM(currentContext, -1, -1);
         
         [renderer drawPageAtIndex:i inRect:paperRect];
         CFRelease(boxData);*/
        //[self drawPageNumber:i size:size];
        //CFRelease(boxData);
        
    }
    
    UIGraphicsEndPDFContext();
    
    [self saveAsPDF:pdfData];
    //NSLog(@"Page count = %d", pages);
    
    //CFDataRef myPDFData        = (__bridge CFDataRef)pdfData;
    //CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)pdfData);
    //pdfDocument       = CGPDFDocumentCreateWithProvider(provider);
    //CFRelease(myPDFData);
    //CGDataProviderRelease(provider);
    //return pdf;
}

-(void)convertPPTToPDF:(CGSize)size pages:(int)count
{
    int height, width, header, leftMargin, rightMargin;
    //Letter size
    //height = 792;
    //width = 612;
    height = [Utility deviceBounds].size.height;
    width = [Utility deviceBounds].size.width;
    header = 216;
    leftMargin = 36;
    rightMargin = 36;
    
    //set margins, header and footer
    UIEdgeInsets pageInset = UIEdgeInsetsMake(header, leftMargin, header, rightMargin);
    //self.webView.viewPrintFormatter.contentInsets = pageInset;
    self.webView.viewPrintFormatter.perPageContentInsets = pageInset;

    UIViewPrintFormatter *formatter = [self.webView viewPrintFormatter];
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pageSize = CGSizeMake(width,height ); //letter size
    CGRect paperRect = CGRectMake(0,0, pageSize.width, pageSize.height);
    
    CGRect printableRect = CGRectMake(pageInset.left,
                                      pageInset.top,
                                      pageSize.width - pageInset.left - pageInset.right,
                                      pageSize.height - pageInset.top - pageInset.bottom);
    
    
    [renderer setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    renderer.headerHeight = 216;
    renderer.footerHeight = 72;
    [renderer prepareForDrawingPages:NSMakeRange(0, renderer.numberOfPages)];
    UIGraphicsBeginPDFContextToData(pdfData, paperRect, [self getPDFDictionary]);
    id pptView = [[self.webView subviews] lastObject];
    
    for (int i = 0; i < count ; i++)
    {
        
        UIGraphicsBeginPDFPageWithInfo(paperRect,nil);
        self.webView.frame = CGRectMake(0,0,size.width, size.height);
        
        [pptView setContentOffset:CGPointMake(0, (size.height * i) + (i*5)) animated:NO];
        
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        //CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -1, -1);
        
    }
    
    UIGraphicsEndPDFContext();
    
    [self saveAsPDF:pdfData];
    //NSLog(@"Page count = %d", pages);
    
    //CFDataRef myPDFData        = (__bridge CFDataRef)pdfData;
    //CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)pdfData);
    //pdfDocument       = CGPDFDocumentCreateWithProvider(provider);
    //CFRelease(myPDFData);
    //CGDataProviderRelease(provider);
    //return pdf;
}



-(void)convertWebContentsToPDF:(CGSize)size pages:(int)count
{
    /*
     //UIPrintFormatter *formatter = self.webView.viewPrintFormatter;
     UIViewPrintFormatter *formatter = [self.webView viewPrintFormatter];
     
     UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
     
     [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
     
     NSMutableData *pdfData = [NSMutableData data];
     
     CGSize pageSize = CGSizeMake(11 * 72,8.5 * 72 ); //letter size
     CGRect pageRect;
     
     renderer.headerHeight = 1.0*72;
     renderer.footerHeight = 1.0*72;
     pageRect = CGRectMake(0,0, pageSize.width, pageSize.height);
     [renderer setValue:[NSValue valueWithCGRect:CGRectMake(0,0,pageRect.size.width, pageRect.size.height)] forKey:@"paperRect"];
     [renderer setValue:[NSValue valueWithCGRect:pageRect] forKey:@"printableRect"];
     
     
     //int pages = [formatter pageCount];
     int pages = count;
     
     [renderer prepareForDrawingPages:NSMakeRange(0, count)];
     //CGRect boxRect = CGRectMake(0,0,7.5*72, 9.5*72);
     
     UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, [self getPDFDictionary]);
     
     */
    [self.activityIndicator startAnimating];
    self.navigationController.navigationBarHidden = YES;
    
    
    int height, width, header, leftMargin, rightMargin;
    //Letter size
    //height = [Utility deviceBounds].size.height;
    //width = [Utility deviceBounds].size.width;
    height = self.jCRPDFView.frame.size.height-64.0;
    width = self.jCRPDFView.frame.size.width;
    header = 0;
    leftMargin = 2;
    rightMargin = 2;
    
    //set margins, header and footer
    UIEdgeInsets pageInset = UIEdgeInsetsMake(header, leftMargin, header, rightMargin);
    //self.webView.viewPrintFormatter.contentInsets = pageInset;
    self.webView.viewPrintFormatter.perPageContentInsets = pageInset;

    UIViewPrintFormatter *formatter = [self.webView viewPrintFormatter];
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pageSize = CGSizeMake(width,height ); //letter size
    CGRect paperRect = CGRectMake(10,10, pageSize.width, pageSize.height);
    
    CGRect printableRect = CGRectMake(pageInset.left,
                                      pageInset.top,
                                      pageSize.width - pageInset.left - pageInset.right,
                                      pageSize.height - pageInset.top - pageInset.bottom);
    
    
    [renderer setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    renderer.headerHeight = 2;
    renderer.footerHeight = 2;
    [renderer prepareForDrawingPages:NSMakeRange(0, renderer.numberOfPages)];
    UIGraphicsBeginPDFContextToData(pdfData, paperRect, [self getPDFDictionary]);
    [self.webView loadHTMLString:self.html baseURL:nil];
    
    for (int i = 0; i < renderer.numberOfPages ; i++)
    {
        /* commented on 3/8/2016

        CFMutableDictionaryRef pageDictionary = NULL;
        CFDataRef boxData = NULL;
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        
         pageDictionary = CFDictionaryCreateMutable(NULL, 0,
                                                   &kCFTypeDictionaryKeyCallBacks,
                                                   &kCFTypeDictionaryValueCallBacks);
        
        boxData = CFDataCreate(NULL,(const UInt8 *)&paperRect, sizeof (CGRect));
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        CFDictionarySetValue(pageDictionary, CFSTR("DA"), CFSTR("/Helvetica 22 Tf 0 g"));
        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault,0, &kCFTypeArrayCallBacks);
        CFArrayInsertValueAtIndex(array, i, pageDictionary);
        
        UIGraphicsBeginPDFPage();
        
        CGContextTranslateCTM(currentContext, -1, -1);
        
        [renderer drawPageAtIndex:i inRect:paperRect];
        CFRelease(boxData);
        //[self drawPageNumber:i size:size];
        //CFRelease(boxData);
        3-8-2016 */
         
         UIGraphicsBeginPDFPage();
         [renderer drawPageAtIndex:i inRect:paperRect];
         
         [renderer drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
        /* NSLog(@"PDFRect = %@", NSStringFromCGRect(UIGraphicsGetPDFContextBounds()));*/
    }
    
    
    
    UIGraphicsEndPDFContext();
    
    [self saveAsPDF:pdfData];
    [self.activityIndicator stopAnimating];
    self.navigationController.navigationBarHidden = NO;
    /*
     CFDataRef myPDFData        = (__bridge CFDataRef)pdfData;
     CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
     pdfDocument       = CGPDFDocumentCreateWithProvider(provider);
     //CFRelease(myPDFData);
     //CFRelease(pdfData);
     
     CGDataProviderRelease(provider);
     
     //return pdf;*/
    
}

/*
 -(CGPDFDocumentRef)convertXLSToPDF:(CGSize)size pageIndex:(int)index view:(UIWebView*)view
 {
 
 
 
 
 CGRect boxRect = CGRectMake(0, 0, size.width, size.height);
 NSMutableData *pdfData = [NSMutableData data];
 //Set values for the PDF data created here
 
 UIGraphicsBeginPDFContextToData( pdfData, boxRect, [self getPDFDictionary] );
 //get one sheet at a time
 CGRect saveWebFrame = view.frame;
 int count = [self.xlsController getSheetCount];
 NSArray *sheets = [self.xlsController getSheets];
 
 for ( int i = 0; i < count; i++)
 {
 CGRect frame = CGRectMake(0,0,size.width, size.height);
 view.frame = frame;
 
 CGContextRef currentContext = UIGraphicsGetCurrentContext();
 
 UIGraphicsBeginPDFPage();
 [xlsWebView setContentOffset:CGPointMake(0, size.height) animated:NO];
 [view.layer renderInContext:currentContext];
 
 [self drawPageNumber:i];
 }
 UIGraphicsEndPDFContext();
 view.frame = saveWebFrame;
 [self saveAsPDF:pdfData];
 
 CFDataRef myPDFData        = (__bridge CFDataRef)pdfData;
 CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
 CGPDFDocumentRef pdf       = CGPDFDocumentCreateWithProvider(provider);
 CGDataProviderRelease(provider);
 //[view removeFromSuperview];
 //[xlsWebView removeFromSuperview];
 //[webview removeFromSuperview];
 return pdf;
 
 }
 */

-(void)convertPowerPointToPDF:(CGSize)size pages:(int)count view:(UIWebView*)view
{
    [self.activityIndicator startAnimating];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSString *fileURL = [applicationSupportDirectory stringByAppendingPathComponent:self.documentName];
    
    
    //remove the source file - no longer required
    //NSString *destinationPath = [NSString stringWithFormat:@"file://%@",fileURL ];
    
    //[self.document removeFile:[[NSURL alloc] initWithString:[destinationPath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [self.document removeFile:self.documentName];
    //update the URL in COREData
    
    NSString *fileURLforContext = [NSString stringWithFormat:@"%@.pdf", fileURL];
    //add file protocol
    
    fileURL = [NSString stringWithFormat:@"file://%@.pdf", fileURL];
    self.documentURL = fileURL;
    self.documentName = [NSString stringWithFormat:@"%@.pdf",self.documentName];
    //self.documentType = kPDF;
    CGRect boxRect = CGRectMake(0, 0, size.width, size.height);
    /*CGRect boxRect = CGRectMake((self.view.frame.size.width - 612)/2.0,(self.view.frame.size.height - 792)/2.0, size.width, size.height);*/
    
    BOOL  bContextCreated  = UIGraphicsBeginPDFContextToFile(fileURLforContext, boxRect, [self getPDFDictionary]);
    id pptView = [[self.webView subviews] lastObject];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //CGPoint offset = CGPointMake((self.view.frame.size.width - size.width)/2.0, 0.0);
    if ( bContextCreated )
    {
        for (int i = 0; i < count; i++)
        {
            //CGRect frame = CGRectMake((self.view.frame.size.width - 612)/2.0,(self.view.frame.size.height - 792)/2.0,self.view.frame.size.width, self.view.frame.size.height);
            self.webView.frame = boxRect;
            UIGraphicsBeginPDFPageWithInfo(boxRect, nil);
            
            [pptView setContentOffset:CGPointMake(0, (size.height * i) + (i*5)) animated:NO];
            
            [self.webView.layer renderInContext:currentContext];
            
            
            [self drawPageNumber:i size:size];
            
        }
        
    }
    UIGraphicsEndPDFContext();
    //CGContextRelease(currentContext);
    
    StorageController *storethis = [[StorageController alloc] init];
    storethis.timestamp = self.documentTimestamp;
    
    storethis.documentName = self.documentName;
    storethis.documentURL = fileURL;
    [storethis updateCoreDataObject];
    
    [self.activityIndicator stopAnimating];
    
    //[self.progressView removeFromSuperview];
    /*view.frame = saveWebFrame;
     [self saveAsPDF:pdfData];
     
     CFDataRef myPDFData        = (__bridge CFDataRef)pdfData;
     CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
     CGPDFDocumentRef pdf       = CGPDFDocumentCreateWithProvider(provider);
     CGDataProviderRelease(provider);
     return pdf;*/
    //return CGPDFDocumentCreateWithURL((__bridge CFURLRef)(absoluteURL));
    
}

- (void)drawPageNumber:(NSInteger)pageNum size:(CGSize)size
{
    NSString *pageString = [NSString stringWithFormat:@"Page %d", (int)pageNum+1];
    CGSize maxSize = CGSizeMake(size.width, 72);
    
    /*deprecated
     CGSize pageStringSize = [pageString sizeWithFont:theFont
     constrainedToSize:maxSize
     lineBreakMode:NSLineBreakByClipping];
     CGRect stringRect = CGRectMake(((size.width - pageStringSize.width) / 2.0),
     size.height + ((72.0 - pageStringSize.height) / 2.0),
     pageStringSize.width,
     pageStringSize.height);
     
     [pageString drawInRect:stringRect withFont:theFont];*/
    
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGRect pageStringBoundingBox = [pageString boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    CGRect stringRect = CGRectMake(((size.width - pageStringBoundingBox.size.width) / 2.0),
                                   size.height,
                                   pageStringBoundingBox.size.width,
                                   pageStringBoundingBox.size.height);
    
    //deprecated[pageString drawInRect:stringRect withFont:theFont];
    
    [pageString drawInRect:stringRect withAttributes:attributes];
}

- (NSDictionary *)getPDFDictionary
{
    NSDictionary *pdfDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"CMyNotes", kCGPDFContextAuthor,
                                   @"Created by CMyNotes", kCGPDFContextCreator,
                                   @"CMyNotes", kCGPDFContextTitle,
                                   nil];
    return pdfDictionary;
}

#pragma mark - utility methods
+(DocumentType)getDocumentType:(NSString *)url
{
    NSURL *absoluteURL = [[NSURL alloc] initWithString:
                          [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSString *extension = [[[[absoluteURL path] lastPathComponent] pathExtension] lowercaseString];
    NSString *scheme = [[absoluteURL scheme] lowercaseString];
    
    if ( [extension isEqualToString:@"pdf"] )
        return kPDF;
    else if ( [extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"])
        return kPPT;
    else if ( [extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"])
        return kXLS;
    else if ( [extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"])
        return kDOC;
    else if ( [extension isEqualToString:@"html"] || [extension isEqualToString:@"html"])
        return kHTML;
    else if ( [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] )
        return kHTTP;
    else if ( [extension isEqualToString:@"adv"] )
            return kAd;
    return kNone;
}



#pragma mark - delegate methods for UIWebView
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // webView connected
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //prepare document for editing
    //self.sizeOfNotesView = CGSizeMake(_webView.frame.size.width, _webView.frame.size.height);
    if ( [webView isLoading]) return;
    
    self.documentType = [DrawingController getDocumentType:self.documentURL];
    if ( self.documentType == kHTTP)
    {
        CGSize contentSize = webView.scrollView.contentSize;
        CGSize viewSize = self.webView.bounds.size;
        
        float rw = viewSize.width / contentSize.width;
        
        webView.scrollView.minimumZoomScale = rw;
        webView.scrollView.maximumZoomScale = rw;
        webView.scrollView.zoomScale = rw;
        self.navigationController.navigationBarHidden = NO;
        
    }
    //[self.timer invalidate];
    
    [self broadcastMessageWebViewFinished];
    
}
- (void)cancelWeb
{
    NSLog(@"didn't finish loading within 20 sec");
    // do anything error
}
-(void)broadcastMessageWebViewFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"WebViewFinishedLoading" object:self userInfo: nil];
    
}

-(void)finishedLoadingWebView
{
    self.activityIndicator.backgroundColor = [UIColor blackColor];
    [self.activityIndicator layer].cornerRadius = 8.0;
    [self.activityIndicator layer].masksToBounds = YES;
    [self.activityIndicator startAnimating];
    //CGPDFDocumentRef pdfData;
    if ( self.documentType == kPPT || self.documentType == kPPTX)
    {
        self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.outerHTML"];
        //NSLog(@"HTML = %@", self.html);
        //float scrollHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        CGSize size = [self.webView sizeThatFits:CGSizeZero];
        //initialize the PPT controller
        PPTController *pptController = [[PPTController alloc] initWithView:self.webView withHTML:self.html];
        //CGSize pptSize = [pptController getScaledPPTSizeForDisplay];
        CGSize pptSize = [pptController getSize];
        size.height = pptSize.height;
        
        //new document
        //do initializations
        //self.shapes = [[NSMutableArray alloc] initWithCapacity:5];
        [self convertDocumentToPDF:pptSize pages:[pptController slideCount] view:self.webView];
        //[self.drawingController configureViewForPPT:self.webView withHTML:self.html];
        //[self configureViewForOfficeDocuments];
        
        [self configureViewForPDF:self.documentURL size:size];
        
        //CGPDFDocumentRelease(pdfData);
        
        //CGPDFDocumentRelease(pdfData);
    }
    else if ( self.documentType == kDOC || self.documentType == kDOCX )
    {
        
        self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        
        CGSize size = [self.webView sizeThatFits:CGSizeZero];
        
        //do we need to worry about margins here?
        int pageCount = size.height/size.height;
        
        [self convertDocumentToPDF:size pages:pageCount view:self.webView];
        //[self configureViewForOfficeDocuments];
        [self configureViewForPDF:self.documentURL size:CGSizeZero];
        
        //CGPDFDocumentRelease(pdfData);
        
    }
    else if ( self.documentType == kPDF )
    {
        //decode the documentURL and get the applicationSupportURL
        //using applicationSupportURL 16-12-2014
        //[self configureViewForPDF:self.documentURL size:size];
        [self configureViewForPDF:self.applicationSupportURL size:CGSizeZero];
        //[self configureViewForPDF:self.documentURL size:CGSizeZero];
    }
    else if ( self.documentType == kHTTP || self.documentType == kHTML)
    {
        self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        //float scrollHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        //NSLog(@"DocX=%@", self.html);
        
        //CGSize size = [self.webView sizeThatFits:CGSizeZero];
        CGSize size = self.webView.scrollView.contentSize;
        int pageCount = size.height/[Utility deviceBounds].size.height;
        
        [self convertDocumentToPDF:size pages:pageCount view:self.webView];
        [self configureViewForPDF:self.documentURL size:CGSizeZero];
        
        //[self configureViewForOfficeDocuments];
        //CGPDFDocumentRelease(pdfData);
        
    }
    else if ( self.documentType == kAd )
    {
        NSLog(@"Do something");
    }
    /*
     else if ( self.documentType == kXLS || self.documentType == kXLSX )
     {
     //static int i = 0;
     self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
     //i++;
     //NSLog(@"Loaded %d times", i);
     //[self configureViewForXLS:self.html];
     //[self.webView removeFromSuperview];
     //self.webView.delegate = nil;
     //self.webView = nil;
     
     //[self convertXLSSheetsToImage:0 view:self.webView];
     //CGPDFDocumentRef pdfData = [self convertDocumentToPDF:self.notesView.frame.size pages:self.xlsSheetCount view:self.webView];
     //[self configureViewForOfficeDocuments:pdfData];
     
     }
     */
    /*
     else if ( self.documentType == kHTTP )
     {
     self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
     //float scrollHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
     //NSLog(@"DocX=%@", self.html);
     
     CGSize size = [self.webView sizeThatFits:CGSizeZero];
     int pageCount = size.height/size.height;
     
     CGPDFDocumentRef pdfData = [self convertDocumentToPDF:size pages:pageCount];
     [self configureViewForOfficeDocuments:pdfData];
     
     }
     */
    //self.webView.hidden = TRUE;;
    
    
    [self loadDocument];
    [self.activityIndicator stopAnimating];
    
}


#pragma mark -PageSlider methods and messages
- (IBAction)pageSliderMoved:(id)sender
{
    int pageNumber = self.pageSlider.value;
    if (  self.shapeObjectChanged )
        [self storePage:_pageNumber];
    else
    {
        //reset shape related globals
        //[self resetShapeRelatedGlobals];
        
    }
    //reset shape related globals
    [self resetShapeRelatedGlobals];
    _pageNumber = pageNumber;
    [self displayPDF:pageNumber];
    self.informationLabel.alpha = 1.0;
    
    [self displayInstructions:[NSString stringWithFormat: @" Page %d", (int)self.pageNumber] instructionType:kDisplayPageNumber];
    
}

#pragma mark CollectionView Code

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    //self.thumbnailCollectionView = collectionView;
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NSArray *dirstPageArray = self.datasource;
    //return [dirstPageArray count];
    return [self.document getDirtyPageCount];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCV" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UICollectionViewCell alloc] init ];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.frame = CGRectMake(2.5,2.5,40,55);
        }
        else
        {
            cell.frame = CGRectMake(2.5,2.5,25,35);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setupCollectionViewCellForDrawing:cell cellForRowAtIndexPath:indexPath];
    });
    
    return cell;
}

-(void)setupCollectionViewCellForDrawing:(UICollectionViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSNumber *index = [dirtyPageNumberSet objectAtIndex:indexPath.row];
    if ( [self.document getDirtyPageCount] > 0 )
    {
        int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row];
        
        cell.contentMode = UIViewContentModeRedraw;
        if ([self.document containsDirtyKey:pageNumber])
        {
            //            if ( self.documentType == kPDF )
            //            {
            CellViewForPDF *pdfView  = (CellViewForPDF *)[cell.contentView viewWithTag:1007];
            if ( [pdfView superview] )
                [pdfView removeFromSuperview];
            
            
            pdfView = [[CellViewForPDF alloc] initWithFrame:cell.bounds]; //82
            pdfView.tag = 1007;
            [cell.contentView addSubview:pdfView];
            pdfView.layer.borderColor = [UIColor redColor].CGColor;
            pdfView.layer.borderWidth = 1;
            
            //set URL
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *applicationSupportDirectory = [paths objectAtIndex:0];
            self.applicationSupportURL = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, self.documentName];
            NSURL *url = [NSURL URLWithString:[self.applicationSupportURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            
            
            [pdfView setURL:url];
            
            //[pdfView setURL:[[NSURL alloc] initWithString:[self.documentURL
            //stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [pdfView  setPageNumber:pageNumber];
            //pdfView.transform = CGAffineTransformMakeRotation(1.5707963);
            pdfView.contentMode = UIViewContentModeScaleAspectFill;
            //[self.thumbnailCollectionView setNeedsDisplay];
            // }
            
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:1005];
            
            if ( [label superview] )
                [label removeFromSuperview];
            
            label = [[UILabel alloc] initWithFrame:cell.bounds];
            label.tag = 1005;
            [pdfView addSubview:label];
            
            
            label.contentMode = UIViewContentModeRedraw;
            
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor redColor];
            
            NSDictionary *fontAttributes = @{
                                             NSForegroundColorAttributeName:[UIColor redColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:12.0]
                                             };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",self.documentType == kPPT? pageNumber+1:pageNumber] attributes:fontAttributes];
            
            label.attributedText = attributedText;
            
            //label.transform = CGAffineTransformMakeRotation(1.5707963);
        }
        
        // then set them via the main queue if the cell is still visible.
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Adjust cell size for orientation
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return CGSizeMake(30.0, 40.0);
    
    return CGSizeMake(45.0, 60.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row ];
    
    if ( [self.document containsDirtyKey:pageNumber] )
        //if ( [dirtyPageNumberSet containsObject:[NSString stringWithFormat:@"%d",pageNumber] ] )
    {
        [self clearSelectedShape];
        
        if ( self.documentType == kPDF )
        {
            _pageNumber = pageNumber;
            [self displayPDF:pageNumber];
        }
        else if ( self.documentType == kXLS )
        {
            _pageNumber = pageNumber;
            [self displayXLS:pageNumber];
        }
        
    }
}

-(void)removePageFromthumbnailCollectionView
{
    //GET THE INDEX OF THE PAGE FROM THE DIRTYPAGE SET
    NSInteger index = [self.document getIndexOfDirtyPage:_pageNumber];
    //Remove it now from the dirtypage set
    [self.document removePageForKey:_pageNumber url:self.documentURL];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    //UICollectionViewCell *cell = [self.thumbnailCollectionView cellForItemAtIndexPath:indexPath];
    
    [self.thumbnailCollectionView performBatchUpdates:^(void){
        
        [self.thumbnailCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:nil];
    
    //[self.thumbnailCollectionView reloadData];
    
    
    if ( [self.document getDirtyPageCount] == 0 )
    {
        [self broadcastMessageIGotThumbnails:NO];
    }
    
    [self centerthumbnailCollectionView];
    
}

-(void)centerthumbnailCollectionView
{
    /*
     if ( widthOfThumbnails > self.pdfView.bounds.size.width )
     {
     originXForThumbnail = 0.0;
     self.thumbnailCollectionView.frame = CGRectMake(originXForThumbnail, self.pdfView.bounds.size.height-65, self.pdfView.frame.size.width, 50.0);
     }
     else
     self.thumbnailCollectionView.frame = CGRectMake(originXForThumbnail, self.pdfView.bounds.size.height-65, widthOfThumbnails, 50.0);*/
    
    //5 redraw
    
    [self.thumbnailCollectionView performBatchUpdates:^{
        [self.thumbnailCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        //[self.thumbnailCollectionView reloadData];
    } completion:nil];
    
    //[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}




-(void)setupCollectionView
{
    //UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    //self.thumbnailCollectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    //[self.thumbnailCollectionView setDataSource:[self.datasource copy]];
    //[self.thumbnailCollectionView setDelegate:self];
    self.thumbnailCollectionView.delegate = self;
    self.thumbnailCollectionView.dataSource = self;
    
}

#pragma mark - Photo insertion



#pragma mark - ActionSheet and Document Interaction


#pragma mark - IDEAS
//can we convert a DOC/DOCx into PDF and then use the PDFController to annotate word document by using CGPDFDocumentCreateWithProvider
//Done

#pragma mark - BUGS
//WEBPAge and EXcel need to be added to complete
//1. Array bounds needs a thorough check - CRITICAL
//2. ALL PPTS are not scaled well - NOT! done,  unable to pin point a problem
//Reason for the problem - careful use of webview is required. If webview object is passed to multiple objects, trouble brews
//6. Swipe leaves lines behind. When in edit mode, all of them shows up
//9. tableview is displayed in the wrong location, at the bottom of the view for IOS5.0 IOS 6, it works well
//   dump of tableView - thumbnailCollectionView: 0x9a8d600; baseClass = UITableView; frame = (0 1006; 768 196); transform = [0, -1, 1, 0, 0, 0]; clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x12036fb0>; contentOffset: {0, 0}>
//14. Stray lines are coming during readonly mode - FIXED for now, need to check randomly to make sure it is removed completely
//16. State of drawing shapes reset to line for every page turn operation
//17. PAritally FIXED: Controlview hiding and show has issues - Still has some issues,but not show stopper
//18. Bezier lines are not selected on touch - NEXT Version

//4. NOT FIXED: HTML style is not rendered properly. It might be due to htmlLoading in webView.
#pragma mark -  FIXED BUGS

//3. FIXED: readonly button should be brought back when necessary. Now hides - ALWAYS ON - done partially


//5. FIXED - Swipe gesture PPT works. PDF does not work - DONE
//7. FIXED -  PDF Annotation not shown in PDF - CRITICAL - partially DONE - Done;
//8. FIXED : In readOnly mode, shapes drawn do not go away -

//10. FIXED: Display dirtied PDF pages brings only the  last page viewed. Identified the problem - Global page number used. Need to localize

//11. FIXED - The shapes drawn also should appear in the thumbnail - DrawShape before capturing the image was the problem

//12. FIXED: First page of PDF file is shown as empty - DONE. The pagenumber in getPDFInfo in class PDFView was 0. PDF pagenumber starts with 1

//13. FIXED: PDFView edit mode and read mode corrupted :)
//15. FIXED: PDFs with landscape mode is not addressed well. Height is defaulting to device height - CRITICAL - ALL PPT converted to PDF is the example - DONE
//19. FIXED: increase the linewith for deault to 5 or any size that is easily touchable


//20. FIXED:Draw a shape in edit mode and press read mode, the shape goes away. It should be saved

//21. FIXED:When all shapes are deleted, the page should be removed
//22. FIXED:When loading from storage - on this instruction, UIView starts the view
//            //9. get the image of the modified page - IMAGE does not CAPTURE SHAPES
//            //thumbnailImage = [self getImageFromView:self.view forFrameSize:self.notesView.frame];
//23. FIXED Not able to select highlighted line - FIXED
//FIXED On single touch, the selected object is not removed

//FIXED:Confusing UI Trash can and delete button - removed the trash button, using context cut copy paste to be consistent with iOS

//Clicking forward or backward after making the change in the page does not reflect in the changed page list

//FIXED:CopyPaste wiggly line - storing it in the database, but not showing up
//Wiggly line transform - moves too slowly with the cursor
//FIXED:BUG:Select a shape, go to library and come back, application crashes
//FIXED:Trash icon is not enabled when there are more items in the page. This happens when coming from Library to doc

//Selection is still considering a large rectangle

//Thumbnailview and pagenagigation bar - toggle on/off not working
//copy paste a line - copies only in one orientation
//FIXED:Not showing the annotations of the first page when opening..
//inceasing the font size of the font increases the size of the contained rectangle in an inproportional way

#pragma mark - TODO V4.0

//Single tap to toggle on/off thumbnail and page navigation toolbar
//shape properties window becomes small when the object is closer to bottom
//Selection of drawing object
//drawing circle/rectangle - from high coordinate point to low, does not draw as intended
//Good idea to separate Font and color proprtties?

@end
