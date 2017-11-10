//
//  DocumentController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/6/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShapeObject.h"
#import "Utility.h"
#import "Thumbnail.h"

@interface DocumentController : NSObject
{
@private NSMutableDictionary *documentDictionary; //contains page number as key and shapes array
//@private NSMutableArray *removedPages;
@private DocumentType documentType;
@private NSMutableDictionary *thumbnails; //contains an array of PageObjects
@private NSMutableOrderedSet *dirtyPageNumberSet; //holds the page numbers of modified pages
//@private Thumbnail *thumbnail;
}

//-(NSMutableArray *)initializeWithCount:(NSInteger)count;
-(id)getPage:(int)pageNumber;
//-(int)pageCount;
//-(void)addPage:(int)pageNumber;
-(void)removePageForKey:(NSInteger)index url:(NSString*)url;
-(void)insertPage:(id)page atPageNumber:(int)index;

-(NSMutableArray*)getDocument;
-(void)setDocumentType:(DocumentType)documentType;

-(NSMutableDictionary*)dataToDictionary:(NSData*)data;
-(NSData*)prepareForStorage;

//-(void)insertPageAt:(PageObject *)page pageNumber:(int)index;
- (NSData *)dataWithValue:(NSValue *)value;
- (NSValue *)valueWithData:(NSData *)data;
-(NSMutableData *)encodeDocumentDataForPersistentStore;

//-(NSMutableArray *)decodeDocumentData:(NSData *)data;
-(void)decodeDocumentData:(NSData *)data;
-(NSMutableDictionary*)getThumbnails;
-(id)getThumbnail:(int)index;
-(void)constructDictionaryFromCoreData:(NSData *)data;

-(BOOL)containsDirtyKey:(int)index;
-(int)getDirtyPageNumber:(int)index;
-(int)getDirtyPageCount;
-(int)getFirstDirtyPage;
-(NSInteger)getIndexOfDirtyPage:(int)pageIndex;
-(NSArray*)getdirtyIndexArray;

-(NSData *)createPdfForEmail:(NSString *)url;

//thumbnail related
-(void)deleteAllThumbnailsFor:(NSString *)url;
-(void)insertThumbnail:(UIImage *)image pageNumber:(int)index url:(NSString *)url;
-(void)deleteThumbnailAt:(int)pageNumber url:(NSString *)url;

//remove file, ,given its url/filename
//-(void)removeFile:(NSURL *)url;
-(void)removeFile:(NSString *)fileName;


@end
