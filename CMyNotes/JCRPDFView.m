//
//  PDFView.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/5/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "JCRPDFView.h"

@implementation JCRPDFView

-(id)init
{
    self = [super init];
    //self.contentScaleFactor = 2.0;
    
    if ( !self )
    {
        return nil;
    }
    CATiledLayer *tempTiledLayer = (CATiledLayer*)self.layer;
    tempTiledLayer.levelsOfDetail = 5;
    tempTiledLayer.levelsOfDetailBias = 2;
    self.opaque=YES;
    return self;
}

- (void)refresh:(int)index
{
    //if ( [self.dataSource getDocumentType] == kPDF )
    {
        pageNumber = index;
        self.contentMode = UIViewContentModeScaleAspectFit;

        [self setNeedsDisplay];
    }
}

- (void)refreshShapesinRect:(CGRect)rect
{
    [self setNeedsDisplayInRect:rect];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, pageNumber);
    
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context, self.bounds);
    //self.autoresizesSubviews = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;

    //setup background pattern
    CGRect pageRect = [self pageFrame:pageNumber ];
    
    float scale = 0.0;
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    //if ( orientation == UIDeviceOrientationPortrait )
    if ( pageRect.size.width > self.frame.size.width )
        scale = self.frame.size.width/pageRect.size.width;
    else
        scale = self.frame.size.height/pageRect.size.height;
    
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
    [self.drawingDataSource redrawShapes:UIGraphicsGetCurrentContext()];
}


/*
- (void)drawRect:(CGRect)rect
{
    
 
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if ( ctx != nil )
    {
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, pageNumber);
    
    
    CGRect drawingRect = CGContextGetClipBoundingBox(ctx);

    CGContextSetRGBFillColor(ctx, 1.0,1.0,1.0,1.0);

    //CGContextFillRect(ctx, drawingRect);

    self.autoresizesSubviews = YES;
    
//    //setup background pattern
//    CGRect pageRect = [self pageFrame:pageNumber ];
//    
//    float scale = 1.0;
//    if ( pageRect.size.width > pageRect.size.height )
//        scale = self.bounds.size.width/pageRect.size.width;
//    else
//        scale = self.bounds.size.height/pageRect.size.height;
//    
//    CGContextSaveGState(context);
//    
//    pageRect.size = CGSizeMake(pageRect.size.width*scale, pageRect.size.height*scale);
//    pageRect.origin = CGPointMake((self.bounds.size.width-pageRect.size.width)/2.0, 0.0);
//    
//
//    
//    if ( pageRect.size.width > pageRect.size.height )
//        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.width);
//    else
//        CGContextTranslateCTM(context, pageRect.origin.x, pageRect.size.height);
//    
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
//    CGContextScaleCTM(context, scale,scale);
//    
//    //CGPDFDocumentRef document = [self.pdfController getPDFDocument];
//    
//    CGContextDrawPDFPage(UIGraphicsGetCurrentContext(), pdfPage);
//    
//
//    CGPDFDocumentRelease(document);
     
 
    CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    CGFloat scale = MIN(self.bounds.size.width / pageRect.size.width, self.bounds.size.height / pageRect.size.height);
    CGContextSaveGState(ctx);

    // PDF might be transparent, assume white paper
    [[UIColor whiteColor] set];
    CGContextFillRect(ctx, drawingRect);
    
    // Flip coordinates
    CGContextGetCTM(ctx);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);

    CGContextScaleCTM(ctx, 1, -1);
    //CGContextScaleCTM(ctx, scale, scale);

        
    CGRect mediaRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFTrimBox);
    CGContextScaleCTM(ctx, rect.size.width / mediaRect.size.width,
                      rect.size.height / mediaRect.size.height);
    CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y);
    
    // draw it
    CGContextDrawPDFPage(ctx, pdfPage);
    CGPDFDocumentRelease(document);
    
    CGContextRestoreGState(ctx);
    [self.drawingDataSource redrawShapes:UIGraphicsGetCurrentContext()];
    }
    
}
*/

-(BOOL)isPDFProtected:(CGPDFDocumentRef)document
{
    if (CGPDFDocumentIsEncrypted (document)) {// 3
        if (!CGPDFDocumentUnlockWithPassword (document, "")) {
            [self passwordAlertView];
            return YES;
            
        }
    }
    if (!CGPDFDocumentIsUnlocked (document)) {// 4
        CGPDFDocumentRelease(document);
        return NO;
        //return EXIT_FAILURE;
    }
    return NO;
}

/*
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen.
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.frame;
    
    // Center horizontally.
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frameToCenter.origin.x = iPad_X_Origin;
        }
        else
        {
            frameToCenter.origin.x = iPhone_X_Origin;
        }
    }
    
    // Center vertically.
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frameToCenter.origin.x = iPad_Y_Origin;
        }
        else
        {
            frameToCenter.origin.x = iPhone_Y_Origin;
        }
    }
    self.frame = frameToCenter;
    //self.contentScaleFactor = 2.0;
}
*/

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"Page %ld", (long)pageNum];
    //UIFont *theFont = [UIFont systemFontOfSize:12];
    CGSize maxSize = CGSizeMake(612, 72);
    
    /*CGSize pageStringSize = [pageString sizeWithFont:theFont
     constrainedToSize:maxSize
     lineBreakMode:UILineBreakModeClip];*/
    
    //NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
    //drawingContext.minimumScaleFactor = 0.5;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    CGRect pageStringBoundingBox = [pageString boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    CGRect stringRect = CGRectMake(((612.0 - pageStringBoundingBox.size.width) / 2.0),
                                   720.0 + ((72.0 - pageStringBoundingBox.size.height) / 2.0),
                                   pageStringBoundingBox.size.width,
                                   pageStringBoundingBox.size.height);
    
    //deprecated[pageString drawInRect:stringRect withFont:theFont];
    
    [pageString drawInRect:stringRect withAttributes:attributes];
}

#pragma mark - BUGS
//1. scale based on the orientation of the device
//consider using this - CRITICAL

/* USEFUL?
 -(void)drawPDFPageInRect: (CGContextRef) context pdfPage:(CGPDFPageRef) pdfPage box:(CGPDFBox) box rect:(CGRect) rect rotation:(int)rotation  preserveAspectRatio:(BOOL)preserveAspectRatio
 
 {
 CGAffineTransform m;
 
 m = CGPDFPageGetDrawingTransform (pdfPage, box, rect, rotation,// 1
 preserveAspectRatio);
 CGContextSaveGState (context);// 2
 CGContextConcatCTM (context, m);// 3
 CGContextClipToRect (context,CGPDFPageGetBoxRect (page, box));// 4
 CGContextDrawPDFPage (context, page);// 5
 CGContextRestoreGState (context);// 6
 }
 
 */

- (void)didMoveToWindow
{
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        //self.contentScaleFactor = 2.0;
    }
    else
    {
       // self.contentScaleFactor = 1.0;
        
    }
    
}

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
    
    //CGPDFPageRelease(pdfPage);
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


// useful code - NOT USED
-(CGPDFDictionaryRef)getDictionaryForPage:(CGPDFPageRef)pdfPage
{
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pdfPage);
    
    CGPDFArrayRef pageBoxArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "MediaBox", &pageBoxArray)) {
        return nil; // we've got something wrong here!!!
    }
    int pageBoxArrayCount = (int)CGPDFArrayGetCount( pageBoxArray );
    CGPDFReal pageCoords[4];
    for( int k = 0; k < pageBoxArrayCount; ++k )
    {
        CGPDFObjectRef pageRectObj;
        if(!CGPDFArrayGetObject(pageBoxArray, k, &pageRectObj))
        {
            return nil;
        }
        
        CGPDFReal pageCoord;
        if(!CGPDFObjectGetValue(pageRectObj, kCGPDFObjectTypeReal, &pageCoord)) {
            return nil;
        }
        
        pageCoords[k] = pageCoord;
    }
    /*
     NSLog(@"PDF coordinates -- bottom left x %f  ",pageCoords[0]); // should be 0
     NSLog(@"PDF coordinates -- bottom left y %f  ",pageCoords[1]); // should be 0
     NSLog(@"PDF coordinates -- top right   x %f  ",pageCoords[2]);
     NSLog(@"PDF coordinates -- top right   y %f  ",pageCoords[3]);
     NSLog(@"-- i.e. PDF page is %f wide and %f high",pageCoords[2],pageCoords[3]);
     */
    return pageDictionary;
}

-(void)passwordAlertView
{
 /*
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" "     message:@""
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    // UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10,350,55, 25)];
    
    //CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    //[alert setTransform:myTransform];
    alert.tag = 100249;
    
    // Give the text field some unique tag
    //[textField setTag:10250];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    //[textField setBackgroundColor:[UIColor greenColor]];
    //[alert addSubview:textField];
    //[self addSubview:textField];
    
    [alert show];
  */
}
/*
- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Get the field you added to the alert view earlier (you should also
    // probably validate that this field is there and that it is a UITextField but...)
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSLog(@"Entered text: %@", [textField text]);
}
*/
-(void)getPage
{
    
}


@end
