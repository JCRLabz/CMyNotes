//
//  ColorToolViewController.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 5/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorToolViewControllerDelegate <NSObject>
-(void)didPickColor:(UIColor *)color;
-(void)alphaChanged:(float)alpha;
-(void)brushSizeChanged:(float)brushSize;
@end


@interface ColorToolViewController : UIViewController


@property (strong, nonatomic) UIView *colorGrid;
@property (strong, nonatomic) NSMutableArray *colorTable;
@property (nonatomic, strong) UIColor *selectedColor;
//@property (weak, nonatomic) IBOutlet UILabel *selectedColorLabel;
//@property (nonatomic, strong) NSString* selectedColorText;

@property (nonatomic, strong) CALayer *selectedColorLayer;
@property (weak, nonatomic) IBOutlet UISlider *brushSizeSlider;
@property (strong, nonatomic) IBOutlet UIImageView *brushSizeImage;
@property (weak, nonatomic) IBOutlet UIImageView *opacityImageView;
@property (weak, nonatomic) IBOutlet UILabel *opacityLabel;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *brushSizeLabel;

@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (nonatomic, assign) id<ColorToolViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorToolView;

@property (strong, nonatomic) NSArray *fontFamilyNames;

- (IBAction)alphaChanged:(id)sender;

- (IBAction)brushSizeChanged:(id)sender;

//class method to provide the selected color
+(UIColor *)getCurrentColor;
+(float)getAlpha;
-(void)setAlpha:(float)alpha;
-(void)setBrushSize:(float)brushSize;
-(void)setColor:(UIColor *)color;
+(float)getBrushSize;

@end
