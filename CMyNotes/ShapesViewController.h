//
//  ShapesViewController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/23/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface ShapesViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *lineButton;
@property (weak, nonatomic) IBOutlet UIButton *circleButton;
@property (weak, nonatomic) IBOutlet UIButton *rectButton;

@property (weak, nonatomic) IBOutlet UIButton *wigglyLine;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *hilighterButton;
@property (weak, nonatomic) IBOutlet UISwitch *drawshapeAuto;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton;

@property (weak, nonatomic) IBOutlet UIButton *closeReadingButton;

@property (weak, nonatomic) IBOutlet UIView *shapesHostView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *insertURLButton;
@property (weak, nonatomic) IBOutlet UILabel *drawShapeAutoLabel;
//@property BOOL displayCloseReadingWindow;

- (IBAction)done:(id)sender;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *assetFileName;

- (IBAction)rectSelected:(id)sender;
- (IBAction)circleSelected:(id)sender;
- (IBAction)lineSelected:(id)sender;
- (IBAction)wigglyLineSelected:(id)sender;
- (IBAction)textSelected:(id)sender;
- (IBAction)hilighterSelected:(id)sender;
- (IBAction)rectButtonTouchedDown:(id)sender;
- (IBAction)drawAutoShapeAction:(id)sender;
- (IBAction)insertURL:(id)sender;
- (IBAction)arrowSelected:(id)sender;
- (IBAction)closeReadingSelected:(id)sender;


- (IBAction)insertCameraShotOrPhoto:(id)sender;

+(uint)getCurrentShape;


@end
