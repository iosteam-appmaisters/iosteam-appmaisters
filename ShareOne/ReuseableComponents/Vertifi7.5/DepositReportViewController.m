//
//  DepositReportViewController.m
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

#import "VIPSampleAppDelegate.h"
#import "DepositReportViewController.h"

@implementation DepositReportViewController

@synthesize webViewReport;
@synthesize webLoading;
@synthesize webViewTopConstraint;
@synthesize navBarHeightConstraint;
@synthesize deposit;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
        // get model and schema objects
        depositModel = [DepositModel sharedInstance];
        schema = [UISchema sharedInstance];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
 
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportComplete:) name:kVIP_NOTIFICATION_DEPOSIT_REPORT_COMPLETE object:nil];

	// set title
	self.title = [NSString stringWithFormat:@"%@ #%@", deposit.depositStatus, deposit.depositId];
	
	// custom Back button
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
 
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [depositModel.networkQueue sendDepositReport:deposit];
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
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	webViewReport.navigationDelegate = nil;				// clear delegate before release
}

#pragma mark Notifications

//-----------------------------------------------------------------------------
// reportComplete notification
//-----------------------------------------------------------------------------

- (void) reportComplete:(NSNotification *)notification
{
    // the object is a dictionary with {kVIP_KEY_REPORT_URL:{url}}  || {kVIP_KEY_ERROR:{string}} 
    NSString *url = [notification.object valueForKey:kVIP_KEY_REPORT_URL];
    NSString *error = [notification.object valueForKey:kVIP_KEY_ERROR];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (error != nil)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else if (url != nil)
        {
//            webViewReport.scalesPageToFit = YES;
            self->webViewReport.navigationDelegate = self;
            [self->webViewReport loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        }
    });
    
}

#pragma mark WebViewDelegate methods

//---------------------------------------------------------------------------------------------
// WebViewDelegate Methods
//---------------------------------------------------------------------------------------------

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated)
    {
        NSURL *url = [webView URL];
        
        // mail/telephone/appstore
        if (([[url scheme] hasPrefix:@"mailto"]) || ([[url scheme] hasPrefix:@"tel"]) || ([[url scheme] hasPrefix:@"itms"]))
        {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        
        // YouTube
        if ([[url scheme] hasPrefix:@"vnd.youtube"])
        {
            NSURL *urlYouTube = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/v/%@",[url resourceSpecifier]]];
            [[UIApplication sharedApplication] openURL:urlYouTube];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    
   decisionHandler(WKNavigationActionPolicyAllow);
    
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [VIPSampleAppDelegate sessionOpen];
       
       [UIView animateWithDuration:0.4f animations:^{
           [webLoading setAlpha:1.0f];
       }];
       [webLoading startAnimating];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [VIPSampleAppDelegate sessionClose];
      
      [UIView animateWithDuration:0.4f animations:^{
          [webLoading setAlpha:0.0f];
      } completion:^(BOOL finished) {
          [webLoading stopAnimating];
      }];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [VIPSampleAppDelegate sessionClose];

       [webLoading stopAnimating];
       
       if (error.code == kCFURLErrorCancelled)
           return;
       
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, unable to load report content:\n\n%@",[error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
       [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
       [self presentViewController:alert animated:YES completion:nil];
}
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//	if (navigationType == UIWebViewNavigationTypeLinkClicked)
//	{
//		NSURL *url = [request URL];
//
//		// mail/telephone/appstore
//		if (([[url scheme] hasPrefix:@"mailto"]) || ([[url scheme] hasPrefix:@"tel"]) || ([[url scheme] hasPrefix:@"itms"]))
//		{
//			[[UIApplication sharedApplication] openURL:url];
//			return (NO);
//		}
//
//		// YouTube
//		if ([[url scheme] hasPrefix:@"vnd.youtube"])
//		{
//			NSURL *urlYouTube = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/v/%@",[url resourceSpecifier]]];
//			[[UIApplication sharedApplication] openURL:urlYouTube];
//			return (NO);
//		}
//	}
//
//	return (YES);
//}

//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    [VIPSampleAppDelegate sessionOpen];
//
//    [UIView animateWithDuration:0.4f animations:^{
//        [webLoading setAlpha:1.0f];
//    }];
//	[webLoading startAnimating];
//}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [VIPSampleAppDelegate sessionClose];
//
//    [UIView animateWithDuration:0.4f animations:^{
//        [webLoading setAlpha:0.0f];
//    } completion:^(BOOL finished) {
//        [webLoading stopAnimating];
//    }];
//}

//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    [VIPSampleAppDelegate sessionClose];
//
//    [webLoading stopAnimating];
//
//	if (error.code == kCFURLErrorCancelled)
//		return;
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, unable to load report content:\n\n%@",[error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alert animated:YES completion:nil];
//}

@end
