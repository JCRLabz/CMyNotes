//
//  PPTView.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/9/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingController.h"
#import "Utility.h"

@protocol PPTDataSource;

@interface PPTView : UIView<UIWebViewDelegate>
{
//@private UIImageView *imageView;
@private int slideNumber;

}
@property (nonatomic, weak) IBOutlet id <PPTDataSource> dataSource;
- (void)refresh:(int)index;
@property (nonatomic, strong) UIWebView *webView;

@end

@protocol PPTDataSource <NSObject>

@required
-(int)getSlideNumber:(PPTView*)view;
-(UIImage*)displayImage:(int)slideNumber forView:(PPTView*)view;
-(CGRect)slideFrameSize;
-(BOOL)isWebviewActive;
-(NSString *)getSlide:(int)slideIndex;
@optional
-(DocumentType)getDocumentType;
@end