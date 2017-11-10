//
//  XLSView.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/21/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@protocol XLSDataSource;

@interface XLSView : UIWebView
{
@private int sheetIndex;
}

@property (nonatomic, weak) IBOutlet id <XLSDataSource> dataSource;
- (void)refresh:(int)index;
-(void)initializeView:(CGRect)rect;


@property (nonatomic, strong) UIWebView *webView;

@end

@protocol XLSDataSource <NSObject>

@required
//-(NSString *)getSheetName:(int)index;
-(CGRect)sheetFrameSize;
-(NSString *)getSheet:(int)index;
-(void)redrawShapes:(CGContextRef)context;
-(int)getSheetCount;
-(BOOL)xlsDrawingMode;
@optional
-(DocumentType)getDocumentType;
@end
