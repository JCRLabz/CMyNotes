//
//  ShapeObject.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "ShapeObject.h"


@implementation ShapeObject



-(id)init
{
    self = [super init];
    if(self) {
        //set alpha to default 1.0
        self.alpha = 1.0;
        self.shapeSelected = false;
        _bzPath = [[UIBezierPath alloc] init];
        self.lineWidth = 1;
        self.fillShape = false;
        self.rotation = 0.0;
        self.scale = 0.0;
        self.color = [Utility CMYNColorDarkBlue];
    }
    return self;
}


-(id)initCopy:(ShapeObject *)shape
{
    self = [[ShapeObject alloc] init];
    
    if(self)
    {
        _origin.x = shape.origin.x;
        _origin.y = shape.origin.y;
        _end.x = shape.end.x;
        _end.y = shape.end.y;
        _color = shape.color;
        self.backgroundColor = shape.backgroundColor;
        _shapeSelected = shape.shapeSelected;
        self.lineWidth = shape.lineWidth;
        _type = shape.type;
        _textObject = shape.textObject;
        _alpha = shape.alpha;
        _bzPath = [shape.bzPath copy];
        _bzPath.lineWidth = shape.lineWidth;
        self.imageObject = shape.imageObject;
        self.bounds = [self shapeBounds];
        self.fillShape = shape.fillShape;
        self.rotation = shape.rotation;
        self.scale = shape.scale;
        if (shape.type == kPhoto)
        {
            self.bounds = self.imageObject.rectangle;
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ShapeObject *shape = [[ShapeObject alloc] initCopy:self];
    return shape;
}

- (id)initWithCoder:(NSCoder *)decode
{
    self = [[ShapeObject alloc] init];
    if(self) {
        _origin = [decode decodeCGPointForKey:@"origin"];
        _end = [decode decodeCGPointForKey:@"end"];
        _color = [decode decodeObjectForKey:@"color"];
        self.backgroundColor = [decode decodeObjectForKey:@"backgroundColor"];
        _shapeSelected = [decode decodeBoolForKey:@"shapeSelected"];
        _fillShape = [decode decodeBoolForKey:@"fillShape"];
        self.lineWidth = [decode decodeIntForKey:@"lineWidth"];
        self.rotation = [decode decodeFloatForKey:@"rotation"];
        self.scale = [decode decodeFloatForKey:@"scale"];
        _type = [decode decodeIntForKey:@"type"];
        _alpha = [decode decodeFloatForKey:@"alpha"];
        _textObject = [decode decodeObjectForKey: @"textObject"];
        _imageObject = [decode decodeObjectForKey:@"imageObject"];
        NSData *bzPathData = [decode decodeObjectForKey:@"bezierPath"];
        _bzPath = [NSKeyedUnarchiver unarchiveObjectWithData:bzPathData];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encode
{
    [encode encodeCGPoint:self.origin forKey:@"origin"];
    [encode encodeCGPoint:self.end forKey:@"end"];
    [encode encodeObject:(UIColor*)self.color  forKey:@"color"];
    [encode encodeObject:(UIColor*)self.backgroundColor  forKey:@"backgroundColor"];
    [encode encodeBool:self.shapeSelected forKey:@"shapeSelected"];
    [encode encodeBool:self.fillShape forKey:@"fillShape"];
    [encode encodeInt:self.lineWidth forKey:@"lineWidth"];
    [encode encodeFloat:self.rotation forKey:@"rotation"];
    [encode encodeFloat:self.scale forKey:@"scale"];
    [encode encodeInt:self.type forKey:@"type"];
    [encode encodeFloat:self.alpha forKey:@"alpha"];
    [encode encodeObject:(TextObject*)self.textObject forKey:@"textObject"];
    [encode encodeObject:(ImageObject*)self.imageObject forKey:@"imageObject"];
    
    NSData *bzPathData = [NSKeyedArchiver archivedDataWithRootObject:self.bzPath];
    [encode encodeObject:(NSData*)bzPathData forKey:@"bezierPath"];
}

#pragma mark - Hit test

- (BOOL)containsPoint:(CGPoint)point
{
    //construct a rectangle of 15 pixels around the touched point

    if ( self.type == kText | self.type == kCloseReading)
        return [self containsText:point];
    
    else if (self.type == kPhoto)
        return [self containsImage:point];
    
    else if ( self.type == kHighlighter || self.type == kLine )
    {
        //CGRect bzRect = [self.bzPath bounds];

        //return [self.bzPath containsPoint:point];
        //construct the rectangle little big enought to enclose the line or highlight to take care of straight lines
        
         CGRect rectangle = CGRectMake(self.origin.x < self.end.x ? self.origin.x - 15: self.end.x - 15, //_origin.x - 5, //
                                      self.origin.y < self.end.y? self.origin.y - 15: self.end.y - 15, //_origin.y - 5,
                                      fabs(_end.x - _origin.x) + 30.0,
                                      fabs(_end.y - _origin.y) + 30.0);
        
        return CGRectContainsPoint(rectangle, point);
    }
    else if ( self.type == kRectangle || self.type == kCircle || self.type == kArrow || self.type == kDoubleHeadedArrow)
    {
        CGRect bzRect = [self.bzPath bounds];

        /*CGRect rectangle = CGRectMake(_origin.x,
                                      _origin.y,
                                      _end.x - _origin.x,
                                      _end.y - _origin.y);*/
        return CGRectContainsPoint(bzRect, point);

    }

    else if ( self.type == kFreeform )
    {
        UIBezierPath *bzPath;// = [UIBezierPath bezierPath];
        bzPath = [self.bzPath copy];
        [bzPath closePath];
        //BOOL empty = [bzPath isEmpty];
        CGRect rectangle = CGRectMake(bzPath.bounds.origin.x-2.0*bzPath.lineWidth, bzPath.bounds.origin.y-2.0*bzPath.lineWidth, bzPath.bounds.size.width+2.0*bzPath.lineWidth, bzPath.bounds.size.height+2.0*bzPath.lineWidth);
        return CGRectContainsPoint(rectangle, point);


        //return [bzPath containsPoint:point];
        //return NO;

    }

    return NO;
}

-(void)resetOriginAndEndPoint:(CGRect)bounds
{
    self.origin = bounds.origin;
    self.end = CGPointMake(bounds.origin.x+bounds.size.width, bounds.origin.y+bounds.size.height);
}

-(BOOL)containsText:(CGPoint)point
{
    
    CGRect bzRect = [self.bzPath bounds];
    /* rectangle = CGRectMake(_origin.x,
                                  _origin.y,
                                  _end.x - _origin.x,
                                  _end.y - _origin.y);*/
    
    return CGRectContainsPoint(bzRect, point);
    
}

-(BOOL)containsImage:(CGPoint)point
{
    //CGRect bzRect = [self.bzPath bounds];
    CGRect rectangle = CGRectMake(_origin.x,
                                  _origin.y,
                                  _end.x - _origin.x,
                                  _end.y - _origin.y);
    
    return CGRectContainsPoint(rectangle, point);
}

-(CGRect)shapeBounds
{
    if ( self.bzPath == nil)
    {
        return CGRectZero;
    }

    return CGRectInset(self.bzPath.bounds, -(self.bzPath.lineWidth/2.0 + 1.0f), -(self.bzPath.lineWidth/2.0 +1.0f));

}

-(CGRect)frame
{
    CGRect frame =  CGRectMake(self.origin.x, self.origin.y, fabs(self.end.x - self.origin.x), fabs(self.end.y - self.origin.y));
    return frame;
}


-(NSMutableArray*)description
{
    NSMutableArray *descriptionArray = [NSMutableArray arrayWithCapacity:12];

    [descriptionArray addObject:[NSString stringWithFormat:@"Origin = %@;", NSStringFromCGPoint(self.origin)] ];
    [descriptionArray addObject:[NSString stringWithFormat:@"End = %@;", NSStringFromCGPoint(self.end)] ];
    [descriptionArray addObject:[NSString stringWithFormat:@"Type = %d;", self.type]];
    [descriptionArray addObject:[NSString stringWithFormat:@"Color = %@;", self.color]];
    
    if (self.type == kPhoto)
    {
        [descriptionArray addObject:[self.imageObject description]];
    }
    
    return descriptionArray;
}

-(int)getType
{
    return self.type;
}

-(BOOL)getFillShape
{
    return self.fillShape;
}

-(BOOL)getStickyNoteState
{
    return self.textObject.stickyNoteState;
}


- (CGRect) getBoundingRectAfterRotation: (CGRect) rectangle byAngle: (CGFloat) angleOfRotation
{
    // Calculate the width and height of the bounding rectangle using basic trig
    CGFloat newWidth = rectangle.size.width * fabs(cosf(angleOfRotation)) + rectangle.size.height * fabs(sinf(angleOfRotation));
    CGFloat newHeight = rectangle.size.height * fabs(cosf(angleOfRotation)) + rectangle.size.width * fabs(sinf(angleOfRotation));
    
    // Calculate the position of the origin
    CGFloat newX = rectangle.origin.x + ((rectangle.size.width - newWidth) / 2);
    CGFloat newY = rectangle.origin.y + ((rectangle.size.height - newHeight) / 2);
    
    self.origin = CGPointMake(newX, newY);
    self.end = CGPointMake(newX+newWidth, newY+newHeight);
    // Return the rectangle
    return CGRectMake(newX, newY, newWidth, newHeight);
}

@end
