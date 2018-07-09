//
//  RegistrationViewController.m
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

#import "VIPSampleAppDelegate.h"
#import "RegistrationViewController.h"
#import "UISchema.h"

//---------------------------------------------------------------------------------------------
// RegistrationViewController implementation
//---------------------------------------------------------------------------------------------

@implementation RegistrationViewController

// Properties
@synthesize webView;
@synthesize toolBar;
@synthesize buttonAccept;
@synthesize buttonDeny;
@synthesize toolBarHeightConstraint;
@synthesize webViewToolbarYConstraint;
@synthesize activityLabel;

// Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
	{
        // get model object
        depositModel = [DepositModel sharedInstance];

        self.title = @"Registration";
        bAcceptingEUA = NO;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];	
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationQueryNotification:) name:kVIP_NOTIFICATION_DEPOSIT_REGISTRATION_QUERY_COMPLETE object:nil];

    UIBarButtonItem *buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onRegistrationDone:)];
    self.navigationItem.rightBarButtonItem = buttonClose;
    
    webView.scalesPageToFit = YES;
	[self onSetSchema];
	
    [self onShowContent];
    
    if (depositModel.htmlContent == nil)
        [self onRegistrationGetEUA];
    
 	return;
}

// WillLayoutSubviews - used to update the navbar height constraint
- (void) viewWillLayoutSubviews
{
    UIEdgeInsets insets = self.webView.scrollView.contentInset;
    //insets.top = self.navigationController.navigationBar.frame.size.height;
    insets.bottom = self.toolBarHeightConstraint.constant;
    [self.webView.scrollView setContentInset:insets];
    [super viewWillLayoutSubviews];
}

// interface orientation (iOS6)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskAll);
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	webView.delegate = nil;				// clear delegate before release
}

//-----------------------------------------------------------------------------
// Set Schema
//-----------------------------------------------------------------------------

- (void) onSetSchema
{
    [self.view bringSubviewToFront:toolBar];
}

#pragma mark Notifications

//-----------------------------------------------------------------------------
// Registration Query notification
//-----------------------------------------------------------------------------

- (void) onRegistrationQueryNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityLabel remove];
        [self onShowContent];
    });
}

//---------------------------------------------------------------------------------------------
// Remove Toolbar
//---------------------------------------------------------------------------------------------

- (void) onRemoveToolBar
{
    if (self.toolBar != nil)
    {
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.4f animations:^{
            toolBarHeightConstraint.constant = 0;
            webViewToolbarYConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [toolBar setHidden:YES];
            self.toolBar = nil;
        }];
        
    }
    return;
}

//---------------------------------------------------------------------------------------------
// Show content
//---------------------------------------------------------------------------------------------

- (void) onShowContent
{
    UISchema *schema = [UISchema sharedInstance];
    if (depositModel.htmlContent != nil)
    {
        NSMutableString *webContent = [[NSMutableString alloc] initWithCapacity:20480];
        [webContent appendFormat:@"%@\n%@",
            @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n",
            @"<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n"];
       
        // set an inline CSS styles indicating smallish font
        [webContent appendFormat:@"<head><meta name=\"viewport\" content=\"initial-scale=1.0, minimum-scale=1.0, maximum-scale=2.0\" /><style type=\"text/css\">body { font-family: Helvetica-Neue,sans-serif; font-size: %.0fpt; padding: 8pt; line-height:1.3em; -webkit-text-size-adjust:none; } h1 { font-size: 110%%; } h2 { font-size: 105%%; } h3 { font-weight: bold; } .small { font-size: %.0fpt; } </style></head>\n<body>\n",
            ceil(schema.fontCaption2.pointSize * 1.0f),
            ceil(schema.fontCaption2.pointSize * 1.0f) - 2];

        // insert content
        [webContent appendString:[[NSString alloc] initWithData:depositModel.htmlContent encoding:NSUTF8StringEncoding]];
        [webContent appendString:@"</body></html>"];

        [webView loadHTMLString:webContent baseURL:nil];
    }

    switch (depositModel.registrationStatus)
    {
        case kVIP_REGSTATUS_DISABLED:						// disabled
            
            self.navigationItem.title = @"Registration Disabled";
            [self onRegistrationDisabled];
            break;

        case kVIP_REGSTATUS_REGISTERED:						// registered - OK
           
            if (bAcceptingEUA)                              // close on an Accept (auto-registered)
            {
                [self onRegistrationDone:self];
                return;
            }

            self.navigationItem.title = @"Terms & Conditions";
            [self onRegistrationRegister];
            break;
        
        case kVIP_REGSTATUS_PENDING:						// registered - not approved
        
            self.navigationItem.title = @"Pending Approval";
            [self onRegistrationPending];
            break;
        
        case kVIP_REGSTATUS_UNREGISTERED:					// not registered
            
            self.navigationItem.title = @"Register";
            [self onRegistrationRegister];
            break;
        
        default:											// unknown - error
            break;
    }

}

//---------------------------------------------------------------------------------------------
// Get EUA
//---------------------------------------------------------------------------------------------

- (void) onRegistrationGetEUA
{
    self.activityLabel = [[ActivityLabelView alloc] initWithViewController:self message:@"Please wait..."];
    [depositModel.networkQueue sendRegistrationGetEUA];
}

//---------------------------------------------------------------------------------------------
// Registration EUA
//---------------------------------------------------------------------------------------------

- (void) onRegistrationRegister
{
    if (depositModel.registrationStatus == kVIP_REGSTATUS_REGISTERED)
        [self onRemoveToolBar];
    else
    {
        buttonAccept.enabled = YES;
        buttonDeny.enabled = YES;
    }
}

//---------------------------------------------------------------------------------------------
// Registration Pending
//---------------------------------------------------------------------------------------------

- (void) onRegistrationPending
{
	buttonAccept.enabled = NO;
	buttonDeny.enabled = NO;
	
	[self onRemoveToolBar];
}

//---------------------------------------------------------------------------------------------
// Registration Disabled
//---------------------------------------------------------------------------------------------

- (void) onRegistrationDisabled
{
	buttonAccept.enabled = NO;
	buttonDeny.enabled = NO;
	[self onRemoveToolBar];
}

//---------------------------------------------------------------------------------------------
// Registration Accept
//---------------------------------------------------------------------------------------------

- (IBAction) onRegistrationAccept:(id)sender
{
    buttonAccept.enabled = NO;
    buttonDeny.enabled = NO;
    [self onRemoveToolBar];
    
    DepositAccount *account = [depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];
    
    if (account.MAC == nil)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Session" message:@"Cannot Process Registration without Active Session" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.activityLabel = [[ActivityLabelView alloc] initWithViewController:self message:@"Please wait..."];
    [depositModel.networkQueue sendRegistrationAccept];
  
    bAcceptingEUA = YES;

	return;
}

//---------------------------------------------------------------------------------------------
// Registration Deny
//---------------------------------------------------------------------------------------------

- (IBAction) onRegistrationDeny:(id)sender
{
   	[self onRegistrationDone:sender];
	return;
}

//---------------------------------------------------------------------------------------------
// Registration Done
//---------------------------------------------------------------------------------------------

- (void) onRegistrationDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
