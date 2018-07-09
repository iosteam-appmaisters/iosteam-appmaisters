//
//  CameraViewController.h
//  VIPSample
//
//  Created by Vertifi Software on 9/27/12.
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
// Use of VIPLibrary framework and its API's is protected under separate license agreement
//
//--------------------------------------------------------------------------------------------------------------------------------------------------


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <VIPLibrary/VIPLibrary.h>

#import "DepositModel.h"
#import "UISchema.h"
#import "CameraLetterboxView.h"
#import "CameraOverlayView.h"
#import "CameraInstructionViewController.h"

@protocol CameraViewControllerDelegate

- (void) onCameraClose;
- (void) onPictureTaken:(UIImage *)imageJPEG withBWImage:(UIImage *)imageBW results:(NSArray *)results isFront:(BOOL)isFront;

@end

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, CameraInstructionViewControllerDelegate, UIScrollViewDelegate>
{
    DepositModel *depositModel;                             // deposit model
    UISchema *schema;                                       // schema
    
    // main views
	IBOutlet UIView *previewView;                           // preview view
    IBOutlet UIToolbar *toolbarTop;                         // top toolbar
    IBOutlet UIToolbar *toolbarBottom;                      // bottom toolbar
    
    // common views
    UIBarButtonItem *flexBarButtonItem;                     // bar button spacers
    UIBarButtonItem *fixBarButtonItem;
    UIBarButtonItem *fixBarButtonItemWide;
    
    // Image preview
    IBOutlet UIScrollView *scrollViewPreview;               // preview scroller
	UIImageView *imageViewPreview;                          // scroller child UIImageView
    UIActivityIndicatorView *spinnerPreview;                // spinner
    UIBarButtonItem *buttonHelp;                            // help button
    UIBarButtonItem *buttonReject;                          // reject photo button
    UIBarButtonItem *buttonAccept;                          // accept photo button
    UIBarButtonItem *buttonSlider;                          // slider button
    UILabel *labelProcessing;                               // processing photo label
    UISlider *sliderBrightness;                             // brightness slider
    NSMutableArray *itemsToolbarPreview;                    // preview toolbar items

    // Camera views
    CameraLetterboxView *letterboxView;                     // camera letterbox overlay
    CameraOverlayView *overlayView;                         // edge detectors overlay
    NSString *titleString;                                  // overlay title
    UISegmentedControl *switchMode;                         // picture mode button
    UIBarButtonItem *buttonFlash;                           // flash button
    UIBarButtonItem *buttonClose;                           // close button
    UIBarButtonItem *buttonHelpLabel;                       // label button
    UIBarButtonItem *buttonTitleLabel;                      // title button
    NSMutableArray *itemsToolbarPhoto;                      // photo toolbar items

    UITapGestureRecognizer *tapRecognizer;                  // tap gesture
    
    // delegate
    id<CameraViewControllerDelegate> __unsafe_unretained delegate;  // controller delegate (close or photo taken)
    
    // AV Foundation stuff
	AVCaptureSession *session;                              // session
    AVCaptureDevice *device;                                // device
    AVCaptureVideoPreviewLayer *previewLayer;               // preview CALayer
	AVCaptureStillImageOutput *stillImageOutput;            // still image output
	AVCaptureVideoDataOutput *videoDataOutput;              // video data output for per frame processing
	dispatch_queue_t videoDataOutputQueue;                  // queue for per frame processing
    BOOL isCapturingStillImage;                             // is capturing still image flag
    
    // Image processing
    dispatch_queue_t imageProcessingQueue;                  // image processing on background queue
    UIImage *imageColor;                                    // cropped/scaled raw color image
    UIImage *imageBW;                                       // cropped/scaled B&W image
    VertifiImageProcessing *mVIP;                           // VIP image processing object
    BOOL isFront;                                           // is front image?
    NSMutableArray *arrayResults;                           // library results array

}

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIToolbar *toolbarTop;
@property (nonatomic, strong) UIToolbar *toolbarBottom;

@property (nonatomic, strong) UIBarButtonItem *flexBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixBarButtonItemWide;

@property (nonatomic, strong) UIScrollView *scrollViewPreview;
@property (nonatomic, strong) UIImageView *imageViewPreview;
@property (nonatomic, strong) UIBarButtonItem *buttonHelp;
@property (nonatomic, strong) UIBarButtonItem *buttonReject;
@property (nonatomic, strong) UIBarButtonItem *buttonAccept;
@property (nonatomic, strong) UIBarButtonItem *buttonSlider;
@property (nonatomic, strong) NSMutableArray *itemsToolbarPreview;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UILabel *labelProcessing;
@property (nonatomic, strong) UISlider *sliderBrightness;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerPreview;
@property (nonatomic, strong) NSString *titleString;

@property (nonatomic, strong) CameraLetterboxView *letterboxView;
@property (nonatomic, strong) CameraOverlayView *overlayView;
@property (nonatomic, strong) UISegmentedControl *switchMode;
@property (nonatomic, strong) UIBarButtonItem *buttonFlash;
@property (nonatomic, strong) UIBarButtonItem *buttonClose;
@property (nonatomic, strong) UIBarButtonItem *buttonHelpLabel;
@property (nonatomic, strong) UIBarButtonItem *buttonTitleLabel;
@property (nonatomic, strong) NSMutableArray *itemsToolbarPhoto;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) UIImage *imageColor;
@property (nonatomic, strong) UIImage *imageBW;
@property (nonatomic, strong) VertifiImageProcessing *mVIP;

@property (nonatomic, unsafe_unretained) id delegate;
@property (assign) BOOL isFront;
@property (assign) BOOL isCapturingStillImage;
@property (nonatomic, strong) NSMutableArray *arrayResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<CameraViewControllerDelegate>)delegate title:(NSString *)title isFront:(BOOL)front;

- (void) loadCameraInstruction:(id)sender;

- (void) setupToolbarForPhoto;
- (void) setupToolbarForPreview;

- (void) setupAVCapture;
- (void) teardownAVCapture;

- (UIImage *) testRearEndorsement;

- (IBAction) onPhotoAccept:(id)sender;
- (IBAction) onPhotoReject:(id)sender;

- (void) onSliderBrightness:(UISlider *)sender;
- (void) showFocusRectAt:(CGPoint)point;

- (IBAction) onCameraModeChange:(UISegmentedControl *)sender;
- (IBAction) onFlashButton:(UIBarButtonItem *)sender;
- (IBAction) onCameraClose:(id)sender;
- (IBAction) onTakePicture:(UITapGestureRecognizer *)sender;

- (void) displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message;

@end
