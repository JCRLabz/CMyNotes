//
//  DrawingController.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@class ShapeObject;
@class JCRPDFView;
@class PPTView;


#import "ColorToolViewController.h"
#import "ShapesViewController.h"
#import "PPTController.h"
#import "JCRPDFView.h"
#import "DocumentController.h"
#import "PPTView.h"
#import "WORDController.h"
#import "FontPropertiesViewController.h"
#import <WebKit/WebKit.h>

#import "Social/Social.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TextEditor.h"
#import <MessageUI/MessageUI.h>
#import "ThumbnailCollectionView.h"

//#import "XLSController.h"
//#import "XLSView.h"
//#import "XLSDrawingView.h"

@protocol CMyNotesControllerViewDelegate <NSObject>
-(void) dismissController;
@end

@interface DrawingController : UIViewController<UITextViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property int xlsSheetCount;
@property (strong, nonatomic) NSArray *xlsSheets;
@property (strong, nonatomic) NSArray *xlsSheetNames;

@property (strong, nonatomic) NSArray *pptSlides;


@property (strong, atomic) ShapeObject *currentShape;
@property (strong, atomic) ShapeObject *cutCopyShape;
@property (strong, nonatomic) UIColor *currentColor;
@property (strong, nonatomic) UIFont *currentFont;
@property (strong, nonatomic) NSTimer* timer;


@property CGPoint currentTappedLocation;


@property (strong, nonatomic) NSMutableArray *shapes;

@property (strong, nonatomic) DocumentController *document;


@property (weak, nonatomic) IBOutlet JCRPDFView *jCRPDFView;

@property (weak, nonatomic) IBOutlet UICollectionView *thumbnailCollectionView;

@property (strong, nonatomic) IBOutletCollection(UICollectionView) NSArray *collectionViewTN;

@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeDown;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRight;

//@property (strong, nonatomic) UIPopoverController *colorPopover;
@property (nonatomic, strong) NSAttributedString *currentText;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *deletedShapes;
//@property (nonatomic, strong) UIPopoverController *toolPopoverController;
@property (nonatomic, strong) ColorToolViewController  *colorToolViewController;
@property (nonatomic, strong) FontPropertiesViewController  *fontPropertiesViewController;
@property (strong, nonatomic) UITextView *textView;

@property (nonatomic, strong) UIView *pageUp, *pageDown;
@property (nonatomic, strong) NSString *html;

@property (nonatomic, strong) NSDate *documentTimestamp;
@property (nonatomic ,strong) NSString *documentName;
@property (nonatomic ,strong) NSString *documentURL;
@property (nonatomic, strong) NSString *applicationSupportURL;
@property (nonatomic, strong) NSData *pageData;
@property  int documentType;

@property (nonatomic, strong) ShapesViewController *shapesViewController;
//@property (nonatomic, strong) UIPopoverController *shapesPopoverController;


@property (nonatomic, strong) UIAlertController *deleteActionSheet;
@property (nonatomic, strong) UIAlertController *socialActionSheet;

@property (nonatomic, strong) NSMutableArray *filesToDelete;
@property ShapeType lastSelectedShape;

@property float lineWidth;
@property BOOL undoOperation;
@property float currentAlpha;
@property float currentBrushSize;
@property int textBoxCount;
@property BOOL changingSize;
@property BOOL rotateShape;
@property NSRange textSelectionRange;
@property BOOL newShape;
@property BOOL backgroundColorChangeRequested;
@property BOOL zoomOperation;
@property (strong, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationGesture;
//- (IBAction)rotationAction:(id)sender;


@property (nonatomic,strong ) NSMutableArray *datasource;

//@property CGSize sizeOfNotesView;
@property int pageNumber;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;

@property BOOL shapeObjectChanged;//shape changed or added a new shape
//@property UIBezierPath *path;
@property (weak, nonatomic) IBOutlet UIButton *shapeButton;
@property (weak, nonatomic) IBOutlet UIButton *previousPageButton;
@property (weak, nonatomic) IBOutlet UIButton *nextPageButton;


- (IBAction)colorTool:(id)sender;
- (IBAction)eraserButtonClicked:(id)sender;
- (IBAction)clearDrawingPad:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)chooseHighlighter:(id)sender;
- (IBAction)textButtonClicked:(id)sender;
- (IBAction)undo:(id)sender;

- (IBAction)nextPage:(id)sender;
- (IBAction)previousPage:(id)sender;

@property (unsafe_unretained, nonatomic) IBOutlet UISlider *pageSlider;
- (IBAction)pageSliderMoved:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
//@property (nonatomic,strong) IMBanner *banner;
//@property (nonatomic, strong) NSDate *adDate;

//for Facebook Ad


-(void)initWithCoreData:(id)object;

+(DocumentType)getDocumentType:(NSString *)url;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);


@end
