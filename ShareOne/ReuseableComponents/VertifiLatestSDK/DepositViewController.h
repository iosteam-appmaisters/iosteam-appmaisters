//
//  DepositViewController.h
//  VIPSample
//
//  Created by Vertifi Software, LLC
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
#import "CameraViewController.h"
#import "UISchema.h"
#import "BadgeBarButtonItem.h"

@interface DepositViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CameraViewControllerDelegate, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate>
{
    BadgeBarButtonItem *buttonHeldForReview;                // held for review button
    UIBarButtonItem *buttonTraash;                          // trash can button
    UIBarButtonItem *buttonTerms;                           // T&C bar button
    UITextField *textAmount;                                // amount
    UIButton *buttonSubmit;                                 // Submit button

    DepositModel *depositModel;                             // model object
    UISchema *schema;                                       // schema object

    // Tableview stuff
    int nSectionRegistration;                               // section #'s
    int nSectionFrontImage;                                 // .
    int nSectionBackImage;                                  // .
    int nSectionSubmit;                                     // .

    BOOL bShowColor;                                        // show color preference
}

// Properties
@property (nonatomic, strong) BadgeBarButtonItem *buttonHeldForReview;
@property (nonatomic, strong) UIBarButtonItem *buttonTrash;
@property (nonatomic, strong) UIBarButtonItem *buttonTerms;
@property (nonatomic, strong) UITextField *textAmount;
@property (nonatomic, strong) UIButton *buttonSubmit;

// Methods
- (void) onCameraClick:(UIButton *)sender;
- (void) loadCamera:(UIButton *)sender;
- (void) showHeldForReview;
- (IBAction) onShowErrors:(id)sender frontOrBack:(char)forb;

// Bar button actions
- (IBAction) onHeldForReview:(id)sender;
- (IBAction) onTrash:(UIBarButtonItem *)sender;
- (IBAction) onTerms:(UIBarButtonItem *)sender;

// Deposit Submit
- (void) onActivateSubmit;                                  // submit button
- (void) onSubmit:(id)sender;                               // submit deposit

- (void) showNoCredentials;                                 // no credentials error

// CAR Mismatch
- (BOOL) checkCARMismatch;
- (void) showCARMismatch:(id)sender;

// Notification
- (void) onFontSizeChanged:(NSNotification *)notification;
- (void) onSettingsChanged:(NSNotification *)notification;
- (void) onLoginNotification:(NSNotification *)notification;
- (void) onDepositInitComplete:(NSNotification *)notification;      // deposit init complete
- (void) onDepositSubmitComplete:(NSNotification *)notification;	// deposit submit complete

// CameraViewControllerDelegate
- (void) onCameraClose;
- (void) onPictureTaken:(UIImage *)imageJPEG withBWImage:(UIImage *)imageBW results:(NSArray *)dictionary isFront:(BOOL)isFront;

// UITextFieldDelegate functions
- (void) textFieldDidBeginEditing:(UITextField *)textField;
- (void) textFieldDidEndEditing:(UITextField *)textField;
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
