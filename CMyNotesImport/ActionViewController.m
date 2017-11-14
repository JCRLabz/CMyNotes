//
//  ActionViewController.m
//  CMyNotesImport
//
//  Created by Ramaseshan Ramachandran on 8/3/16.
//  Copyright © 2016 jcrlabz. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <SafariServices/SafariServices.h>

#define CMyNotesAppExtnDictionaryFile @"CMyNotesAppExtnDict.plist"

@interface ActionViewController ()


@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.informationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.informationLabel.numberOfLines = 0;
    // Get the item[s] we're handling from the extension context.
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;

    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
    {
        // This is an image. We'll load it, then place it in our image view.
        /*
         __weak UIImageView *imageView = self.imageView;
         [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
         if(image) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
         [imageView setImage:image];
         }];*/

        [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *url, NSError *error)
         {
             // send url to server to share the link
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 self.documentURL = url;
                 NSString *scheme = url.scheme;

                 if ( [scheme.lowercaseString isEqualToString:@"http"])
                 {
                     //send out a message to user
                     [self insecureTransportAlert:url];
                     return;
                 }
                 //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
                 // Make synchronous request
                 NSURLSession *session = [NSURLSession sharedSession];
                 NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:urlRequest
                                                                         completionHandler:
                                                           ^(NSURL *location, NSURLResponse *response, NSError *error)
                                                           {
                                                               self.response = response;
                                                               self.suggestedFileName = response.suggestedFilename;
                                                               self.MIMEType = [response MIMEType];
                                                               DocumentType documentType = [self getDocumentType:self.MIMEType];

                                                               self.suggestedFileName = [response suggestedFilename];
                                                               NSURL *groupURL =[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.cmynotes.jcrlabz.com"];

                                                               if (self.suggestedFileName != nil ){
                                                                   groupURL = [groupURL URLByAppendingPathComponent:_suggestedFileName isDirectory:NO];
                                                                   NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                               [response suggestedFilename], @"documentName",
                                                                                               (documentType == kHTML)?[url absoluteString]:[groupURL absoluteString], @"documentURL",
                                                                                               [NSDate date], @"timestamp",
                                                                                               [response MIMEType], @"MimeType",
                                                                                               nil];

                                                                   self.informationLabel.text = [NSString stringWithFormat:@"Importing %@... Please wait.",self.suggestedFileName];
                                                                   [self createPListFile:dictionary];
                                                               }
                                                               else
                                                                   [self import:nil];



                                                           }];
                 //[self.webView loadRequest:urlRequest];
                 [downloadTask resume];
             }];

             //[self.extensionContext completeRequestReturningItems:@[]completionHandler:nil];
         }];
    }

}

-(void)insecureTransportAlert:(NSURL *)url
{

    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:blurEffectView];
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }

    NSString *message = [NSString stringWithFormat:@"CMyNotes requires secure HTTPS connections.\nDownload blocked for \n%@", url];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Blocked by iOS" message:message preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alertController animated:YES completion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:^{
            [self cancel:nil];
        }];
    });
}

-(void)createPListFile:(NSDictionary*)dictionary
{
    NSURL *groupURL =[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.cmynotes.jcrlabz.com"];
    groupURL = [groupURL URLByAppendingPathComponent:CMyNotesAppExtnDictionaryFile isDirectory:NO];
    [dictionary writeToURL:groupURL atomically:NO];

    //copy file to group URL
    NSURL *destinationURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.cmynotes.jcrlabz.com"];
    NSData *data = [NSData dataWithContentsOfURL:self.documentURL];
    [data writeToURL:[destinationURL URLByAppendingPathComponent:[dictionary valueForKey:@"documentName"]]  atomically:NO];

    [self invokeApp:groupURL];
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:@"Cancel"];

    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done
{
    }

- (IBAction)cancel:(id)sender {
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:@"Cancel"];


    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
}

const NSString * APP_SHARE_URL_SCHEME = @"CMyNotes";


- ( void ) invokeApp:(NSURL *)url
{
    // Prepare the URL request
    // this will use the custom url scheme of your app
    // and the paths to the photos you want to share:

    NSString * urlString = [ NSString stringWithFormat: @"%@://%@", APP_SHARE_URL_SCHEME, [url resourceSpecifier] ];
    NSURL * appURL = [ NSURL URLWithString: urlString ];

    NSString *className = @"UIApplication";
    if ( NSClassFromString( className ) )
    {
        id object = [ NSClassFromString( className ) performSelector: @selector( sharedApplication ) ];
        [ object performSelector: @selector( openURL: ) withObject: appURL ];
    }

    // Now let the host app know we are done, so that it unblocks its UI:
    //[ super didSelectPost ];
}
-(DocumentType)getDocumentType:(NSString *)MIMEType
{

    //Doc and DocX mime types
    if ([MIMEType isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"] ||
        [MIMEType isEqualToString:@"application/msword"])
        return kDOC;

    //PPT and PPTX types
    else if ([MIMEType isEqualToString:@"application/vnd.openxmlformats-officedocument.presentationml.presentation"] ||
             [MIMEType isEqualToString:@"application/vnd.ms-powerpoint"])
        return kPPT;

    else if ([MIMEType isEqualToString:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"] ||
             [MIMEType isEqualToString:@"application/vnd.ms-excel"])
        return kXLS;

    else if ([MIMEType isEqualToString:@"text/html"])
        return kHTML;

    else if ([MIMEType isEqualToString:@"application/pdf"] ||
             [MIMEType isEqualToString:@"application/x-pdf"])
        return kPDF;

    return kNone;

}
- (IBAction)import:(id)sender
{
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    //[self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];

    DocumentType documentType;
    documentType = [self getDocumentType:self.MIMEType];

    /*
     switch (documentType)
     {
     case kDOC:
     {
     CGSize size = [self.webView sizeThatFits:CGSizeZero];

     //do we need to worry about margins here?
     int pageCount = size.height/size.height;
     url = [self convertWordToPDF:size pages:pageCount];
     break;
     }
     case kPPT:
     {
     NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.outerHTML"];

     //initialize the PPT controller
     PPTController *pptController = [[PPTController alloc] initWithView:self.webView withHTML:html];
     //CGSize pptSize = [pptController getScaledPPTSizeForDisplay];
     CGSize pptSize = [pptController getSize];

     url = [self convertPPTToPDF:pptSize pages:[pptController slideCount] ];
     break;
     }
     case kHTML:
     {
     CGSize size = self.webView.scrollView.contentSize;
     int pageCount = size.height/[Utility deviceBounds].size.height;
     url = [self convertWebContentsToPDF:size pages:pageCount];
     }

     case kPDF:
     break;
     default:
     NSLog(@"Only web pages, PPT, PPTX and PDF files are imported");
     break;

     }
     */
    if ( documentType != kNone )
    {
        //[self invokeApp:url];
    }
    self.informationLabel.text = @"Pleae connect to internet";NSLog(@"text output = %@", self.informationLabel.text);
    sleep(3);
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:@"Cancel"];
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
    
}
@end
