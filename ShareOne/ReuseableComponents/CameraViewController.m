//
//  Controller.m
//  ImageProcSample
//
//  Created by Vertifi Software on 9/27/12.
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

#import "Global.h"
#import "CameraViewController.h"
#import "VertifiImageProcessing.h"
//#import "GoogleAnalytics.h"


@interface CameraViewController ()

@end

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *kAVCaptureStillImageIsCapturing = @"AVCaptureStillImageIsCapturing";
static const NSString *kAVCaptureDeviceAdjust = @"AVCaptureDeviceAdjust";

static const float VIP_VIEWPORT_ASPECT_WIDE = 2.4f;
static const float VIP_VIEWPORT_ASPECT_NORMAL = 2.2f;

@implementation CameraViewController

@synthesize previewView;
@synthesize toolbarTop;
@synthesize toolbarBottom;
@synthesize fixBarButtonItem;
@synthesize fixBarButtonItemWide;
@synthesize flexBarButtonItem;

@synthesize scrollViewPreview;
@synthesize imageViewPreview;
@synthesize spinnerPreview;
@synthesize buttonHelp;
@synthesize buttonAccept;
@synthesize buttonReject;
@synthesize buttonSlider;
@synthesize labelProcessing;
@synthesize sliderBrightness;
@synthesize titleString;
@synthesize itemsToolbarPreview;

@synthesize overlayView;
@synthesize cropView;
@synthesize buttonFlash;
@synthesize buttonClose;
@synthesize buttonHelpLabel;
@synthesize buttonTitleLabel;
@synthesize itemsToolbarPhoto;

@synthesize session;
@synthesize device;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize videoDataOutput;

@synthesize imageColor;
@synthesize imageBW;
@synthesize mVIP;

@synthesize delegate;
@synthesize isFront;
@synthesize isCapturingStillImage;
@synthesize dictResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<CameraViewControllerDelegate>)cvdelegate title:(NSString *)title isFront:(BOOL)front
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.delegate = cvdelegate;
        self.titleString = title;
        self.isFront = front;
        //self.wantsFullScreenLayout = YES;
        self.dictResults = [[NSMutableArray alloc] init];
    }
    return (self);
}
//------------------------------------------------------------------------------------------
// viewDidLoad
//------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // -------------------------------------------------------------------------------------
    // Picture
    // -------------------------------------------------------------------------------------
    
    // initialize AV Foundation
    [self setupAVCapture];
    
    previewView.backgroundColor = [UIColor whiteColor];

    // camera overlay - the alignment rectangle
	self.overlayView = [[CameraGridView alloc] initWithFrame:CGRectMake(0,0,previewView.bounds.size.width,previewView.bounds.size.height) sender:self];
    [previewView addSubview:overlayView];
    
    // camera crop view - the corner detectors
    self.cropView = [[CameraCropView alloc] initWithFrame:CGRectMake(0,0,previewView.bounds.size.width,previewView.bounds.size.height) sender:self];
    cropView.alpha = 0;
    [previewView addSubview:cropView];

    // alignment image
    Global *pGl = [Global globalinstance];
    CGFloat margin = 8;
    UIImageView *alignImage = [[UIImageView alloc] initWithFrame:CGRectMake((previewView.bounds.size.width * pGl.rectViewPort.origin.x) + margin,
                                                                            (previewView.bounds.size.height * pGl.rectViewPort.origin.y) + margin,
                                                                            (previewView.bounds.size.width * (pGl.rectViewPort.size.width)) - (margin * 2),
                                                                            (previewView.bounds.size.height * (pGl.rectViewPort.size.height)) - (margin * 2))];
    [alignImage setImage:[UIImage imageNamed:isFront ? @"ckalignfront" : @"ckalignback"]];
    alignImage.contentMode = UIViewContentModeScaleAspectFit;
    alignImage.alpha = 0;
    
    [previewView addSubview:alignImage];
    
    [UIView animateWithDuration:0.4f animations:^{
        alignImage.alpha = 1.0;
    } completion:^(BOOL finished) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:1.4f animations:^{
                alignImage.alpha = 0;
                cropView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [alignImage removeFromSuperview];
            }];
        });
    }];

    // -------------------------------------------------------------------------------------
    // Preview view
    // -------------------------------------------------------------------------------------
    
    scrollViewPreview.backgroundColor = [UIColor blackColor];
    
    // Scroll container view
    self.imageViewPreview = [[UIImageView alloc] initWithFrame:scrollViewPreview.frame];
    imageViewPreview.frame = scrollViewPreview.frame;					// same as scroller
    imageViewPreview.contentMode = UIViewContentModeScaleAspectFit;
    
    // configure scroll view
    scrollViewPreview.contentSize = CGSizeMake(imageViewPreview.frame.size.width, imageViewPreview.frame.size.height);
    scrollViewPreview.contentMode = UIViewContentModeScaleAspectFit;
    [scrollViewPreview addSubview:imageViewPreview];
    
    self.spinnerPreview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinnerPreview.frame = CGRectMake(scrollViewPreview.center.x - 15, scrollViewPreview.center.y - 15,30,30);
    spinnerPreview.center = scrollViewPreview.center;
    spinnerPreview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    spinnerPreview.hidesWhenStopped = YES;
    [self.view addSubview:spinnerPreview];
    
    [self setupToolbarForPhoto];
    
    // VIP library queue initialization
    imageProcessingQueue = dispatch_queue_create("com.Vertifi.ImageProcessing.Queue", DISPATCH_QUEUE_SERIAL);
    
    // VIP library initialization
    dispatch_async(imageProcessingQueue, ^
    {
        self.mVIP = [[VertifiImageProcessing alloc] initWithSide:self.isFront];
    });
    
}

//------------------------------------------------------------------------------------------
// viewDidLayoutSubviews
//------------------------------------------------------------------------------------------

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    imageViewPreview.frame = scrollViewPreview.frame;					// same as scroller
    scrollViewPreview.contentSize = CGSizeMake(imageViewPreview.frame.size.width, imageViewPreview.frame.size.height);
    spinnerPreview.center = imageViewPreview.center;
}

//------------------------------------------------------------------------------------------
// memory warning
//------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
// interface orientation - landscape only!
//------------------------------------------------------------------------------------------

// interface orientation (iOS6)
- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscape);
}

// interface orientation (iOS5)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        return (YES);
    return (NO);
}

//------------------------------------------------------------------------------------------
// device rotations - rotate preview layer
//------------------------------------------------------------------------------------------

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^
     {
         switch (toInterfaceOrientation)
         {
             case UIInterfaceOrientationLandscapeLeft:
                 [previewLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 [previewLayer setAffineTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
                 break;
             default:
                 break;
         }
         
     } completion:^(BOOL finished)
     {
     }];
    
}

//------------------------------------------------------------------------------------------
// dealloc
//------------------------------------------------------------------------------------------

- (void) dealloc
{
    self.delegate = nil;                    // release delegate
    //[self teardownAVCapture];               // AVFoundation teardown
    
//    if (imageProcessingQueue != nil)        // queue for ImageProcessing
//        dispatch_release(imageProcessingQueue);
}

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// initialize for Photo
//------------------------------------------------------------------------------------------

- (void) setupToolbarForPhoto
{
    //toolbarTop.hidden = NO;
    [UIView animateWithDuration:0.4f animations:^
     {
         toolbarTop.alpha = 1.0f;
         previewView.alpha = 1.0f;                              // show camera preview
         overlayView.alpha = 1.0f;                              // show camera overlay
         scrollViewPreview.alpha = 0.0f;                        // hide the scroller
     } completion:^(BOOL finished)
     {
         scrollViewPreview.hidden = YES;
         
         [UIView animateWithDuration:0.4f delay:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^
          {
              cropView.alpha = 1.0f;                            // show crop corners after delay
          } completion:^(BOOL finished)
          {
          }];
     }];
    
    self.imageColor = nil;                                      // clear color image
    self.imageBW = nil;                                         // clear B/W imae
    imageViewPreview.image = nil;                               // and preview ImageView

    // spacers
    if (flexBarButtonItem == nil)
        self.flexBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if (fixBarButtonItem == nil)
        self.fixBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (fixBarButtonItemWide == nil)
    {
        self.fixBarButtonItemWide = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixBarButtonItemWide.width = 10;
    }

    // title label
    if (buttonTitleLabel == nil)
    {
        UILabel *labelTitle = [[UILabel alloc] init];
        [labelTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        [labelTitle setTextColor:[UIColor lightTextColor]];
        [labelTitle setText:self.titleString];
        [labelTitle sizeToFit];
        buttonTitleLabel = [[UIBarButtonItem alloc] initWithCustomView:labelTitle];
        self.buttonFlash =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flash_off"] style:UIBarButtonItemStylePlain target:self action:@selector(onFlashButton:)];
        buttonFlash.tag = kVIP_FLASH_OFF;
        [toolbarTop setItems:[NSMutableArray arrayWithObjects:fixBarButtonItem,buttonTitleLabel,flexBarButtonItem,buttonFlash,fixBarButtonItem,nil] animated:YES];
    }
    
    // help label
    if (buttonHelpLabel == nil)
    {
        UILabel *labelInstruction = [[UILabel alloc] init];
        [labelInstruction setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
        [labelInstruction setTextColor:[UIColor lightTextColor]];
        [labelInstruction setText:[[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_TIP_CAMERA" value:@"Place check on dark surface, align to fit within green guide lines" table:@"VIPSample"]];
        [labelInstruction sizeToFit];
        buttonHelpLabel = [[UIBarButtonItem alloc] initWithCustomView:labelInstruction];
    }
    
    // close button
    if (buttonClose == nil)
        self.buttonClose = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onCameraClose:)];
    
    // set the toolbar buttons
    if (itemsToolbarPhoto == nil)
        itemsToolbarPhoto = [NSMutableArray arrayWithObjects:fixBarButtonItem,buttonHelpLabel,flexBarButtonItem,buttonClose,fixBarButtonItem,nil];
    [toolbarBottom setItems:itemsToolbarPhoto animated:(BOOL)YES];

    // enable video output and start session
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    spinnerPreview.color = [UIColor lightTextColor];
    
}

//------------------------------------------------------------------------------------------
// initialize for Preview
//------------------------------------------------------------------------------------------

- (void) setupToolbarForPreview
{
    //-------------------------------------------------------------------------------------------
    // Toolbar setup
    //-------------------------------------------------------------------------------------------
    
    [UIView animateWithDuration:0.2f animations:^
     {
         toolbarTop.alpha = 0.0f;

     } completion:^(BOOL finished)
     {
         //toolbarTop.hidden = YES;
     }];

    
    // brightness slider
    if (sliderBrightness == nil)
    {
        self.sliderBrightness = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
        sliderBrightness.minimumValueImage = [[UIImage imageNamed:@"darkness.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        sliderBrightness.maximumValueImage = [[UIImage imageNamed:@"brightness.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        sliderBrightness.value = 0.5f;
        sliderBrightness.continuous = NO;
        [sliderBrightness addTarget:self action:@selector(onSliderBrightness:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (buttonSlider == nil)
        self.buttonSlider = [[UIBarButtonItem alloc] initWithCustomView:sliderBrightness];
    
    // reject button
    if (buttonReject == nil)
    {
        self.buttonReject = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onPhotoReject:)];
    }
    
    // accept button
    if (buttonAccept == nil)
        self.buttonAccept = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPhotoAccept:)];
    
    buttonAccept.enabled = NO;
    buttonReject.enabled = NO;
    
    // set the toolbar buttons
    self.itemsToolbarPreview = [NSMutableArray arrayWithObjects:fixBarButtonItem,buttonReject,flexBarButtonItem,flexBarButtonItem,buttonAccept,fixBarButtonItem,nil];
    
    [toolbarBottom setItems:itemsToolbarPreview animated:(BOOL)YES];

    //-------------------------------------------------------------------------------------------
    // Image Processing - color cropping
    //-------------------------------------------------------------------------------------------
    dispatch_async(imageProcessingQueue, ^
                   {
                       @autoreleasepool
                       {
                           
                           [dictResults removeAllObjects];

                           Global *pGl = [Global globalinstance];                                        // initialize global

                           CGRect *rectRef = (CGRect *)NULL;
                           CGRect rectViewport = pGl.rectViewPort;

                           if (!isFront)
                           {
                               if (!CGRectIsNull(pGl.rectFront))
                               {
                                   CGRect rectReference = pGl.rectFront;
                                   rectRef = &rectReference;
                               }

                           }
                           
                           // Create cropped/scaled color image
                           
                           self.imageColor = [mVIP onProcessImageCrop:dictResults crop:rectRef viewport:&rectViewport];
                           
                           dispatch_async(dispatch_get_main_queue(), ^(void)
                                          {
                                              imageViewPreview.image = imageColor;                      // set Color image into ImageView
                                              imageViewPreview.alpha = 0;
                                              
                                              [UIView animateWithDuration:0.2f animations:^
                                               {
                                                   imageViewPreview.alpha = 1.0f;
                                               } completion:^(BOOL finished)
                                               {
                                               }];
                                              
                                          });
                           
                       }
                       
                   });
    
    //-------------------------------------------------------------------------------------------
    // Image Processing (color to b/w)
    //-------------------------------------------------------------------------------------------
    dispatch_async(imageProcessingQueue, ^
                   {
                       @autoreleasepool
                       {
                           // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                           // Google Analytics
//                           @try
//                           {
//                               GAIDictionaryBuilder *gaiDictionary = [GAIDictionaryBuilder createEventWithCategory:(isFront ? @"Front" : @"Back")
//                                                                                                            action:@"Photo"
//                                                                                                             label:(dictResults.count == 0 ? @"Success" : dictResults.firstObject)
//                                                                                                             value:nil];
//                               id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//                               [tracker set:[GAIFields customDimensionForIndex:2] value:[VertifiImageProcessing getVersion]];
//                               [tracker send:[gaiDictionary build]];
//                           }
//                           @catch (NSException *exception)
//                           {
//                               NSLog(@"Google Analytics exception %@",exception.reason);
//                           }
//                           @finally
//                           {
//                           }
                           // End Google Analytics
                           // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                           
                           if (dictResults.count == 0)
                           {
                               [mVIP onProcessImageBWBindImage:imageColor];
                               
                               // Convert to Black/White in auto-brightness mode
                               self.imageBW = [mVIP onProcessImageBWDrawImageAuto:dictResults];
                               
                               // main thread update UI
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  sliderBrightness.value = [mVIP brightness];             // set proper initial brightness
                                                  
                                                  [UIView transitionWithView:imageViewPreview duration:0.8f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                                                      
                                                      imageViewPreview.image = imageBW;                   // set B/W image into ImageView using cross dissolve
                                                      
                                                  } completion:^(BOOL finished)
                                                   {
                                                   }];
                                                  
                                                  
                                              });
                           }
                           
                           // main thread update UI
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [UIView animateWithDuration:0.4f animations:^
                                               {
                                                   [spinnerPreview stopAnimating];
                                                   labelProcessing.alpha = 0.0f;                            // fade out Processing label
                                               } completion:^(BOOL finished)
                                               {
                                                   [labelProcessing removeFromSuperview];                   // remove label from superview
                                               }];
                                              
                                              buttonReject.enabled = YES;                                   // enable Reject button
                                              
                                              // No errors???  Insert slider and enable the Accept button
                                              if (dictResults.count == 0)
                                              {
                                                  // insert UISlider into toolbar
                                                  [self.itemsToolbarPreview insertObject:buttonSlider atIndex:3];
                                                  [toolbarBottom setItems:itemsToolbarPreview animated:(BOOL)YES];
                                                  
                                                  buttonAccept.enabled = YES;
                                              }
                                              else
                                              {
                                                  NSMutableString *strContent = [[NSMutableString alloc] initWithString:@""];
                                                  for (id key in dictResults)
                                                  {
                                                      [strContent appendFormat:@"* %@\r\n", key];
                                                  }
                                                  [strContent appendString:@"\r\nPlease take a new photo."];
                                                  
                                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo errors" message:strContent delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                  [alertView show];
                                              }
                                              
                                          });
                       }
                   });
    
}

//---------------------------------------------------------------------------------------------
// Brightness slider
//---------------------------------------------------------------------------------------------

- (void) onSliderBrightness:(UISlider *)sender
{
    buttonAccept.enabled = NO;
    buttonReject.enabled = NO;

    spinnerPreview.color = [UIColor blackColor];
    [spinnerPreview startAnimating];
    
    dispatch_async(imageProcessingQueue, ^
                   {
                       // Convert to Black/White
                       self.imageBW = [mVIP onProcessImageBWDrawImage:dictResults brightness:sender.value];
                           
                       // main thread update UI
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [spinnerPreview stopAnimating];
                                              
                                          buttonAccept.enabled = YES;
                                          buttonReject.enabled = YES;

                                          imageViewPreview.image = imageBW;
                                      });
                   });
}

//------------------------------------------------------------------------------------------
// Close button handler
//------------------------------------------------------------------------------------------

- (void) onCameraClose:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    mVIP = nil;
//    if (imageProcessingQueue != nil)        // queue for ImageProcessing
//        dispatch_release(imageProcessingQueue);
//    imageProcessingQueue = nil;
    
    if (delegate != nil)
    {
        [self teardownAVCapture];
        [delegate onCameraClose];
    }
}

//------------------------------------------------------------------------------------------
// Flash Button
//------------------------------------------------------------------------------------------

- (void) onFlashButton:(UIBarButtonItem *)sender
{
    NSError *error = nil;

    if (![device hasFlash])
        return;

    // device configuration
    [device lockForConfiguration:&error];
    
    switch (sender.tag)
    {
        case kVIP_FLASH_OFF:
            [device setFlashMode:AVCaptureFlashModeAuto];
            [sender setImage:[UIImage imageNamed:@"flash_automatic"]];
            sender.tag = kVIP_FLASH_AUTOMATIC;
            break;
        case kVIP_FLASH_AUTOMATIC:
            [device setFlashMode:AVCaptureFlashModeOn];
            [sender setImage:[UIImage imageNamed:@"flash_on"]];
            sender.tag = kVIP_FLASH_ON;
            break;
        case kVIP_FLASH_ON:
            [device setFlashMode:AVCaptureFlashModeOff];
            [sender setImage:[UIImage imageNamed:@"flash_off"]];
            sender.tag = kVIP_FLASH_OFF;
            break;
            
    }
    
    [device unlockForConfiguration];
}

//------------------------------------------------------------------------------------------
// Photo Preview Accept
//------------------------------------------------------------------------------------------

- (IBAction)onPhotoAccept:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    mVIP = nil;
//    if (imageProcessingQueue != nil)        // queue for ImageProcessing
//        dispatch_release(imageProcessingQueue);
//    imageProcessingQueue = nil;
    
    if (delegate != nil)
    {
        [self teardownAVCapture];
        [delegate onPictureTaken:imageColor withBWImage:imageBW results:dictResults isFront:self.isFront];
    }
}

//------------------------------------------------------------------------------------------
// Photo Preview Reject
//------------------------------------------------------------------------------------------

- (IBAction)onPhotoReject:(id)sender
{
    [self setupToolbarForPhoto];
}

//------------------------------------------------------------------------------------------
// Take Picture button handler
//------------------------------------------------------------------------------------------

- (void) onTakePicture:(UITapGestureRecognizer *)sender
{
    // don't take picture during focus/exposure/white-balance adjustments
    if ( (device.isAdjustingFocus) || (device.isAdjustingExposure) || (device.isAdjustingWhiteBalance) || (isCapturingStillImage))
        return;
    
    // Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	
    // Jpeg output
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG	forKey:AVVideoCodecKey]];
	
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {

         if (error)
         {
             [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
         }
         else
         {
             // send picture back to delegate on main thread
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                // animate the scrollview into view
                                scrollViewPreview.alpha = 0.0f;
                                scrollViewPreview.hidden = NO;
                                spinnerPreview.color = [UIColor lightTextColor];
                                [spinnerPreview startAnimating];
                                spinnerPreview.alpha = 0.0f;
                                
                                // label
                                if (labelProcessing == nil)
                                {
                                    // above the spinner
                                    self.labelProcessing = [[UILabel alloc] initWithFrame:CGRectMake(0,scrollViewPreview.center.y - 15 - 54,scrollViewPreview.frame.size.width,44)];
                                    labelProcessing.autoresizingMask = UIViewAutoresizingNone;
                                    [labelProcessing setBackgroundColor:[UIColor clearColor]];
                                    [labelProcessing setShadowOffset:CGSizeMake(1,-1)];
                                    [labelProcessing setShadowColor:[UIColor blackColor]];
                                    [labelProcessing setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
                                    [labelProcessing setTextColor:[UIColor lightTextColor]];
                                    labelProcessing.numberOfLines = 1;
                                    labelProcessing.textAlignment = NSTextAlignmentCenter;
                                    [labelProcessing setText:@"Processing photo..."];
                                }
                                [self.view addSubview:labelProcessing];
                                labelProcessing.alpha = 0.0f;
                                
                                [UIView animateWithDuration:0.4f animations:^
                                 {
                                     previewView.alpha = 0.0f;
                                     scrollViewPreview.alpha = 1.0f;
                                     labelProcessing.alpha = 1.0f;
                                     spinnerPreview.alpha = 1.0f;
                                 } completion:^(BOOL finished)
                                 {
                                 }];
                                
                            });

             
             [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
             
             // JPEG
             UIImage *imageJPG = [UIImage imageWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]];
             
             // landscape left will take an upside-down picture!
             if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)
                 imageJPG = [self onRotateImage180:imageJPG];
             
             // VIP Library - bind image for cropping
             [mVIP onProcessImageCropBindImage:imageJPG];
             imageJPG = nil;

             // send picture back to delegate on main thread
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self setupToolbarForPreview];                        // switch to photo preview!
                            });
             
         }
    }];
    
}

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// AV Capture setup
//------------------------------------------------------------------------------------------

- (void)setupAVCapture
{
	NSError *error = nil;
	
    Global *pGl= [Global globalinstance];                           // initialize global

	self.session = [[AVCaptureSession alloc] init];
	[session setSessionPreset:AVCaptureSessionPresetPhoto];

    // Select a video device, make an input
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
	if (error != nil)
        return;
    
    // enumerate supported device video formats, look for size >= 2Mpx @ 420f, but no necessarily highest res photo supported by device.  Saves memory!
//    AVCaptureDeviceFormat *preferredFormat = nil;
//    for (AVCaptureDeviceFormat *deviceFormat in [device formats])
//    {
//        CMFormatDescriptionRef fd = deviceFormat.formatDescription;
//
//#ifdef _DEBUG
//        NSLog(@"%@",fd);
//#endif
//        
//        CMMediaType mediaType = CMFormatDescriptionGetMediaType(fd);
//        if (mediaType == kCMMediaType_Video)
//        {
//            CMVideoCodecType mediaSubtype = CMFormatDescriptionGetMediaSubType(fd);
//            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(fd);
//
//            // converts 4-byte to string
//            //            mediaSubtype = OSSwapHostToBigInt32( mediaSubtype );
//            //            NSString *typeString = [NSString stringWithFormat:@"%.4s", (char*)&mediaSubtype];
//            //            NSLog(@"%@",typeString);
//            
//            // 420f == 0x34323066, >= 2Mpx 4:3 aspect ratio
//            if ( (mediaSubtype == 0x34323066) &&                                                        // 420f
//                (dimensions.width > 1600) &&                                                            // > 1600px wide
//                ( (((float)dimensions.width / (float)dimensions.height) == (4.0f/3.0f)) ||              // 4:3 aspect ratio
//                  (((float)dimensions.width / (float)dimensions.height) == (2592.0f/1936.0f))) )        // OR strange 5Mpx ratio which is not exactly 4:3
//            {
//                preferredFormat = deviceFormat;                                                         // got it, look no further
//                break;
//            }
//        }
//        
//    }
//    
//    if (preferredFormat == nil)
//        [session setSessionPreset:AVCaptureSessionPresetPhoto];
//    else
//        [session setSessionPreset:AVCaptureSessionPresetInputPriority];

    // device configuration
    [device lockForConfiguration:&error];
    
//    if (preferredFormat != nil)                                                                         // set preferred format selected above
//        [device setActiveFormat:preferredFormat];
    
    // disable flash!
    if ([device hasFlash])
        [device setFlashMode:AVCaptureFlashModeOff];
    
    // auto-focus range = NEAR
    //    if ([device isAutoFocusRangeRestrictionSupported])
    //        [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
    
    // focus/exposure point of interest
    if ([device isFocusPointOfInterestSupported])
        [device setFocusPointOfInterest:CGPointMake(0.5,0.5)];                                          // center of check
    if ([device isExposurePointOfInterestSupported])
        [device setExposurePointOfInterest:CGPointMake(0.5,0.5)];                                       // center of check
    
    // focus/exposure/white balance modes
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    
    // low light boost
    if ([device respondsToSelector:@selector(isLowLightBoostSupported)])
    {
        if ([device isLowLightBoostSupported])
            [device setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
    }
    
    [device unlockForConfiguration];

    // add device to session
	if ([session canAddInput:deviceInput])
		[session addInput:deviceInput];
    
    // focus/exposure/white-balance adjust KVO
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    [device addObserver:self forKeyPath:@"adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    
    // Still image output
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	[stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureStillImageIsCapturing)];
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
    
    // Video data output
	self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
	
    // BGRA preview frames!
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];     // discard frames if the data output queue is blocked
    
    // create a serial dispatch queue used for the sample buffer delegate
	videoDataOutputQueue = dispatch_queue_create("com.Vertifi.Queue.VideoDataOutput", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
    
    // Video preview frame
    
    CGRect previewFrame = previewView.frame;                        // initial preview frame
    CGRect rectScreen = [[UIScreen mainScreen] bounds];             // get screen bounds
    
    // full width, in 4:3 aspect ratio, centered
    CGFloat windowWidth = fmaxf(rectScreen.size.width,rectScreen.size.height);
    CGFloat windowHeight = fminf(rectScreen.size.width,rectScreen.size.height);
    previewFrame.size.width = windowWidth;
    previewFrame.size.height = windowWidth * 0.75f;
    [previewView setFrame:previewFrame];
    [previewView setCenter:CGPointMake(windowWidth/2,windowHeight/2)];

    // Viewport
    CGRect rectViewport = CGRectMake (0.005, 0.16, 0.99, 0.65);
    
    rectViewport.origin.x = 0.005f;                                 // full frame width
    rectViewport.size.width = 0.99f;                                // .
    
    CGFloat w = previewFrame.size.width * rectViewport.size.width;  // frame width * viewport width
    CGFloat h = w / ((windowWidth / windowHeight > 1.5) ? VIP_VIEWPORT_ASPECT_WIDE : VIP_VIEWPORT_ASPECT_NORMAL);   // aspect ratio height
    CGFloat hSpan = h / previewFrame.size.height;                   // % span of frame height
    
    rectViewport.origin.y = 0.5f - (hSpan / 2.0f);
    rectViewport.size.height = hSpan;
  
    pGl.rectViewPort = rectViewport;                                // set viewport
 
    // preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            [previewLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI / 2)];
            break;
        default:
            [previewLayer setAffineTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
            break;
    }

	[previewView.layer setMasksToBounds:YES];
	[previewLayer setFrame:[previewView.layer bounds]];
	[previewView.layer addSublayer:previewLayer];
    
    // taps
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTakePicture:)];
    [previewView addGestureRecognizer:tapRecognizer];
    
    [session startRunning];
    
    if (error)
    {
        [self displayErrorOnMainQueue:error withMessage:@"Error Initializing Camera"];
    }
    
}

//------------------------------------------------------------------------------------------
// clean up capture setup
//------------------------------------------------------------------------------------------

- (void)teardownAVCapture
{
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
	[device removeObserver:self forKeyPath:@"adjustingExposure"];
	[device removeObserver:self forKeyPath:@"adjustingWhiteBalance"];
	[stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    
//    if (videoDataOutputQueue)
//		dispatch_release(videoDataOutputQueue);
    
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    [videoDataOutput setSampleBufferDelegate:nil queue:nil];
    [session stopRunning];
    
    [previewLayer removeFromSuperlayer];
}

//------------------------------------------------------------------------------------------
// capturingStillImage KVO
//------------------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // device adjust is for focus, exposure, white balance changes
	if (context == (__bridge void *)kAVCaptureDeviceAdjust)
    {
    }
    
    // still image capturing is for picture taking
	else if (context == (__bridge void *)kAVCaptureStillImageIsCapturing)
    {
		self.isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
	}
}


//------------------------------------------------------------------------------------------
// Display Error AlertView on main thread
//------------------------------------------------------------------------------------------

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
                                                                           message:[error localizedDescription]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
                       [alertView show];
                   });
}

//------------------------------------------------------------------------------------------
// Image Rotation
//------------------------------------------------------------------------------------------

- (UIImage *) onRotateImage180:(UIImage *)image
{
	CGImageRef imageRef = image.CGImage;
	
	NSUInteger nWidth = CGImageGetWidth(imageRef);
	NSUInteger nHeight = CGImageGetHeight(imageRef);
	
    UIGraphicsBeginImageContext(CGSizeMake(nWidth,nHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM (context, nWidth, 0);
 	CGContextRotateCTM (context, M_PI);
    CGContextScaleCTM (context, 1.0, -1.0);
    CGContextDrawImage (context, CGRectMake(0, 0, nWidth, nHeight), imageRef);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return (newImage);
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

//------------------------------------------------------------------------------------------
// VideoDataOutput sample buffer
//------------------------------------------------------------------------------------------

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    __block __weak CameraViewController *weakSelf = self;
    
    if ( (weakSelf.device.isAdjustingFocus) || (weakSelf.device.isAdjustingExposure) || (weakSelf.device.isAdjustingWhiteBalance) || (weakSelf.isCapturingStillImage))
        return;

    // crop view doesn't exist?
    if (weakSelf.cropView == nil)
        return;

	// got an image
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *rawPixels = CVPixelBufferGetBaseAddress(imageBuffer);
    int stride = (int)CVPixelBufferGetBytesPerRow(imageBuffer);
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);

    if ((width > 0) && (height > 0))
    {
        Global *pGl= [Global globalinstance];                           // initialize global
        CGRect rectViewport = pGl.rectViewPort;                         // get the viewport

        __block CGPoint pointTL;
        __block CGPoint pointTR;
        __block CGPoint pointBL;
        __block CGPoint pointBR;

        // find the corners
        [mVIP onProcessImageGetCropCorners:rawPixels viewport:&rectViewport BPP:4 width:width height:height stride:stride toPointTL:&pointTL toPointTR:&pointTR toPointBL:&pointBL toPointBR:&pointBR];
        
        // landscape left will take an upside-down picture!
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)
        {
            // rotate 180 degrees
            [self rotateCorners180:&pointTL tr:&pointTR bl:&pointBL br:&pointBR width:width height:height];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            // convert corner points into percentages
            weakSelf.cropView->pointTL.x = pointTL.x / width;
            weakSelf.cropView->pointTL.y = pointTL.y / height;
            weakSelf.cropView->pointTR.x = pointTR.x / width;
            weakSelf.cropView->pointTR.y = pointTR.y / height;
            weakSelf.cropView->pointBL.x = pointBL.x / width;
            weakSelf.cropView->pointBL.y = pointBL.y / height;
            weakSelf.cropView->pointBR.x = pointBR.x / width;
            weakSelf.cropView->pointBR.y = pointBR.y / height;

            [weakSelf.cropView setNeedsDisplay];                        // display the cropView
        });
        
    }

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

}

//---------------------------------------------------------------------------------------------
// Rotate corners around center
//---------------------------------------------------------------------------------------------

- (void) rotateCorners180:(CGPoint *)tl tr:(CGPoint *)tr bl:(CGPoint *)bl br:(CGPoint *)br width:(int)width height:(int)height
{
    // rotate corners around center
    
    // translate
    tl->x = width - tl->x;
    tl->y = height - tl->y;
    tr->x = width - tr->x;
    tr->y = height - tr->y;
    bl->x = width - bl->x;
    bl->y = height - bl->y;
    br->x = width - br->x;
    br->y = height - br->y;

    // swap TL/BR corners
    CGPoint pTemp = CGPointMake(tl->x,tl->y);
    tl->x = br->x;
    tl->y = br->y;
    br->x = pTemp.x;
    br->y = pTemp.y;

    // swap TR/BL corners
    pTemp = CGPointMake(tr->x,tr->y);
    tr->x = bl->x;
    tr->y = bl->y;
    bl->x = pTemp.x;
    bl->y = pTemp.y;

    return;
}


#pragma mark UIScrollViewDelegate

//---------------------------------------------------------------------------------------------
// Scroll View Delegate Methods
//---------------------------------------------------------------------------------------------

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return (imageViewPreview);
}

#pragma mark UIAlertViewDelegate methods

//-----------------------------------------------------------------------------
// Action Sheet Delegate
//-----------------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)					// OK
	{
        [self setupToolbarForPhoto];        // back to photo capture
	}
}

@end
