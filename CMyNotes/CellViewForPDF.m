//
//  CellViewForPDF.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "CellViewForPDF.h"

@implementation CellViewForPDF

- (id)initWithFrame:(CGRect)frame url:(NSURL*)pdfurl
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self.pdfController = [[PDFController alloc] init];
        [self setURL:pdfurl];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, self.pageNumber);
    
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context, self.bounds);
    self.autoresizesSubviews = YES;

    //setup background pattern
    CGRect pageRect = [self pageFrame:self.pageNumber ];

    float scale = 0.0;
    //if ( pageRect.size.width > self.frame.size.height )
        scale = self.frame.size.width/pageRect.size.width;
    //else
        //scale = self.frame.size.height/pageRect.size.height;
    
    CGContextSaveGState(context);

    pageRect.size = CGSizeMake(pageRect.size.width*scale, pageRect.size.height*scale);
    pageRect.origin = CGPointMake((self.frame.size.width-pageRect.size.width)/2.0, 0.0);
    
    
    if ( pageRect.size.width > pageRect.size.height )
        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.width);
    else
        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.height);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
    CGContextScaleCTM(context, scale,scale);
    
    //CGPDFDocumentRef document = [self.pdfController getPDFDocument];
    
    CGContextDrawPDFPage(UIGraphicsGetCurrentContext(), pdfPage);
    
    //release them
    //CGPDFPageRelease(pdfPage);
    CGPDFDocumentRelease(document);

    //[self drawPDFPageInRect:context pdfPage:page box:kCGPDFTrimBox rect:pageRect rotation:0 preserveAspectRatio:YES];
    CGContextRestoreGState(context);
}

/*
-(CGPDFPageRef)getFirstPage
{
    return [self.pdfController getPage:1];
}

-(CGPDFPageRef)getPDFPage:(int)index
{
    return [self.pdfController getPage:index];
}


-(int)pageCount
{
    return [self.pdfController count];
}
 */

#pragma mark - PDF reading


-(void)setURL:(NSURL *)documentURL
{

    url = documentURL;
}

-(NSUInteger)count
{
    
    CGPDFDocumentRef document;
    
    document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    NSUInteger pageCount = CGPDFDocumentGetNumberOfPages (document);// 3
    CGPDFDocumentRelease(document);

    return pageCount;
}



-(CGRect)pageFrame:(int)index
{
    CGPDFDocumentRef document;

    document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, index);
    
    CGRect pageSize = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    
    CGPDFDocumentRelease(document);
    
    return pageSize;
}


-(CGRect)pageFrame:(CGPDFPageRef)pdfPage forPageNumber:(int)index
{
    CGRect frame;
    CGPDFDocumentRef document;
    
    document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    
    pdfPage = CGPDFDocumentGetPage(document, index);
    
    frame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    
    //CGPDFPageRelease(pdfPage);
    CGPDFDocumentRelease(document);
    
    return frame;
}


- (void)didMoveToWindow
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        //self.contentScaleFactor = 2.0;
    }
    else
    {
        //self.contentScaleFactor = 1.0;
    }
}

@end
