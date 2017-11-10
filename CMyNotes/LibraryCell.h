//
//  LibraryCell.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 8/29/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LibraryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *separatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *numberOfPagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfModifiedPagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastModifiedDate;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnnotationsLabel;
@end
