//
//  BrushSizeViewController.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/16/13.
//  Copyright (c) 2013 Cognizant. All rights reserved.
//

#import "BrushSizeController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+ColorOfPointView.h"

static CGFloat _brushSize = 1.0;

@interface BrushSizeViewController () <ColorToolViewControllerDelegate>

@end


@implementation BrushSizeViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }

    return self;
}
-(void)didPickColor
{
}
//- (void)setPopOver:(UIPopoverController *)popOver
//{
//    if (_popOver != popOver) {
//        _popOver = popOver;
//        
//        // Update the view
//        //[self configureView];
//    }
//    
//    //if (self.masterPopoverController != nil) {
//    //    //[self.masterPopoverController dismissPopoverAnimated:YES];
//    //}
//}

- (void)viewDidLoad

{
    [super viewDidLoad];

    [_brushSizeSlider   setValue:_brushSize animated:YES]; 
    [_brushSizeSlider setEnabled:YES];
    //restore the brushSize;
    _brushSize = [BrushSizeViewController getBrushSize];
    [self updateBrushSize:_brushSize];


    
    UIColor *color = [ColorToolViewController getCurrentColor];

    [self decomposeRGBComponentsFrom:color];
    _brushSizeSlider.minimumTrackTintColor = color;
    
    _brushSizeSlider.minimumTrackTintColor = color;

    //ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc] init];
    ;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(colorPicked:)
                                                 name:@"ColorPicked"
                                               object:nil];

}


-(void)colorPicked:(NSNotification *) notification
{
    UIColor *color = [[notification userInfo] valueForKey:@"ColorPicked"];
    NSLog(@"Color received = %@", color);
    //_brushSizeImage.backgroundColor = color;
    _brushSizeSlider.minimumTrackTintColor = color;
    [self decomposeRGBComponentsFrom:color];
    [self drawBrushShape];
    //brush = [brushSize floatValue];
}




-(void)decomposeRGBComponentsFrom:(UIColor *)color
{
    
    size_t componentsCount = CGColorGetNumberOfComponents([color CGColor]);
    
    if ( componentsCount == 4 ) {
        if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
            [color getRed:&red green:&green blue:&blue alpha:&opacity];
        }
    }
    else if ( componentsCount == 2 )
        if ([color respondsToSelector:@selector(getWhite:alpha:)]) {
            [color getWhite:&white alpha:&opacity];
        }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) updateBrushSize:(CGFloat) brushSize
{
    _brushSize = brushSize;
    _brushSizeLabel.text = [[NSString alloc ] initWithFormat:@"Brush size = %2.0f",_brushSizeSlider.value];

    if ([self.delegate respondsToSelector:@selector(didChangeBrushSize:)])
        [self.delegate didChangeBrushSize:brushSize];
    //[self.popOver dismissPopoverAnimated:YES];

}


- (IBAction)sliderAction:(id)sender
{
    [self updateBrushSize:self.brushSizeSlider.value];
    _brushSize = self.brushSizeSlider.value;
    _brushSizeSlider.minimumTrackTintColor = [ColorToolViewController getCurrentColor];
    [self decomposeRGBComponentsFrom:[ColorToolViewController getCurrentColor]];

    _brushSizeLabel.text = [[NSString alloc ] initWithFormat:@"Brush size = %2.0f",_brushSizeSlider.value];
    [self drawBrushShape];
//    _brushSizeImage.image = nil;
//    
//    //drawImage is a UIImageView declared at header
//    UIGraphicsBeginImageContext(_brushSizeImage.frame.size);
//    [_brushSizeImage.image drawInRect:CGRectMake(0, 0, _brushSizeImage.frame.size.width, _brushSizeImage.frame.size.height)];
//    
//    //sets the style for the endpoints of lines drawn in a graphics context
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetLineCap(ctx, kCGLineCapButt);
//
//    //set the line colour
//    //creates a new empty path in a graphics context
//    CGContextBeginPath(ctx);
//    
//    CGContextSetRGBFillColor(ctx, red, green, blue, opacity);
//
//    //begin a new path at the point you specify
//
//    //paints a line along the current path
//    CGRect frame = _brushSizeImage.frame;
//    
//    //sets the line width for a graphic context
//    //CGContextSetLineWidth(ctx,_brushSizeSlider.value);
//    //begin a new path at the point you specify
//    CGContextMoveToPoint(ctx, frame.origin.x, frame.origin.y);
//    //Appends a straight line segment from the current point to the provided point
//    //CGContextAddRect(ctx, CGRectMake(currentPoint.x,currentPoint.y, currentPoint.x+_brushSizeSlider.value/4, currentPoint.y+_brushSizeSlider.value/4));
//    //CGContextAddLineToPoint(ctx, frame.origin.x+frame.size.width, frame.origin.y+frame.size.height/2.0);
//
//        
//    CGContextFillRect(ctx,CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _brushSizeSlider.value));
//    
//    //CGContextSetRGBFillColor(ctx, red, green, blue, opacity);
//    
//    //CGContextFillEllipseInRect(ctx, CGRectMake(frame.size.height/2, frame.size.width/2, _brushSizeSlider.value, _brushSizeSlider.value));
//    //CGContextFillEllipseInRect(ctx, CGRectMake(frame.origin.x, frame.origin.y+frame.size.height/2, frame.size.width, frame.size.height/2+_brushSizeSlider.value));
//    CGContextStrokePath(ctx);
//    
//    
//    _brushSizeImage.image = UIGraphicsGetImageFromCurrentImageContext();
//    [_brushSizeImage setNeedsDisplay];
//    
//    UIGraphicsEndImageContext();
//    
    
}

-(void)drawBrushShape
{
    _brushSizeImage.image = nil;
    
    //drawImage is a UIImageView declared at header
    UIGraphicsBeginImageContext(_brushSizeImage.frame.size);
    [_brushSizeImage.image drawInRect:CGRectMake(0, 0, _brushSizeImage.frame.size.width, _brushSizeImage.frame.size.height)];
    
    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //set the line colour
    //creates a new empty path in a graphics context
    CGContextBeginPath(ctx);
    
    CGContextSetRGBFillColor(ctx, red, green, blue, opacity);
    
    //begin a new path at the point you specify
    
    //paints a line along the current path
    CGRect frame = _brushSizeImage.frame;
    
    //sets the line width for a graphic context
    //CGContextSetLineWidth(ctx,_brushSizeSlider.value);
    //begin a new path at the point you specify
    CGContextMoveToPoint(ctx, frame.origin.x, frame.origin.y);
    //Appends a straight line segment from the current point to the provided point
    //CGContextAddRect(ctx, CGRectMake(currentPoint.x,currentPoint.y, currentPoint.x+_brushSizeSlider.value/4, currentPoint.y+_brushSizeSlider.value/4));
    //CGContextAddLineToPoint(ctx, frame.origin.x+frame.size.width, frame.origin.y+frame.size.height/2.0);
    
    
    CGContextFillRect(ctx,CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _brushSizeSlider.value));
    
    //CGContextSetRGBFillColor(ctx, red, green, blue, opacity);
    
    //CGContextFillEllipseInRect(ctx, CGRectMake(frame.size.height/2, frame.size.width/2, _brushSizeSlider.value, _brushSizeSlider.value));
    //CGContextFillEllipseInRect(ctx, CGRectMake(frame.origin.x, frame.origin.y+frame.size.height/2, frame.size.width, frame.size.height/2+_brushSizeSlider.value));
    CGContextStrokePath(ctx);
    
    
    _brushSizeImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [_brushSizeImage setNeedsDisplay];
    
    UIGraphicsEndImageContext();
}


//- (void)viewDidUnload {
//    [self setBrushSizeImage:nil];
//    [super viewDidUnload];
//}


+(void)setBrushSize:(CGFloat)brushSize
{
    _brushSize = brushSize;
}

+(CGFloat)getBrushSize
{
    return _brushSize;
}

- (void)alphaChanged:(float)alpha {

}

- (void)brushSizeChanged:(float)brushSize {

}

- (void)didPickColor:(UIColor *)color {

}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {

}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {

}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {

}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    CGSize cgSize = CGSizeMake(0.0, 0.0);
    return cgSize;
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {

}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {

}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {

}

- (void)setNeedsFocusUpdate {

}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return false;
}

- (void)updateFocusIfNeeded {
    
}

@end

