//
//  Utility.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/14/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import "Utility.h"
//#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>
#import <UIKit/UIScreen.h>


@implementation Utility

-(id)init {
    if (self = [super init] ) {
        return self;
    }
    return nil;
}

-(NSString *)hostNameFromString:(NSString *)url

{
    NSURL *theURL = [[NSURL alloc] initWithString:url];
    return [self hostNameFromURL:theURL];
}

-(NSString *)hostNameFromURL:(NSURL*)url
{
    return [url host];
}

-(NSString *)path:(NSURL *)url
{
    return [url path];
}

-(NSString*)subDomainFromString:(NSString *) url
{
    NSURL *theURL = [[NSURL alloc] initWithString:url];
    
    return [self subDomainFromURL:theURL];
}


-(NSString*)subDomainFromURL:(NSURL *) url
{
    NSString *host = [url host] ;
    NSArray *splitURL = [host componentsSeparatedByString:@"."];
    
    if ( [splitURL count]  > 0 ) {
        //get the last two components of the host and convert it into lowercase
        NSString *subDomain = [[NSString  stringWithFormat:@"%@.%@", splitURL[ [splitURL count] -2], splitURL[ [splitURL count] -1]] lowercaseString];
    
        NSLog(@"sub = %@", subDomain);
        return subDomain;
    }
    
    return nil;
}

+(void)drawFramesAroundSubviews:(UIView *)view
{
    [view.layer setCornerRadius:5.0f];
    [view.layer setBorderColor:[UIColor blackColor].CGColor];
    [view.layer setBorderWidth:1.0f];
    [view.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [view.layer setShadowOpacity:0.8];
    [view.layer setShadowRadius:5.0];
    [view.layer setShadowOffset:CGSizeMake(10.0, 10.0)];
}

+(CGRect)deviceBounds
{
    return [[UIScreen mainScreen] bounds];

}

+(NSString *)deviceModel
{
    UIDevice *device = [UIDevice currentDevice] ;
    return device.model;
}

+(CGPoint)deviceOrigin
{
    if ( [[Utility deviceModel]  isEqual: @iPad] )
        return CGPointMake(iPad_X_Origin, iPad_Y_Origin);
    
    if ( [[Utility deviceModel]  isEqual: @iPhone] )
        return CGPointMake(iPhone_X_Origin,iPhone_Y_Origin);

    if ( [[Utility deviceModel]  isEqual: @iPadSimulator] )
        return CGPointMake(iPad_X_Origin, iPad_Y_Origin);

    if ( [[Utility deviceModel]  isEqual: @iPhoneSimulator] )
        return CGPointMake(iPhone_X_Origin,iPhone_Y_Origin);

    return CGPointMake(0.0,0.0);
}

+(UIDeviceOrientation)deviceOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return orientation;
}

+(UIImage *) imageFromView:(UIView *)view 
{
    // tempframe to reset view size after image was created
    CGRect tmpFrame         = view.bounds;
    
    
    CGRect aFrame               = view.bounds;
    aFrame.size.height  = [view sizeThatFits:[[UIScreen mainScreen] bounds].size].height;
    //aFrame.size.height  = 640;
    //CGFloat offset = _webView.scrollView.contentOffset.y;
    //aFrame.origin.y = offset;
    view.frame              = aFrame;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // reset Frame of view to origin
    view.frame = tmpFrame;
    return image;
}


/*
- (void) splashFade: (UIImageView *)imageView
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
    imageView.image = [UIImage imageNamed:@"Default-Portrait~ipad"];
    [_window addSubview:self.imageView];
    [_window bringSubviewToFront:self.imageView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationDelay:2.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_window cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    self.imageView.alpha = 0.0;
    [UIView commitAnimations];
    
    //Create and add the Activity Indicator to splashView
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(160, 360);
    activityIndicator.hidesWhenStopped = NO;
    [self.imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

*/

//returns the file name of the image stored in Application support directory
-(NSString *)saveImage:(UIImage *)image
{
    NSString *imageFileName = [NSString stringWithFormat:@"CMyNotesPhoto%@.jpg",[NSDate date] ];
    //save image as a file in the ApplicationSupport folder
    
    //NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    NSURL *copyToURL = [NSURL fileURLWithPath:applicationSupportDirectory];
    
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:imageFileName isDirectory:NO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:copyToURL.path])
    {
        // Duplicate path
        NSURL *duplicateURL = copyToURL;
        // Remove the filename extension
        copyToURL = [copyToURL URLByDeletingPathExtension];
        // Filename no extension
        NSString *fileNameWithoutExtension = [copyToURL lastPathComponent];
        // File extension
        NSString *fileExtension = [imageFileName pathExtension];
        
        //check for duplicate file name. If exists, extend the file name with "-%i"
        int i=1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:duplicateURL.path]) {
            
            // Delete the last path component
            copyToURL = [copyToURL URLByDeletingLastPathComponent];
            // Update URL with new name
            copyToURL=[copyToURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i",fileNameWithoutExtension,i]];
            
            // Add back the file extension
            copyToURL =[copyToURL URLByAppendingPathExtension:fileExtension];
            // Copy path to duplicate
            duplicateURL = copyToURL;
            i++;
            
        }
        
    }
    
    if ( ![UIImageJPEGRepresentation(image, 1.0) writeToURL:copyToURL atomically:YES] )
    {
        NSLog(@"Unable to write file -%@", copyToURL);
        return nil;
    }

    
    return [copyToURL lastPathComponent];
}



+(NSURL *)moveItemAtURLToApplicationSupportDirectory:(NSURL*)sourceURL
{
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    NSURL *copyToURL = [NSURL fileURLWithPath:applicationSupportDirectory];
    
    NSString *fileName = [sourceURL lastPathComponent];
    
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:fileName isDirectory:NO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:copyToURL.path]) {
        
        // Duplicate path
        NSURL *duplicateURL = copyToURL;
        // Remove the filename extension
        copyToURL = [copyToURL URLByDeletingPathExtension];
        // Filename no extension
        NSString *fileNameWithoutExtension = [copyToURL lastPathComponent];
        // File extension
        NSString *fileExtension = [sourceURL pathExtension];
        
        //check for duplicate file name. If exists, extend the file name with "-%i"
        int i=1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:duplicateURL.path]) {
            
            // Delete the last path component
            copyToURL = [copyToURL URLByDeletingLastPathComponent];
            // Update URL with new name
            copyToURL=[copyToURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i",fileNameWithoutExtension,i]];
            // Add back the file extension
            copyToURL =[copyToURL URLByAppendingPathExtension:fileExtension];
            // Copy path to duplicate
            duplicateURL = copyToURL;
            i++;
            
        }
        
        
    }
    
    if ( ![[NSFileManager defaultManager] moveItemAtURL:sourceURL toURL:copyToURL error:&error])
        
        // Feed back any errors
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            return nil;
        }
    
    return copyToURL;
}



+(NSURL *)createItemAtApplicationSupportDirectory:(NSString*)fileName
{
    
    //NSURL *sourceURL = [[NSURL alloc] initWithString:[fileName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    NSURL *copyToURL = [NSURL fileURLWithPath:applicationSupportDirectory];
    NSString *fileNameWithDate = [NSString stringWithFormat:@"%@_%@",fileName, [NSDate date]];
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:fileNameWithDate isDirectory:NO];
    copyToURL =[copyToURL URLByAppendingPathExtension:@"pdf"];
    NSString *fileExtension = @"pdf";//[sourceURL pathExtension];

    if ([[NSFileManager defaultManager] fileExistsAtPath:copyToURL.path])
    {
        
        // Duplicate path
        NSURL *duplicateURL = copyToURL;
        // Remove the filename extension
        copyToURL = [copyToURL URLByDeletingPathExtension];
        // Filename no extension
        NSString *fileNameWithoutExtension = [copyToURL lastPathComponent];
        // File extension
        
        //check for duplicate file name. If exists, extend the file name with "-%i"
        int i=1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:duplicateURL.path]) {
            
            // Delete the last path component
            copyToURL = [copyToURL URLByDeletingLastPathComponent];
            // Update URL with new name
            copyToURL=[copyToURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%i",fileNameWithoutExtension,i]];
            // Add back the file extension
            copyToURL =[copyToURL URLByAppendingPathExtension:fileExtension];
            // Copy path to duplicate
            duplicateURL = copyToURL;
            i++;
            
        }
        
        NSString *filePath = [applicationSupportDirectory stringByAppendingPathComponent:[duplicateURL lastPathComponent]];
        NSData *data = [[NSData alloc] init];
        
        if ( [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil] )
        {
            return duplicateURL;
        }
        
    }


    else
    {
        NSString *filePath = [NSString stringWithFormat:@"%@.pdf", [applicationSupportDirectory  stringByAppendingPathComponent:fileName]];
        NSData *data = [[NSData alloc] init];
    
        if ( [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil] )
        {
            return copyToURL;
        }
    }
    return nil;
}

+(BOOL)isValidUrl:(NSString *)urlString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //Handle requests. Check
    
    /*NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"statusCode = %ld", (long)[response statusCode]);
    
    if (response == nil)
        return NO;
    
    if ( [response statusCode] == 404 )
        return NO;*/

    return [NSURLConnection canHandleRequest:request];

}



+(UIColor *)CMYNColorLightBlue
{
    return [UIColor colorWithRed:96.0/255.0 green:201.0/255.0 blue:248.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorDarkBlue
{
    return [UIColor colorWithRed:22.0/255.0 green:127.0/255.0 blue:252.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorLightOrange
{
    return [UIColor colorWithRed:255/255 green:203.0/255.0 blue:47.0/255/0 alpha:1.0];
}
+(UIColor *)CMYNColorDarkOrange
{
    return [UIColor colorWithRed:254.0/255.0 green:149.0/255.0 blue:38.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorRed2
{
    return [UIColor colorWithRed:253.0/255.0 green:50.0/255.0 blue:89.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorGreen
{
    return [UIColor colorWithRed:83.0/255.0 green:216.0/255.0 blue:106.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorRed1
{
    return [UIColor colorWithRed:253.0/255.0 green:61.0/255.0 blue:57.0/255.0 alpha:1.0];
}
+(UIColor *)CMYNColorGray
{
    return [UIColor colorWithRed:142.0/255.0 green:143.0/255.0 blue:147.0/255.0 alpha:1.0];
}
+(UIColor*)CMYNColorLightYellow
{
    return [UIColor colorWithRed:254.0/255.0 green:231.0/255.0 blue:195.0/255.0 alpha:1.0];
}
+(UIColor*)CMYNColorRed3
{
    return [UIColor colorWithRed:247.0/255.0 green:0.0 blue:51.0/255.0 alpha:1.0];
}

//image from color
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 + (BOOL)isNetworkAvailable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (kCFAllocatorDefault, (__bridge CFURLRef)[NSURL URLWithString:@"www.apple.com"]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        //NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        //NSLog (@"Connection is down");
        return NO;
    }
}
 */
@end
