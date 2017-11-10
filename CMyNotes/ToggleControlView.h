//
//  ToggleControlView.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/22/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleControlView : UIControl
{
    BOOL selected;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *unSelectedImage;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic ) NSIndexPath *indexPath;


- (id)initWithFrame:(CGRect)frame;
-(void)setSelectedImage;
-(void)setUnSelectedImage;



@end
