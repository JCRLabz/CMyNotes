//
//  UIView+ColorOfPointView.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/17/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//
#import "UIView+ColorOfPointView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ColorOfPoint)

- (UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapByteOrderDefault/*kCGImageAlphaPremultipliedLast*/);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

@end
