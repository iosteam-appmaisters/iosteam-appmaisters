//
//  RegistrationViewController.h
//  VIPSample
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

#import <UIKit/UIKit.h>
#import "ActivityLabelView.h"
#import "DepositModel.h"
#import <WebKit/WebKit.h>

@interface RegistrationViewController : UIViewController
{
    DepositModel *depositModel;                             // model

	IBOutlet WKWebView *webView;                            // web view
	IBOutlet UIToolbar *toolBar;                            // bottom toolbar
	IBOutlet UIBarButtonItem *buttonAccept;                 // toolbar bar buttons
	IBOutlet UIBarButtonItem *buttonDeny;
    
    IBOutlet NSLayoutConstraint *toolBarHeightConstraint;   // constraints
    IBOutlet NSLayoutConstraint *webViewToolbarYConstraint;

    ActivityLabelView *activityLabel;                       // a UIView with spinner and label

    BOOL bAcceptingEUA;                                     // flag to indicate closure on an Acceptance operation
}

// Properties

@property  WKWebView *webView;
@property  UIToolbar *toolBar;
@property  UIBarButtonItem *buttonAccept;
@property  UIBarButtonItem *buttonDeny;
@property (nonatomic, strong) ActivityLabelView *activityLabel;

@property (nonatomic) NSLayoutConstraint *webViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *toolBarHeightConstraint;
@property (nonatomic) NSLayoutConstraint *webViewToolbarYConstraint;

// Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

// Notifications
- (void) onRegistrationQueryNotification:(NSNotification *)notification;    // registration query complete

- (void) onRegistrationGetEUA;
- (void) onRegistrationRegister;
- (void) onRegistrationPending;
- (void) onRegistrationDisabled;
- (void) onRemoveToolBar;

- (void) onSetSchema;
- (void) onShowContent;

- (IBAction) onRegistrationDone:(id)sender;
- (IBAction) onRegistrationAccept:(id)sender;
- (IBAction) onRegistrationDeny:(id)sender;

@end
