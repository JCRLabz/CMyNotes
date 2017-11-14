//
//  ColorToolViewController.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 5/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "ColorToolViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"


static UIColor *_currentColor;
static float _alpha = 1.0;
static float _brushSize = 1.0;

@interface ColorToolViewController ()

@end

@implementation ColorToolViewController

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
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.hidden = YES;
    [self setupColorPalette];
    
    //_currentColor = [UIColor colorWithRed:0.125 green:0.0 blue:1.0 alpha:1.0];
    [_alphaSlider setValue:_alpha];
    
    [_brushSizeSlider setValue:_brushSize];
    [self brushSizeChanged:nil];
    //[self drawBrushShape];
    //[self setAlphaForSeletedColor];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.view addGestureRecognizer:recognizer];
    //[self updateSelectedColor:_currentColor];
    //[self setColor:_currentColor];
    self.fontFamilyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    
    //create a round button
    //self.closeButton.layer.cornerRadius = 5.0;
    self.closeButton.tintColor = [Utility CMYNColorRed1];
    self.closeButton.layer.borderColor = [[Utility CMYNColorLightBlue] CGColor];
    //self.closeButton.layer.borderWidth = 0.3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setupColorPalette
{
    //_currentColor = [UIColor colorWithRed:0.125 green:0.0 blue:1.0 alpha:1.0];
    
    if ( _currentColor == nil )
    {
        _currentColor = [UIColor colorWithRed:0.125 green:0 blue:1.0 alpha:1.0];
        
        self.selectedColor = _currentColor;
    }
    else
        self.selectedColor = _currentColor;
    
    
    _colorTable = [NSMutableArray array];
    
    //add variations of RGB
    int colorCount = 16;
    for (int i = 0; i < colorCount; i++)
    {
        UIColor *color = [UIColor colorWithHue:(float)i/16.0  saturation:1.0 brightness:1.0 alpha:1.0];
        //UIColor *color = [UIColor colorWithRed:i/colorCount green:i/(colorCount+1) blue:i/(colorCount+1) alpha:1.0];
        [_colorTable addObject:color];
    }
    
    //add variations for Black to White
    colorCount = 4;
    
    for (int i = 0; i < colorCount; i++)
    {
        UIColor *color = [UIColor colorWithWhite:(float)(i/(float)(colorCount - 1)) alpha:1.0];
        [_colorTable addObject:color];
    }
    
    if (!self.selectedColor)
    {
        self.selectedColor = [UIColor blackColor];
    }
    
    /*
     if (self.selectedColorText.length != 0)
     {
     self.selectedColorLabel.text = self.selectedColorText;
     }
     
     */
    [self setAlphaForSelectedColor];
    
    //for IPAD
    //for IPAD
    colorCount = 20;
    CGSize screenSize;
    //get the size of the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
         screenSize = [[UIScreen mainScreen] bounds].size;
    else
        screenSize = _colorToolView.bounds.size;
    //width of color table
    CGFloat colorTableWidth = 68.0*4+3*6.0;

    CGPoint colorTableOrigin = CGPointMake((screenSize.width - colorTableWidth)/2.0, 10.0);
    //CGPoint colorTableOrigin = CGPointMake(16.0, 10.0);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        colorTableOrigin.x = 16.0;
        colorTableOrigin.y = 55.0;
    }

    for (int i = 0; i < colorCount && i < _colorTable.count; i++)
    {
        CALayer *layer = [CALayer layer];
        layer.cornerRadius = 6.0;
        UIColor *color = [_colorTable objectAtIndex:i];
        layer.backgroundColor = color.CGColor;

        int column = i % 4;
        int row = i / 4;
        layer.frame = CGRectMake(colorTableOrigin.x + (column * 72), colorTableOrigin.y + row * 48, 68, 40);
        [self setupShadow:layer];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            [self.view.layer addSublayer:layer];
        else
            [self.colorToolView.layer addSublayer:layer];
        NSLog(@"Layer frame = %@", NSStringFromCGRect(layer.frame));
    }
}

/*
-(void)updateViewConstraints
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //width of color table
    CGFloat colorTableWidth = 56.0*5+24.0;
    NSLayoutConstraint *constraint;
    CGPoint colorTableOrigin = CGPointMake((screenSize.width - colorTableWidth)/2.0, 10.0);
    
    [self.view addSubview:self.opacityLabel];
    [self.view addSubview:self.brushSizeLabel];
    [self.view addSubview:self.alphaSlider];
    [self.view addSubview:self.brushSizeSlider];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *metrics = @{
                              @"colorTableOrigin":@(colorTableOrigin.x),
                              @"colorTableWidth":@(colorTableWidth)
                              };

    NSDictionary *views = @{
                                @"opacityLabel" : self.opacityLabel,
                                @"brushSizeLabel": self.brushSizeLabel,
                                @"opacitySlider":self.alphaSlider,
                                @"view" : self.view

                                };
                            

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.opacityLabel
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:-colorTableOrigin.x]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.brushSizeLabel
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:-colorTableOrigin.x]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.alphaSlider
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:-colorTableOrigin.x - 100.0]];
//
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
//                                                          attribute:NSLayoutAttributeLeft
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.opacityImageView
//                                                          attribute:NSLayoutAttributeTrailing
//                                                         multiplier:1.0
//                                                           constant:-colorTableWidth-55.0]];

    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[opacityLabel]-[opacitySlider]-|" options:0 metrics:metrics views:views]];

    [super updateViewConstraints];

}
*/

- (void) setupShadow:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(0, 2);
    CGRect rect = layer.frame;
    rect.origin = CGPointZero;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:layer.cornerRadius].CGPath;
}



- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer
{
    //get the size of the device
    CGSize screenSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        screenSize = [[UIScreen mainScreen] bounds].size;
    else
        screenSize = _colorToolView.bounds.size;

    //width of color table
    CGFloat colorTableWidth = 68.0*4+3*6.0;
    //origin for iPhone
    CGPoint colorTableOrigin = CGPointMake((screenSize.width - colorTableWidth)/2.0, 10.0);
    //CGPoint colorTableOrigin = CGPointMake(16.0, 10.0);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        colorTableOrigin.x = 16.0;
        colorTableOrigin.y = 50.0;
    }
    CGPoint point = [recognizer locationInView:self.view];

    
    CGRect colorFrame = CGRectMake(colorTableOrigin.x, colorTableOrigin.y, 4*72+4*8, 5*40+5*4); //color grid rectangle..bad code :)
    CGRect sliderFrame = self.brushSizeSlider.frame;
    
    CGRect frame = CGRectUnion(colorFrame, sliderFrame);
    
    if ( CGRectContainsPoint(frame, point) )
    {
        int row = (int)((point.y -  colorTableOrigin.y) / 48);
        int column = (int)((point.x -  colorTableOrigin.x) / 72);
        int index = row * 4 + column;
        
        if (index < _colorTable.count)
        {
            self.selectedColor = [_colorTable objectAtIndex:index];
            _currentColor = self.selectedColor;
            /*CGFloat r,g,b,a;
            if ( [self.selectedColor getRed:&r green:&g blue:&b alpha:&a] )
            {
                UIColor *color = [[UIColor alloc] initWithRed:r green:g blue:b alpha:_alpha];
                self.selectedColor = color;
            }*/
            [self setAlphaForSelectedColor];
            [self updateSelectedColor:self.selectedColor];
            [self broadcastColorPickedMessage];
            [self drawBrushShape];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/*
- (UIColor *) colorOfPoint:(UITapGestureRecognizer *)recognizer
{
    unsigned char pixel[4] = {0};
    CGPoint point = [recognizer locationInView:self.view];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.view.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    self.selectedColor = color;
    
    //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //label.backgroundColor = color;
    //label.layer.borderColor = [[UIColor redColor] CGColor];
    //[self.view addSubview:label];
    [self updateSelectedColor:color];
    [self broadcastColorPickedMessage];
    [self drawBrushShape];
    return color;
}
*/
-(void)broadcastColorPickedMessage
{
    //broadcast that the color selection changed
    if ( self.selectedColor == nil )
        self.color = [Utility CMYNColorLightBlue];
    NSDictionary *color = [NSDictionary dictionaryWithObject:self.selectedColor forKey:@"ColorChanged"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ColorChanged" object:self userInfo: color];
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    //{
        //[self dismissViewControllerAnimated:YES completion:nil];
    //}
}


- (IBAction)alphaChanged:(id)sender
{
    self.selectedColorLayer.opacity = _alphaSlider.value;
    _alpha = _alphaSlider.value;
    if ([self.delegate respondsToSelector:@selector(alphaChanged:)])
    {
        [self.delegate alphaChanged:_alpha];
    }
    [self setAlphaForSelectedColor];
}

- (IBAction)brushSizeChanged:(id)sender
{
    _brushSize = _brushSizeSlider.value;
    if ([self.delegate respondsToSelector:@selector(brushSizeChanged:)])
    {
        [self.delegate brushSizeChanged:_brushSize];
    }
    
    [self drawBrushShape];
}

- (void) updateSelectedColor:(UIColor *)color
{
        self.selectedColorLayer.backgroundColor = color.CGColor;
        _currentColor = color;
    if ([self.delegate respondsToSelector:@selector(didPickColor:)])
    {
        [self.delegate didPickColor:_currentColor];
    }
}



- (void)viewDidUnload
{
    [self setAlphaSlider:nil];
    [self setBrushSizeSlider:nil];
    [super viewDidUnload];
}

+(UIColor *)getCurrentColor
{
    if ( _currentColor == nil )
        _currentColor = [UIColor colorWithRed:0.125 green:0.0 blue:1.0 alpha:1.0];
    return _currentColor;
}

+(float)getAlpha
{
    return _alpha;
}

-(void)setAlpha:(float)alpha
{
    _alpha = alpha;
    [self.alphaSlider setValue:alpha];
}

-(void)setBrushSize:(float)brushSize
{
    _brushSize = brushSize;
    _brushSizeSlider.value = _brushSize;
    [self drawBrushShape];
}
-(void)setColor:(UIColor *)color
{
    //_currentColor = color;
    [self updateSelectedColor:color];
    [self drawBrushShape];
}

+(float)getBrushSize
{
    return _brushSize;
}



-(void)setAlphaForSelectedColor
{
    self.opacityImageView.image = nil;

    //UIGraphicsBeginImageContext(size);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextBeginPath(context);
     ////if ( context != nil )
     //{
    //CGContextSetFillColorWithColor(context, [_currentColor CGColor]);
    //CGContextSetStrokeColorWithColor(context, [_currentColor CGColor]);
    //CGContextDrawPath(context, kCGPathFillStroke);
    //CGContextAddArc(context, (self.opacityImageView.frame.size.width-10.0)/2.0, self.opacityImageView.frame.size.height/2.0, self.opacityImageView.frame.size.width/5.0, 0, M_PI * 2.0, 1);
    //CGContextSetAlpha(context, self.alphaSlider.value);
         self.opacityImageView.layer.cornerRadius = 8.0;
         self.opacityImageView.layer.backgroundColor = [_currentColor CGColor];
         self.opacityImageView.layer.frame = self.opacityImageView.frame;
         self.opacityImageView.layer.opacity = self.alphaSlider.value;
    
    self.opacityImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.opacityImageView.layer.shadowOpacity = 1.0;
    self.opacityImageView.layer.shadowOffset = CGSizeMake(0,15);
    
    CGRect rect = self.opacityImageView.layer.frame;
    rect.origin = CGPointZero;
    self.opacityImageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.opacityImageView.layer.cornerRadius].CGPath;
    //CGContextAddEllipseInRect(context, rect);
    //CGContextFillPath(context);
    //self.opacityImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    [self.view setNeedsDisplay];
     //}

}

-(void)drawBrushShape
{
    //**WORKING CODE *///
    
    _brushSizeImage.image = nil;
    UIGraphicsBeginImageContext(self.brushSizeImage.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( context != nil )
    {
    //CGContextBeginPath(context);
    
    CGContextSetFillColorWithColor(context, [_currentColor CGColor]);
    CGContextSetStrokeColorWithColor(context, [_currentColor CGColor]);
    //CGContextDrawPath(context, kCGPathFillStroke);
    CGContextAddArc(context, self.brushSizeImage.frame.size.width/2.0, self.brushSizeImage.frame.size.width/2.0, _brushSizeSlider.value/2.0, 0, M_PI * 2.0, 1);
    
    //CGContextAddEllipseInRect(context, self.brushSizeImage.frame);

    CGContextFillPath(context);
    _brushSizeImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setNeedsDisplay];
    }
    
    //**WORKING CODE *///
}


//font name

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Color palette using CollectionView

@end
