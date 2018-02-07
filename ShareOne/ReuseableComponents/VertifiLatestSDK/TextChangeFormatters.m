//
//  TextChangeFormatters.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2017 Vertifi Software, LLC
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

//

#import "TextChangeFormatters.h"

@implementation TextChangeFormatters

+ (ContentFormatterBlock) formatterAmount
{
    return (^ BOOL (UITextField *textField, NSRange range, NSString *replacementString) {
        
        NSString *text = [textField text];  // we'll retrieve the old string from the textField to work with.
        NSString *decimalSeperator = @".,";
        
        
        // we'll define a characterSet to filter all invalid chars.  The entered string will be trimmed down to the valid chars only.
        
        NSCharacterSet *characterSet = nil;
        NSString *numberChars = @"0123456789";
        if ([text rangeOfString:decimalSeperator].location != NSNotFound)
            characterSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
        else
            characterSet = [NSCharacterSet characterSetWithCharactersInString:[numberChars stringByAppendingString:decimalSeperator]];
        
        NSCharacterSet *invertedCharSet = [characterSet invertedSet];
        NSString *trimmedString = [replacementString stringByTrimmingCharactersInSet:invertedCharSet];
        
        text = [text stringByReplacingCharactersInRange:range withString:trimmedString];
        [textField setText:text];
        
        // field full?  close keyboard
        for (int i = 0;i < decimalSeperator.length;i++)
        {
            NSString *decimalChar = [decimalSeperator substringWithRange:NSMakeRange(i,1)];
            NSInteger decimalLocation = [text rangeOfString:decimalChar].location;
            if ((decimalLocation != NSNotFound) && (decimalLocation == ([text length] - 3)))
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [textField resignFirstResponder];
                });
                break;
            }
            
        }
        return (NO);							// we return NO because we have manually edited the textField contents.
    });
}

@end
