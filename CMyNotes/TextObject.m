//
//  TextObject.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 5/1/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "TextObject.h"



@implementation TextObject


-(id)init
{
    self = [super init];
    if (!self)
        return nil;
    return self;
}

/*
-(id)initWithText:(NSString*)text textSize:(CGSize)textSize font:(UIFont*)font fontSize:(NSNumber *)fontSize fontColor:(UIColor *)color atPoint:(CGPoint) point
{
    self.text = text;
    self.textSize = textSize;
   self.fontColor = color;
    self.backgroundColor = [UIColor lightGrayColor];
    self.fontSize = fontSize;
    self.font = font;
    self.origin = point;
    
    self.attributedText = [[NSMutableAttributedString alloc]  initWithString:text attributes:nil];
    return self;
}
*/

-(id)initWithAttributedText:(NSMutableAttributedString *)text
{
    self.attributedText = text;
    return self;
}



-(id)initCopy:(TextObject *)textObject
{
    self = [[TextObject alloc] init];
    
    if(self)
    {
        self.attributedText = textObject.attributedText;
        self.textStorage = textObject.textStorage;
        self.layoutManager = textObject.layoutManager;
        self.textContainer = textObject.textContainer;
    }
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    TextObject *textObject = [[TextObject alloc] initCopy:self];
    return textObject;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [[TextObject alloc] init];
    if(self) {
        self.origin = [aDecoder decodeCGPointForKey:@"origin"];
        self.textSize = [aDecoder decodeCGSizeForKey:@"textSize"];
        self.fontColor = [aDecoder decodeObjectForKey:@"fontColor"];
        self.backgroundColor = [aDecoder decodeObjectForKey:@"backgroundFontColor"];
        self.font = [aDecoder decodeObjectForKey:@"fontName"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.attributedText = [aDecoder decodeObjectForKey:@"attributedText"];
        self.stickyNoteState = [aDecoder decodeBoolForKey:@"stickyNoteState"];
        self.layoutManager = [aDecoder decodeObjectForKey:@"layoutManager"];
        self.textStorage = [aDecoder decodeObjectForKey:@"textStorage"];
        self.textContainer = [aDecoder decodeObjectForKey:@"textContainer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:self.origin forKey:@"origin"];
    [aCoder encodeCGSize:self.textSize forKey:@"textSize"];
    [aCoder encodeObject:(UIColor*)self.fontColor  forKey:@"fontColor"];
    [aCoder encodeObject:(UIColor*)self.backgroundColor  forKey:@"backgroundFontColor"];
    [aCoder encodeObject:(UIFont*)self.font forKey:@"fontName"];
    [aCoder encodeObject:(NSString*)self.text forKey:@"text"];
    [aCoder encodeObject:(NSString*)self.attributedText forKey:@"attributedText"];
    [aCoder encodeBool:self.stickyNoteState forKey:@"stickyNoteState"];
    
    [aCoder encodeObject:(NSTextStorage*)self.textStorage forKey:@"textStorage"];
    [aCoder encodeObject:(NSTextContainer*)self.textContainer forKey:@"textContainer"];
    [aCoder encodeObject:(NSLayoutManager*)self.layoutManager forKey:@"layoutManager"];
}

-(CGRect)bounds
{
    CGFloat fontSize = [self.fontSize floatValue];
    return [self.text boundingRectWithSize:CGSizeMake(200, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                  context:nil];
}

-(void)setCloseReadingSysmbol:(NSString *)symbol font:(UIFont *)font color:(UIColor *)color
{
    self.attributedText = [self getAttributedString:symbol color:color font:font];
}

-(NSMutableAttributedString *)getAttributedString:(NSString *)text color:(UIColor* )color font:(UIFont *)font
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,  NSForegroundColorAttributeName:color, NSBaselineOffsetAttributeName:@-5}]  ;
    return attributedString;
}

@end