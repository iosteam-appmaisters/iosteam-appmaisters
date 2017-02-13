//
//  UISchema.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2016 Vertifi Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//--------------------------------------------------------------------------------------------------------------------------------------------------

#import "UISchema.h"


@implementation UISchema

@synthesize colorTint;
@synthesize colorNavigation;
@synthesize colorBlack;
@synthesize colorWhite;
@synthesize colorClear;
@synthesize colorLightGray;
@synthesize colorDarkText;
@synthesize colorLightText;
@synthesize colorValue;
@synthesize colorWarning;
@synthesize colorFootnote;
@synthesize colorToastBackground;
@synthesize colorToastText;

@synthesize fontHeadline;
@synthesize fontBody;
@synthesize fontCaption1;
@synthesize fontCaption2;
@synthesize fontFootnote;
@synthesize fontFootnoteBold;

@synthesize currencyFormat;

//--------------------------------------------------------------------------------------------
// Singleton schema object
//--------------------------------------------------------------------------------------------

+ (UISchema *) sharedInstance
{
    static UISchema *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[self alloc] init];
            

        }
    });
    
    return (instance);
}

//--------------------------------------------------------------------------------------------
// instance initialization
//--------------------------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]) != nil)
    {
        // colors
        self.colorNavigation = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
        self.colorTint = [UIColor colorWithRed:0.2804 green:0.5314 blue:0.7196 alpha:1.0f];
        self.colorBlack = [UIColor blackColor];
        self.colorWhite = [UIColor whiteColor];
        self.colorClear = [UIColor clearColor];
        self.colorLightGray = [UIColor colorWithWhite:0 alpha:0.4];
        self.colorDarkText = [UIColor darkTextColor];
        self.colorLightText = [UIColor lightTextColor];
        self.colorValue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        self.colorToastBackground = [UIColor colorWithRed:0.0804 green:0.3314 blue:0.5196 alpha:1.0];
        self.colorToastText = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
        self.colorWarning = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
        self.colorFootnote = [UIColor colorWithRed:0.1804 green:0.4314 blue:0.6196 alpha:1.0f];
        
        // fonts
        [self initFonts];
        
        // currency formatter
        self.currencyFormat = [[NSNumberFormatter alloc] init];
        [currencyFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];   // English/US locale
        [currencyFormat setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [currencyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    }
    return (self);
}

//--------------------------------------------------------------------------------------------
// dealloc
//--------------------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];             // remove observer
}


//-----------------------------------------------------------------------------
// Font initialization
//-----------------------------------------------------------------------------

- (void)initFonts
{
    self.fontHeadline = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.fontBody = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.fontCaption1 = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.fontCaption2 = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    self.fontFootnote = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    // bold fonts
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    self.fontFootnoteBold = [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0.0];
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Notifications
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma mark UIContentSizeCategoryDidChangeNotification

//-----------------------------------------------------------------------------------
// onFontSizeChanged notification
//-----------------------------------------------------------------------------------

- (void) onFontSizeChanged:(NSNotification *)notification
{
    [self initFonts];
}

@end
