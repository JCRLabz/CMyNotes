//
//  PPTController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/26/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "PPTController.h"
#import "Utility.h"
#import <UIKit/UIScreen.h>

@implementation PPTController
{
    //JSContext *context = [[JSContext alloc] init];
}

-(id) init
{
    self = [super init];
    if ( self  )
    {
        return self;
    }
    return nil;
}

-(int)slideCount
{
    return self.count;
}
-(void)computeSlideCount
{

    //NSString *div = getDivByClassName:self.html;
/*

    CGSize pptSize = [self getSize];
    //CGRect frame, orifinaleFrame = self.document.frame;
 
    //count = _scrollHeight/pptSize.height;

    float height = pptSize.height/pptSize.width * 752; //Ha ha... Where did this magic number come frome? Potential time bomb
    count = _scrollHeight/height;
    NSLog(@"Number of slides = %d", count);
    //NSLog(@"HTML=%@",_html);
    
 */
    //use regular expression to count div class="Slide"
    
    NSError *error = NULL;
    //find this pattern - <div class="slide"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<div \b*class\b*=\"slide\"" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:_html options:0 range:NSMakeRange(0, [_html length])];
    //NSLog(@"Found %i matches using Regex",numberOfMatches);

    //if ( numberOfMatches == count )
        //return count;

 
    self.count = (int)numberOfMatches;
}

-(void)initialize:(UIWebView *)view withHTML:(NSString *)text
{

    self.html = text;
    //self.scrollHeight = scrollHeight;
    
    [self computeSlideCount];
    [self computeSlideSize];
    //[self getStyles:self.count forView:view];
    //[self makeSlides:self.count forView:view];
}

-(id)initWithView:(UIWebView*)view withHTML:(NSString *)text 
{
    self = [super init];
    if ( !self  )
    {
        return nil;
    }
    self.html = text;
    [self computeSlideCount];
    [self computeSlideSize];
    //[self getStyles:self.count forView:view];
    //[self makeSlides:self.count forView:view];


    return self;
}

-(void)makeSlides:(int)slideCount forView:(UIWebView*)view
{
    self.slides = [[NSMutableArray alloc] init];
    for ( int i = 0; i < self.count; i++)
    {
        NSString *slideBody = [NSString stringWithFormat:@"document.getElementsByClassName('slide')[%d].outerHTML", i];
        NSString *div = [view stringByEvaluatingJavaScriptFromString:slideBody];
        
        NSString *slide = [self.slideStyles stringByAppendingString:div];
        [self.slides addObject:slide];
    }

}

-(void)getStyles:(int)slideCount forView:(UIWebView*)view
{
    NSString *allStyles = [[NSString alloc] init];
    
    for (int i = 0; i < self.count; i++)
    {
        NSString *getElementByTag = [NSString stringWithFormat:@"document.getElementsByTagName('style')[%d].outerHTML", i];
        NSString *style =  [[view stringByEvaluatingJavaScriptFromString:getElementByTag ] stringByAppendingString:@"\n"];
        allStyles = [allStyles stringByAppendingString:style];
    }    
    allStyles = [@"<style type='text/css'>" stringByAppendingString: allStyles];
    self.slideStyles = [allStyles stringByAppendingString:@"</style>\n"];
}

-(NSString *)getSlide:(int)index
{
    if ( index < 0 )
        return [self.slides objectAtIndex:0];
    
    if (index > [self.slides count]-1)
        return [self.slides lastObject];

    return   [self.slides objectAtIndex:index];    
}

//-(CGSize)getOriginalPPTSize
//{
//    NSString *w=[self.document stringByEvaluatingJavaScriptFromString:@"function x(){var rtn='';for (var i=1;i<document.all.length;i++){var a=document.all[i];if (((a.clientWidth>0)&&(a.clientHeight>0))&&(a.scrollHeight.toString()==a.offsetHeight.toString())&&(a.offsetHeight.toString()==a.clientHeight.toString())){return ''+a.offsetWidth; }}return rtn;};x();"];
//    NSString *h=[self.document stringByEvaluatingJavaScriptFromString:@"function x(){var rtn='';for (var i=1;i<document.all.length;i++){var a=document.all[i];if (((a.clientWidth>0)&&(a.clientHeight>0))&&(a.scrollHeight.toString()==a.offsetHeight.toString())&&(a.offsetHeight.toString()==a.clientHeight.toString())){return ''+a.offsetHeight; }}return rtn;};x();"];
//    NSLog(@"Original Width = %@ height = %@", w, h);
//    CGSize size = CGSizeMake([w floatValue], [h floatValue]);
//    return size;
//}

-(CGSize)getScaledPPTSizeForDisplay
{
    CGRect deviceRect = [Utility deviceBounds];
    //UIDeviceOrientation orientation = [Utility deviceOrientation];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    /*  UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
        UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
        UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
        UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
        
    */
    

    CGSize pptSize = [self getSize]; //get the PPT size from HTML
    float scale = 0.0;
    CGSize scaledPPTSize;
    
    if ( interfaceOrientation == (UIDeviceOrientationPortrait ) || (interfaceOrientation) == UIDeviceOrientationPortraitUpsideDown)
    {
        scale = deviceRect.size.width/pptSize.width;
        scaledPPTSize = CGSizeMake(deviceRect.size.width, scale*pptSize.height);
    }
    else
    {
        scale = (deviceRect.size.width-TOP_BORDER)/pptSize.height;
        scaledPPTSize = CGSizeMake(deviceRect.size.height, (scale*deviceRect.size.width));
        //scale = deviceRect.size.height/originalPPTSize.height;
        //scaledPPTSize = CGSizeMake(scale*originalPPTSize.width, scale*originalPPTSize.width);
    }
    return scaledPPTSize;
}

-(NSString *)firstSlide
{
    return [self getSlide:0];
}

-(NSString *)lastSlide
{
    return [self.slides lastObject];
}


-(CGSize)getSize
{
 
    return self.size;
}

-(void)computeSlideSize
{
    CGSize size;
    NSError *error = NULL;
    //get Width first
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"width:\\d{3,4}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:_html options:0 range:NSMakeRange(0, [_html length])];
    NSString *str = [_html substringWithRange:[match rangeAtIndex:0]];
    

    
    /*NSString *widthString = [[str componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
     */
    size.width = [[[str componentsSeparatedByCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                   componentsJoinedByString:@""] floatValue];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"height:\\d{3,4}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    match = [regex firstMatchInString:_html options:0 range:NSMakeRange(0, [_html length])];
    str = [_html substringWithRange:[match rangeAtIndex:0]];
    
    size.height = [[[str componentsSeparatedByCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                   componentsJoinedByString:@""] floatValue];
    self.size = size;
    
}


-(UIInterfaceOrientation)preferedOrientation
{
    CGSize size = [self getSize];
    //UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if ( size.width > size.height)
    {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortrait;
}

-(NSArray *)getSlides
{
    return self.slides;
}

#pragma mark - BUGS
//regular expression error - FIXED
//when the width is 3 digits or 4 digits, it should work
//same with height
//PPTView should scale the PPT
//http://www.arachnoid.com/javascript/treebrowse.html?window.document.body
//document.getElementsByClassName(klassName)
//http://hayageek.com/execute-javascript-in-ios/

/*
-(NSString*)getDivByClassName:(NSString *)name
{
    JSContext *context = [[JSContext alloc] init];

    context[@"findDivClassByName"]= ^(NSString *html)
    {
        var divCollection = document.getElementsByTagName("div");
        for (var i=0; i<divCollection.length; i++) {
            if(divCollection[i].getAttribute("class") == "style")
            {
                divText += divCollection[i].innerHTML;
            }
        }
        return divText;
    };
    
    JSValue *d = jsCode = @"findDivClassByName(name);";
    NSLog(@"ALL divs = %@", d);
    return d;

}
 */


@end
