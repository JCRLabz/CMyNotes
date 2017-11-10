//
//  ImageObject.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 2/21/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import "ImageObject.h"

@implementation ImageObject


-(id)init
{
    self = [super init];
    if (!self)
        return nil;
    return self;
}

-(id)initCopy:(ImageObject *)imageObject
{
    self = [[ImageObject alloc] init];
    
    if(self)
    {
        _origin = imageObject.origin;
        _scaleFactor = imageObject.scaleFactor;
        _rectangle = imageObject.rectangle;
        _minimumSize = imageObject.minimumSize;
        _orientation = imageObject.orientation;
        _resizingMode = imageObject.resizingMode;
        _borderType = imageObject.borderType;
        _image = imageObject.image;
        _url = imageObject.url;
        _fileName = imageObject.fileName;
    }
    
    return self;
}

-(id)initWithImage:(UIImage *)image atPoint:(CGPoint)point withSize:(CGSize)size scaleFactor:(CGFloat)scaleFactor
{
    self = [super init];
    if (!self)
        return nil;
    
    self.image = image;
    self.origin = point;
    self.rectangle = CGRectMake(point.x, point.y, size.width, size.height);
    self.scaleFactor = scaleFactor;
    /*
     if (size.height > 10.0 || ) {
     <#statements#>
     }
     self.minimumSize = CGRectMake(point.x, point.y,size.width/10.0, size.height/10.0);*/
    return self;
}

-(id)initWithImageName:(NSString *)imageName atPoint:(CGPoint)point withSize:(CGSize)size scaleFactor:(CGFloat)scaleFactor
{
    self = [super init];
    if (!self)
        return nil;
    
    self.fileName = imageName;
    self.origin = point;
    self.rectangle = CGRectMake(point.x, point.y, size.width, size.height);
    self.scaleFactor = scaleFactor;
    /*
     if (size.height > 10.0 || ) {
     <#statements#>
     }
     self.minimumSize = CGRectMake(point.x, point.y,size.width/10.0, size.height/10.0);*/
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ImageObject *imageObject = [[ImageObject alloc] initCopy:self];
    return imageObject;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [[ImageObject alloc] init];
    if(self)
    {
        self.origin = [aDecoder decodeCGPointForKey:@"origin"];
        self.rectangle = [aDecoder decodeCGRectForKey:@"rectangle"];
        self.scaleFactor = [aDecoder decodeFloatForKey:@"scaleFactor"];
        self.borderType = [aDecoder decodeIntForKey:@"borderType"];
        self.image = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"image"]];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.url = [aDecoder decodeObjectForKey:@"URL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:self.origin forKey:@"origin"];
    [aCoder encodeCGRect:self.rectangle forKey:@"rectangle"];
    [aCoder encodeFloat:self.scaleFactor forKey:@"scaleFactor"];
    [aCoder encodeInt:self.borderType forKey:@"borderType"];
    [aCoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.url forKey:@"URL"];
}


-(NSMutableArray*)description
{
    NSMutableArray *descriptionArray = [NSMutableArray arrayWithCapacity:12];
    
    
    [descriptionArray addObject:[NSString stringWithFormat:@"Origin = %@;", NSStringFromCGPoint(self.origin)] ];
    [descriptionArray addObject:[NSString stringWithFormat:@"Bounds = %@;", NSStringFromCGRect(self.rectangle)] ];
    [descriptionArray addObject:self.image];
    [descriptionArray addObject:self.url];

    return descriptionArray;
}

@end
