//
//  CameraViewController.h
//  VIPSample
//
//  Created by Vertifi Software on 9/27/12.
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


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DepositModel.h"
#import "UISchema.h"
#import "VertifiImageProcessing.h"
#import "CameraGridView.h"
#import "CameraCropView.h"
#import "TransparentToolbar.h"
#import "CameraInstructionViewController.h"

@protocol CameraViewControllerDelegate

- (void) onCameraClose;
- (void) onPictureTaken:(UIImage *)imageJPEG withBWImage:(UIImage *)imageBW results:(NSArray *)dictionary isFront:(BOOL)isFront;

@end

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, CameraInstructionViewControllerDelegate, UIScrollViewDelegate>
{
    // main views
	IBOutlet UIView *previewView;                           // preview view
    IBOutlet TransparentToolbar *toolbarTop;                // top toolbar
    IBOutlet TransparentToolbar *toolbarBottom;             // bottom toolbar
    
    DepositModel *depositModel;                             // deposit model
    UISchema *schema;                                       // schema
    
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
    BOOL isPreviewDisabled;                                 // preview disabled

    // Camera views
    CameraGridView *overlayView;                            // camera overlay
    __block CameraCropView *cropView;                       // crop corners overlay
    NSString *titleString;                                  // overlay title
    UISegmentedControl *switchMode;                         // picture mode button
    UIBarButtonItem *buttonFlash;                           // flash button
    UIBarButtonItem *buttonClose;                           // close button
    UIBarButtonItem *buttonHelpLabel;                       // label button
    UIBarButtonItem *buttonTitleLabel;                      // title button
    NSMutableArray *itemsToolbarPhoto;                      // photo toolbar items

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
    __block UIImage *imageColor;                            // cropped/scaled raw color image
    __block UIImage *imageBW;                               // cropped/scaled B&W image
    __block VertifiImageProcessing *mVIP;                   // VIP image processing object
    BOOL isFront;                                           // is front image?
    NSMutableArray *dictResults;

}

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) TransparentToolbar *toolbarTop;
@property (nonatomic, strong) TransparentToolbar *toolbarBottom;

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

@property (nonatomic, strong) UILabel *labelProcessing;
@property (nonatomic, strong) UISlider *sliderBrightness;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerPreview;
@property (nonatomic, strong) NSString *titleString;

@property (nonatomic, strong) CameraGridView *overlayView;
@property (nonatomic, strong) CameraCropView *cropView;
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
@property (nonatomic, strong) NSMutableArray *dictResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<CameraViewControllerDelegate>)delegate title:(NSString *)title isFront:(BOOL)front;

- (void) loadCameraInstruction;

- (void) setupToolbarForPhoto;
- (void) setupToolbarForPreview;

- (void) setupAVCapture;
- (void) teardownAVCapture;

- (IBAction) onPhotoAccept:(id)sender;
- (IBAction) onPhotoReject:(id)sender;

- (void) onSliderBrightness:(UISlider *)sender;

- (IBAction) onCameraModeChange:(UISegmentedControl *)sender;
- (IBAction) onFlashButton:(UIBarButtonItem *)sender;
- (IBAction) onCameraClose:(id)sender;
- (IBAction) onTakePicture:(UITapGestureRecognizer *)sender;

- (void) displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message;

- (UIImage *) onRotateImage180:(UIImage *)image;

@end
