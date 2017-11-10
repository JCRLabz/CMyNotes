//
//  ImageObject.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 2/21/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface ImageObject : NSObject

@property (nonatomic, strong) UIImage *image;
@property CGPoint origin;
@property CGFloat scaleFactor;
@property CGRect rectangle;
@property CGRect minimumSize;
@property CGFloat orientation;
@property(nonatomic, readonly) UIImageResizingMode resizingMode;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *url;
@property int borderType;


-(id)initWithImage:(UIImage *)image atPoint:(CGPoint)point withSize:(CGSize)size scaleFactor:(CGFloat)scaleFactor;
-(id)initWithImageName:(NSString *)imageURL atPoint:(CGPoint)point withSize:(CGSize)size scaleFactor:(CGFloat)scaleFactor;
-(NSMutableArray*)description;


@end
