//
//  PDFView.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFController.h"
#import "DrawingController.h"

@protocol PDFDataSource;
@protocol DrawingSource;


@interface JCRPDFView : UIView<UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
{
//@private CGPDFPageRef page;
@private int pageNumber;
@private NSURL *url;
}

@property (nonatomic, weak) IBOutlet id <PDFDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <DrawingSource> drawingDataSource;

-(void)refresh:(int)index;
-(void)refreshShapesinRect:(CGRect)rect;
-(void)setURL:(NSURL*)url;
-(NSUInteger)count;



@end

/*
@protocol PDFDataSource <NSObject>

@required
-(int)getPageNumber;
-(CGRect)pageFrame:(CGPDFPageRef)page;
-(DocumentType)getDocumentType;
-(CGPDFPageRef)getPDFPage:(int)index;


@optional
//nothing at present
@end
*/
@protocol DrawingSource <NSObject>

@required
-(int)shapeCount;
//-(void)getShape:(int)index;
//-(void)getDocumentType;
//-(int)getSelectedShapeIndex;
//-(void)drawAShape:(ShapeObject *)shapeObject;
-(void)redrawShapes:(CGContextRef)context;

@optional
//nothing at present
@end
