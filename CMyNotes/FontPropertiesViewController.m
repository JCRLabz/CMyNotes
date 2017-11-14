//
//  FontPropertiesViewController.m
//  CMyNotes
//
//  Created by Ramaseshan Ramachandran on 6/23/15.
//  Copyright (c) 2015 jcrlabz. All rights reserved.
//

#import "FontPropertiesViewController.h"
#import "Utility.h"
#define MIN_FONT_SIZE 8
#define MAX_FFONT_SIZE 33
static UIFont *_currentFont;
static float _currentFontSize;

@implementation FontPropertiesViewController


-(id)init
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)initialize
{
    self.familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *sortedFamilyNames = [self.familyNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    
    self.familyNames = [[NSArray alloc] initWithArray:sortedFamilyNames];
    
    self.fontSizeArray = [[NSMutableArray alloc] initWithCapacity:24];
    for ( int i = MIN_FONT_SIZE; i < MAX_FFONT_SIZE; i++)
    {
        [self.fontSizeArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //self.fontNameLabel.text = @"Helvetica";
    //self.fontSizeLabel.text = @"16";
    //self.fontNameLabel.textColor = [Utility CMYNColorDarkBlue];
    //self.fontSizeLabel.textColor = [Utility CMYNColorDarkBlue];
    //create a round button
    //self.closeButton.layer.cornerRadius = 5.0;
    //self.closeButton.tintColor = [Utility CMYNColorRed1];
    self.closeButton.layer.borderColor = [[Utility CMYNColorLightBlue] CGColor];
    //self.closeButton.layer.borderWidth = 0.3;
    self.view.opaque = NO;
    
    if (_currentFont == nil )
    {
        _currentFont = [UIFont fontWithName:@"Helvetica" size:16.0];
        _currentFontSize = 16.0;
        [self setAttributedTextForLabels:_currentFont];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( tableView.tag == 2020)
        return [self.familyNames count];
    return 1; //for size tableview
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( tableView.tag == 2020)
        return [self.familyNames objectAtIndex:section];
    else if ( tableView.tag == 2021)
        return @"Size";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView.tag == 2020)
        return [[UIFont fontNamesForFamilyName:[self.familyNames objectAtIndex:section]] count];
    else //(tableView.tag == 2021)
        return [self.fontSizeArray count];
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [Utility CMYNColorDarkBlue];
    header.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];

    //CGRect headerFrame = header.frame;
    //header.textLabel.frame = headerFrame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView.tag == 2020 )
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FontNameCell" forIndexPath:indexPath];
        
        NSString *fontNameFull = [[UIFont fontNamesForFamilyName:[self.familyNames objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSString *title;// = [[NSString alloc] init];
        NSArray *attributes = [fontNameFull componentsSeparatedByString:@"-"];
        if ( [attributes count] == 1)
            title = @"Normal";
        else
            title = attributes[1];
        
        NSDictionary *attribs = @{ NSFontAttributeName:[UIFont fontWithName:fontNameFull size:16] };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title attributes:attribs];
        cell.textLabel.attributedText = attributedText;
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor =  [UIColor lightGrayColor];
        cell.contentView.backgroundColor = cell.backgroundColor;

        return cell;
    }
    else //tableview.tag == 2021
    {
        static NSString *CellIdentifier = @"FontSizeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        NSString *fontSize = [self.fontSizeArray objectAtIndex:indexPath.row];
        
        NSDictionary *attribs = @{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:16] };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fontSize attributes:attribs];
        cell.textLabel.attributedText = attributedText;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor =  [UIColor lightGrayColor];
        cell.contentView.backgroundColor = cell.backgroundColor;

        return cell;
    }
    return nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView.tag == 2020 )
    {
        NSString *fontName = [[UIFont fontNamesForFamilyName:[self.familyNames objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSDictionary *fontAttributes;
        fontAttributes = @{ NSFontAttributeName:[UIFont fontWithName:fontName size:[self.fontSizeLabel.text intValue]]};
        
        //display attributed Text
        NSAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fontName attributes:fontAttributes];
        self.fontNameLabel.attributedText = attributedText;
        self.fontSizeLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",[self.fontSizeLabel.text intValue]] attributes:fontAttributes];;

        UIFont *font = [UIFont fontWithName:fontName size:[self.fontSizeLabel.text floatValue]];
        [self setAttributedTextForLabels:font];
         
        [self updateSelectedFont:font ];
        
    }
    else
    {
        CGFloat fontSize = [[self.fontSizeArray objectAtIndex:indexPath.row] floatValue];
        UIFont *font = [UIFont fontWithName:self.fontNameLabel.text size:fontSize];
        if ( font == nil )
            font = [UIFont fontWithName:[_currentFont fontName] size:fontSize];
        [self setAttributedTextForLabels:font];
        [self updateSelectedFont:font ];
    }
}

-(void)setAttributedTextForLabels:font
{
    NSDictionary *fontAttributes = @{ NSFontAttributeName:[UIFont fontWithName:[font fontName] size:[font pointSize]] };
    
    self.fontNameLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[font fontName] attributes:fontAttributes];
    self.fontSizeLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",(int)[font pointSize]] attributes:fontAttributes];

}

- (IBAction)changeValue:(UIStepper*)sender
{
    int value = (int)[sender value];
    _currentFontSize = value;

    [self.fontSizeLabel setText:[NSString stringWithFormat:@"%d", value]];
    //[self updateSelectedFont];
}

- (void) updateSelectedFont:(UIFont *)font
{
    if ( font != nil )
    {
        _currentFont = font;
        _currentFontSize = [font pointSize];
        //broadcast that the color selection changed
        NSDictionary *fontInfo = [NSDictionary dictionaryWithObject:font forKey:@"FontChanged"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"FontChanged" object:font userInfo: fontInfo];
    }
    else
    {
        //broadcast that the color selection changed
        NSDictionary *fontInfo = [NSDictionary dictionaryWithObject:_currentFont forKey:@"FontChanged"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"FontChanged" object:_currentFont userInfo: fontInfo];
    }

}

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateFont:(UIFont *)font
{
    self.font = font;
    NSString *fontName = [self.font fontName];
    CGFloat fontSize = [self.font pointSize];
    
    if ( font != nil )
    {
    _currentFont = font;
    _currentFontSize = fontSize;
    }
    
    NSDictionary *attribs = @{
                              NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]
                              };
    NSAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fontName attributes:attribs];
    
    self.fontNameLabel.attributedText = attributedText;
    [self.fontSizeLabel setText:[NSString stringWithFormat:@"%d", (int)fontSize]];
    
}

+(UIFont *)getCurrentFont
{
    if (_currentFont == nil )
    {
        _currentFont = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
        _currentFontSize = 16.0;
    }
    return _currentFont;
}
@end
