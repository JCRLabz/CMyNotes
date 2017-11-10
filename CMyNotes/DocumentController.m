//
//  DocumentController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/6/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//
//Document contains the background image and the drawn shapes

#import "DocumentController.h"
#import "StorageController.h"
#import "AppDelegate.h"


@implementation DocumentController
-(id)init
{
    self = [super init];
    if (!self)
        return nil;
    //start with a count of 4
    documentDictionary = [[NSMutableDictionary alloc] init];
    thumbnails = [[NSMutableDictionary alloc] init];
    dirtyPageNumberSet = [[NSMutableOrderedSet alloc ] init];
    //AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
                                              //inManagedObjectContext:[appdelegate managedObjectContext]];
    
    return self;
}


-(int)count
{
    return (int)[documentDictionary count];
}


-(void)removePageForKey:(NSInteger)index url:(NSString *)url
{
    NSString *pageNumberKey = [NSString stringWithFormat:@"%d",(int)index];
    [documentDictionary removeObjectForKey:pageNumberKey];
    [dirtyPageNumberSet removeObject:pageNumberKey];
    //[thumbnails removeObjectForKey:pageNumberKey];
    //and finally remove from the coredata
    [self deleteThumbnailAt:(int)index url:url];
}

-(NSInteger)getIndexOfDirtyPage:(int)pageIndex
{
    NSString *pageNumberKey = [NSString stringWithFormat:@"%d",(int)pageIndex];
    return [dirtyPageNumberSet indexOfObject:pageNumberKey];
}

-(void)insertPage:(id)page atPageNumber:(int)index
{
    NSString *pageNumberKey = [NSString stringWithFormat:@"%d",index];
    [documentDictionary  setObject:page forKey:pageNumberKey];
    [self appendDirtyPageNumberToDirtyPageSet:index];
}


/*
 -(void)insertPageAt:(PageObject *)page pageNumber:(int)index
 {
 @try {
 [pages setObject:page atIndexedSubscript:index];
 }
 @catch (NSException *exception) {
 NSLog(@"Error - %@", exception);
 }
 @catch (NSException *exception) {
 NSLog(@"Range exception = %@",exception);
 }
 
 }
 */

-(NSMutableDictionary *)getDocument
{
    return documentDictionary;
}

-(id)getPage:(int)index
{
    NSString *pageNumberKey = [NSString stringWithFormat:@"%d",index];
    NSMutableArray *page = [documentDictionary valueForKey:pageNumberKey];
    return page;
}

-(void)setDocumentType:(DocumentType)type
{
    documentType = type;
}

-(void)updateThumbnail:(UIImage *)image pageNumber:(int)pageNumber url:(NSString *)url
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Thumbnail *object = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
                                                      inManagedObjectContext:appdelegate.managedObjectContext];
    [object setValue:[NSDate date] forKey:@"timestamp"];
    [object setValue:url forKey:@"documentURL"];
    [object setValue:UIImagePNGRepresentation(image) forKey:@"data"];
    [object setValue:[NSNumber numberWithInt:pageNumber] forKey:@"pageNumber"];
    
    // Save the context.
    NSError *error = nil;
    if (![appdelegate.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

-(void)deleteAllThumbnailsFor:(NSString *)url
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:appdelegate.managedObjectContext]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"documentURL == %@ ", url];
    [fetchRequest setPredicate:predicate];
    
    NSArray * result = [[appdelegate managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    for (NSManagedObject *managedObject in result)
        [[appdelegate managedObjectContext] deleteObject:managedObject];
    
    // Save the context.
    NSError *error = nil;
    if (![[appdelegate managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

-(void)deleteThumbnailAt:(int)pageNumber url:(NSString *)url
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *object = [self fetchThumbnail:url pageNumber:pageNumber];
    
    if ( [object count] > 0 )
    {
    NSManagedObject *managedObject = [object objectAtIndex:0];
    [[appdelegate managedObjectContext] deleteObject:managedObject];

    // Save the context.
    NSError *error = nil;
    if (![[appdelegate managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    }
}

#pragma mark - dirty page operations/methods
-(void)insertThumbnail:(UIImage *)image pageNumber:(int)pageNumber url:(NSString *)url
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *object = [self fetchThumbnail:url pageNumber:pageNumber];
    if ( [object count ] == 0 )
    {
        Thumbnail *thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
                                                             inManagedObjectContext:appdelegate.managedObjectContext];
        [thumbnail setValue:[NSDate date] forKey:@"timestamp"];
        [thumbnail setValue:url forKey:@"documentURL"];
        [thumbnail setValue:UIImagePNGRepresentation(image) forKey:@"data"];
        [thumbnail setValue:[NSNumber numberWithInt:pageNumber] forKey:@"pageNumber"];
        
        // Save the context.
        NSError *error = nil;
        if (![appdelegate.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    else //== 1
    {
        NSManagedObject *managedObject = [object objectAtIndex:0];
        [managedObject setValue:[NSDate date] forKey:@"timestamp"];
        [managedObject setValue:url forKey:@"documentURL"];

        [managedObject setValue:UIImagePNGRepresentation(image) forKey:@"data"];
        [managedObject setValue:[NSNumber numberWithInt:pageNumber] forKey:@"pageNumber"];
        NSError *error = nil;
        if (![appdelegate.managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

-(NSArray *)fetchThumbnail:(NSString *)url pageNumber:(int)pageNumber
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:appdelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"documentURL == %@ AND pageNumber == %@", url, [NSNumber numberWithInt:pageNumber]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageNumber"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [appdelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchedObjects;
}

-(void)reconstructThumbnailsWithSortedKeys:(NSArray *)sortedKeys
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int count = (int)[sortedKeys count];
    for ( int i = 0; i < count; i++)
    {
        [dictionary setObject:[thumbnails objectForKey:[sortedKeys objectAtIndex:i]] forKey:[sortedKeys objectAtIndex:i]];
    }
    thumbnails = [[[NSMutableDictionary alloc]initWithDictionary:dictionary] mutableCopy];
}


-(NSMutableDictionary*)getThumbnails
{
    return thumbnails;
}

-(BOOL)containsDirtyKey:(int)index
{
    NSString *pageNumber = [NSString stringWithFormat:@"%d",index];
    
    if ([dirtyPageNumberSet containsObject:pageNumber])
        return TRUE;
    
    return FALSE;
}

-(id)getThumbnail:(int)index
{
    NSString *pageNumberKey = [NSString stringWithFormat:@"%d",index];
    return  [thumbnails valueForKey:pageNumberKey];
}

-(void)appendDirtyPageNumberToDirtyPageSet:(int)index
{
    NSString *pageNumberString = [NSString stringWithFormat:@"%d",index];
    
    [dirtyPageNumberSet addObject:pageNumberString];
    if ([dirtyPageNumberSet count] > 1 )
        [dirtyPageNumberSet
         sortUsingComparator:(NSComparator)^
         (NSString* obj1, NSString* obj2)
         {
             return [obj1 compare:obj2 options:NSNumericSearch];
         }
         ];
}

-(int)getFirstDirtyPage
{
    if ( [self getDirtyPageCount] > 0)
    {
        NSString *pageNumberString =  [dirtyPageNumberSet objectAtIndex:0];
        return [pageNumberString intValue];
    }
    return -1;
}

-(int)getDirtyPageNumber:(int)index
{
    if ( [self getDirtyPageCount] > 0)
    {
        NSString *pageNumberString =  [dirtyPageNumberSet objectAtIndex:index];
        return [pageNumberString intValue];
    }
    else
        return -1;
}

-(int)getDirtyPageCount
{
    int count = (int)[dirtyPageNumberSet count];
    return count;
}


-(NSArray *)getdirtyIndexArray
{
    return [dirtyPageNumberSet array];
}
#pragma mark - persistent and non-persistent storage methods

-(NSData*)prepareForStorage
{
    NSArray *keys = [documentDictionary allKeys];//[[NSMutableData alloc] init];
    NSArray *values = [documentDictionary allValues];
    
    //NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //[archiver encodeObject:dictionaryOfObjects forKey:@"DirtyPages"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:(NSArray*)keys forKey:@"Keys"];
    [archiver encodeObject:(NSArray*)values forKey:@"Values"];
    
    return data;
}

-(NSMutableDictionary*)dataToDictionary:(NSData*)data
{
    @try
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSArray *keys = [unarchiver decodeObjectForKey:@"Keys"];
        NSArray *values = [unarchiver decodeObjectForKey:@"Values"];
        
        documentDictionary  = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error = %@", exception);
    }
    
    return nil;
}

// Here, data holds the serialized version of your dictionary
// do what you need to do with it before you:

#pragma mark - TODO
//1. add persistence layer
//2. add Dictionary object instead of array
//3. How do we add images to the dictionary


//Useful code
- (NSData *)dataWithValue:(NSValue *)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (NSValue *)valueWithData:(NSData *)data
{
    return (NSValue *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
}


//pack the dictionary into CoreData as binary
-(NSMutableData *)encodeDocumentDataForPersistentStore
{
    __block NSMutableData *coreData = [[NSMutableData alloc]initWithCapacity:4];
    
    //enumerate to get objects and keys
    [documentDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         //1.0 get the page number
         NSString *pageNumberString = key;
         //1.5 get the integer
         NSInteger pageIndex = [pageNumberString integerValue];
         //2.0 convert it into NSData
         NSMutableData *pageNumberData = [NSMutableData dataWithBytes:&pageIndex length:sizeof(pageIndex)];
         /*
          //3.0 get the page Object as NSArray from dictionary
          NSArray *pageArray = obj;
          */
         //4.0 get the shapes from the dictionary array
         NSMutableArray *shapes = obj;
         
         //5.0 convert it into NSData
         NSData * shapeData = [NSKeyedArchiver archivedDataWithRootObject:shapes];
         //6.0 get the size of the shapes in bytes
         NSUInteger size = [shapeData length]; //get the shapes length
         
         //7.0 convert it into NSData
         NSData *shapeSizeData = [NSMutableData dataWithBytes:&size length:sizeof(size)];
         
         //pack the data into a single NSData
         //4 bytes for page number + 4 bytes for shapes data + shapes
         
         //NSLog(@"Size of NSUInteger = %ld", sizeof(NSUInteger));
         [coreData appendData:pageNumberData];
         [coreData appendData:shapeSizeData];
         [coreData appendData:shapeData];
         /*
          NSInteger pn = 0, sz = 0;
          
          NSData *data1 = [coreData subdataWithRange:NSMakeRange(0, sizeof(pn))];
          NSData *data2 = [coreData subdataWithRange:NSMakeRange(4, sizeof(sz))];
          
          [data1 getBytes:&pn length:sizeof(pn)];
          [data2 getBytes:&sz length:sizeof(sz)];
          */
         //convert it to NSInteger
         //[data1 getBytes:&pn length:sizeof(NSInteger)];
     }];
    return coreData;
}

//decode the coredata and make it available in the documentDictionary
//first 4 bytes for pageNumber
//next four contains the size of the shapes
//shapes start from 8 to size of shapes
//+----------------------+--------------------+-----------------+
//|page number - 4 bytes | size of shape data | shapes data     |
//+----------------------+--------------------+-----------------+
//-(NSMutableArray *)decodeDocumentData:(NSData *)data
-(void)decodeDocumentData:(NSData *)data
{
    //NSMutableArray *arrayOfObjects = [[NSMutableArray alloc] initWithCapacity:3]; //will be removed
    //Array order - 1) Page number, 2) page itself, 3) shapes drawn
    
    //get the size of the data
    NSInteger length = [data length];
    NSInteger counter = 0;
    NSData *temp;
    
    while ( counter < length)
    {
        NSInteger pageNumber = 0, sizeOfShapes = 0;
        //get the page number - 4 bytes
        temp = [data subdataWithRange:NSMakeRange(counter, sizeof(pageNumber))];
        [temp getBytes:&pageNumber length:sizeof(pageNumber)];
        //increment the counter by sizeof(pageNumber)
        counter += sizeof(pageNumber);
        
        //get the size of shapes data
        temp = [data subdataWithRange:NSMakeRange(counter, sizeof(sizeOfShapes))];
        [temp getBytes:&sizeOfShapes length:sizeof(sizeOfShapes)];
        //increment the counter by sizeof(sizeOfShapes)
        counter += sizeof(sizeOfShapes);
        //get the shapes data
        temp = [data subdataWithRange:NSMakeRange(counter, sizeOfShapes)];
        
        //NSData *shapeData = [NSCoder decodeObjectForKey:@"shapesCollection"];
        NSMutableArray *shapeArray = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
        //increment the counter by sizeOfShapes
        counter += sizeOfShapes;
        
        //construct documentDictionary with shapesarray and page number as the key
        [self insertPage:shapeArray atPageNumber:(int)pageNumber];
        /*
         NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
         [array addObject:[NSNumber numberWithInt:pageNumber]];
         [array addObject:shapeArray];
         [arrayOfObjects addObject:array];
         */
        
    }
}

-(void)constructDictionaryFromCoreData:(NSData *)data
{
    [self decodeDocumentData:data];
}

#pragma mark - creating PDF Files

-(NSData *)createPdfForEmail:(NSString *)url
{
    /*
     __block NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    
    //[dirtyPageNumberSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    [thumbnails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         //NSLog(@"Indexe = %ld, value = %@", (unsigned long)idx, obj);
         UIImage *image = (UIImage*)obj;
         
         CGRect rect = CGRectMake(0, 0,image.size.width,image.size.height);
         UIGraphicsBeginPDFPageWithInfo(rect, nil);
         [image drawInRect:rect];
         
     }];
    UIGraphicsEndPDFContext();

    return pdfData;
     */
     /*
     NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
     
     NSString* documentDirectory = [documentDirectories objectAtIndex:0];
     NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:@"TESTINGEMAIL"];
     
     // instructs the mutable data object to write its context to a file on disk
     [pdfData writeToFile:documentDirectoryFilename atomically:YES];
     NSLog(@"documentDirectoryFileName: %@",documentDirectoryFilename);*/   
    /*
     [thumbnails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
     UIImage *image = (UIImage*)obj;
     
     CGRect rect = CGRectMake(0, 0,image.size.width ,image.size.height);
     UIGraphicsBeginPDFPageWithInfo(rect, nil);
     [image drawInRect:rect];
     }];
     
     UIGraphicsEndPDFContext();
     
     return (pdfData);
     */

     NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:appdelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"documentURL == %@ ", url];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageNumber"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [appdelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        /*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel!"
                                              otherButtonTitles:nil];
        [alert show];
         */
    }
    
    int count = (int)[fetchedObjects count];
    
    for ( int i = 0; i < count; i++ )
    {
        NSManagedObject *managedObject = [fetchedObjects objectAtIndex:i];
        
        UIImage *image = [UIImage imageWithData:[managedObject valueForKey:@"data"]];

        ;
        //check for retina
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
             image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];

        CGSize newSize;
        newSize.height = image.size.height/2.0;
        newSize.width = image.size.width/2.0;
        //image = [self scaleImage:image size:newSize];
        CGRect rect = CGRectMake(0, 0,image.size.width ,image.size.height);
        UIGraphicsBeginPDFPageWithInfo(rect, nil);
        [image drawInRect:rect];
    }
    
    UIGraphicsEndPDFContext();
    
    
    /*Remove tihs after testing
    NSArray* applicationSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES);
    
    NSString* applicationSupportDirectory = [applicationSupportDirectories objectAtIndex:0];
    NSString* filename = [applicationSupportDirectory stringByAppendingPathComponent:@"TESTINGEMAIL.pdf"];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:filename atomically:YES];

    NSLog(@"documentDirectoryFileName: %@",filename);*/
    
    /*[self createTextPDFForEmail:url];

    Remove tihs after testing */

    return (pdfData);
}

- (UIImage *)scaleImage:(UIImage*)image size:(CGSize)size
{
    CGRect imageBounds = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to KCGinterpolation to high
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    
    CGContextConcatCTM(context, transform);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, imageBounds, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *scaledImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    
    return scaledImage;
}

-(void)removeFile:(NSString *)fileName
{
    
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *resourcePath = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, fileName];
    NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[url path]] == YES) {
        NSError *error;
        if (![fileManager removeItemAtURL:url error:&error])
        {
            NSLog(@"Error removing file: %@", error);
        };
    }
}

#pragma mark NEXT Release
-(NSData *)createTextPDFForEmail:(NSString *)url
{
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

    //set up PDF reading
    NSURL *nsURL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)nsURL);
    
    //int count = (int)[fetchedObjects count];
    
    //get dirtyPage count
    int count = [self getDirtyPageCount];
    
    for ( int i = 0; i < count; i++ )
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        int pageNumber = [self getDirtyPageNumber:i];
        
        //NSLog(@"Page number = %d", pageNumber);
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, pageNumber);
        const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);

        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);

        //	Draw the page (flipped)
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);
        
        //draw shapes for page
        [self drawShapesForPageWithContext:ctx frame:pageFrame pageNumber:pageNumber];
        
        
    }
    UIGraphicsEndPDFContext();
    
    
    NSArray* applicationSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES);
    
    NSString* applicationSupportDirectory = [applicationSupportDirectories objectAtIndex:0];
    NSString* filename = [applicationSupportDirectory stringByAppendingPathComponent:@"TESTINGTEXTEMAIL.pdf"];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:filename atomically:YES];
    CGPDFDocumentRelease(pdf);

    //NSLog(@"documentDirectoryFileName: %@",filename);
    return (pdfData);
}


-(void)drawShapesForPageWithContext:(CGContextRef )context frame:(CGRect)frame pageNumber:(int)pageNumber
{
    NSMutableArray *shapes = [self getPage:pageNumber];
    CGPoint scale;

    
    scale.x = frame.size.width/768;
    scale.y = frame.size.height/1024;
    
    
    for ( ShapeObject *shape in shapes)
    {
        CGContextBeginPath(context);
        
        CGContextSetLineWidth(context, shape.lineWidth*scale.x);
        CGContextSetStrokeColorWithColor(context, [shape.color  CGColor]);
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        CGContextSetAlpha(context, shape.alpha);
        
        if ( shape.type == kLine || shape.type == kHighlighter )
        {
            CGContextMoveToPoint(context, shape.origin.x*scale.x, shape.origin.y*scale.y);
            CGContextAddLineToPoint(context, shape.end.x*scale.x, shape.end.y*scale.y);
        }
        else if ( shape.type == kRectangle)
        {
            CGContextAddRect(context, CGRectMake(shape.origin.x*scale.x,
                                                 shape.origin.y*scale.y,
                                                 shape.end.x*scale.x - shape.origin.x*scale.x,
                                                 shape.end.y*scale.y - shape.origin.y*scale.y));
        }
        else if ( shape.type == kCircle)
        {
            CGContextAddEllipseInRect(context, CGRectMake(shape.origin.x*scale.x,
                                                 shape.origin.y*scale.y,
                                                 shape.end.x*scale.x - shape.origin.x*scale.x,
                                                 shape.end.y*scale.y - shape.origin.y*scale.y));
        }
        
        else if ( shape.type == kFreeform)
        {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(scale.x, scale.y);
            [shape.bzPath applyTransform:transform];
            CGContextAddPath(context, shape.bzPath.CGPath);

        }
        else //text
        {
            
        }
        
        CGContextDrawPath(context, kCGPathFillStroke);

    }
}
/*
 
 -(void) createPDFFile:(NSString *)fileName
 {
 CGContextRef pdfContext;
 CFURLRef url;
 CFDataRef boxData = NULL;
 CFMutableDictionaryRef myDictionary = NULL;
 CFMutableDictionaryRef pageDictionary = NULL;
 
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
 
 NSURL *nsURL = [[NSURL alloc] initWithString:path];
 url = (__bridge CFURLRef)(nsURL);
 
 url = CFURLCreateWithFileSystemPath (NULL, (__bridge CFStringRef)(path), kCFURLPOSIXPathStyle, 0);
 
 myDictionary = CFDictionaryCreateMutable(NULL, 0,
 &kCFTypeDictionaryKeyCallBacks,
 &kCFTypeDictionaryValueCallBacks); // 4
 CFDictionarySetValue(myDictionary, kCGPDFContextTitle, (__bridge const void *)(fileName));
 CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("CMyNotes"));
 
 pdfContext = CGPDFContextCreateWithURL (url, NULL, myDictionary); // 5
 CFRelease(myDictionary);
 CFRelease(url);
 pageDictionary = CFDictionaryCreateMutable(NULL, 0,
 &kCFTypeDictionaryKeyCallBacks,
 &kCFTypeDictionaryValueCallBacks); // 6
 boxData = CFDataCreate(NULL,(const UInt8 *)NULL, sizeof (CGRect));
 CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
 CGPDFContextBeginPage (pdfContext, pageDictionary); // 7
 myDrawContent (pdfContext);// 8
 CGPDFContextEndPage (pdfContext);// 9
 CGContextRelease (pdfContext);// 10
 CFRelease(pageDictionary); // 11
 CFRelease(boxData);
 }
 */
//[mailComposer addAttachmentData:pdfData mimeType:@"pdf" fileName:@"file.pdf"];
//Arranges the images in the ascending order
@end
