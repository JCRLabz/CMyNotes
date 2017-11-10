//
//  MailViewController.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/21/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "MailViewController.h"

@interface MailViewController ()

@end

@implementation MailViewController

-(id)init
{
    if (self = [super init])
    {
        return self;
    }
    else
        return nil;
}

-(void)setAttachment:(NSData *)attachment
{
    
}

-(void)configure:(NSData  *)data
{
    [self setSubject:@"Annotated Using CMyNotes"];
    //[self addAttachmentData:_data mimeType:@"image/png" fileName:@"myAnnotations.png"];
    [self addAttachmentData:data mimeType:@"application/pdf" fileName:@"myAnnotations.pdf"];
    
    //NSString *emailBody = @"Annotated using CMyNotes";
    NSString *emailBody = @"PFA my annotations - <a href=\"https://itunes.apple.com/us/app/cmynotes/id914353771?ls=1&//mt=8\">Annotated using CMyNotes</a>\n";
    [self setMessageBody:emailBody isHTML:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithData:(NSData*)data
{
    if (self = [super init])
    {
        [self configure:data];
        return self;
    }
    else
        return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
