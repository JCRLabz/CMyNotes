//
//  ShapeObject.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TextObject.h"
#import "Utility.h"
#import "ImageObject.h"

@interface ShapeObject : NSObject

@property CGPoint origin;
@property CGPoint end;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *backgroundColor;
@property int type;
@property bool shapeSelected;
@property int lineWidth;
@property (strong, nonatomic) TextObject *textObject;
@property float alpha;
@property (nonatomic, strong) UIBezierPath *bzPath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect bounds;
@property BOOL fillShape;
@property CGFloat rotation, scale;
@property (strong, nonatomic) ImageObject *imageObject;


- (BOOL)containsPoint:(CGPoint)point;
-(id)initCopy:(ShapeObject *)input;
float distanceFromPointToLineSegment(CGPoint a, CGPoint b, CGPoint p);
-(CGRect)shapeBounds;
-(CGRect)frame;
-(NSMutableArray *)description;
-(int)getType;
-(BOOL)getFillShape;
-(BOOL)getStickyNoteState;
-(void)resetOriginAndEndPoint:(CGRect)bounds;
- (CGRect) getBoundingRectAfterRotation: (CGRect) rectangle byAngle: (CGFloat) angleOfRotation;

@end

