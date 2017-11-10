//
//  main.m
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/7/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}


//A bug that killed 3 days of my time
//Terminating app due to uncaught exception 'NSUnknownKeyException', The Class name PDFView clashe
//with Apples new class PDFView. Stupid of Apple to give an error message that was difficult to
//decipher. Renamed the class and then it worked
