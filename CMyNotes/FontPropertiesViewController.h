//
//  FontPropertiesViewController.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 6/23/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontPropertiesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *fontNames;
@property (strong, nonatomic) NSArray *familyNames;
@property (weak, nonatomic) IBOutlet UILabel *fontSizeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *fontNameLabel;
@property (strong, nonatomic) UIFont *font;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *fontSizeArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)closeButtonClicked:(id)sender;
-(void)updateFont:(UIFont *)font;
+(UIFont *)getCurrentFont;

@end
