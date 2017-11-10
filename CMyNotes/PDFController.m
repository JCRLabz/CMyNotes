//
//  PDFController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "PDFController.h"
//#import "PDFView.h"
#import <CoreGRaphics/CoreGraphics.h>

@implementation PDFController



-(void)initializeWithURL:(NSURL *)url
{
    pdfurl = url;
    //_document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)(url));
    numberOfPages = (int)[self pageCount];
}

-(NSUInteger)pageCount
{
    
    CGPDFDocumentRef document;
    
    document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfurl);
    NSUInteger pageCount = CGPDFDocumentGetNumberOfPages (document);// 3
    CGPDFDocumentRelease(document);
    return pageCount;
}



-(CGRect)pageFrame:(int)index
{
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfurl);
    
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, index);
    
    CGRect pageSize = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    
    //CGPDFPageRelease(pdfPage);
    CGPDFDocumentRelease(document);
    
    return pageSize;
}

-(int)count
{
    return numberOfPages;
    
}


-(CGPDFPageRef)getPage:(int)pageNumber
{
    //alling method is responsible for releasing the document
    //1. getDocument
    //1a. Check for encrypted
    //2.getPage
    //3 release page
    //4 release document
    
    CGPDFDocumentRef document;
    
    document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfurl);
    

    
    CGPDFPageRef page = CGPDFDocumentGetPage(document, pageNumber);
    CGPDFDocumentRelease(document);
    
    // CGPDFDictionaryRef pageDict = [self getDictionaryForPage:page];
    return page;
}


//    CGPDFDocumentRelease(self.document);

@end
