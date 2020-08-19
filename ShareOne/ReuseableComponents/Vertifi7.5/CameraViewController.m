//
//  Controller.m
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

#import <VIPLibrary/VIPLibrary.h>

#import "DepositModel.h"
#import "CameraViewController.h"

@interface CameraViewController ()

@end

// used for KVO observation of the @"adjusting*" properties
static const NSString *kAVCaptureDeviceAdjust = @"AVCaptureDeviceAdjust";
static NSString *kAVCaptureAdjustingFocus = @"adjustingFocus";
static NSString *kAVCaptureAdjustingExposure = @"adjustingExposure";
static NSString *kAVCaptureAdjustingWhiteBalance = @"adjustingWhiteBalance";

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

@synthesize tapRecognizer;

@synthesize letterboxView;
@synthesize overlayView;
@synthesize switchMode;
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
@synthesize arrayResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<CameraViewControllerDelegate>)cvdelegate title:(NSString *)title isFront:(BOOL)front
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        schema = [UISchema sharedInstance];
        self.delegate = cvdelegate;
        self.titleString = title;
        self.isFront = front;

        self.arrayResults = [[NSMutableArray alloc] init];
    }
    return (self);
}

//------------------------------------------------------------------------------------------
// viewDidLoad
//------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    depositModel = [DepositModel sharedInstance];

    // -------------------------------------------------------------------------------------
    // Picture
    // -------------------------------------------------------------------------------------
    
    // initialize AV Foundation
    [self setupAVCapture];
    
    [self.view setBackgroundColor:schema.colorNavigation];
    previewView.backgroundColor = schema.colorWhite;

    // camera letterbox overlay - the alignment rectangle
	self.letterboxView = [[CameraLetterboxView alloc] initWithFrame:CGRectMake(0,0,previewView.bounds.size.width,previewView.bounds.size.height) sender:self];
    [previewView addSubview:letterboxView];
    
    // camera overlay view - the edge detectors
    self.overlayView = [[CameraOverlayView alloc] initWithFrame:CGRectMake(0,0,previewView.bounds.size.width,previewView.bounds.size.height) sender:self];
    overlayView.alpha = 0;
    [previewView addSubview:overlayView];

    // -------------------------------------------------------------------------------------
    // Preview view
    // -------------------------------------------------------------------------------------
    
    scrollViewPreview.backgroundColor = schema.colorBlack;
    
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
    spinnerPreview.color = schema.colorLightText;
    [self.view addSubview:spinnerPreview];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTakePicture:)];
    [self setupToolbarForPhoto];

    // VIP library queue initialization
    imageProcessingQueue = dispatch_queue_create("com.Vertifi.Queue.ImageProcessing", DISPATCH_QUEUE_SERIAL);
    
    // VIP library initialization
    dispatch_async(imageProcessingQueue, ^
    {
        self.mVIP = [[VertifiImageProcessing alloc] initWithSide:self.isFront];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadCameraInstruction:nil];
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
// status bar
//------------------------------------------------------------------------------------------

- (BOOL) prefersStatusBarHidden
{
    return (YES);
}

//------------------------------------------------------------------------------------------
// interface orientation - landscape only!
//------------------------------------------------------------------------------------------

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscape);
}

//------------------------------------------------------------------------------------------
// device rotations - rotate preview layer
//------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// viewWillTransitionToSize
//-----------------------------------------------------------------------------

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (orientation)
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
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    return;
}

//- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [UIView animateWithDuration:duration animations:^
//    {
//        switch (toInterfaceOrientation)
//        {
//            case UIInterfaceOrientationLandscapeLeft:
//                [previewLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI / 2)];
//                break;
//            case UIInterfaceOrientationLandscapeRight:
//                [previewLayer setAffineTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
//                break;
//            default:
//                break;
//        }
//    } completion:^(BOOL finished)
//    {
//    }];
//}

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
         letterboxView.alpha = 1.0f;                            // show camera overlay
         scrollViewPreview.alpha = 0.0f;                        // hide the scroller
     } completion:^(BOOL finished)
     {
         scrollViewPreview.hidden = YES;
         
         [UIView animateWithDuration:0.4f delay:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^
          {
              overlayView.alpha = 1.0f;                         // show crop corners after delay
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
    
    // Help button (CameraInstructionViewController)
    if (buttonHelp == nil)
    {
        self.buttonHelp = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(loadCameraInstruction:)];
    }

    // title label
    if (buttonTitleLabel == nil)
    {
        UILabel *labelTitle = [[UILabel alloc] init];
        [labelTitle setFont:schema.fontHeadline];
        [labelTitle setTextColor:schema.colorLightText];
        [labelTitle setText:self.titleString];
        [labelTitle sizeToFit];
        buttonTitleLabel = [[UIBarButtonItem alloc] initWithCustomView:labelTitle];
        
        // mode
        self.switchMode = [[UISegmentedControl alloc] initWithItems:@[ @"Auto", @"Manual"]];
        [self.switchMode setFrame:CGRectMake(0,0,switchMode.frame.size.width, 32)];       // slightly increase frame height of segment switch
        
        NSInteger nPreference = kVIP_MODE_MANUAL;

        // get preference
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        NSNumber *oPreference = [defaults objectForKey:kVIP_PREFERENCE_CAMERA_MODE];
        if (oPreference != nil)
            nPreference = [oPreference integerValue];
        [switchMode setSelectedSegmentIndex:nPreference];
        [overlayView setMode:nPreference];
        [switchMode addTarget:self action:@selector(onCameraModeChange:) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *switchModeButton = [[UIBarButtonItem alloc] initWithCustomView:switchMode];
        
        // flash
        self.buttonFlash =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flash_off"] style:UIBarButtonItemStylePlain target:self action:@selector(onFlashButton:)];
        buttonFlash.tag = kVIP_FLASH_OFF;

        [toolbarTop setItems:[NSMutableArray arrayWithObjects:fixBarButtonItem,buttonTitleLabel,flexBarButtonItem,switchModeButton, fixBarButtonItemWide, buttonFlash,fixBarButtonItem,nil] animated:YES];
    }
    
    // help label
    if (buttonHelpLabel == nil)
    {
        UILabel *labelInstruction = [[UILabel alloc] init];
        [labelInstruction setFont:schema.fontFootnote];
        [labelInstruction setTextColor:schema.colorLightText];
        [labelInstruction setAdjustsFontSizeToFitWidth:YES];                    // allow font to shrink if needed
        [labelInstruction setMinimumScaleFactor:0.8];                           // ...
        [labelInstruction setText:[[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_TIP_CAMERA" value:@"Place check on dark surface, align to fit within viewfinder" table:@"VIPSample"]];
        [labelInstruction sizeToFit];

        // v7.5; ensure it fits and doesn't overrun buttons on right via a constraint
        CGSize screen = [UIScreen mainScreen].bounds.size;
        CGFloat maxWidth = MAX(screen.width,screen.height) * 0.666f;            // maximum width = 2/3 [landscape] screen width
        [labelInstruction addConstraint:[labelInstruction.widthAnchor constraintLessThanOrEqualToConstant:maxWidth]];
        
        buttonHelpLabel = [[UIBarButtonItem alloc] initWithCustomView:labelInstruction];
    }
    
    // close button
    if (buttonClose == nil)
        self.buttonClose = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(onCameraClose:)];
    
    // set the toolbar buttons
    if (itemsToolbarPhoto == nil)
        itemsToolbarPhoto = [NSMutableArray arrayWithObjects:fixBarButtonItem,buttonHelpLabel,flexBarButtonItem,buttonHelp,fixBarButtonItem,buttonClose,fixBarButtonItem,nil];
    [toolbarBottom setItems:itemsToolbarPhoto animated:(BOOL)YES];

    // reset camera mode
    [self onCameraModeChange:self.switchMode];
    
    // enable video output and start session
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    
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
        sliderBrightness.minimumValueImage = [[UIImage imageNamed:@"darkness"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        sliderBrightness.maximumValueImage = [[UIImage imageNamed:@"brightness"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
    self.itemsToolbarPreview = [NSMutableArray arrayWithObjects:fixBarButtonItem,flexBarButtonItem, buttonReject, fixBarButtonItemWide, buttonAccept, fixBarButtonItem,nil];
    
    [toolbarBottom setItems:itemsToolbarPreview animated:(BOOL)YES];

    //-------------------------------------------------------------------------------------------
    // Image Processing - color cropping
    //-------------------------------------------------------------------------------------------
    dispatch_async(imageProcessingQueue, ^
    {
        @autoreleasepool
        {
            [arrayResults removeAllObjects];
            
            CGRect rectFront;
            CGRect *rectReference = NULL;
            CGRect rectViewport = depositModel.rectViewPort;
            
            if (!isFront)
            {
                rectFront = CGRectMake (0, 0, depositModel.rectFront.size.width, depositModel.rectFront.size.height);
                rectReference = &rectFront;
            }
            
            // Create cropped/scaled color image
            self.imageColor = [mVIP onProcessImageCrop:arrayResults crop:rectReference viewport:&rectViewport];
            
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
            if (arrayResults.count == 0)                                                  // no errors?
            {
                [mVIP onProcessImageBWBindImage:imageColor];
                
                // Convert to Black/White in auto-brightness mode
                self.imageBW = [mVIP onProcessImageBWDrawImageAuto:arrayResults];
                if (isFront)
                {
                    depositModel.isSmartScaled = mVIP.isSmartScaled;                       // set smart scaling flag on front image
                }
                
                if ([arrayResults containsObject:@"UpsideDown"])
                {
#ifdef DEBUG
                    NSLog(@"%@ rotate upside-down Color image", self.class);
#endif
                    // rotate the image
                    [arrayResults removeObject:@"UpsideDown"];
                    self.imageColor = [mVIP onRotateImage180:imageColor];
                }
                
                __block UIImage *imageEndorsementThumb = nil;
                
                // No errors on B/W image conversion?
                if (arrayResults.count == 0)
                {
                    // rear endorsement testing
                    if (!isFront)
                        depositModel.iuRearEndorsement = IURearEndorsementPassed; // must've passed presence test if no errors
                    
                    if ((!isFront) && (depositModel.visionApiKey != nil) && (depositModel.visionApiKey.length > 0))
                    {
                        imageEndorsementThumb = [self testRearEndorsement];
                    }
                }
                
                // main thread update UI
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    sliderBrightness.value = [mVIP brightness];             // set proper initial brightness
                    
                    // set B/W image into ImageView using cross dissolve
                    [UIView transitionWithView:imageViewPreview duration:0.8f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                        
                        // this code will show the annotated thumb for rear image in Debug mode, else the full B&W image
                        // A production app should only show the imageBW
                        if (depositModel.debugMode)
                            imageViewPreview.image = imageEndorsementThumb != nil ? imageEndorsementThumb : imageBW;
                        else
                            imageViewPreview.image = imageBW;               // show B&W image
                        
                    } completion:^(BOOL finished)
                    {
                    }];
                });
            }
            
            // main thread update UI
            dispatch_async(dispatch_get_main_queue(), ^
            {
                buttonReject.enabled = YES;                                       // enable Reject button
                
                // No errors???  Insert slider and enable the Accept button
                if (arrayResults.count == 0)
                {
                    // insert UISlider into toolbar
                    [self.itemsToolbarPreview insertObject:buttonSlider atIndex:0];
                    [toolbarBottom setItems:itemsToolbarPreview animated:(BOOL)YES];
                    
                    buttonAccept.enabled = YES;
                    
                    if (switchMode.selectedSegmentIndex == kVIP_MODE_AUTOMATIC)
                    {
                        [self onPhotoAccept:buttonAccept];
                    }
                }
                else
                {
                    // show an Alert if errors
                    BOOL bNoRetry = NO;
                    NSMutableString *strContent = [[NSMutableString alloc] initWithString:@""];
                    for (NSString *key in arrayResults)
                    {
                        if ([key isEqualToString:@"OutOfScale"])              // don't allow retry on OutOfScale error
                            bNoRetry = YES;
                        
                        [strContent appendFormat:@"* %@\r\n", isFront ? [depositModel.dictMasterFrontImage helpForKey:key] : [depositModel.dictMasterBackImage helpForKey:key]];
                    }
                    if (!bNoRetry)
                        [strContent appendString:@"\r\nPlease take a new photo."];
                    
                    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Photo Errors" message:strContent preferredStyle:UIAlertControllerStyleAlert];
                    [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        if (bNoRetry)
                            [self onCameraClose:self.buttonClose];
                        else
                            [self setupToolbarForPhoto];
                        
                    }]];
                    [self presentViewController:sheet animated:YES completion:nil];
                }
                
                // fade out and remove the Processing... label
                [UIView animateWithDuration:0.4f animations:^
                {
                    [spinnerPreview stopAnimating];
                    labelProcessing.alpha = 0.0f;                            // fade out Processing label
                } completion:^(BOOL finished)
                {
                    [labelProcessing removeFromSuperview];                   // remove label from superview
                }];
                
            });
        }
    });
    
}

//---------------------------------------------------------------------------------------------
// Rear endorsement testing
//
// should be called from imageProcessingQueue thread!
//---------------------------------------------------------------------------------------------

- (UIImage *) testRearEndorsement
{
    // rear endorsement test
    UIImage *imageEndorsementThumb = [mVIP onProcessImageEndorsementTest:imageColor
                                                                  values:depositModel.endorsements
                                                               threshold:depositModel.endorsementThreshold
                                                                  apiUrl:depositModel.visionApiURL
                                                                  apiKey:depositModel.visionApiKey];
    
    // set IU results into model
    depositModel.iuRearEndorsement = mVIP.iuRearEndorsement;
    
    return (imageEndorsementThumb);
}

//---------------------------------------------------------------------------------------------
// Brightness slider
//---------------------------------------------------------------------------------------------

- (void) onSliderBrightness:(UISlider *)sender
{
    buttonAccept.enabled = NO;
    buttonReject.enabled = NO;

    [spinnerPreview startAnimating];
    
    __block double brightness = sender.value;       // get slider value on UI thread!
    __block __weak CameraViewController *weakSelf = self;
    
    dispatch_async(imageProcessingQueue, ^
    {
        [arrayResults removeAllObjects];

        // Convert to Black/White
        weakSelf.imageBW = [mVIP onProcessImageBWDrawImage:arrayResults brightness:brightness];
        
        // main thread update UI
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [weakSelf.spinnerPreview stopAnimating];
            
            // don't enable Accept button if errors returned from library!
            weakSelf.buttonAccept.enabled = (arrayResults.count > 0) ? NO : YES;
            weakSelf.buttonReject.enabled = YES;
            
            weakSelf.imageViewPreview.image = weakSelf.imageBW;
        });
    });
}

//------------------------------------------------------------------------------------------
// Close button handler
//------------------------------------------------------------------------------------------

- (void) onCameraClose:(id)sender
{
    mVIP = nil;
    if (delegate != nil)
    {
        [self teardownAVCapture];
        [delegate onCameraClose];
    }
}

//------------------------------------------------------------------------------------------
// Camera Mode Switch
//------------------------------------------------------------------------------------------

- (void) onCameraModeChange:(UISegmentedControl *)sender
{
    // set preference
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setInteger:sender.selectedSegmentIndex forKey:kVIP_PREFERENCE_CAMERA_MODE];
    [defaults synchronize];
    
    switch (sender.selectedSegmentIndex)
    {
        case kVIP_MODE_AUTOMATIC:
            [previewView removeGestureRecognizer:tapRecognizer];
            break;
        case kVIP_MODE_MANUAL:
        {
            // tap gesture; v7.5, only add gestureRecognizer if not already added
            if (![[previewView gestureRecognizers] containsObject:tapRecognizer])
                [previewView addGestureRecognizer:tapRecognizer];
            break;
        }
    }
    
    // adjust overlay
    [overlayView setMode:sender.selectedSegmentIndex];
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
    mVIP = nil;
    
    if (delegate != nil)
    {
        [self teardownAVCapture];
        [delegate onPictureTaken:imageColor withBWImage:imageBW results:arrayResults isFront:self.isFront];
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
    // already taking picture?
    if (self.isCapturingStillImage)
        return;
    
    // v7.5; don't take picture during focus/exposure/white-balance adjustments
    if ( (device.isAdjustingFocus) || (device.isAdjustingExposure) || (device.isAdjustingWhiteBalance))
    {
        // but do set focus/exposure point of interest
        CGPoint touchPoint = [sender locationInView:self.previewView];
        [self showFocusRectAt:touchPoint];
        return;
    }
    
    self.isCapturingStillImage = YES;       // mutex type flag to ensure only single photo at a time
    
    // v7.5; remove tap gestureRecognizer if enabled
    if ([[previewView gestureRecognizers] containsObject:tapRecognizer])
        [previewView removeGestureRecognizer:tapRecognizer];
    
    // Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	
    // Jpeg output
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG	forKey:AVVideoCodecKey]];
	
    __block UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // v7.5; simulated flash in Auto mode (i.e. sender == nil)
    if (sender == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            __block UIView *flashView = [[UIView alloc] initWithFrame:self.view.frame];
            [flashView setBackgroundColor:schema.colorWhite];
            [self.view addSubview:flashView];
            [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                flashView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [flashView removeFromSuperview];
            }];
        });
    }

    // v7.5; re-arrange the block/queue handling for optimal efficiency
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {

        // we're on the UI thread here...
        if (error)
        {
            [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
        }
        else
        {
            [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
             
            // UI update, animate the scrollview into view, start a spinner and Processing label
            scrollViewPreview.alpha = 0.0f;
            scrollViewPreview.hidden = NO;
            [spinnerPreview startAnimating];
            spinnerPreview.alpha = 0.0f;
             
            // label
            if (labelProcessing == nil)
            {
                // above the spinner
                self.labelProcessing = [[UILabel alloc] initWithFrame:CGRectMake(0,scrollViewPreview.center.y - 15 - 54,scrollViewPreview.frame.size.width,44)];
                labelProcessing.autoresizingMask = UIViewAutoresizingNone;
                [labelProcessing setBackgroundColor:schema.colorToastBackground];
                [labelProcessing setShadowOffset:CGSizeMake(1,-1)];
                [labelProcessing setShadowColor:schema.colorBlack];
                [labelProcessing setFont:schema.fontHeadline];
                [labelProcessing setTextColor:schema.colorToastText];
                labelProcessing.numberOfLines = 1;
                labelProcessing.textAlignment = NSTextAlignmentCenter;
                [labelProcessing setText:@"Processing photo..."];
                CGSize r = [labelProcessing sizeThatFits:CGSizeMake(999,999)];
                [labelProcessing setFrame:CGRectMake(0,0,r.width + 16,r.height + 16)];
                [labelProcessing setCenter:CGPointMake(scrollViewPreview.center.x, scrollViewPreview.center.y - 54)];
                labelProcessing.layer.cornerRadius = 8;
                labelProcessing.layer.masksToBounds = YES;
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

            // create JPEG
            __block UIImage *imageJPG = [UIImage imageWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]];
            
            // dispatch to image processing queue
            dispatch_async(imageProcessingQueue, ^{
            
                // landscape left will take an upside-down picture! Rotate the image...
                if (statusBarOrientation == UIInterfaceOrientationLandscapeLeft)
                    imageJPG = [mVIP onRotateImage180:imageJPG];

                // VIP Library - bind image for cropping
                [mVIP onProcessImageCropBindImage:imageJPG];
                imageJPG = nil;
                 
                // setupToolbarForPreview will finish the job and update the UI, run on UI thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupToolbarForPreview];             // switch to photo preview!
                    self.isCapturingStillImage = NO;           // v7.5; clear this flag back on UI thread
                });
                 
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
	
	self.session = [[AVCaptureSession alloc] init];
	[session setSessionPreset:AVCaptureSessionPresetPhoto];

    // Select a video device, make an input
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error)
    {
        [self displayErrorOnMainQueue:error withMessage:@"Error Initializing Camera"];
        return;
    }
    
    // device configuration
    [device lockForConfiguration:&error];
    
    // disable flash!
    if ([device hasFlash])
        [device setFlashMode:AVCaptureFlashModeOff];
    
    // auto-focus range = NEAR; enabled for v7.5 (iPhone X seems to struggle sometimes with near field focus)
//    if ([device isAutoFocusRangeRestrictionSupported])
//        [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
    
    // iniital focus/exposure point of interest
    if ([device isFocusPointOfInterestSupported])
        [device setFocusPointOfInterest:CGPointMake(0.75,0.5)];                 // right/center of check
    if ([device isExposurePointOfInterestSupported])
        [device setExposurePointOfInterest:CGPointMake(0.5,0.5)];               // center of check
    
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
    [device addObserver:self forKeyPath:kAVCaptureAdjustingFocus options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    [device addObserver:self forKeyPath:kAVCaptureAdjustingExposure options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    [device addObserver:self forKeyPath:kAVCaptureAdjustingWhiteBalance options:NSKeyValueObservingOptionNew context:(__bridge void *)(kAVCaptureDeviceAdjust)];
    
    // Still image output
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
    
    // Video data output
	self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
	
    // BGRA preview frames!
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];         // discard frames if the data output queue is blocked

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
    //[previewView setCenter:CGPointMake(windowWidth/2,windowHeight/2)];

    // Viewport
    CGRect rectViewport = CGRectMake (0.005, 0.16, 0.99, 0.65);
    
    rectViewport.origin.x = 0.005f;                                 // full frame width
    rectViewport.size.width = 0.99f;                                // .
    
    CGFloat w = previewFrame.size.width * rectViewport.size.width;  // frame width * viewport width
    CGFloat h = w / ((windowWidth / windowHeight > 1.5) ? VIP_VIEWPORT_ASPECT_WIDE : VIP_VIEWPORT_ASPECT_NORMAL);   // aspect ratio height
    CGFloat hSpan = h / previewFrame.size.height;                   // % span of frame height
    
    rectViewport.origin.y = 0.5f - (hSpan / 2.0f);
    rectViewport.size.height = hSpan;
  
    depositModel.rectViewPort = rectViewport;                       // set viewport
 
    // preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[schema.colorBlack CGColor]];
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
    [device removeObserver:self forKeyPath:kAVCaptureAdjustingFocus];
	[device removeObserver:self forKeyPath:kAVCaptureAdjustingExposure];
	[device removeObserver:self forKeyPath:kAVCaptureAdjustingWhiteBalance];
    
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
        // v7.5, reset auto mode counters if adjusting focus, exposure, or white balance
        if ((device.isAdjustingFocus) || (device.isAdjustingExposure) || (device.isAdjustingWhiteBalance))
        {
            [self.overlayView reset];              // reset the counters on the overlay
        }
    }
}

//------------------------------------------------------------------------------------------
// Display Error AlertView on main thread
//
// utility routine to display error aleart if takePicture fails
//
//------------------------------------------------------------------------------------------

- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]] message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:sheet animated:YES completion:nil];
    });
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
    if (weakSelf.overlayView == nil)
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
        CGRect rectViewport = depositModel.rectViewPort;                // get the viewport

        __block CGPoint pointTL;
        __block CGPoint pointTR;
        __block CGPoint pointBL;
        __block CGPoint pointBR;

        //double tNow = CACurrentMediaTime();                           // current time (fractional seconds)
        
        // find the corners
        [mVIP onProcessImageGetCropCorners:rawPixels viewport:&rectViewport BPP:4 width:width height:height stride:stride toPointTL:&pointTL toPointTR:&pointTR toPointBL:&pointBL toPointBR:&pointBR];
        
        //NSLog(@"didOutputSampleBuffer onProcessImageGetCropCorners %.3f", CACurrentMediaTime() - tNow);
       
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            // landscape left will take an upside-down picture!
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)
            {
                // rotate 180 degrees
                [self rotateCorners180:&pointTL tr:&pointTR bl:&pointBL br:&pointBR width:width height:height];
            }

            // convert corner points into percentages
            weakSelf.overlayView->pointTL.x = pointTL.x / width;
            weakSelf.overlayView->pointTL.y = pointTL.y / height;
            weakSelf.overlayView->pointTR.x = pointTR.x / width;
            weakSelf.overlayView->pointTR.y = pointTR.y / height;
            weakSelf.overlayView->pointBL.x = pointBL.x / width;
            weakSelf.overlayView->pointBL.y = pointBL.y / height;
            weakSelf.overlayView->pointBR.x = pointBR.x / width;
            weakSelf.overlayView->pointBR.y = pointBR.y / height;

            [weakSelf.overlayView setNeedsDisplay];                     // display the overlayView
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

//------------------------------------------------------------------------------------------
// Show Focus Rectangle
//
// animates in/out a focus rectangle
//------------------------------------------------------------------------------------------

- (void) showFocusRectAt:(CGPoint)point
{
    if (isCapturingStillImage)                                      // don't bother if capturing still
        return;
    
    CGPoint focusPoint = CGPointMake(point.x/previewView.bounds.size.width,point.y/previewView.bounds.size.height);

    __block UIView *focusRect = [[UIView alloc] init];
    [focusRect setBackgroundColor:schema.colorClear];               // fully transparent view
    CGFloat focusRectSize = self.previewView.frame.size.width * 0.175; // initial size
    CGFloat focusRectSize2 = focusRectSize * 0.666f;                // target size
    CGRect frame = CGRectMake(point.x - (focusRectSize/2),point.y - (focusRectSize/2),focusRectSize,focusRectSize);
    CGRect frame2 = CGRectMake(point.x - (focusRectSize2/2),point.y - (focusRectSize2/2),focusRectSize2,focusRectSize2);
    [focusRect setFrame:frame];
    focusRect.layer.borderWidth = 1;                                // use layer to draw yellow border only
    focusRect.layer.borderColor = [UIColor yellowColor].CGColor;
    focusRect.alpha = 0;                                            // initially transparent
    [self.previewView addSubview:focusRect];
    
    [UIView animateWithDuration:0.4f animations:^{

        focusRect.alpha = 1.0f;                                     // fade in and shrink
        [focusRect setFrame:frame2];
    
    } completion:^(BOOL finished) {
    
        if (!isCapturingStillImage)
        {
            NSError *error = nil;
            
            // device configuration
            [device lockForConfiguration:&error];
            
            // set focus/exposure point of interest
            if ([device isFocusPointOfInterestSupported])
                [device setFocusPointOfInterest:focusPoint];
            if ([device isExposurePointOfInterestSupported])
                [device setExposurePointOfInterest:focusPoint];
            
            [device unlockForConfiguration];
        }
        
        [UIView animateWithDuration:0.4f delay:0.8f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            focusRect.alpha = 0.0f;                                 // fade out
        
        } completion:^(BOOL finished) {
        
            [focusRect removeFromSuperview];                        // remove
        
        }];
    }];
}

#pragma mark Camera alignment image

- (void) showAlignmentImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // v7.5; disable overlay while alignment image appears
        [overlayView enableOverlay:NO];
        
        // alignment image
        CGFloat margin = 20;
        __block CGRect alignImageFrame = CGRectMake((previewView.bounds.size.width * depositModel.rectViewPort.origin.x) + margin,
                                            (previewView.bounds.size.height * depositModel.rectViewPort.origin.y) + margin,
                                            (previewView.bounds.size.width * (depositModel.rectViewPort.size.width)) - (margin * 2),
                                            (previewView.bounds.size.height * (depositModel.rectViewPort.size.height)) - (margin * 2));
        
        __block UIImageView *alignImage = [[UIImageView alloc] initWithFrame:alignImageFrame];
        [alignImage setImage:[UIImage imageNamed:isFront ? @"ckalignfront" : @"ckalignback"]];
        alignImage.contentMode = UIViewContentModeScaleAspectFit;
        alignImage.alpha = 0;
        alignImage.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        [previewView addSubview:alignImage];
        
        [UIView animateWithDuration:0.6f animations:^{

            alignImage.alpha = 1.0;
            alignImage.transform = CGAffineTransformIdentity;

        } completion:^(BOOL finished) {

            [UIView animateWithDuration:0.6f delay:1.6f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                
                alignImage.alpha = 0;
                overlayView.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                [alignImage removeFromSuperview];
                
                // v7.5; enable overlay
                [overlayView enableOverlay:YES];
                
                // v7.5; set focus/exposure point of interest to center
                //CGPoint touchPoint = CGPointMake(self.previewView.bounds.size.width/2,self.previewView.bounds.size.height/2);
                //[self showFocusRectAt:touchPoint];
            }];
            
        }];

    });
    
}

#pragma mark Camera instruction

//-----------------------------------------------------------------------------
// Load Camera Instruction
//-----------------------------------------------------------------------------

- (void) loadCameraInstruction:(id)sender
{
    NSString *preferenceName = isFront ? kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_FRONT : kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_BACK;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    id oPreference = [defaults objectForKey:preferenceName];
    BOOL preferenceValue = (oPreference == nil) ? YES : [defaults boolForKey:preferenceName];

    // if user initiated via bar button, force the open
    if ([sender isKindOfClass:[UIBarButtonItem class]])
        preferenceValue = YES;
    
    if (preferenceValue == YES)
    {
        CameraInstructionViewController *cameraInstructionViewController = [[CameraInstructionViewController alloc] initWithNibName:@"CameraInstructionViewController" bundle:nil isFront:isFront delegate:self];
        if (cameraInstructionViewController != nil)
        {
            [self presentViewController:cameraInstructionViewController animated:YES completion:nil];
        }
    }
    else
    {
        [self showAlignmentImage];
    }
    
}

- (void) onInstructionDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self showAlignmentImage];
    }];
    
}

#pragma mark UIScrollViewDelegate

//---------------------------------------------------------------------------------------------
// Scroll View Delegate Methods
//---------------------------------------------------------------------------------------------

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return (imageViewPreview);
}

@end
