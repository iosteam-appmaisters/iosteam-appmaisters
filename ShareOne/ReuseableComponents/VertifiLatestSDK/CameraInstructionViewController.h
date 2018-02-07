//
//  CameraInstructionViewController.h
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

#import <UIKit/UIKit.h>

@protocol CameraInstructionViewControllerDelegate

- (void) onInstructionDone:(UIViewController *)sender;

@end

@interface CameraInstructionViewController : UIViewController
{
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIImageView *imageView;
    IBOutlet UIToolbar *toolbar;
    
    UISwitch *switchDoNotShow;
    
    id<CameraInstructionViewControllerDelegate> __unsafe_unretained delegate;

    BOOL isFront;
}

@property (nonatomic) UINavigationBar *navBar;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) UISwitch *switchDoNotShow;

@property (nonatomic, unsafe_unretained) id<CameraInstructionViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isFront:(BOOL)isFront delegate:(id<CameraInstructionViewControllerDelegate>)delegate;

@end
