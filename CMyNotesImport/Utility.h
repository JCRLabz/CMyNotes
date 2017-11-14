//
//  Utility.h
//  SSO4CC
//
//  Created by Ramaseshan Ramachandran on 4/14/13.
//  Copyright (c) 2014 JCR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define TOP_BORDER 45
#define PAGE_NAVIGATION_WIDTH 45
#define iPad "iPad"
#define iPhone "iPhone"
#define iPadSimulator "iPad Simulator"
#define iPhoneSimulator "iPhone Simulator"


#define iPad_X_Origin 0
#define iPad_Y_Origin 0
#define iPhone_X_Origin 0
#define iPhone_Y_Origin 0

//Do NOT disturb any existing order. Add new enum at the end
typedef enum documentType
{
    kPPT,
    kPPTX,
    kDOC,
    kDOCX,
    kPDF,
    kXLS,
    kXLSX,
    kNSData,
    kHTTP,
    kHTTPS,
    kHTML,
    kNone
} DocumentType;

typedef enum toolbarButtonTag
{
    kColorPalette,
    kShapes,
    kTextEdit,
    kHilight,
    kUndo,
    kDelete,
    kTrash,
    kReadOnly,
    kMail,
    kCompose,
    kNext,
    kPrevious,
    kPageNumber,
    kAction,
    kSpacer
}ToolbarButtonTag;


typedef enum shapeType
{
    kLine,
    kRectangle,
    kCircle,
    kText,
    kHighlighter,
    kFreeform,
    kArrow,
    kTextAndRectangle,
    kTextAndCircle,
    kTextAndFreeform,
    kFill,
    kCamera,
    kPhoto,
    kURL,
    kDoubleHeadedArrow,
    kCloseReading,
    kHeart,
    kQuestionMark,
    kExclamationMark,
    kStar,
    kCheckMark,
    kXMark,
    kInfinity,
    kConnection,
    kEvidence,
    kAgree,
    kDisAgree,
    kNoShapeSelected
} ShapeType;

typedef enum borderType
{
    kNoBorder,
    kLineBorder,
    kPictureFrame
    
}borderType;

typedef enum Side
{
    kLeft,
    kRight,
    kTop,
    kBottom
}Side;


typedef enum InstructionType
{
    kDisplayPageNumber,
    kMemorywarning
}InstructionType;

@interface Utility : NSObject

-(NSString *)path:(NSURL *)url;
-(NSString *)hostNameFromURL:(NSURL *)url ;
-(NSString *)hostNameFromString:(NSString*)url;

-(NSString *)subDomainFromURL:(NSURL *) url;
-(NSString *)subDomainFromString:(NSString *) url;

+(void)drawFramesAroundSubviews:(UIView *)view;

+(UIDeviceOrientation)deviceOrientation;
+(CGRect)deviceBounds;
+(UIImage *) imageFromView:(UIView *)view;

-(NSString *)saveImage:(UIImage *)image; //returns the file name of the image stored in Application support directory
+(NSURL *)moveItemAtURLToApplicationSupportDirectory:(NSURL*)sourceURL;
+(NSURL *)createItemAtApplicationSupportDirectory:(NSString*)fileName;
+(BOOL)isValidUrl:(NSString *)urlString;
+(CGPoint)deviceOrigin;
+(NSString *)deviceModel;
+(UIColor *)CMYNColorLightBlue;
+(UIColor *)CMYNColorDarkBlue;
+(UIColor *)CMYNColorLightOrange;
+(UIColor *)CMYNColorDarkOrange;
+(UIColor *)CMYNColorRed2;
+(UIColor *)CMYNColorGreen;
+(UIColor *)CMYNColorRed1;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (BOOL)isNetworkAvailable;


@end