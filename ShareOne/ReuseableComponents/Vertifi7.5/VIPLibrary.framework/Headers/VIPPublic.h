//
//  VIPPublic.h
//  VIPLibrary
//
//  Created by Vertifi Software, LLC on 1/8/18.
//  Copyright 2018 Vertifi Software, LLC. All rights reserved.
//

#ifndef VIPPublic_h
#define VIPPublic_h

// Rear Endorsement enumeration
typedef NS_ENUM(NSInteger,IURearEndorsement)
{
    IURearEndorsementNotTested = 0,
    IURearEndorsementFailed,
    IURearEndorsementPassed
};

//--------------------------------------------------------------------------------------------
// VertifiImageProcessing Class object
//--------------------------------------------------------------------------------------------

@interface VertifiImageProcessing : NSObject
{
}

//--------------------------------------------------------------------------------------------
// Properties
//--------------------------------------------------------------------------------------------

@property (nonatomic, readonly) IURearEndorsement iuRearEndorsement;

//--------------------------------------------------------------------------------------------
// Initializer
//--------------------------------------------------------------------------------------------

// designated initializer, isFront=YES for front images, NO for back images
- (instancetype) initWithSide:(BOOL)isFront;

//--------------------------------------------------------------------------------------------
// Utility functions
//--------------------------------------------------------------------------------------------

// get library version
+ (NSString *) getVersion;

//--------------------------------------------------------------------------------------------
// Helper functions for rotation, scaling
//--------------------------------------------------------------------------------------------
- (UIImage *) onRotateImage180:(UIImage *)image;
- (UIImage *) onScaleImage:(UIImage *)image toWidth:(int)width;

//--------------------------------------------------------------------------------------------
// Cropping
//--------------------------------------------------------------------------------------------

// bind color image for cropping
- (void) onProcessImageCropBindImage:(UIImage *)image;

// perform the crop operation
- (UIImage *) onProcessImageCrop:(NSMutableArray *)dictResultsImage crop:(CGRect *)rectReference viewport:(CGRect *)rectViewPort;

// corner detection for live camera preview processing
- (CGRect) onProcessImageGetCropCorners:(unsigned char *)rawData viewport:(CGRect *)rectViewPort BPP:(int)nBPP width:(int)nWidth height:(int)nHeight stride:(int)nStride toPointTL:(CGPoint *)pointTL toPointTR:(CGPoint *)pointTR toPointBL:(CGPoint *)pointBL toPointBR:(CGPoint *)pointBR;

//--------------------------------------------------------------------------------------------
// B&W conversion
//--------------------------------------------------------------------------------------------

// bind [cropped] color image for processing
- (void) onProcessImageBWBindImage:(UIImage *)image;

// convert to B&W with manual brightness
- (UIImage *) onProcessImageBWDrawImage:(NSMutableArray *)dictResultsImage brightness:(double)brightness;

// convert to B&W with automatic brightness
- (UIImage *) onProcessImageBWDrawImageAuto:(NSMutableArray *)dictResultsImage;

//--------------------------------------------------------------------------------------------
// rear endorsement
//--------------------------------------------------------------------------------------------

// test for rear endorsement
- (UIImage *) onProcessImageEndorsementTest:(UIImage *)image values:(NSArray<NSString *> *)values threshold:(short)threshold apiUrl:(NSString *)apiUrl apiKey:(NSString *)apiKey;

//--------------------------------------------------------------------------------------------
// properties
//--------------------------------------------------------------------------------------------

// brightness measurement
- (CGFloat) brightness;

// smart-scaled image?
- (BOOL) isSmartScaled;

// rear endorsement value
- (IURearEndorsement) iuRearEndorsement;
- (short) rearEndorsementScore;

@end

#endif /* VIPPublic_h */
