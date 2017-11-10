//
//  XLSDrawingView.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "XLSDrawingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation XLSDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)refreshDrawing
{

    [self setNeedsDisplay];
    
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if ( [self.drawingSource getDocumentType] == kXLS )
    {
        //[self addSubview:self->drawingView];
        
        //UIGraphicsBeginImageContext(self.frame.size);
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1.0,1.0,1.0,0.0);
        
        CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
        
        
        self.autoresizesSubviews = YES;
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        
        //[self storeAsImage:UIGraphicsGetCurrentContext()];
        
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
        [self.drawingSource redrawShapes:UIGraphicsGetCurrentContext()];
        
    }
    
}


@end
