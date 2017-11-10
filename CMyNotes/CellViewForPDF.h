//
//  CellViewForPDF.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFController.h"


@interface CellViewForPDF : UIView
{
    //page number to display
    @private NSURL *url;
}
@property int pageNumber;


//@property (nonatomic, strong) PDFController *pdfController;

//-(int)pageCount;
-(id)initWithFrame:(CGRect)frame url:(NSURL*)url;
-(void)setURL:(NSURL*)url;
-(NSUInteger)count;

@end
