
//
//  CNotesLibraryViewController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/24/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "CMyNotesLibraryViewController.h"
//#import "AddViewController.h"
#import "CellViewForPDF.h"
#import "LibraryCell.h"
#import "DocumentController.h"
//#import "CellViewForXLS.h"
#import <TargetConditionals.h>
#import "ApplicationSettingsController.h"

BOOL addFile = NO;

@interface CMyNotesLibraryViewController ()
{
}

@end

@implementation CMyNotesLibraryViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

-(void)initializeFromOpenIn:(NSDate*)date
{
    self.itemDateFromOpenIn = date;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.drawingController = [[DrawingController alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayNewFileCreationSheet:)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    isAppLaunchedFirstTime = YES;
    self.addWebPage = NO;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectObjectFromOpenIn:)
                                                 name:@"ObjectFromOpenIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged)
                                                 name:@"SettingsChanged"
                                               object:nil];
    
    //notfication from DrawingController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backToHome:)
                                                 name:@"BackToHome"
                                               object:nil];

}

- (void)displayNewFileCreationSheet:(id)sender
{
    self.createPDFDocumentSheet = [UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blankPDFFileCreation;
    blankPDFFileCreation = [UIAlertAction actionWithTitle:@"Create a blank PDF" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [self createBlankPDFFile];
                                                  }];
    
    [self.createPDFDocumentSheet addAction:blankPDFFileCreation];
    
    UIAlertAction *createPDFFromWebPages = [UIAlertAction actionWithTitle:@"Create PDF File from Web Pages" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self createNewFileFromWebPage];
                                                                  }];
    
    [self.createPDFDocumentSheet addAction:createPDFFromWebPages];
    
    self.createPDFDocumentSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:self.createPDFDocumentSheet animated:YES
                     completion:nil];
    
}

-(void)createBlankPDFFile
{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Create a blank PDF file"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //setUpDocument
                                                   
                                                   if (![self setupPDFDocument:alert] )
                                                   {
                                                       [self presentViewController:alert animated:YES completion:nil];
                                                       
                                                   }
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name of the file to be saved";
         
     }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)createNewFileFromWebPage
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Create a PDF file from WebContent"
                                  message:@"Note:Most URLS are converted into PDF"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //setUpDocument
                                                   
                                                   if (![self setupHTTPDocument:alert] )
                                                   {
                                                       [self presentViewController:alert animated:YES completion:nil];
                                                       
                                                   }
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name of the file to be saved";
     }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Type or copy the URL here";
     }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//-(void)setupHTTPDocument:(NSArray *)array
-(BOOL)setupHTTPDocument:(UIAlertController *)alert
{
    //Initialize
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *array = alert.textFields;
    
    UITextField *title = [array objectAtIndex:0];
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *trimmedReplacementOfTitle = [[title.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    if ( [trimmedReplacementOfTitle length] == 0 )
        return FALSE;
    
    UITextField *urlField = [array objectAtIndex:1];
    if ( ![Utility isValidUrl:urlField.text] )
    {
        NSLog(@"Error in the URL");
        urlField.layer.borderColor = [UIColor redColor].CGColor;
        alert.message = @"error in the URL";
        return FALSE;
    }
    else
    {
        self.addWebPage = YES;
        NSURL *url = [Utility createItemAtApplicationSupportDirectory:[NSString stringWithFormat:@"%@", trimmedReplacementOfTitle]];
        [objectDictionary setObject:[url lastPathComponent] forKey:@"documentName"];
        [objectDictionary setObject:urlField.text forKey:@"documentURL"];
        [objectDictionary setObject:[NSDate date] forKey:@"timestamp"];
        [appSettingsController insertCoreDataObjectFromOpenIn:objectDictionary];
    }
    return TRUE;
}


-(BOOL)setupPDFDocument:(UIAlertController *)alert
{
    //Initialize
    ApplicationSettingsController *appSettingsController = [[ApplicationSettingsController alloc] init];
    NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];
    NSArray *array = alert.textFields;
    UITextField *title = [array objectAtIndex:0];
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *trimmedReplacementOfTitle = [[title.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    if ( [trimmedReplacementOfTitle length] == 0 )
        return FALSE;

    self.addWebPage = YES;
        
    NSURL *url = [Utility createItemAtApplicationSupportDirectory:[NSString stringWithFormat:@"%@", trimmedReplacementOfTitle]];
    [objectDictionary setObject:[url lastPathComponent] forKey:@"documentName"];
    [objectDictionary setObject:[url absoluteString] forKey:@"documentURL"];
    [objectDictionary setObject:[NSDate date] forKey:@"timestamp"];
    
    [appSettingsController insertCoreDataObjectFromOpenIn:objectDictionary];
    
    [self createBlankPDFDocument:url dictionary:objectDictionary];
    return TRUE;
}

-(NSData *)createBlankPDFDocument:(NSURL *)url dictionary:(NSMutableDictionary *)dictionary
{
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    
    //set up PDF reading
    //NSURL *nsURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    //only one page for this release
    int count = 2;
    
    for ( int i = 0; i < count; i++ )
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        //NSLog(@"Page number = %d", pageNumber);
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, count);
        //const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        CGRect pageFrame = [Utility deviceBounds];
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        
        //	Draw the page (flipped)
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);
        
        //draw shapes for page
        if ( i == 0 )
        {
            //create the cover page
            [self drawCoverPage:ctx dictionary:dictionary];
        }
        else
            [self drawPageNumber:i];
    }
    UIGraphicsEndPDFContext();
    
    NSArray* applicationSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES);
    NSString* applicationSupportDirectory = [applicationSupportDirectories objectAtIndex:0];
    NSString* filename = [applicationSupportDirectory stringByAppendingPathComponent:[url lastPathComponent]];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:filename atomically:YES];
    CGPDFDocumentRelease(pdf);
    return (pdfData);
}

- (void)drawCoverPage:(CGContextRef)ctx dictionary:(NSMutableDictionary *)dictionary
{
    
    CGRect deviceSize = [Utility deviceBounds];
    
    CGRect rect = CGRectMake(20.0,5.0,deviceSize.size.width-40,deviceSize.size.height-10);
    CGContextAddRect(ctx, rect);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetAlpha(ctx, 1.0);

    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont boldSystemFontOfSize:35];
    
    [@"Notes" drawInRect:rect  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
    
    
    rect = CGRectMake(20.0,deviceSize.size.height/2.0-15.0, deviceSize.size.width-40,deviceSize.size.height/2+15.0);
    textStyle.alignment = NSTextAlignmentCenter;
    textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[dictionary  valueForKey:@"timestamp"] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    NSString *fileDetails = [NSString stringWithFormat:@"File name: %@ \nDate of Creation: %@", [dictionary objectForKey:@"documentName"], timestamp ];
    [fileDetails drawInRect:rect  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];

    
}

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"-%ld-", (long)pageNum];
    CGRect deviceSize = [Utility deviceBounds];

    CGRect rect = CGRectMake(20.0,
                             deviceSize.size.height-70,
                             deviceSize.size.width-40,
                             deviceSize.size.height-40);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [pageString drawInRect:rect  withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (LibraryCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"Cell";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
     */
    
    //downgrading to version 5.1
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    LibraryCell *cell = (LibraryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[LibraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LibraryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ( [object valueForKey:@"timestamp"] == nil )
    {
        //This should not have happened. just in case :) programmers' fear
        return;
    }
    if ( self.itemDateFromOpenIn != nil)
    {
        if ( [self.itemDateFromOpenIn compare:[object valueForKey:@"timestamp"] ] == NSOrderedSame )
        {
            [[self tableView ] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            [[self tableView] selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            self.itemDateFromOpenIn = nil;
            return;
        }
    }
    //Initialize
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.0];
    NSDictionary *attributesDictionary = @{ NSForegroundColorAttributeName : [Utility CMYNColorDarkBlue],
                                            NSFontAttributeName : font};
    
    DocumentType docType = [DrawingController getDocumentType:[object valueForKey:@"documentURL"]];
    cell.nameLabel.attributedText = [[NSMutableAttributedString alloc]  initWithString:[[object valueForKey:@"documentName"] description] attributes:attributesDictionary];
    if ( docType == kPDF)
    {
        CellViewForPDF *pdfView  = (CellViewForPDF *)[cell.contentView viewWithTag:1007];
        if ( [pdfView superview] )
            [pdfView removeFromSuperview];
        //get the document url - Application Support URL from the physical app island and not from CoeData
        NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
        NSString *resourcePath = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, [[object valueForKey:@"documentName"] description]];
        NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            pdfView = [[CellViewForPDF alloc] initWithFrame:CGRectMake(10,15,140,180) url:url];
        }
        else
        {
            pdfView = [[CellViewForPDF alloc] initWithFrame:CGRectMake(10,15,105,135) url:url];
        }
        //set page number
        [pdfView setPageNumber:1];
        
        pdfView.tag = 1007;
        [cell.contentView addSubview:pdfView];
        pdfView.backgroundColor = [UIColor clearColor];
        NSString *numberOfPages = [NSString stringWithFormat:@"Number of Pages: %d", (int)[pdfView  count]];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.numberOfPagesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.numberOfPagesLabel.attributedText = [[NSMutableAttributedString alloc]  initWithString:numberOfPages attributes:attributesDictionary];
        cell.backgroundColor = [UIColor colorWithWhite:0.90 alpha:0.2];
    }
    
    DocumentController *documentController = [[DocumentController alloc] init];
    NSString *numberOfModifiedPages;
    int numberOfannotations = 0;
    
    if ( [object valueForKey:@"pageData"] == NULL)
        numberOfModifiedPages = [NSString stringWithFormat:@"Number of Modified Pages: 0"];
    else
    {
        [documentController constructDictionaryFromCoreData:[object valueForKey:@"pageData"]];
        numberOfModifiedPages = [NSString stringWithFormat:@"Number of Modified Pages: %d", [documentController getDirtyPageCount]];
        int dirtyPageCount  = [documentController getDirtyPageCount];
        for ( int i = 0; i < dirtyPageCount; i++ )
        {
            NSArray *shapes = [documentController getPage:[documentController getDirtyPageNumber:i]];
            //shapes = [documentController getPage:[documentController getDirtyPageNumber:i]];
            numberOfannotations += [shapes count];
        }
        
    }
    cell.numberOfModifiedPagesLabel.attributedText = [[NSMutableAttributedString alloc]  initWithString:numberOfModifiedPages attributes:attributesDictionary];
    //convert GMT to local time
    NSString *lastModifiedDate = [NSDateFormatter localizedStringFromDate:[object  valueForKey:@"lastModifiedDate"] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    cell.lastModifiedDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.numberOfAnnotationsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.lastModifiedDate.attributedText = [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"Last Modified on: %@",lastModifiedDate] attributes:attributesDictionary];
    cell.numberOfAnnotationsLabel.attributedText = [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"Number of annotations: %d",numberOfannotations]attributes:attributesDictionary];;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        //delete if there are any thumbnails for this object - SHOULD be done in a decent manner using Relationship Delete Rules
        //https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdRelationships.html
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DocumentController *documentController = [[DocumentController alloc] init];
        [documentController deleteAllThumbnailsFor:[managedObject valueForKey:@"documentURL"]];
        
        //delete the file too
        [documentController removeFile:[managedObject valueForKey:@"documentName"]];
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        //delete the file too at this path
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Sorry for the inconvenience "
                                          message:[error localizedDescription]
                                          preferredStyle:UIAlertControllerStyleAlert];
            /* deprecated
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
             message:[error localizedDescription]
             delegate:self
             cancelButtonTitle:@"Cancel!"
             otherButtonTitles:nil];
             [alert show];*/
            
            [self presentViewController:alert animated:YES completion:nil];
        }

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
     NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
     
     [self.drawingController initWithCoreData:object];
     
     
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
     self.drawingController = (DrawingController *)[storyboard instantiateViewControllerWithIdentifier:@"DrawingController"];
     
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
     {
     
     
     [self.drawingController initWithCoreData:object];
     }
     [self presentViewController:self.drawingController animated:NO completion:^
     {
     //[self connectAndLoad:_currentURL];
     }
     ];
     */
    
    /*  NSMutableArray *debugObject = [NSMutableArray array];
     [debugObject addObject:object];
     NSLog(@"After prepareForSegue %s:%d object=%@", __func__, __LINE__, debugObject);
     [self.drawingController initWithCoreData:object];
     [self presentViewController:self.drawingController animated:YES completion:nil];
     
     //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
     //NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     //}
     
     */
    //[self performSegueWithIdentifier:@"DrawingControllerViewSegue" sender:self.view];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Storage" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//@"Master"
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Sorry for the inconvenience "
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];
        /* deprecated
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unresolved Error. "
         message:[error localizedDescription]
         delegate:self
         cancelButtonTitle:@"Cancel!"
         otherButtonTitles:nil];
         [alert show];*/
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self tableView:self.tableView didSelectRowAtIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(LibraryCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - helpers

-(void) selectObjectFromOpenIn:(NSNotification*)notification
{
    self.itemDateFromOpenIn = [[notification userInfo] valueForKey:@"ObjectFromOpenIn"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DrawingControllerViewSegue" sender:self.view];
    
}

//Dismiss settings popup
- (void)settingsChanged
{
    //[self.settingsPopover dismissPopoverAnimated:YES];
    //set the popover to nil to enable the contaiing controller to have the correct application settings
    //self.settingsPopover = nil;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


//dismiss drawing controller
-(void)backToHome:(NSNotification *) notification
{
    //if (![[self.drawingController presentedViewController] isBeingDismissed])\
    //[self.drawingController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"DrawingControllerViewSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.drawingController = [segue destinationViewController];
        /* Dec 16, 2014. Leaving the url as is and using the data during the creation process as it is unique
         
         NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
         NSString *resourcePath = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, [[object valueForKey:@"documentName"] description]];
         //NSURL *url = [NSURL URLWithString:[resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
         [object setValue:resourcePath forKey:@"documentURL"];
         
         */
        
        [self.drawingController initWithCoreData:object];
    }
    
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // allow the segue to perform
    return YES;
}


- (IBAction)unwindToCMyNotesController:(UIStoryboardSegue *)unwindSegue
{
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[DrawingController class]])
    {
        NSLog(@"Coming from DrawingViewController!");
    }
    
}

-(void)shadowForCellImage:(UIView *)view
{
    //draw a border
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOpacity = 0.4;
    view.layer.shadowOffset = CGSizeMake(5, -5);
    CGRect rect = view.layer.frame;
    rect.origin = CGPointZero;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:view.layer.cornerRadius].CGPath;
}

#pragma  mark - BUGS
/*
 1. Application crashed on delete of a document
 2013-08-29 23:24:38.251 CMyNotes[18987:c07] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid update: invalid number of rows in section 0.  The number of rows contained in an existing section after the update (1) must be equal to the number of rows contained in that section before the update (1), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).'
 REASON: It was not deleted from the coredata **** FIXED
 
 CRASHES on XLS selection
 */
@end



