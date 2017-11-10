//
//  CellViewForXLS.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/11/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLSController.h"
#import "Utility.h"

@interface CellViewForXLS : UIWebView

//page number to display
@property int sheetNumber;

@property int sheetCount;
@property (strong, nonatomic) NSString *url;
@property (nonatomic, strong) XLSController *xlsController;
@property DocumentType documentType;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *firstSheet;

-(void)initializeWith:(NSString *)url documentType:(DocumentType)docType;

@end
