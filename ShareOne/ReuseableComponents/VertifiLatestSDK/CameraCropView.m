//
//  CameraCropView.m
//  VIPSample
//
//  This UIView draws the corner detectors on the preview window
//
//  Created by Vertifi Software on 10/2/12.
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
//

#import "CameraCropView.h"
#import "DepositModel.h"
#import "CameraViewController.h"

static float kVIP_CORNER_ANGLE_OPTIMAL_MIN = 85.0f;
static float kVIP_CORNER_ANGLE_OPTIMAL_MAX = 95.0f;

@implementation CameraCropView

@synthesize imageCamera;
@synthesize instructionCamera;
@synthesize fillColor;
@synthesize strokeColor;
@synthesize countdownCamera;

//-----------------------------------------------------------------------------------
// Initialize
//-----------------------------------------------------------------------------------

- (id) initWithFrame:(CGRect)aRect sender:(id)sender
{
	if ((self = [super initWithFrame:aRect]) != nil)
	{
        depositModel = [DepositModel sharedInstance];                       // initialize model
        schema = [UISchema sharedInstance];                                 // schema
        
        if ([sender isKindOfClass:CameraViewController.class])
            cameraViewController = sender;                                  // save weak reference to CameraViewController
        
        // save frame rectangle for drawing, set inner bounds rectangle
        rectFrame = CGRectMake(0, 0, aRect.size.width, aRect.size.height);
        rectInnerBounds = CGRectMake(depositModel.rectViewPort.origin.x + (depositModel.rectViewPort.size.width * 0.225), depositModel.rectViewPort.origin.y + (depositModel.rectViewPort.size.height * 0.25), depositModel.rectViewPort.size.width * 0.55, depositModel.rectViewPort.size.height * 0.50);

        // Colors
        self.fillColor = [schema.colorTint colorWithAlphaComponent:0.175f]; // [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.175f];
        self.strokeColor = schema.colorTint; //[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];

        // transparent background, initially hidden
		self.backgroundColor = schema.colorClear;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.clipsToBounds = NO;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;

        // Tap for Photo 'button'
        self.imageCamera = [UIImage imageNamed:@"camera"];

        tTimerDeferredDisable = -1;
        tTimerDeferredTakePicture = -1;
        tTimerDeferredDraw = CACurrentMediaTime() + 3.0f;                   // current time + 3 seconds

        [UIView animateWithDuration:0.4f delay:3.0f options:UIViewAnimationCurveEaseIn animations:^
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

    double tNow = CACurrentMediaTime();                         // current time (fractional seconds)

    if (tTimerDeferredDraw > tNow)                              // not past deferred drawing time?
        return;
    
    CGContextRef context = (CGContextRef)UIGraphicsGetCurrentContext();
    
 	// the corners
    CGFloat nWidth = depositModel.rectViewPort.size.width * rectFrame.size.width;
    CGFloat nHeight = (depositModel.rectViewPort.size.height) * rectFrame.size.height;
    int nLeft = rectFrame.origin.x + (depositModel.rectViewPort.origin.x) * rectFrame.size.width;
    int nTop = rectFrame.origin.y + (depositModel.rectViewPort.origin.y) * rectFrame.size.height;

    int nCorners = 0;                                           // count # of good corners

    if ((pointTL.x > depositModel.rectViewPort.origin.x) && (pointTL.x < rectInnerBounds.origin.x) && (pointTL.y > depositModel.rectViewPort.origin.y) && (pointTL.y < rectInnerBounds.origin.y))
        nCorners++;
    if ((pointBL.x > depositModel.rectViewPort.origin.x) && (pointBL.x < rectInnerBounds.origin.x) && (pointBL.y > rectInnerBounds.origin.y + rectInnerBounds.size.height) && (pointBL.y < depositModel.rectViewPort.origin.y + depositModel.rectViewPort.size.height))
        nCorners++;
    if ((pointTR.x > rectInnerBounds.origin.x + rectInnerBounds.size.width) && (pointTR.y > depositModel.rectViewPort.origin.y) && (pointTR.y < rectInnerBounds.origin.y))
        nCorners++;
    if ((pointBR.x > rectInnerBounds.origin.x + rectInnerBounds.size.width) && (pointBR.y > rectInnerBounds.origin.y + rectInnerBounds.size.height) && (pointBR.y < depositModel.rectViewPort.origin.y + depositModel.rectViewPort.size.height))
        nCorners++;
    
    // measure angles
    double dAngleTL,dAngleTR,dAngleBL,dAngleBR;
    dAngleTL = [CameraCropView getAngle:pointTL withVector:pointTR andVector:pointBL];
    dAngleTR = [CameraCropView getAngle:pointTR withVector:pointTL andVector:pointBR];
    dAngleBL = [CameraCropView getAngle:pointBL withVector:pointTL andVector:pointBR];
    dAngleBR = [CameraCropView getAngle:pointBR withVector:pointTR andVector:pointBL];

    // 4 corners and all optimal angles?
    if ((nCorners == 4) &&
        (dAngleTL >= kVIP_CORNER_ANGLE_OPTIMAL_MIN) && (dAngleTL <= kVIP_CORNER_ANGLE_OPTIMAL_MAX) &&
        (dAngleTR >= kVIP_CORNER_ANGLE_OPTIMAL_MIN) && (dAngleTR <= kVIP_CORNER_ANGLE_OPTIMAL_MAX) &&
        (dAngleBR >= kVIP_CORNER_ANGLE_OPTIMAL_MIN) && (dAngleBR <= kVIP_CORNER_ANGLE_OPTIMAL_MAX) &&
        (dAngleBL >= kVIP_CORNER_ANGLE_OPTIMAL_MIN) && (dAngleBL <= kVIP_CORNER_ANGLE_OPTIMAL_MAX))
    {
        tTimerDeferredDisable = tNow + 0.400;                   // 4/10 second deferred
        
        if ((cameraMode == kVIP_MODE_AUTOMATIC) && (tTimerDeferredTakePicture == -1))
            tTimerDeferredTakePicture = tNow + 0.400;           // 4/10 second deferred for auto mode
        
        pointLastKnownTL.x = pointTL.x;
        pointLastKnownTL.y = pointTL.y;
        pointLastKnownTR.x = pointTR.x;
        pointLastKnownTR.y = pointTR.y;
        pointLastKnownBL.x = pointBL.x;
        pointLastKnownBL.y = pointBL.y;
        pointLastKnownBR.x = pointBR.x;
        pointLastKnownBR.y = pointBR.y;
    }

    // if we're in a deferred disable state and past the time, clear the last knowns and deferred timestamp
    if ((tNow >= tTimerDeferredDisable) && (nCorners < 4))
    {
        pointLastKnownTL.x = 0;
        pointLastKnownTL.y = 0;
        pointLastKnownTR.x = 0;
        pointLastKnownTR.y = 0;
        pointLastKnownBL.x = 0;
        pointLastKnownBL.y = 0;
        pointLastKnownBR.x = 0;
        pointLastKnownBR.y = 0;
        
        tTimerDeferredDisable = -1;
        tTimerDeferredTakePicture = -1;
        
        return;
    }

    CGFloat xCenter = (rectFrame.size.width * depositModel.rectViewPort.origin.x) + ((rectFrame.size.width * depositModel.rectViewPort.size.width) / 2);
    CGFloat yCenter = (rectFrame.size.height * depositModel.rectViewPort.origin.y) + ((rectFrame.size.height * depositModel.rectViewPort.size.height) / 2);

    // take picture countdown
    if ((tTimerDeferredTakePicture > 0) && (tNow > tTimerDeferredTakePicture) && (nCorners == 4))
    {
        
        if ((cameraMode == kVIP_MODE_AUTOMATIC) && (self.countdownCamera != nil))
        {
            if (tNow - tTimerDeferredTakePicture < 0.75f)
            {
                [countdownCamera replaceCharactersInRange:NSMakeRange(0, 1) withString:@"3"];
            }
            else if (tNow - tTimerDeferredTakePicture < 1.25f)
            {
                [countdownCamera replaceCharactersInRange:NSMakeRange(0, 1) withString:@"2"];
            }
            else if (tNow - tTimerDeferredTakePicture < 1.75f)
            {
                [countdownCamera replaceCharactersInRange:NSMakeRange(0, 1) withString:@"1"];
            }
            else
            {
                tTimerDeferredTakePicture = -1;
                tTimerDeferredDraw = tNow + 0.400;
                [cameraViewController onTakePicture:nil];
                
                // simulate a flash
                [schema.colorWhite set];
                CGContextFillRect(context, rect);
                return;
            }

            // text
            [self.countdownCamera drawInRect:CGRectMake(xCenter - (rectCountdownCamera.size.width / 2), yCenter - rectCountdownCamera.size.height - 12, rectCountdownCamera.size.width, rectCountdownCamera.size.height) withAttributes:dictCountdownAttributes];
            [self.instructionCamera drawInRect:CGRectMake(xCenter - (rectTitleCamera.size.width / 2), yCenter, rectTitleCamera.size.width, rectTitleCamera.size.height) withAttributes:dictTextAttributes];
        }
        
    }
    
    // draw the corners
    if ((pointLastKnownTL.x != 0) && (pointLastKnownTL.y != 0))
    {
        if ((cameraMode == kVIP_MODE_MANUAL) && (self.instructionCamera != nil))
        {
            // image
            CGContextSetShadowWithColor(context, CGSizeMake(1,1), 4.0, schema.colorBlack.CGColor);
            [imageCamera drawAtPoint:CGPointMake(xCenter - (imageCamera.size.width / 2), yCenter - (imageCamera.size.height))];
        
            // text
            [self.instructionCamera drawInRect:CGRectMake(xCenter - (rectTitleCamera.size.width / 2), yCenter, rectTitleCamera.size.width, rectTitleCamera.size.height) withAttributes:dictTextAttributes];
        }
        
        double dWidth = 1.0f;

        // fill, involves filling the viewport but excluding the inner quadrilateral ... must draw concentric paths, outer path Clockwise, inner path counter-clockwise

        [fillColor set];
        
        // fill viewport path (CW)
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, nLeft, nTop);
        CGContextAddLineToPoint(context, nLeft + nWidth, nTop);
        CGContextAddLineToPoint(context, nLeft + nWidth, nTop + nHeight);
        CGContextAddLineToPoint(context, nLeft, nTop + nHeight);
        CGContextAddLineToPoint(context, nLeft, nTop);
        CGContextClosePath(context);
        
        // corners rectangle (CCW)
        CGContextMoveToPoint(context, (rectFrame.size.width * pointLastKnownTL.x), (rectFrame.size.height * pointLastKnownTL.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownBL.x), (rectFrame.size.height * pointLastKnownBL.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownBR.x), (rectFrame.size.height * pointLastKnownBR.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownTR.x), (rectFrame.size.height * pointLastKnownTR.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownTL.x), (rectFrame.size.height * pointLastKnownTL.y));
        CGContextClosePath(context);
        
        CGContextFillPath(context);                             // do the fill

        // border stroke
        [strokeColor set];
        CGContextSetLineWidth(context, dWidth);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (rectFrame.size.width * pointLastKnownTL.x), (rectFrame.size.height * pointLastKnownTL.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownTR.x), (rectFrame.size.height * pointLastKnownTR.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownBR.x), (rectFrame.size.height * pointLastKnownBR.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownBL.x), (rectFrame.size.height * pointLastKnownBL.y));
        CGContextAddLineToPoint(context, (rectFrame.size.width * pointLastKnownTL.x), (rectFrame.size.height * pointLastKnownTL.y));

        CGContextStrokePath(context);                           // do the stroke

    }
    
}

//---------------------------------------------------------------------------------------------
//
// setMode
//
// set cameraMode (AUTOMATIC or MANUAL)
//
//---------------------------------------------------------------------------------------------

- (void) setMode:(NSInteger)mode
{
    cameraMode = mode;

    if (cameraMode == kVIP_MODE_MANUAL)
        self.instructionCamera = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_INSTRUCTION_CAMERA" value:@"Tap for Photo" table:@"VIPSample"];
    else
        self.instructionCamera = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_INSTRUCTION_AUTO_PHOTO" value:@"Hold Steady" table:@"VIPSample"];

    self.countdownCamera = [NSMutableString stringWithString:@"3"];

    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:schema.colorBlack];
    [shadow setShadowOffset:CGSizeMake(1,1)];
    [shadow setShadowBlurRadius:4];

    UIFont *font = [UIFont systemFontOfSize:30];
    CGSize szMaxLabel = CGSizeMake (self.frame.size.width,36);
    rectTitleCamera = [self.instructionCamera boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSLineBreakByWordWrapping attributes:@{NSFontAttributeName: font} context:nil];
    dictTextAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0f alpha:1.0f], NSShadowAttributeName:shadow};

    font = [UIFont systemFontOfSize:72];
    szMaxLabel = CGSizeMake (self.frame.size.width,54);
    rectCountdownCamera = [self.countdownCamera boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSLineBreakByWordWrapping attributes:@{NSFontAttributeName: font} context:nil];
    dictCountdownAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:0.5 alpha:1.0], NSShadowAttributeName:shadow};

    [self reset];
}

- (void) reset
{
    tTimerDeferredDisable = -1;
    tTimerDeferredTakePicture = -1;
}

//---------------------------------------------------------------------------------------------
//
// getAngle
//
// return angle between two vectors
//
//---------------------------------------------------------------------------------------------

+ (CGFloat) getAngle:(CGPoint)anchor withVector:(CGPoint)p1 andVector:(CGPoint)p2
{
    double nDot;
    double nLen1,nLen2;
    
    nDot = ((p1.x - anchor.x) * (p2.x - anchor.x)) +
    ((p1.y - anchor.y) * (p2.y - anchor.y));
    
    nLen1 = hypot((p1.x - anchor.x),(p1.y - anchor.y));
    nLen2 = hypot((p2.x - anchor.x),(p2.y - anchor.y));
    
    return (acos(nDot / (nLen1 * nLen2)) * (180.0f / M_PI));
}

@end
