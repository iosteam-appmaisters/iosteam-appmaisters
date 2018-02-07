//
//  CameraGridView.m
//  VIPSample
//
//  This UIView draws the static alignment rectangle on the preview window
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
#import <QuartzCore/QuartzCore.h>
#import "CameraGridView.h"
#import "DepositModel.h"
#import "UISchema.h"

@implementation CameraGridView

@synthesize borderColor;
@synthesize letterboxColor;

//-----------------------------------------------------------------------------------
// Initialize
//-----------------------------------------------------------------------------------

- (id) initWithFrame:(CGRect)aRect sender:(id)sender
{
	if ((self = [super initWithFrame:aRect]) != nil)
	{
        depositModel = [DepositModel sharedInstance];						// initialize global

        UISchema *schema = [UISchema sharedInstance];                       // schema
        
        // save frame rectangle for drawing
        rectFrame = CGRectMake(0, 0, aRect.size.width, aRect.size.height);
    
        // Colors
        self.borderColor = schema.colorLightGray;
        self.letterboxColor = schema.colorNavigation;
        
        // transparent background, initially hidden
		self.backgroundColor = schema.colorClear;
        self.autoresizingMask = UIViewAutoresizingNone;;
        self.clipsToBounds = NO;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:1.0f animations:^
        {
             self.alpha = 1.0f;
        } completion:^(BOOL finished)
        {
        }];
        
	}
	return (self);
}

//-----------------------------------------------------------------------------------
// dealloc
//-----------------------------------------------------------------------------------

- (void)dealloc 
{
    
}

//-----------------------------------------------------------------------------------
// Draw
//-----------------------------------------------------------------------------------

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = (CGContextRef)UIGraphicsGetCurrentContext();
    
    CGFloat nWidth = depositModel.rectViewPort.size.width * rectFrame.size.width;
    CGFloat nHeight = (depositModel.rectViewPort.size.height) * rectFrame.size.height;
    int nLeft = rectFrame.origin.x + (depositModel.rectViewPort.origin.x) * rectFrame.size.width;
    int nTop = rectFrame.origin.y + (depositModel.rectViewPort.origin.y) * rectFrame.size.height;

    // the letterboxes
    [self.letterboxColor set];
    
    CGContextFillRect(context, CGRectMake(rectFrame.origin.x, rectFrame.origin.y, rectFrame.size.width, nTop));
    CGContextFillRect(context, CGRectMake(rectFrame.origin.x, rectFrame.origin.y + nTop + nHeight, rectFrame.size.width, rectFrame.size.height - (rectFrame.origin.y + nTop + nHeight)));

    CGContextFillRect(context, CGRectMake(rectFrame.origin.x, nTop, nLeft, nHeight));
    CGContextFillRect(context, CGRectMake(rectFrame.origin.x + nLeft + nWidth, nTop, rectFrame.size.width - (rectFrame.origin.x + nLeft + nWidth), nHeight));
    
 	// the border
	[self.borderColor set];
	CGContextBeginPath(context);
	CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, nLeft, nTop);
    CGContextAddLineToPoint(context, nLeft + nWidth, nTop);
	CGContextAddLineToPoint(context, nLeft + nWidth, nTop + nHeight);
	CGContextAddLineToPoint(context, nLeft, nTop + nHeight);
    CGContextAddLineToPoint(context, nLeft, nTop);
	CGContextStrokePath(context);
}

@end
