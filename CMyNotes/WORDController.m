//
//  WORDController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/17/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "WORDController.h"

@implementation WORDController


-(id) init
{
    self = [super init];
    if ( self  )
    {
        return self;
    }
    return nil;
}

-(void)initialize:(UIWebView*)view withHTML:(NSString *)text withScrollHeight:(float)scrollHeight;
{
    self.html = text;
    self.scrollHeight = scrollHeight;
    
    //int slideCount = [self slideCount];
    
    //[self getStyles:slideCount forView:view];
    //[self makeSlides:slideCount forView:view];
}

-(NSString *)getPage:(int)index
{
    return self.html;
}

@end
