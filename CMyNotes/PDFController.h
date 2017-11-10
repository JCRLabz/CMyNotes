//
//  PDFController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFController : NSObject
{
@private int numberOfPages;
@private NSURL *pdfurl;
}


-(void)initializeWithURL:(NSURL *)url;
//-(void)initializeWithData:(CGPDFDocumentRef )pdfData;
-(CGRect)pageFrame:(int)pageNumber;
-(CGPDFPageRef)getPage:(int)pageNumber;
-(int)count;
//-(CGRect)pageFrameFor:(CGPDFPageRef)page andPageNumber:(int)pageNumber;


@end
