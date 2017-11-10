//
//  PPTController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/26/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UiKit.h>
/*
 #import <JavaScriptCore/JavaScriptCore.h> ios 7
 */

@interface PPTController : NSObject


@property (strong, nonatomic) UIWebView *document;
@property (strong, nonatomic) NSMutableArray *slides;
@property (strong, nonatomic) NSString *slideStyles;
@property (strong, nonatomic) NSString *html;
@property CGFloat  scrollHeight;
@property int count;
@property CGSize size;


//methods
-(int)slideCount;
-(NSString *)getSlide:(int)index;
-(void)initialize:(UIWebView*)view withHTML:(NSString *)text; //withScrollHeight:(float)scrollHeight;
-(CGSize)getScaledPPTSizeForDisplay;
-(NSString *)firstSlide;
-(NSString *)lastSlide;
-(CGSize)getSize;
-(UIInterfaceOrientation)preferedOrientation;
//another init method
-(id)initWithView:(UIWebView*)view withHTML:(NSString *)text;
-(NSArray *)getSlides;



@end
