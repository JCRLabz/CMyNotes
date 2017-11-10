//
//  MailViewController.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/21/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MailViewController : MFMailComposeViewController <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>

-(id)initWithData:(NSData*)data;

@end
 