//
//  CellViewForXLS.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/11/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "CellViewForXLS.h"

@implementation CellViewForXLS

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
        //self.webView.delegate = self;
        self.xlsController = [[XLSController alloc] init];
        self.firstSheet = [[NSString alloc] init];
    }
    return self;
}

-(void)initializeWith:(NSString *)url documentType:(DocumentType)docType
{
    self.url = url;
    self.documentType = docType;
    [self loadDocument];

}

- (void)drawRect:(CGRect)rect
{
    if ( self.documentType == kXLS && self.sheetCount > 0)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        CGContextFillRect(context, self.bounds);
        
        UIWebView *cellView;
        if ( cellView == nil )
        {
            cellView = [[UIWebView alloc] init];
            cellView.frame = self.bounds;
            [self addSubview:cellView];
            cellView.scalesPageToFit = TRUE;
            
        }
        
        if ( self.firstSheet != nil)
            
            [cellView loadHTMLString:self.firstSheet baseURL:nil];
        /*
         CGFloat scale = MIN(self.bounds.size.width / frame.size.width, self.bounds.size.height / frame.size.height);
         CGContextSaveGState(context);
         CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
         CGContextScaleCTM(context, 1.0, -1.0);
         CGContextScaleCTM(context, scale, scale);
         */
        CGRect pageRect = self.frame;
        float scale = 1.0;
        if ( pageRect.size.width > pageRect.size.height )
            scale = self.frame.size.width/pageRect.size.width;
        else
            scale = self.frame.size.height/pageRect.size.height;
        
        CGContextSaveGState(context);
        //pageRect.size = CGSizeMake(pageRect.size.width*scale, pageRect.size.height*scale);
        //pageRect.origin = CGPointMake((self.frame.size.width-pageRect.size.width)/2.0, 0.0);
        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.height);
        //CGContextScaleCTM(context, 1.0, -1.0);
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        //CGContextScaleCTM(context, scale,scale);
        CGContextRestoreGState(context);
    }
}

-(void)loadDocument
{
    
    //NSURL *absoluteURL = [[NSURL alloc] initWithString:[self.url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSString *str = [self url]; // some URL
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSURL *absoluteURL = [[NSURL alloc] initWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:set]];


    self.webView.hidden = FALSE;
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:absoluteURL];
    [self.webView loadRequest:requestObj];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
}


@end
