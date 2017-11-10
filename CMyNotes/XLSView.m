//
//  XLSView.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/21/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "XLSView.h"
#import <QuartzCore/QuartzCore.h>

@implementation XLSView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.scalesPageToFit = TRUE;
        self.userInteractionEnabled = FALSE;
    }
    return self;
}

-(void)initializeView:(CGRect)rect
{
}

- (void)refresh:(int)index
{
    
     if ( [self.dataSource getDocumentType] == kXLS )
    {
        //self.frame = frame;
        //imageView.bounds = frame;
        sheetIndex = index;
        //imageView.image = [self.dataSource displayImage:slideNumber forView:self];
        [self loadHTMLString:[self getSheet:index] baseURL:nil];
        //[self addSubview:imageView];
        ;
    }
    
    [self setNeedsDisplay];

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

 - (void)drawRect:(CGRect)rect
{
    // Drawing code
    BOOL readOnly = [self.dataSource xlsDrawingMode];
    if ( ([self.dataSource getDocumentType] == kXLS ) && (readOnly == YES ) )
    {
        
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1.0,1.0,1.0,1.0);
        
        CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);

        
        //self.autoresizesSubviews = YES;
        CGContextSaveGState(UIGraphicsGetCurrentContext());

        //[self storeAsImage:UIGraphicsGetCurrentContext()];

        CGContextRestoreGState(UIGraphicsGetCurrentContext());
        [self.dataSource redrawShapes:UIGraphicsGetCurrentContext()];


    }
    
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

-(NSString *)getSheet:(int)index
{
    return [self.dataSource getSheet:index];
}


@end
