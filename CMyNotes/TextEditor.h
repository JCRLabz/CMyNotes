//
//  TextEditor.h
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 7/9/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "TextObject.h"

@protocol TextEditorDelegate <UITextViewDelegate>
-(void)endTextEditing:(NSDictionary*)textDictionary;
@end

typedef enum TextEditorButtonTag
{
    kColorButton,
    kTextAlignLeft,
    kTextAlignRight,
    kTextAlignJustified,
    kFontClicked,
    kDoneClicked
}TextEditorButtonTag;

@interface TextEditor : UITextView <UITextViewDelegate>
{
    NSTextStorage *textStorage;
    unsigned int toolbarButton;
    CGFloat keyboardHeight;
}
@property (nonatomic, assign) id delegate;
@property (strong, nonatomic) UIButton *closeButton;

@end


