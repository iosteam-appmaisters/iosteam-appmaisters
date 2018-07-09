//
//  UISchema.h
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2018 Vertifi Software, LLC
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

#import <Foundation/Foundation.h>

@interface UISchema : NSObject
{
    // colors
    UIColor *colorTint;
    UIColor *colorNavigation;
    UIColor *colorBlack;
    UIColor *colorWhite;
    UIColor *colorClear;
    UIColor *colorLightGray;
    UIColor *colorDarkText;
    UIColor *colorLightText;
    UIColor *colorValue;
    UIColor *colorWarning;
    UIColor *colorFootnote;
    UIColor *colorToastBackground;
    UIColor *colorToastText;
    
    // Fonts
    UIFont *fontHeadline;
    UIFont *fontBody;
    UIFont *fontBodyLarge;
    UIFont *fontCaption1;
    UIFont *fontCaption2;
    UIFont *fontFootnote;
    UIFont *fontFootnoteBold;
    
    // Formatters
    NSNumberFormatter *currencyFormat;                      // for formatting amounts

}

// Properties
@property (nonatomic, strong) UIColor *colorTint;
@property (nonatomic, strong) UIColor *colorNavigation;
@property (nonatomic, strong) UIColor *colorBlack;
@property (nonatomic, strong) UIColor *colorWhite;
@property (nonatomic, strong) UIColor *colorClear;
@property (nonatomic, strong) UIColor *colorLightGray;
@property (nonatomic, strong) UIColor *colorDarkText;
@property (nonatomic, strong) UIColor *colorLightText;
@property (nonatomic, strong) UIColor *colorValue;
@property (nonatomic, strong) UIColor *colorWarning;
@property (nonatomic, strong) UIColor *colorFootnote;
@property (nonatomic, strong) UIColor *colorToastBackground;
@property (nonatomic, strong) UIColor *colorToastText;

@property (nonatomic, strong) UIFont *fontHeadline;
@property (nonatomic, strong) UIFont *fontBody;
@property (nonatomic, strong) UIFont *fontBodyLarge;
@property (nonatomic, strong) UIFont *fontCaption1;
@property (nonatomic, strong) UIFont *fontCaption2;
@property (nonatomic, strong) UIFont *fontFootnote;
@property (nonatomic, strong) UIFont *fontFootnoteBold;

@property (nonatomic, strong) NSNumberFormatter	*currencyFormat;

// Methods
+ (UISchema *) sharedInstance;
- (id)init;

- (void) onFontSizeChanged:(NSNotification *)notification;

@end
