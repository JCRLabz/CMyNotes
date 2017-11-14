//
//  ShapesViewController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/23/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "ShapesViewController.h"
#import "ColorToolViewController.h"
#import "ShapeObject.h"
#import "Utility.h"

static uint _currentShape = kLine;

@interface ShapesViewController ()

@end

@implementation ShapesViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //get the current color and fill it
    UIColor *currentColor = [ColorToolViewController getCurrentColor];
    _lineButton.backgroundColor = currentColor;
    _circleButton.backgroundColor = currentColor;
    _rectButton.backgroundColor = currentColor;
    //self.wigglyLine.backgroundColor = currentColor;
    //_hilighterButton.backgroundColor = currentColor;
    
    //draw a line on the botton
    [self drawShape:kLine color:currentColor];
    
    /*ShapeButton *lineButton = [[ShapeButton alloc] initWithFrame:(CGRect){14,20,60,60}];
     [lineButton drawButton:kLine bounds:(CGRect){20,20,60,60} color:currentColor];*/
    
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        self.cameraButton.enabled = NO;
    }
    
    
    [self drawShape:kRectangle color:currentColor];
    [self drawShape:kCircle color:currentColor];
    [self drawShape:kArrow color:currentColor];
    [self drawPencil:currentColor];
    [self drawHilighter:currentColor];
    [self drawText:kText color:currentColor];
    [self drawShape:kCamera color:currentColor];
    [self drawShape:kPhoto color:currentColor];
    
    [self.rectButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.lineButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.arrowButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.circleButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.wigglyLine setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.textButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.hilighterButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.cameraButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    [self.photoButton setBackgroundImage:[self imageWithColor:currentColor] forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shapeTouched:)];
    [self.shapesHostView addGestureRecognizer:recognizer];
    [super viewDidLoad];
}

-(void)shapeTouched:(UITapGestureRecognizer *)recognizer
{
    if (!CGRectContainsPoint(CGRectUnion(self.lineButton.frame, self.closeReadingButton.frame), [recognizer locationInView:self.view]))
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)drawShape:(ShapeType)type color:(UIColor *)color
{
    UIBezierPath * bzPath = [[UIBezierPath alloc]  init];
    
    if ( type == kLine )
    {
        [bzPath moveToPoint:CGPointMake(self.lineButton.bounds.origin.x, self.lineButton.bounds.origin.y+30)];
        [bzPath addLineToPoint:CGPointMake(self.lineButton.bounds.origin.x+60, self.lineButton.bounds.origin.y+30)];
        
        self.lineButton.backgroundColor = [UIColor clearColor];
        self.lineButton.opaque = YES;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.lineButton.frame;
        shapeLayer.path = bzPath.CGPath;
        shapeLayer.opaque = NO;
        shapeLayer.strokeColor = color.CGColor;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        shapeLayer.lineWidth = 2;
        [self.shapesHostView.layer addSublayer:shapeLayer];
    }
    
    else if ( type == kRectangle )
    {
        CGRect rect = (CGRect){self.rectButton.bounds.origin.x+8,self.rectButton.bounds.origin.y+8,44,44};
        bzPath = [UIBezierPath bezierPathWithRect:rect];
        self.rectButton.backgroundColor = [UIColor clearColor];
        self.rectButton.opaque = YES;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.rectButton.frame;
        shapeLayer.path = bzPath.CGPath;
        shapeLayer.opaque = NO;
        shapeLayer.strokeColor = color.CGColor;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        shapeLayer.lineWidth = 2;
        [self.shapesHostView.layer addSublayer:shapeLayer];
    }
    
    
    else if ( type == kCircle)
    {
        CGRect rect = (CGRect){self.circleButton.bounds.origin.x+2,self.circleButton.bounds.origin.y+2,55,55};//self.lineButton.bounds;
        bzPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        self.circleButton.backgroundColor = [UIColor clearColor];
        self.circleButton.opaque = YES;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.circleButton.frame;
        shapeLayer.path = bzPath.CGPath;
        shapeLayer.opaque = NO;
        shapeLayer.strokeColor = color.CGColor;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        shapeLayer.lineWidth = 2;
        [self.shapesHostView.layer addSublayer:shapeLayer];
    }
    else if ( type == kArrow )
    {
        self.arrowButton.tintColor = [UIColor whiteColor];
        self.arrowButton.titleLabel.text = @"2";
        [self drawArrow:color];
    }
    else if ( type == kFreeform)
    {
        self.wigglyLine.tintColor = color;
        _wigglyLine.backgroundColor = [UIColor clearColor];
        self.wigglyLine.opaque = YES;
    }
    
    
    else if ( type == kCamera)
    {
        [self drawCameraIcon:color];
    }
    else if ( type == kPhoto)
    {
        [self drawPhotoIcon:color];
    }
    
}


-(UIImage *)drawArrowImage:(int)type
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(imageView.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    // translate matrix so that path will be centered in bounds
    UIBezierPath * bzPath;// = [[UIBezierPath alloc]  init];
    if ( type == kArrow)
    {
        imageView.frame = CGRectMake(0, 0, 60, 16);
        bzPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 45, 6)];
        //draw head
        [bzPath moveToPoint:CGPointMake(45, 0)];
        [bzPath addLineToPoint:CGPointMake(45, 16)];
        [bzPath addLineToPoint:CGPointMake(60, 8)];
        //[bzPath addLineToPoint:CGPointMake(45, 0)];
        [bzPath closePath];
    }
    else
    {
        imageView.frame = CGRectMake(0, 0, 60, 16);
        bzPath = [UIBezierPath bezierPathWithRect:CGRectMake(5, 5, 40, 6)];
        //draw head
        [bzPath moveToPoint:CGPointMake(45, 0)];
        [bzPath addLineToPoint:CGPointMake(45, 16)];
        [bzPath addLineToPoint:CGPointMake(60, 8)];
        [bzPath closePath];
        [bzPath moveToPoint:CGPointMake(15, 0)];
        [bzPath addLineToPoint:CGPointMake(15, 16)];
        [bzPath addLineToPoint:CGPointMake(0, 8)];
        [bzPath closePath];
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = imageView.frame;
    shapeLayer.path = bzPath.CGPath;
    shapeLayer.opaque = NO;
    shapeLayer.strokeColor = [Utility CMYNColorDarkBlue].CGColor;
    shapeLayer.fillColor = [Utility CMYNColorDarkBlue].CGColor;
    [bzPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.9];
    [bzPath fillWithBlendMode:kCGBlendModeNormal alpha:0.9];
    [imageView.layer addSublayer:shapeLayer];
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

-(UIImage*)drawCloseReadingSymbols:(NSString *)symbol
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 22)];

    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(imageView.frame.size, NO, [[UIScreen mainScreen] scale]);
    NSDictionary *attribs = @{ NSFontAttributeName:[UIFont systemFontOfSize:20 weight:2.0] };

    //NSDictionary *attr = [NSDictionary dictionaryWithObject:attribs forKey:NSParagraphStyleAttributeName];
    
    [symbol drawInRect:CGRectMake(0, 0, 60, 22) withAttributes:attribs];
    // configure the view to render in the graphics context
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
}

-(void)drawArrow:(UIColor*)color
{
    UIBezierPath * bzPath;// = [[UIBezierPath alloc]  init];
    
    bzPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.arrowButton.bounds.origin.x, self.arrowButton.bounds.origin.y+30, 45, 5)];
    //draw head
    [bzPath moveToPoint:CGPointMake(45, self.arrowButton.bounds.size.height/2-5)];
    [bzPath addLineToPoint:CGPointMake(45, self.arrowButton.bounds.size.height/2+10)];
    [bzPath addLineToPoint:CGPointMake(60, self.arrowButton.bounds.size.height/2+2.5)];
    [bzPath addLineToPoint:CGPointMake(45, self.arrowButton.bounds.size.height/2-5)];
    [bzPath closePath];
    
    self.arrowButton.backgroundColor = [UIColor clearColor];
    self.arrowButton.opaque = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.arrowButton.frame;
    shapeLayer.path = bzPath.CGPath;
    shapeLayer.opaque = NO;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [color CGColor];
    //shapeLayer.lineWidth = 5;
    [self.shapesHostView.layer addSublayer:shapeLayer];
}

-(void)drawText:(ShapeType)type color:(UIColor* )color
{
    if ( type == kText)
        [self.textButton setAttributedTitle:[self getAttributedString:@"T" color:color] forState:UIControlStateNormal];
}

-(NSAttributedString *)getAttributedString:(NSString *)text color:(UIColor* )color
{
    
    NSAttributedString *logoText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino-Roman" size:60.0],  NSForegroundColorAttributeName:color, NSBaselineOffsetAttributeName:@-5}]  ;
    return logoText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setRectButton:nil];
    [self setCircleButton:nil];
    [self setLineButton:nil];
    [self setWigglyLine:nil];
    [super viewDidUnload];
}

- (IBAction)rectSelected:(id)sender
{
    _currentShape = kRectangle;
    [self broadcastShapeChangedMessage ];
}

- (IBAction)circleSelected:(id)sender
{
    _currentShape = kCircle;
    [self broadcastShapeChangedMessage ];
    
}

- (IBAction)lineSelected:(id)sender
{
    _currentShape = kLine;
    
    [self broadcastShapeChangedMessage ];
    
}

- (IBAction)wigglyLineSelected:(id)sender
{
    _currentShape = kFreeform;
    [self broadcastShapeChangedMessage ];
    
    
}

- (IBAction)textSelected:(id)sender
{
    _currentShape = kText;
    [self broadcastShapeChangedMessage ];
    
    
}

- (IBAction)hilighterSelected:(id)sender
{
    _currentShape = kHighlighter;
    [self broadcastShapeChangedMessage ];
}

- (IBAction)rectButtonTouchedDown:(id)sender
{
    //draw color halos
    
}

- (IBAction)drawAutoShapeAction:(id)sender
{
    if ( !self.drawshapeAuto.isOn)
    {
        self.drawShapeAutoLabel.text = @"Use pan gesture to draw the shape";
    }
    else
    {
        self.drawShapeAutoLabel.text = @"Let CMyNotes draw default shapes on selection";
    }
}

- (IBAction)insertURL:(id)sender
{
    _currentShape = kURL;
    [self broadcastShapeChangedMessage ];
    
}

- (IBAction)arrowSelected:(id)sender
{
    _currentShape = kArrow;
    
    //create alert action
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *singleHeadedArrow;
    //[alertController.view sizeToFit];
    //[alertController setPreferredContentSize:CGSizeMake(200, 150)];
    singleHeadedArrow = [UIAlertAction actionWithTitle:@"Single Headed Arrow"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   _currentShape = kArrow;
                                                   [self broadcastShapeChangedMessage ];
                                               }];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[self drawArrowImage:kArrow]];
    
    [singleHeadedArrow setValue:[self drawArrowImage:kArrow] forKey:@"image"];
    //[alertController.view addSubview:imageView];
    [alertController addAction:singleHeadedArrow];
    
    UIAlertAction *doubleHeadedArrow;
    doubleHeadedArrow = [UIAlertAction actionWithTitle:@"Double Headed Arrow"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   _currentShape = kDoubleHeadedArrow;
                                                   [self broadcastShapeChangedMessage ];
                                               }];
    //imageView = [[UIImageView alloc] initWithImage:[self drawArrowImage:kDoubleHeadedArrow]];
    //[alertController.view addSubview:imageView];
    [doubleHeadedArrow setValue:[self drawArrowImage:kDoubleHeadedArrow] forKey:@"image"];
    
    [alertController addAction:doubleHeadedArrow];
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [alertController addAction:cancel];
    }

    alertController.popoverPresentationController.backgroundColor = [Utility CMYNColorLightYellow];
    //UIView *view = alertController.view.subviews.firstObject;
    //view.backgroundColor = [Utility CMYNColorLightYellow];
    [alertController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionRight];

    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    [alertController.popoverPresentationController setSourceView:sender];

//    UIView *senderView = (UIView*)sender;
//    [alertController.popoverPresentationController setSourceRect:senderView.bounds];

    [self presentViewController:alertController animated:YES
                     completion:nil];
    
    
}


- (IBAction)closeReadingSelected:(id)sender
{
    _currentShape = kCloseReading;
    
    //create alert action
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *heart;;
    heart = [UIAlertAction actionWithTitle:@"Like it/Love it"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       _currentShape = kHeart;
                                       [self broadcastShapeChangedMessage ];
                                   }];
    [alertController addAction:heart];
    [heart setValue:[self drawCloseReadingSymbols:@"\u2665"] forKey:@"image"];
    UIAlertAction *star;
    star = [UIAlertAction actionWithTitle:@"Interesting"
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      _currentShape = kStar;
                                      [self broadcastShapeChangedMessage ];
                                  }];
    [alertController addAction:star];
    [star setValue:[self drawCloseReadingSymbols:@"\u2605"] forKey:@"image"];
    
    UIAlertAction *qMark;
    qMark = [UIAlertAction actionWithTitle:@"Question/Confusing"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       _currentShape = kQuestionMark;
                                       [self broadcastShapeChangedMessage ];
                                   }];
    [alertController addAction:qMark];
    [qMark setValue:[self drawCloseReadingSymbols:@"\u2753"] forKey:@"image"];
    UIAlertAction *checkMark;
    checkMark = [UIAlertAction actionWithTitle:@"Correct/Confirm"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           _currentShape = kCheckMark;
                                           [self broadcastShapeChangedMessage ];
                                       }];
    [alertController addAction:checkMark];
    [checkMark setValue:[self drawCloseReadingSymbols:@"\u2714"] forKey:@"image"];
    UIAlertAction *exclamationMark;
    exclamationMark = [UIAlertAction actionWithTitle:@"Surprising"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 _currentShape = kExclamationMark;
                                                 [self broadcastShapeChangedMessage ];
                                             }];
    [alertController addAction:exclamationMark];
    [exclamationMark setValue:[self drawCloseReadingSymbols:@"\u2757"] forKey:@"image"];
    UIAlertAction *xMark;
    xMark = [UIAlertAction actionWithTitle:@"Wrong"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       _currentShape = kXMark;
                                       [self broadcastShapeChangedMessage ];
                                   }];
    [alertController addAction:xMark];
    [xMark setValue:[self drawCloseReadingSymbols:@"\u2715"] forKey:@"image"];
    UIAlertAction *evidence;
    evidence = [UIAlertAction actionWithTitle:@"Evidence"
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
                                          _currentShape = kEvidence;
                                          [self broadcastShapeChangedMessage ];
                                      }];
    [alertController addAction:evidence];
    [evidence setValue:[self drawCloseReadingSymbols:@"\u24BA"] forKey:@"image"];
    UIAlertAction *connection;
    connection = [UIAlertAction actionWithTitle:@"I have a Connection"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            _currentShape = kConnection;
                                            [self broadcastShapeChangedMessage ];
                                        }];
    [alertController addAction:connection];
    [connection setValue:[self drawCloseReadingSymbols:@"\u221E"] forKey:@"image"];
    
    
    UIAlertAction *agree;
    agree = [UIAlertAction actionWithTitle:@"Agree"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       _currentShape = kAgree;
                                       [self broadcastShapeChangedMessage ];
                                   }];
    [alertController addAction:agree];
    [agree setValue:[self drawCloseReadingSymbols:@"\u271A"] forKey:@"image"];
    
    UIAlertAction *disAgree;
    disAgree = [UIAlertAction actionWithTitle:@"Disagree"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       _currentShape = kDisAgree;
                                       [self broadcastShapeChangedMessage ];
                                   }];
    [alertController addAction:disAgree];
    [disAgree setValue:[self drawCloseReadingSymbols:@"\u2796"] forKey:@"image"];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [alertController addAction:cancel];
    }

    alertController.popoverPresentationController.backgroundColor = [Utility CMYNColorLightYellow];
    //UIView *view = alertController.view.subviews.firstObject;
    //view.backgroundColor = [Utility CMYNColorLightYellow];

    [alertController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionRight];

    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    [alertController.popoverPresentationController setSourceView:sender];

    //UIView *senderView = (UIView*)sender;
    //[alertController.popoverPresentationController setSourceRect:senderView.bounds];

    [self presentViewController:alertController animated:YES
                     completion:nil];
    
}

- (IBAction)insertCameraShotOrPhoto:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    //[picker setDelegate:self.view.con];
    // Don't forget to add UIImagePickerControllerDelegate in your .h
    //picker.delegate = self;
    
    if((UIButton *) sender == self.cameraButton)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //_currentShape = kCamera;
    }
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
    }
    _currentShape = kPhoto;
    
    [picker setDelegate:self];
    
    [self presentViewController:picker animated:YES completion:NULL];
    //[self broadcastShapeChangedMessage ];
}



- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = self.lineButton.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    /*if ( _currentShape == kFreeform || _currentShape == kHighlighter)
    {
        CGContextSetFillColorWithColor(context, [color colorWithAlphaComponent:0.4].CGColor);
    }
    else*/
        CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetFillColorWithColor(context, [color colorWithAlphaComponent:0.4].CGColor);

    CGContextFillEllipseInRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeScreen);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)broadcastShapeChangedMessage
{
    //broadcast that the color selection changed
    NSMutableDictionary *shapeInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:_currentShape] forKey:@"ShapeSelectionChanged"];
    [shapeInfo setObject:[NSDate date] forKey:@"ShapeSelectionTime"];
    if ( _currentShape == kCamera || _currentShape == kPhoto)
    {
        [shapeInfo setObject:self.image forKey:@"ShapeImage"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ShapeSelectionChanged" object:self userInfo: shapeInfo];
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


+(uint)getCurrentShape
{
    return _currentShape;
}

-(void)drawPencil:(UIColor* )color
{
    UIBezierPath * bzPath;// = [[UIBezierPath alloc]  init];
    CGRect rect = CGRectMake(self.wigglyLine.frame.origin.x + 40.0,self.wigglyLine.frame.origin.y + 14.0, 4.0, 4.0);
    bzPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    //draw the tip of the pencil
    UIBezierPath *tipPath = [[UIBezierPath alloc] init];;
    [tipPath moveToPoint:CGPointMake(self.wigglyLine.frame.origin.x+4.0, self.wigglyLine.frame.origin.y+55.5)];
    [tipPath addLineToPoint:CGPointMake(self.wigglyLine.frame.origin.x+5.9, self.wigglyLine.frame.origin.y+50.5)];
    [tipPath addLineToPoint:CGPointMake(self.wigglyLine.frame.origin.x+9.0, self.wigglyLine.frame.origin.y+54.0)];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(3.5,-3.5);
    [tipPath applyTransform:transform];
    
    [bzPath appendPath:tipPath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.wigglyLine.bounds;
    shapeLayer.path = bzPath.CGPath;
    shapeLayer.fillColor = color.CGColor;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.lineWidth = 1;
    //self.wigglyLine.backgroundColor = color;
    [self.shapesHostView.layer addSublayer:shapeLayer];
    
    //self.wigglyLine.backgroundColor = [UIColor clearColor];
}


-(void)drawHilighter:(UIColor* )color
{
    
    UIBezierPath * bzPath;// = [[UIBezierPath alloc]  init];
    CGRect rect = CGRectMake(46.0, 11.0, 4.0, 4.0);//49,6,5,5
    bzPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    UIBezierPath *tipPath = [[UIBezierPath alloc] init];;
    [tipPath moveToPoint:CGPointMake(2.0, 54.0)];
    [tipPath addLineToPoint:CGPointMake(6.0, 49.0)];
    [tipPath addLineToPoint:CGPointMake(11.5, 53.9)];
    [tipPath addLineToPoint:CGPointMake(8.0, 57.0)];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(3.5,-3.5);
    
    [tipPath applyTransform:transform];
    
    [bzPath appendPath:tipPath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.hilighterButton.bounds;
    shapeLayer.path = bzPath.CGPath;
    shapeLayer.fillColor = color.CGColor;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.lineJoin = kCALineJoinRound;
    
    
    [self.hilighterButton.layer addSublayer:shapeLayer];
    //self.hilighterButton.backgroundColor = [UIColor clearColor];
}

-(void)drawCameraIcon:(UIColor*)color
{
    if ( !self.cameraButton.enabled)
    {
        color = [UIColor grayColor];
        NSAttributedString *logoText = [[NSMutableAttributedString alloc] initWithString:@"JCR" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino-Roman" size:7.0],  NSForegroundColorAttributeName:[UIColor grayColor]}]  ;
        
        [self.cameraButton setAttributedTitle:logoText forState:UIControlStateNormal];
    }
    else
    {
        color = [UIColor blackColor];
        NSAttributedString *logoText = [[NSMutableAttributedString alloc] initWithString:@"JCR" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino-Roman" size:7.0],  NSForegroundColorAttributeName:[Utility CMYNColorRed1]}]  ;
        
        [self.cameraButton setAttributedTitle:logoText forState:UIControlStateNormal];
    }
    CGPoint origin = CGPointMake(self.cameraButton.bounds.origin.x, self.cameraButton.bounds.origin.y+15);//CGPointMake(55,156);
    //CGRect rect = (CGRect){24,176,40,20};//self.lineButton.bounds;
    CGRect rect = (CGRect){origin.x,origin.y,60,30};//self.lineButton.bounds;
    UIBezierPath * bzPath;// = [[UIBezierPath alloc]  init];
    
    bzPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 2.0)];
    //[[UIColor redColor] setStroke];
    //[[UIColor redColor] setFill];
    self.cameraButton.backgroundColor = [UIColor clearColor];
    self.cameraButton.opaque = YES;
    
    //lens
    UIBezierPath *lens;// = [[UIBezierPath alloc] init];
    
    //[bzPath appendPath:lens];
    rect = (CGRect){origin.x+20,origin.y+5,20,20};
    lens = [UIBezierPath bezierPathWithOvalInRect:rect];
    [bzPath appendPath:lens];
    
    rect = (CGRect){origin.x+21,origin.y+6,18,18};
    lens = [UIBezierPath bezierPathWithOvalInRect:rect];
    [bzPath appendPath:lens];
    
    /*rect = (CGRect){origin.x+22,origin.y+7,16,16};
     lens = [UIBezierPath bezierPathWithOvalInRect:rect];
     [bzPath appendPath:lens];
     
     rect = (CGRect){origin.x+26,origin.y+11,8,8};//43
     lens = [UIBezierPath bezierPathWithOvalInRect:rect];
     [bzPath appendPath:lens];*/
    
    //sensor
    rect = (CGRect){origin.x+16,origin.y+9,2,2};
    lens = [UIBezierPath bezierPathWithOvalInRect:rect];
    [bzPath appendPath:lens];
    
    //flash
    UIBezierPath *flashRect;// = [[UIBezierPath alloc] init];
    rect = (CGRect){origin.x+42,origin.y-6,14,6};
    flashRect = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0.25, 0.25)];
    [bzPath appendPath:flashRect];
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.cameraButton.bounds;
    shapeLayer.path = bzPath.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = 2.0;
    
    //shapeLayer.lineWidth = 0.75;
    //
    //    //Add text
    //    CATextLayer *label = [[CATextLayer alloc] init];
    //    rect = (CGRect){origin.x+5,origin.y+19,55,15};
    //
    //    [label setFontSize:6];
    //    [label setFrame:rect];
    //    [label setString:@"JCR"];
    //    [label setAlignmentMode:kCAAlignmentLeft];
    //    [label setForegroundColor:[color CGColor]];
    
    [self.cameraButton.layer addSublayer:shapeLayer];
}

-(void)drawPhotoIcon:(UIColor *)color
{
    if ( !self.photoButton.enabled)
    {
        //color = [UIColor grayColor];
    }
    
    NSMutableArray *colorTable = [NSMutableArray array];
    
    [colorTable addObject:[Utility CMYNColorDarkBlue]];
    [colorTable addObject:[Utility CMYNColorDarkOrange]];
    [colorTable addObject:[Utility CMYNColorGreen]];
    [colorTable addObject:[Utility CMYNColorRed1]];
    
    for (int i = 0; i < 4 ; i++)
    {
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIColor *color = [colorTable objectAtIndex:i];
        
        layer.backgroundColor = color.CGColor;
        int column = i % 2;
        int row = i / 2;
        CGRect rect = CGRectMake(self.photoButton.bounds.origin.x + (column * 12)+12, self.photoButton.bounds.origin.y + (row * 12)+12, 26, 26);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect  cornerRadius:9];
        layer.path = path.CGPath;
        layer.fillColor = color.CGColor;
        layer.opacity = 0.80;
        [self.photoButton.layer addSublayer:layer];
    }
}

/*
 ARROW CODE
 //// Bezier Drawing
 UIBezierPath* bezierPath = UIBezierPath.bezierPath;
 [bezierPath moveToPoint: CGPointMake(49.5, 53.5)];
 [bezierPath addLineToPoint: CGPointMake(129.5, 53.5)];
 [bezierPath addLineToPoint: CGPointMake(129.5, 39.5)];
 [bezierPath addLineToPoint: CGPointMake(146.5, 56.5)];
 [bezierPath addLineToPoint: CGPointMake(129.5, 73.5)];
 [bezierPath addLineToPoint: CGPointMake(129.5, 60.5)];
 [bezierPath addLineToPoint: CGPointMake(49.5, 60.5)];
 [bezierPath addLineToPoint: CGPointMake(49.5, 53.5)];
 [bezierPath closePath];
 [UIColor.grayColor setFill];
 [bezierPath fill];
 [UIColor.blackColor setStroke];
 bezierPath.lineWidth = 1;
 [bezierPath stroke];
 
 
 /// Star Drawing
 UIBezierPath* starPath = UIBezierPath.bezierPath;
 [starPath moveToPoint: CGPointMake(58.5, 29)];
 [starPath addLineToPoint: CGPointMake(65.38, 39.03)];
 [starPath addLineToPoint: CGPointMake(77.05, 42.47)];
 [starPath addLineToPoint: CGPointMake(69.63, 52.12)];
 [starPath addLineToPoint: CGPointMake(69.96, 64.28)];
 [starPath addLineToPoint: CGPointMake(58.5, 60.2)];
 [starPath addLineToPoint: CGPointMake(47.04, 64.28)];
 [starPath addLineToPoint: CGPointMake(47.37, 52.12)];
 [starPath addLineToPoint: CGPointMake(39.95, 42.47)];
 [starPath addLineToPoint: CGPointMake(51.62, 39.03)];
 [starPath closePath];
 [UIColor.grayColor setFill];
 [starPath fill];
 
 
 - (void)drawClockPlaygroundWithNumbersColor: (UIColor*)numbersColor darkHandsColor: (UIColor*)darkHandsColor lightHandColor: (UIColor*)lightHandColor rimColor: (UIColor*)rimColor tickColor: (UIColor*)tickColor faceColor: (UIColor*)faceColor
 {
 //// General Declarations
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 //// Color Declarations
 UIColor* color = [UIColor colorWithRed: 1 green: 0 blue: 0 alpha: 1];
 UIColor* color2 = [UIColor colorWithRed: 0.219 green: 0.373 blue: 0.457 alpha: 1];
 UIColor* color3 = [UIColor colorWithRed: 0.29 green: 0.29 blue: 0.29 alpha: 1];
 UIColor* color4 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
 UIColor* color5 = [UIColor colorWithRed: 0.086 green: 0.846 blue: 0.85 alpha: 1];
 
 //// Symbol Drawing
 CGRect symbolRect = CGRectMake(90, 30, 258, 258);
 CGContextSaveGState(context);
 UIRectClip(symbolRect);
 CGContextTranslateCTM(context, symbolRect.origin.x, symbolRect.origin.y);
 CGContextScaleCTM(context, symbolRect.size.width / 260, symbolRect.size.height / 260);
 
 [StyleKitName drawClockWithNumbersColor: color5 darkHandsColor: color2 lightHandColor: color rimColor: color2 tickColor: tickColor faceColor: faceColor hours: 11 minutes: 45 seconds: 39];
 CGContextRestoreGState(context);
 
 
 //// Symbol 2 Drawing
 CGRect symbol2Rect = CGRectMake(348, 33, 253, 253);
 CGContextSaveGState(context);
 UIRectClip(symbol2Rect);
 CGContextTranslateCTM(context, symbol2Rect.origin.x, symbol2Rect.origin.y);
 CGContextScaleCTM(context, symbol2Rect.size.width / 260, symbol2Rect.size.height / 260);
 
 [StyleKitName drawClockWithNumbersColor: numbersColor darkHandsColor: darkHandsColor lightHandColor: lightHandColor rimColor: rimColor tickColor: tickColor faceColor: faceColor hours: 7 minutes: 43 seconds: 3];
 CGContextRestoreGState(context);
 
 
 //// Symbol 3 Drawing
 CGRect symbol3Rect = CGRectMake(611, 33, 260, 260);
 CGContextSaveGState(context);
 UIRectClip(symbol3Rect);
 CGContextTranslateCTM(context, symbol3Rect.origin.x, symbol3Rect.origin.y);
 
 [StyleKitName drawClockWithNumbersColor: color4 darkHandsColor: color4 lightHandColor: color5 rimColor: color4 tickColor: color4 faceColor: color3 hours: 16 minutes: 6 seconds: 43];
 CGContextRestoreGState(context);
 }
 */

//picker for image
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self broadcastShapeChangedMessage ];
}



- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
