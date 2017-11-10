//
//  TextObject.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 5/1/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "TextStorage.h"

@interface TextObject : NSObject


@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableAttributedString *attributedText;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSNumber *fontSize;
@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property CGPoint origin;
@property CGSize textSize;
@property int borderType;
@property BOOL stickyNoteState;

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

//-(id)initWithText:(NSString*)text textSize:(CGSize)textSize font:(UIFont*)font fontSize:(NSNumber *)fontSize fontColor:(UIColor *)color atPoint:(CGPoint)point;
//-(id)initWithTextObject:(TextObject*)textObject;
-(id)initWithAttributedText:(NSMutableAttributedString *)text;
-(void)setCloseReadingSysmbol:(NSString *)symbol font:(UIFont *)font color:(UIColor *)color;


@end
