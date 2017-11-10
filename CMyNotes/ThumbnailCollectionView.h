//
//  ThumbnailCollectionView.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/30/16.
//  Copyright © 2016 jcrlabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentController.h"

@interface ThumbnailCollectionView : UICollectionView

@property (strong, nonatomic) DocumentController *document;
@property (nonatomic ,strong) NSString *documentName;
@property  int documentType;
@property int pageNumber;

//methods
-(id)initWithDocument:(DocumentController*)document documentName:(NSString*)documentName documentType:(int)documentType pageNumber:(int)pageNumber;
-(void)removePageFromCollectionView:(int)pageNumber;
-(void)refresh;
@end
