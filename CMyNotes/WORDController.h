//
//  WORDController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/17/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WORDController : NSObject



@property (strong, nonatomic) UIWebView *document;
@property (strong, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) NSString *pageStyles;
@property (strong, nonatomic) NSString *html;
@property CGFloat  scrollHeight;


//methods
-(NSString *)getPage:(int)index;
//-(CGSize) getOriginalPPTSize;
-(void)initialize:(UIWebView*)view withHTML:(NSString *)text withScrollHeight:(float)scrollHeight;
//-(CGSize)getScaledPageSizeForDisplay;
//-(NSString *)firstPage;
//-(CGSize)getSize;
//-(UIInterfaceOrientation)preferedOrientation;


@end
