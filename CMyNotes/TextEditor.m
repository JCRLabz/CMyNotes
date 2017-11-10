//
//  TextEditor.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/9/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import "TextEditor.h"
#import "ColorToolViewController.h"
#import "FontPropertiesViewController.h"

@implementation TextEditor
{
    CGRect frameLocationAtBeginEditing;
    CGRect frameAfterTextChange;
    CGSize contentSizeAfterTextChange;

}
@dynamic delegate;

-(void) setDelegate:(id<TextEditorDelegate>) delegate
{
    [super setDelegate: delegate];
}
- (id) delegate
{
    return [super delegate];
}

-(id)init
{
    self = [super init];

    
    if ( !self )
    {
        return nil;
    }
    self.delegate = self;
    return self;
}

-(id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    if ( self = [super initWithFrame:frame textContainer:textContainer])
    {
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorChanged:) name:@"ColorChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:@"FontChanged"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    self.autocorrectionType = UITextSpellCheckingTypeDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.delegate = self;
    [self.textContainer setLineBreakMode:NSLineBreakByWordWrapping];
    [self setUserInteractionEnabled:YES];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.layer.borderWidth = 0.3f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    [self setSelectable:YES];
    [self setEditable:YES];
    [self becomeFirstResponder];
    self.pagingEnabled = YES; 
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:recognizer];
    
    UIToolbar *tipToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[self doneImage] style:UIBarButtonItemStylePlain target:self action:@selector(textEntryDone:)];
    done.tintColor = [Utility CMYNColorRed1];
    
    tipToolbar.items = [NSArray arrayWithObjects:

                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ColorPalette"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSelectedTextColor:)],
                        [[UIBarButtonItem alloc] initWithImage:[self leftAlignImage] style:UIBarButtonItemStylePlain target:self action:@selector(textAlignmentLeft:)],
                        [[UIBarButtonItem alloc] initWithImage:[self rightAlignImage] style:UIBarButtonItemStylePlain target:self action:@selector(textAlignmentRight:)],
                        [[UIBarButtonItem alloc] initWithImage:[self justifiedImage] style:UIBarButtonItemStylePlain target:self action:@selector(textAlignmentJustified:)],
                        [[UIBarButtonItem alloc] initWithImage:[self centeredImage] style:UIBarButtonItemStylePlain target:self action:@selector(textAlignmentCentered:)],
                        //[[UIBarButtonItem alloc] initWithImage:[self fontImage] style:UIBarButtonItemStylePlain target:self action:@selector(changeSelectedTextFont:)],
                        [[UIBarButtonItem alloc] initWithImage:[self fontUnderlineImage] style:UIBarButtonItemStylePlain target:self action:@selector(underlineText:)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],

                        done, nil];
    
    [tipToolbar sizeToFit];
    tipToolbar.barTintColor = [Utility CMYNColorLightYellow];
    tipToolbar.translucent = NO;
    UIBarButtonItem *doneItem = [tipToolbar.items objectAtIndex:7];
    doneItem.tintColor = [Utility CMYNColorRed2];
    [self setInputAccessoryView:tipToolbar];
}

-(UIImage *)leftAlignImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 0.2);
    CGContextFillRect(context, CGRectMake(2, 8, 22, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 12, 35, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 16, 12, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 20, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 24, 33, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 28, 29, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 32,34, 0.5f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)rightAlignImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 0.2);

    CGContextFillRect(context, CGRectMake(20, 8, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(12, 12, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(4, 16, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(8, 20, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 24, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(6, 28, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(16, 32, 36, 0.5f));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)justifiedImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 0.5);
    
    CGContextFillRect(context, CGRectMake(2, 8, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 12, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 16, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 20, 20, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 24, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 28, 36, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 32, 36, 0.5f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

-(UIImage *)centeredImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 0.5);
    
    CGContextFillRect(context, CGRectMake(2, 8, 32, 0.5f));
    CGContextFillRect(context, CGRectMake(4, 12, 28, 0.5f));
    CGContextFillRect(context, CGRectMake(8, 16, 20, 0.5f));
    CGContextFillRect(context, CGRectMake(6, 20, 24, 0.5f));
    CGContextFillRect(context, CGRectMake(10, 24, 16, 0.5f));
    CGContextFillRect(context, CGRectMake(2, 28, 32, 0.5f));
    CGContextFillRect(context, CGRectMake(12, 32, 12, 0.5f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

-(UIImage *)fontImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    UIFont *font = [UIFont systemFontOfSize:16];
    [attr setObject:font forKey:NSFontAttributeName];
    [attr setObject:[Utility CMYNColorLightOrange] forKey:NSForegroundColorAttributeName];
    CGContextSetRGBStrokeColor(context, 1.0f, 0.0f, 1.0f, 1.0f);
    NSMutableAttributedString *letterAa = [[NSMutableAttributedString alloc] initWithString:@"Aa"];
    [letterAa addAttributes:attr range:(NSRange){0,[letterAa length]}];
    [letterAa drawInRect:CGRectMake(2, 12, 36, 40)];
    
    font = [UIFont fontWithName:@"Arial" size:16.0];
    UIFont *italicFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
    
    [attr removeObjectForKey:NSFontAttributeName];
    [attr setObject:italicFont forKey:NSFontAttributeName];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)doneImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, 0);

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    UIFont *font = [UIFont systemFontOfSize:16];
    [attr setObject:font forKey:NSFontAttributeName];
    NSMutableAttributedString *done = [[NSMutableAttributedString alloc] initWithString:@"Done"];
    [done addAttributes:attr range:(NSRange){0,[done length]}];
    [done drawInRect:CGRectMake(0, 12, 40, 40)];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)fontUnderlineImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,40), NO, 0);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    UIFont *font = [UIFont systemFontOfSize:16.0];
    [attr setObject:font forKey:NSFontAttributeName];

    NSMutableAttributedString *letterA = [[NSMutableAttributedString alloc] initWithString:@"Aa"];
    [letterA addAttributes:attr range:(NSRange){0,[letterA length]}];
    [letterA addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:(NSRange){0,[letterA length]}];
    [letterA drawInRect:CGRectMake(2, 12, 36, 40)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -Message Handling
-(void)fontChanged:notification
{
    //get selected string and range
    UITextRange *textRange = self.selectedTextRange;
    UIFont *font = [[notification userInfo] valueForKey:@"FontChanged"];

    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    //NSRangePointer *rp = NULL;
    //NSDictionary *attributeDictionary = [attributedText attributesAtIndex:location effectiveRange:NULL];
    NSRange range =  NSMakeRange(location, length);
    //remove old font
    [attributedText removeAttribute:@"NSFont" range:range];
    //add new font
    [attributedText addAttribute:NSFontAttributeName value:font range:self.selectedRange];
    [attributedText fixAttributesInRange:(NSRange){0,[attributedText length]}];
    self.attributedText = attributedText;
    self.selectedTextRange = textRange;
}

-(void)colorChanged:notification
{
    //get selected string and range
    UITextRange *textRange = self.selectedTextRange;
    UIColor *color = [[notification userInfo] valueForKey:@"ColorChanged"];
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    [attributedText addAttribute:NSForegroundColorAttributeName value:color range:self.selectedRange];
    self.attributedText = attributedText;
    [attributedText fixAttributesInRange:(NSRange){0,[attributedText length]}];
    self.attributedText = attributedText;
    self.selectedTextRange = textRange;
}

-(void)underlineText:(id)sender
{
    //get selected string and range
    UITextRange *textRange = self.selectedTextRange;

    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    if ( length == 0 )
        return;
    //NSRangePointer *rp = NULL;
    NSDictionary *attributeDictionary = [attributedText attributesAtIndex:location effectiveRange:NULL];
    NSRange range =  NSMakeRange(location, length);
    //underline found? if yes, remove underline, else underline
    int underline = [[attributeDictionary objectForKey:@"NSUnderline"] intValue];
    if ( underline == 1 )
    {
        [attributedText removeAttribute:@"NSUnderline" range:range];
    }
    else
        [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:self.selectedRange];
    self.attributedText = attributedText;
    [attributedText fixAttributesInRange:(NSRange){0,[attributedText length]}];
    self.attributedText = attributedText;
    self.selectedTextRange = textRange;}


-(void)textAlignmentJustified:(id)sender
{
    [self alignParagraph:NSTextAlignmentJustified];
}

-(void)textAlignmentRight:(id)sender
{
    [self alignParagraph:NSTextAlignmentRight];
}

-(void)textAlignmentLeft:(id)sender
{
    [self alignParagraph:NSTextAlignmentLeft];
}

-(void)textAlignmentCentered:(id)sender
{
    [self alignParagraph:NSTextAlignmentCenter];
}


-(void)alignParagraph:(NSTextAlignment)textAlignment
{
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    NSRange textRange = self.selectedRange;
    
    NSString *string = self.text;
    unsigned length = (unsigned)[string length];
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSRange currentRange = { .location = NSNotFound, .length = 0 };
    while (paraEnd < length)
    {
        [string getParagraphStart:&paraStart end:&paraEnd
                      contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        if ( NSLocationInRange(textRange.location, currentRange))
        {
            break;
        }
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = textAlignment;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
    self.attributedText = attributedText;
    self.selectedRange = textRange;
}

-(void)changeSelectedTextColor:(id)sender
{
    //ColorToolViewController *colorToolViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        //self.colorToolViewController  = (ColorToolViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ColorToolViewController"];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        //UIPopoverController *toolPopoverController = [[UIPopoverController alloc]initWithContentViewController:tabBarController];
        
        
        tabBarController.selectedIndex = 0;

        /*for (UIViewController *controller in tabBarController.viewControllers)
        {
            if ([controller isKindOfClass:[ColorToolViewController class]])
            {
                colorToolViewController = (ColorToolViewController *)controller;
                //colorToolViewController.delegate = self.;
            }

        }*/
        //if from UIBarbutton launch popover, else present it from the location of the shape object
        if([sender isKindOfClass:[UIBarButtonItem class]])
        {
            //[toolPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
            UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
            
            tabBarController.modalPresentationStyle = UIModalPresentationPopover;
            
            // configure the Popover presentation controller
            UIPopoverPresentationController *popController = [tabBarController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.barButtonItem = sender;
            [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:tabBarController animated:NO completion: nil];
            
        }
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
        
        navigationController.definesPresentationContext = YES; //self is presenting view controller
        navigationController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        //navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;       //WORKING //now present this navigation controller modally
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;        //now present this navigation controller modally
        navigationController.navigationBarHidden = YES;
        tabBarController.selectedIndex = 0;
        [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:navigationController animated:NO completion: nil];
    }

}

-(void)changeSelectedTextFont:(id)sender
{
    //FontPropertiesViewController *fontToolViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        //self.colorToolViewController  = (ColorToolViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ColorToolViewController"];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        //UIPopoverController *toolPopoverController = [[UIPopoverController alloc]initWithContentViewController:tabBarController];
        tabBarController.selectedIndex = 1;
        
        /*for (UIViewController *controller in tabBarController.viewControllers)
        {
            if ([controller isKindOfClass:[FontPropertiesViewController class]])
            {
                fontToolViewController = (FontPropertiesViewController *)controller;
                //colorToolViewController.delegate = self.;
            }
            
        }*/
        //if from UIBarbutton launch popover, else present it from the location of the shape object
        if([sender isKindOfClass:[UIBarButtonItem class]])
        {
            //[toolPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
            UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
            
            tabBarController.modalPresentationStyle = UIModalPresentationPopover;
            
            // configure the Popover presentation controller
            UIPopoverPresentationController *popController = [tabBarController popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.barButtonItem = sender;
            [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:tabBarController animated:NO completion: nil];
        }
        /*
         else if ( [sender isKindOfClass:[UIMenuController class]] )
        {
            UIMenuController *menuController = sender;
            toolPopoverController.backgroundColor = [UIColor clearColor];

            [toolPopoverController presentPopoverFromRect:menuController.menuFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
         */
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UniversalCMyNotes" bundle:nil];
        UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"ShapePropertyTabs"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
        
        navigationController.definesPresentationContext = YES; //self is presenting view controller
        navigationController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        //navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;       //WORKING //now present this navigation controller modally
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;        //now present this navigation controller modally
        navigationController.navigationBarHidden = YES;
        tabBarController.selectedIndex = 1;
        [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:navigationController animated:NO completion: nil];
    }
    
}

-(void)textEntryDone:(id)sender
{
    
    //self.textContainer.size = self.frame.size;
    self.layer.borderWidth = 0.0f;
    //complete the operations
   // delegate should complete the operation
    [self keyboardWillHide:nil];
    [self resignFirstResponder];
    [self broadcastMessageTextEditingCompleted];
}
/*
-(id)initTextEditor:(TextObject *)textObject frame:(CGRect)frame
{
    //self = [[TextEditor alloc] init];
    self.frame = frame;
    self.attributedText = [[NSTextStorage alloc] initWithAttributedString:textObject.attributedText];
    
    return self;
}
*/

-(void)broadcastMessageTextEditingCompleted
{
    //broadcast that the text editing completed

    //Why not pass self?
    NSMutableDictionary *textEditor = [NSMutableDictionary dictionaryWithObject:self forKey:@"TextEditingCompleted"];

   [[NSNotificationCenter defaultCenter] postNotificationName: @"TextEditingCompleted" object:self userInfo: textEditor];
    
   // if ([self.delegate respondsToSelector:@selector(endTextEditing:)])
    //{
        //[self.delegate endTextEditing:textEditor];
    //}

}

- (void) singleTap:(UITapGestureRecognizer *)recognizer
{

    CGPoint point = [recognizer locationInView:self];
    
    if ( !CGRectContainsPoint(self.bounds, point) )
    {

        [self textEntryDone:nil];

    }
}


-(void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    //textView.frame = newFrame;
    CGFloat deltaHeight = fabs(frameAfterTextChange.size.height - newSize.height);
    if ( frameAfterTextChange.origin.y - deltaHeight > 5.0 )
        newFrame.origin.y = frameAfterTextChange.origin.y - deltaHeight;
    textView.frame = newFrame;
}

//find the keyboard width and height. If the textView is inside or partially indide Keuboard view, move it to a location where it is visible
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return TRUE;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGSize keyboardSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect deviceBounds = [Utility deviceBounds];
    frameLocationAtBeginEditing = self.frame;

    //case 1
    //if keyboard rectangle contains the textview, then move the textview from hideout :)
    //
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    //self.frame = CGRectMake(5.0,(deviceBounds.size.height-keyboardSize.height)-self.frame.size.height-self.inputAccessoryView.frame.size.height-30.0,self.frame.size.width,self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x,(deviceBounds.size.height-keyboardSize.height)-self.frame.size.height-self.inputAccessoryView.frame.size.height-30.0,self.frame.size.width,self.frame.size.height);
    [UIView commitAnimations];
    frameAfterTextChange = self.frame;
    contentSizeAfterTextChange = self.contentSize;
}

/*
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];

    //NSRangePointer *rp = NULL;
    NSDictionary *attributeDictionary = [attributedText attributesAtIndex:location effectiveRange:NULL];
}
*/
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.frame = CGRectMake(frameLocationAtBeginEditing.origin.x,frameLocationAtBeginEditing.origin.y,self.frame.size.width,self.frame.size.height);
    [UIView commitAnimations];
}
@end
