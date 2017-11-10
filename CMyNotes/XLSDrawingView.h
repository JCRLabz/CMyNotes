//
//  XLSDrawingView.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/28/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@protocol DrawingSource;

@interface XLSDrawingView : UIView

@property (nonatomic, weak) IBOutlet id <DrawingSource> drawingSource;
- (void)refreshDrawing;

@end
@protocol DrawingSource <NSObject>
-(DocumentType)getDocumentType;
-(void)redrawShapes:(CGContextRef)context;
@end
