//
//  ColorPickerViewController.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/16/13.
//  Copyright (c) 2013 Cognizant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorToolViewController.h"

@protocol BrushSizeControllerDelegate <NSObject>
-(void)didChangeBrushSize:(CGFloat)brushSize;
@end

@interface BrushSizeViewController : UIViewController
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat white;
    CGFloat brush;
    CGFloat opacity;
}

//@property (nonatomic, weak) UIPopoverController *popOver;

//@property (nonatomic, strong) NSNumber *brushSize;
@property (nonatomic, assign) id<BrushSizeControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *currentColor;

@property (weak, nonatomic) IBOutlet UISlider *brushSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *brushSizeLabel;
@property (nonatomic, strong) ColorToolViewController *colorToolViewController;
@property (weak, nonatomic) IBOutlet UIImageView *brushSizeImage;



- (void) updateBrushSize:(CGFloat) brushSize;


- (IBAction)sliderAction:(id)sender;
-(void)decomposeRGBComponentsFrom:(UIColor *)color;
-(void)drawBrushShape;

+(void)setBrushSize:(CGFloat)brushSize;
+(CGFloat)getBrushSize;



@end
