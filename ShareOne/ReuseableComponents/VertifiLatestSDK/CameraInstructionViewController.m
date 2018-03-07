//
//  CameraInstructionViewController.m
//  VIPSample
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
#import "CameraInstructionViewController.h"
#import "UISchema.h"
#import "DepositModel.h"
#import "Configuration.h"

@interface CameraInstructionViewController ()
@end

@implementation CameraInstructionViewController

@synthesize navBar;
@synthesize imageView;
@synthesize toolbar;
@synthesize switchDoNotShow;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isFront:(BOOL)isFrontInstruction  delegate:(id<CameraInstructionViewControllerDelegate>)sender
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
    
    [self.navBar.items[0] setTitle:isFront ? @"Prepare Check Front" : @"Prepare Check Back"];
    
    [imageView setImage:[UIImage imageNamed:isFront ? @"ckinstructfront" : @"ckinstructback"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    UILabel *labelShowAgain = [[UILabel alloc] init];
    [labelShowAgain setText:@"Do not show this again"];
    [labelShowAgain setTextColor:schema.colorDarkText];

    [labelShowAgain setFont:schema.fontFootnote];
    [labelShowAgain sizeToFit];
    UIBarButtonItem *buttonLabelShowAgain = [[UIBarButtonItem alloc] initWithCustomView:labelShowAgain];
    
    switchDoNotShow = [[UISwitch alloc] init];
    [switchDoNotShow setSelected:NO];
    UIBarButtonItem *buttonShowAgain = [[UIBarButtonItem alloc] initWithCustomView:switchDoNotShow];
    
    UIBarButtonItem *buttonFlexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonContinue = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    
    BOOL forcedInstructions = [[Configuration getClientSettingsContent].rdcforceinstruction boolValue];
    if (forcedInstructions){
        [toolbar setItems:@[buttonFlexSpace,buttonContinue]];
    }
    else {
        [toolbar setItems:@[buttonLabelShowAgain,buttonShowAgain,buttonFlexSpace,buttonContinue]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------
// interface orientation - landscape only!
//------------------------------------------------------------------------------------------

// interface orientation (iOS6)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscape);
}


- (void) onDone:(UIBarButtonItem *)sender
{
    if (switchDoNotShow.isOn)
    {
        NSString *preferenceName = isFront ? kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_FRONT : kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_BACK;
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        id oPreference = [defaults objectForKey:preferenceName];
        if ((oPreference == nil) || ([defaults boolForKey:preferenceName] == YES))
        {
            [defaults setObject:[NSNumber numberWithBool:NO] forKey:preferenceName];
            [defaults synchronize];
        }
    }

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
