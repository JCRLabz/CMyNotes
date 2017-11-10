//
//  XLSController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/6/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "XLSController.h"

@implementation XLSController

//static int initializedCounter = 0; //BAD CODE - The number of instantialtion of this class will be equal to the number of sheets in the xls. This should be avoided.

-(id) init
{
    self = [super init];
    if ( self  )
    {
        self->sheets = [[NSMutableOrderedSet alloc] init];
        self->sheetNames = [[NSMutableArray alloc] init];
        initialized = FALSE;
        return self;
    }
    return nil;
}

/*
-(void)findNumberOfSheets
{
    sheetCount = 0;
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"id\b*=\"Tab\\d+\"" options:NSRegularExpressionCaseInsensitive error:&error];
    sheetCount = [regex numberOfMatchesInString:self->html options:0 range:NSMakeRange(0, [self->html length])];
}
*/
-(int)getSheetCount
{
    return (int)[sheets count];
}

-(void)initializeWithHTML:(NSString *)inputHtml
{
    self->html = inputHtml;
    
    [self constructSheetsForDisplay];
    [self collectSheetNames];
 
    NSString *beginDiv1 = @"</head><body><div id=\"wrapper\" style=\"position:absolute; top:40; left:0; right:0; \"><iframe height=100% width=100%";//id=\"SheetFrame";
 
    NSString *src = @"src=";
     
    NSString *endDiv0 = @" style=\"border:0; width:100%; height:100%;\"> </iframe>";
    NSString *endDiv2 = @"</div>";
    
    int count = (int)[sheets count];
    for ( int i = 0; i < count; i++)
    {
        NSString *sheet = [sheets objectAtIndex:i];
        
        //insert div portion
        NSString *endDiv1 = [NSString stringWithFormat:@"%@%@",endDiv0, endDiv2];
        //title for the tab
        NSString *title = [NSString stringWithFormat:@"<font color = \"23b2ff\" face=\"Arial\" size=\"5\"><b><i><u>Sheet %d:</u>  %@</i></b></font>",i, [self->sheetNames objectAtIndex:i]];
        
        NSString *tempSheet = [NSString stringWithFormat:@"%@ %@ %@%@%@",title, beginDiv1, src,sheet, endDiv1];
        

        [sheets replaceObjectAtIndex:i withObject:tempSheet];
    }
}

-(void)collectSheetNames
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:self->html];
    
    while ( [scanner isAtEnd] != TRUE)
    {
        if ( [scanner scanUpToString:@"<div onclick" intoString:NULL] )
        {
            NSString *sheet;
            [scanner scanUpToString:@">" intoString:NULL];
            [scanner scanUpToString:@"<" intoString:&sheet];

            if ( sheet == nil)
                break;
            //remove the first character of the sheet "<"
            sheet = [sheet substringFromIndex:1 ];
            [sheetNames addObject:sheet];
        }
    }
}

-(NSString *)getSheet:(int)sheetIndex
{
    return [self->sheets objectAtIndex:sheetIndex];
}

-(void)constructSheetsForDisplay
{
    NSError *error = NULL;
 
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"'x-apple-ql-id(.*?)'" options:NSRegularExpressionCaseInsensitive error:&error];
   
    NSArray *xlsSheets = [regex matchesInString:self->html options:NSMatchingReportProgress range:NSMakeRange(0, [self->html length])];
    
    
    
    for (NSTextCheckingResult *match in xlsSheets)
    {
        NSString* substringForMatch = [self->html substringWithRange:match.range];
        //NSLog(@"Extracted data: %@",substringForMatch);
        [sheets addObject:substringForMatch];
    }

}

-(NSArray *)getSheetNames
{
    return sheetNames;
}

-(NSArray *)getSheets
{
    return [sheets array];
}

-(int)isInitialized
{
    return initialized;
}
@end

//BUGS failed in scanner code????
