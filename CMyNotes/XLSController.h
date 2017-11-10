//
//  XLSController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/6/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLSController : NSObject
{
@private NSString *html;
@private NSMutableOrderedSet *sheets;
@private NSMutableArray *sheetSource;
@private NSMutableArray *sheetNames;
@private int sheetCount;
@private BOOL initialized;
}

-(void)initializeWithHTML:(NSString *)inputHtml;
-(int)getSheetCount;
-(NSArray *)getSheetNames;
-(NSArray *)getSheets;
-(int)isInitialized;


@end
