//
//  DetailViewController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 11/10/17.
//  Copyright © 2017 JCR Labz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMyNotes+CoreDataModel.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Event *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

