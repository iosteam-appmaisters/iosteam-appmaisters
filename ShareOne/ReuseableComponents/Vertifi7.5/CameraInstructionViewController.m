//
//  CameraInstructionViewController.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
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
//--------------------------------------------------------------------------------------------------------------------------------------------------
#import "CameraInstructionViewController.h"
#import "UISchema.h"
#import "DepositModel.h"

@interface CameraInstructionViewController ()
@end

@implementation CameraInstructionViewController

@synthesize navBar;
@synthesize imageView;
@synthesize toolbar;
@synthesize switchDoNotShow;
@synthesize images;
@synthesize timer;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isFront:(BOOL)isFrontInstruction delegate:(id<CameraInstructionViewControllerDelegate>)sender
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
    {
        // Custom initialization
        self.delegate = sender;
        isFront = isFrontInstruction;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISchema *schema = [UISchema sharedInstance];

    [self.navBar.items[0] setTitle:isFront ? @"Prepare the front of the check" : @"Prepare the back of the check"];
    
    if (isFront)
        self.images = @[ [UIImage imageNamed:@"ckinstructfront"] ];
    else
        self.images = @[ [UIImage imageNamed:@"ckinstructback"], [UIImage imageNamed:@"ckinstructback2"], [UIImage imageNamed:@"ckinstructback3"] ];
    
    nImageSequence = 0;
    [imageView setImage:[self.images objectAtIndex:nImageSequence]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    UIBarButtonItem *buttonFlexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonContinue = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];

    UILabel *labelShowAgain = [[UILabel alloc] init];
    [labelShowAgain setText:@"Do not show this again"];
    [labelShowAgain setTextColor:schema.colorLightText];
    
    [labelShowAgain setFont:schema.fontFootnote];
    [labelShowAgain sizeToFit];
    UIBarButtonItem *buttonLabelShowAgain = [[UIBarButtonItem alloc] initWithCustomView:labelShowAgain];
    
    self.switchDoNotShow = [[UISwitch alloc] init];
    [switchDoNotShow setOn:YES];
    NSString *preferenceName = isFront ? kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_FRONT : kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_BACK;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    id oPreference = [defaults objectForKey:preferenceName];
    if ((oPreference == nil) || ([defaults boolForKey:preferenceName] == YES))      // Show preference YES, set Do Not Show to NO
        [switchDoNotShow setOn:NO];

    UIBarButtonItem *buttonShowAgain = [[UIBarButtonItem alloc] initWithCustomView:switchDoNotShow];
    
    UIBarButtonItem *buttonFixSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    buttonFixSpace.width = 10;
    
    [toolbar setItems:@[buttonLabelShowAgain,buttonFixSpace,buttonShowAgain,buttonFlexSpace,buttonContinue]];

    if (images.count > 1)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    if (timer != nil)
        [timer invalidate];
}

//------------------------------------------------------------------------------------------
// interface orientation - landscape only!
//------------------------------------------------------------------------------------------

// interface orientation (iOS6)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscape);
}


//-----------------------------------------------------------------------------
// Timer Fire
//-----------------------------------------------------------------------------

- (void)onTimer:(NSTimer*)timer
{
    // set B/W image into ImageView using cross dissolve
    [UIView transitionWithView:imageView duration:1.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        
        nImageSequence++;
        if (nImageSequence >= images.count)
            nImageSequence = 0;
        
        imageView.image = [images objectAtIndex:nImageSequence];
        
    } completion:^(BOOL finished)
    {
    }];
}

//-----------------------------------------------------------------------------
// Done
//-----------------------------------------------------------------------------

- (void) onDone:(UIBarButtonItem *)sender
{
    NSString *preferenceName = isFront ? kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_FRONT : kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_BACK;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setObject:[NSNumber numberWithBool:!switchDoNotShow.isOn] forKey:preferenceName];     // Preference == SHOW, UI switch = DO NOT SHOW, so negate the value
    [defaults synchronize];

    if (delegate)
        [delegate onInstructionDone:self];
}

//------------------------------------------------------------------------------------------
// status bar
//------------------------------------------------------------------------------------------

- (BOOL) prefersStatusBarHidden
{
    return (YES);
}

@end
