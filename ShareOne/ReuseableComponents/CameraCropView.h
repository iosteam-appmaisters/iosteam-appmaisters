//
//  CameraCropView.h
//  VMB
//
//  Created by Vertifi Software on 10/2/12.
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2013 Vertifi Software, LLC
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

#import <UIKit/UIKit.h>
#import <QuartzCore/CAAnimation.h>

@interface CameraCropView : UIView
{
    CGRect rectFrame;                       // frame rectangle
    CGRect rectInnerBounds;                 // inner bounds used for showing corner locators
    
    UIImage *imageCamera;                   // the camera "button" image
    NSString *instructionCamera;            // the "Tap for Photo" instruction
    NSDictionary *dictTextAttributes;       // text attributes for displaying instructionCamera
    CGRect rectTitleCamera;                 // rectangle for instruction
    
    UIColor *fillColor;                     // corner locator fill color
    UIColor *strokeColor;                   // corner locator stroke color
    
    CGFloat tTimerDeferredDisable;          // timestamp for deferred disable
    
    CGPoint pointLastKnownTL;               // last known corner points
    CGPoint pointLastKnownBL;               // .
    CGPoint pointLastKnownTR;               // .
    CGPoint pointLastKnownBR;               // .
    
@public
    CGPoint pointTL;                        // current corner points
    CGPoint pointBL;                        // .
    CGPoint pointTR;                        // .
    CGPoint pointBR;                        // .
}

// Properties

@property (nonatomic, strong) UIImage *imageCamera;
@property (nonatomic, strong) NSString *instructionCamera;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;

// Methods

- (id) initWithFrame:(CGRect)aRect sender:(id)sender;
- (void) drawRect:(CGRect)rect;

@end
