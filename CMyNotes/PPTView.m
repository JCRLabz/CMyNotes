//
//  PPTView.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/9/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "PPTView.h"
#import "DrawingController.h"

@protocol PPTDataSourceFromDrawingView;
@implementation PPTView

-(id)init
{
    self = [super init];
    
    if ( !self )
    {
        return nil;
    }
    return self;
}


- (void)refresh:(int)index
{
    if ( [self.dataSource getDocumentType] == kPPT )
    {
        //self.frame = frame;
        //imageView.bounds = frame;
        self->slideNumber = index;
        //imageView.image = [self.dataSource displayImage:slideNumber forView:self];
        //[self addSubview:imageView];
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //if ( [self.dataSource documentType] == kPPT && [self.dataSource isWebviewActive])
    if ( [self.dataSource getDocumentType] == kPPT )
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        CGContextFillRect(context, self.bounds);
        CGRect frame = [self.dataSource slideFrameSize];
        //create a web view
        /*
         UIWebView *webView = nil;
        for (UIView *view in self.subviews )
        {
            if ( [view isKindOfClass:[UIWebView class]] )
                webView = (UIWebView *)view;
            
            break;
        }
         */
        
        if ( self.webView == nil )
        {
            self.webView = [[UIWebView alloc] init];
            self.webView.frame = CGRectMake(0,0,frame.size.width, frame.size.height);
            [self addSubview:self.webView];

        }
        [self.webView loadHTMLString:[self.dataSource getSlide:slideNumber] baseURL:nil];

/*
        CGFloat scale = MIN(self.bounds.size.width / frame.size.width, self.bounds.size.height / frame.size.height);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextScaleCTM(context, scale, scale);
  */      

        CGRect pageRect = [self.dataSource slideFrameSize];
        float scale = 0.0;
        if ( pageRect.size.width > pageRect.size.height )
            scale = self.frame.size.width/pageRect.size.width;
        else
            scale = self.frame.size.height/pageRect.size.height;
        
        CGContextSaveGState(context);
        
        pageRect.size = CGSizeMake(pageRect.size.width*scale, pageRect.size.height*scale);
        pageRect.origin = CGPointMake((self.frame.size.width-pageRect.size.width)/2.0, 0.0);
        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.height);
        //CGContextScaleCTM(context, 1.0, -1.0);
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        CGContextScaleCTM(context, scale,scale);
        CGContextRestoreGState(context);
    }
    
}

-(NSString *)getSlide
{
    return [self.dataSource getSlide:slideNumber];
    //[self->webView loadHTMLString:slide baseURL:nil];
}

- (void)didMoveToWindow {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        self.contentScaleFactor = 2.0;
    }
    else
    {
        self.contentScaleFactor = 1.0;
        
    }
}
@end

#pragma mark BUGS
//Critical slide moves to below view
