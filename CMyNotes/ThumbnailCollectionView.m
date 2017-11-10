//
//  ThumbnailCollectionView.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/30/16.
//  Copyright © 2016 jcrlabz. All rights reserved.
//

#import "ThumbnailCollectionView.h"
#import "CellViewForPDF.h"

@implementation ThumbnailCollectionView



-(id)initWithDocument:(DocumentController*)document documentName:(NSString*)documentName documentType:(int)documentType pageNumber:(int)pageNumber
{
    self.document = document;
    self.documentName = documentName;
    self.documentType = documentType;
    self.pageNumber = pageNumber;
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    //self.thumbnailCollectionView = collectionView;

    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NSArray *dirstPageArray = self.datasource;
    //return [dirstPageArray count];
    return [self.document getDirtyPageCount];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCV" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UICollectionViewCell alloc] init ];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.frame = CGRectMake(2.5,2.5,40,55);
        }
        else
        {
            cell.frame = CGRectMake(2.5,2.5,25,35);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{

        [self setupCollectionViewCellForDrawing:cell cellForRowAtIndexPath:indexPath];
    });

    return cell;
}

-(void)setupCollectionViewCellForDrawing:(UICollectionViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSNumber *index = [dirtyPageNumberSet objectAtIndex:indexPath.row];
    if ( [self.document getDirtyPageCount] > 0 )
    {
        int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row];

        cell.contentMode = UIViewContentModeRedraw;
        if ([self.document containsDirtyKey:pageNumber])
        {
            //            if ( self.documentType == kPDF )
            //            {
            CellViewForPDF *pdfView  = (CellViewForPDF *)[cell.contentView viewWithTag:1007];
            if ( [pdfView superview] )
                [pdfView removeFromSuperview];


            pdfView = [[CellViewForPDF alloc] initWithFrame:cell.bounds]; //82
            pdfView.tag = 1007;
            [cell.contentView addSubview:pdfView];
            pdfView.layer.borderColor = [UIColor redColor].CGColor;
            pdfView.layer.borderWidth = 1;

            //set URL
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *applicationSupportDirectory = [paths objectAtIndex:0];
            NSString *applicationSupportURL = [NSString stringWithFormat:@"file://%@//%@",applicationSupportDirectory, self.documentName];
            NSURL *url = [NSURL URLWithString:[applicationSupportURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];


            [pdfView setURL:url];

            //[pdfView setURL:[[NSURL alloc] initWithString:[self.documentURL
            //stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [pdfView  setPageNumber:pageNumber];
            //pdfView.transform = CGAffineTransformMakeRotation(1.5707963);
            pdfView.contentMode = UIViewContentModeScaleAspectFill;
            //[self.thumbnailCollectionView setNeedsDisplay];
            // }

            UILabel *label = (UILabel *)[cell.contentView viewWithTag:1005];

            if ( [label superview] )
                [label removeFromSuperview];

            label = [[UILabel alloc] initWithFrame:cell.bounds];
            label.tag = 1005;
            [pdfView addSubview:label];


            label.contentMode = UIViewContentModeRedraw;

            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor redColor];

            NSDictionary *fontAttributes = @{
                                             NSForegroundColorAttributeName:[UIColor redColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:12.0]
                                             };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",self.documentType == kPPT? pageNumber+1:pageNumber] attributes:fontAttributes];

            label.attributedText = attributedText;

            //label.transform = CGAffineTransformMakeRotation(1.5707963);
        }

        // then set them via the main queue if the cell is still visible.
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];

    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    // Adjust cell size for orientation
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return CGSizeMake(30.0, 40.0);

    return CGSizeMake(45.0, 60.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];

    int pageNumber = [self.document getDirtyPageNumber:(int)indexPath.row ];

    if ( [self.document containsDirtyKey:pageNumber] )
        //if ( [dirtyPageNumberSet containsObject:[NSString stringWithFormat:@"%d",pageNumber] ] )
    {
        /*
        [self clearSelectedShape];

        if ( self.documentType == kPDF )
        {
            _pageNumber = pageNumber;
            [self displayPDF:pageNumber];
        }
        else if ( self.documentType == kXLS )
        {
            _pageNumber = pageNumber;
            [self displayXLS:pageNumber];
        }
         */

    }
}


-(void)removePageFromCollectionView:(int)pageNumber
{
    NSInteger index = [self.document getIndexOfDirtyPage:pageNumber];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    //UICollectionViewCell *cell = [self.thumbnailCollectionView cellForItemAtIndexPath:indexPath];

    [self performBatchUpdates:^(void){

        [self deleteItemsAtIndexPaths:@[indexPath]];

    } completion:nil];

    [self centerthumbnailCollectionView];

}


-(void)centerthumbnailCollectionView
{
    /*
     if ( widthOfThumbnails > self.pdfView.bounds.size.width )
     {
     originXForThumbnail = 0.0;
     self.thumbnailCollectionView.frame = CGRectMake(originXForThumbnail, self.pdfView.bounds.size.height-65, self.pdfView.frame.size.width, 50.0);
     }
     else
     self.thumbnailCollectionView.frame = CGRectMake(originXForThumbnail, self.pdfView.bounds.size.height-65, widthOfThumbnails, 50.0);*/

    //5 redraw

    [self performBatchUpdates:^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
        //[self.thumbnailCollectionView reloadData];
    } completion:nil];

    //[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

-(void)refresh
{
    [self performBatchUpdates:^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
        //[self.thumbnailCollectionView reloadData];
    } completion:nil];}


@end

/*
 *TODO
 (A) Reload immediately when a page is annotated/deleted
 */
