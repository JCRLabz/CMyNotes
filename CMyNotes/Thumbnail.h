//
//  Thumbnail.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 9/29/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"


@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSDate * timestamp;


-(void) updateCoreDataObject;
-(void) insertCoreDataObject;
-(id)initWithDate:(NSDate *)timestamp pageData:(NSData *)thumbnail pageNumber:(int)pageNumber;
@end
