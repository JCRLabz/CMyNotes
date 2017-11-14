//
//  ActionViewController.h
//  CMyNotesImport
//
//  Created by Ramaseshan Ramachandran on 8/3/16.
//  Copyright © 2016 jcrlabz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Utility.h"
@interface ActionViewController : UIViewController
@property  int documentType;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, atomic) NSURL *documentURL;
@property (strong, atomic) NSURLResponse *response;
@property (strong, atomic) NSString *suggestedFileName;
@property (strong, atomic) NSString *MIMEType;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

- (IBAction)import:(id)sender;
@end
