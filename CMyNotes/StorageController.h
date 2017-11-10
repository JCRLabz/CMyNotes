//
//  StorageForDrawingObjects.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 5/12/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface StorageController : NSObject <NSFetchedResultsControllerDelegate>


@property (nonatomic, strong) NSString *documentName;
@property (nonatomic, strong) NSString *documentURL;
@property (nonatomic, strong) NSData *bookmarkURL;
@property (nonatomic, strong) NSData *pageData;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property  NSInteger starred;
@property (nonatomic, strong) NSData *bookmark;
@property  NSInteger bLastSeen;


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(id)initWithName:(NSString*)documentName pageData:(NSData *)pageData shapes:(NSData *)shapes pageNumber:(NSNumber*)pageNumber;

- (void)insertCoreDataObject;
-(BOOL) updateCoreDataObject;
- (NSFetchedResultsController *)fetchedResultsController;
-(void)changeURLFrom:(NSString *)fromURL to:(NSString*)toURL;
-(BOOL)updateCoreDataObjectUsingDocumentName;
-(void)deleteAdObject:(NSString *)adName;



@end
