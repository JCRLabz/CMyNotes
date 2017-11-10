//
//  ToggleControlView.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/22/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "ToggleControlView.h"

@implementation ToggleControlView


-(id)init
{
    self = [super init];
    if (self) {
        _unSelectedImage = [UIImage imageNamed: @"star_unselected.png"];
        _selectedImage = [UIImage imageNamed: @"star_selected.png"];
        _imageView = [[UIImageView alloc] initWithImage: _unSelectedImage];
        
        //NSLog(@"Frame = %lf\n , %lf\n, %lf\n, %lf\n" , frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
        
        // set imageView frame
        [self addSubview: _imageView];
        
        [self addTarget: self action: @selector(toggleImage) forControlEvents: UIControlEventTouchDown];    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _unSelectedImage = [UIImage imageNamed: @"star_unselected.png"];
        _selectedImage = [UIImage imageNamed: @"star_selected.png"];
        _imageView = [[UIImageView alloc] initWithImage: _unSelectedImage];
        
        //NSLog(@"Frame = %lf\n , %lf\n, %lf\n, %lf\n" , frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
        
        // set imageView frame
        [self addSubview: _imageView];
        
        [self addTarget: self action: @selector(toggleImage) forControlEvents: UIControlEventTouchDown];    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setSelectedImage
{
    _imageView.image = [UIImage imageNamed: @"star_selected.png"];
}

-(void)setUnSelectedImage
{
    _imageView.image = [UIImage imageNamed: @"star_unselected.png"];
}

- (void) toggleImage
{
    //NSDictionary *clickedItem = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.tag] forKey:@"CellIconClicked"];
    NSDictionary *indexPath = [NSDictionary dictionaryWithObject:_indexPath forKey:@"CellIconClicked"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CellIconClicked" object: self userInfo: indexPath];
}
@end
