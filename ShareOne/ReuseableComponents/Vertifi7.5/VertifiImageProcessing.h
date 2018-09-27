//
//  VertifiImageProcessing.h
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

#import <UIKit/UIKit.h>

@interface VertifiImageProcessing : NSObject
{
}

// Instance methods

- (id) initWithSide:(BOOL)isFront;

- (void) onProcessImageCropBindImage:(UIImage *)image;
- (UIImage *) onProcessImageCrop:(NSMutableArray *)dictResultsImage crop:(CGRect *)rectReference viewport:(CGRect *)rectViewPort;

- (CGRect) onProcessImageGetCropCorners:(unsigned char *)rawData viewport:(CGRect *)rectViewPort BPP:(int)nBPP width:(int)nWidth height:(int)nHeight stride:(int)nStride toPointTL:(CGPoint *)pointTL toPointTR:(CGPoint *)pointTR toPointBL:(CGPoint *)pointBL toPointBR:(CGPoint *)pointBR;

- (void) onProcessImageBWBindImage:(UIImage *)image;
- (UIImage *) onProcessImageBWDrawImage:(NSMutableArray *)dictResultsImage brightness:(double)brightness;
- (UIImage *) onProcessImageBWDrawImageAuto:(NSMutableArray *)dictResultsImage;

- (UIImage *) onRotateImage180:(UIImage *)image;
- (UIImage *) onScaleImage:(UIImage *)image toWidth:(int)width;

- (UIImage *) onProcessImageEndorsementTest:(UIImage *)image values:(NSArray<NSString *> *)values threshold:(int)threshold apiKey:(NSString *)apiKey;

- (CGFloat) brightness;                 // brightness/contrast
- (BOOL) isSmartScaled;                 // smart-scaled image?

// rear endorsement value and score
- (NSString *)rearEndorsement;
- (int)rearEndorsementScore;
- (NSString *)rearEndorsement;

// rear endorsement API URL
- (void) setVisionApiUrl:(NSString *)visionApiUrl;

// Static methods

+ (NSString *) getVersion;

@end