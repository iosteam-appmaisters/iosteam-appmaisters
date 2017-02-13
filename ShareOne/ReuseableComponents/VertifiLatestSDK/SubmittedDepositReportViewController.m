//
//  SubmittedDepositReportViewController.m
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

#import "VIPSampleAppDelegate.h"
#import "SubmittedDepositReportViewController.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"
#import "XmlSimpleParser.h"

@implementation SubmittedDepositReportViewController

@synthesize submittedDeposit;
@synthesize webViewReport;
@synthesize webLoading;
@synthesize webViewTopConstraint;
@synthesize navBarHeightConstraint;

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
 
	// set title
	self.title = [NSString stringWithFormat:@"Deposit #%@", submittedDeposit.deposit_ID];
	
	// custom Back button
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
 
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
	[self onGetSubmittedDepositReport];
	
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
	webViewReport.delegate = nil;				// clear delegate before release
}

#pragma mark Get Submitted Deposit Report from server

- (void) onGetSubmittedDepositReport
{
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];

	// perform server call
    if ((account.MAC != nil))
	{
        FormPostHandler *postHandler = [[FormPostHandler alloc] init];
        NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_HeldForReviewReport"]];
		
		MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
		
		// fields
        [form addFormField:@"requestor" withStringData:depositModel.requestor];
        [form addFormField:@"session" withStringData:account.session];
        [form addFormField:@"timestamp" withStringData:account.timestamp];
        [form addFormField:@"routing" withStringData:depositModel.routing];
        [form addFormField:@"member" withStringData:account.member];
        [form addFormField:@"account" withStringData:account.account];
        [form addFormField:@"MAC" withStringData:account.MAC];
        [form addFormField:@"mode" withStringData:depositModel.testMode ? @"test" : @"prod"];
		[form addFormField:@"deposit_id" withStringData:submittedDeposit.deposit_ID];
		
        
        // Post the message
        [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
        {
             if (success)
             {
                 XmlSimpleParser *parser = [[XmlSimpleParser alloc] initXmlParser];
                 NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
                 
                 [xml setDelegate:parser];
                 if ([xml parse])
                 {
                     NSString *strValue = (NSString *)[parser.dictElements valueForKey:@"URL"];
                     if (strValue != nil)
                     {
                         [webViewReport loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strValue]]];
                         webViewReport.scalesPageToFit = YES;
                         webViewReport.delegate = self;
                     }
                     
                     strValue = (NSString *)[parser.dictElements valueForKey:@"Error"];
                     if (strValue != nil)
                     {
                         [webLoading stopAnimating];
                         
                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:strValue preferredStyle:UIAlertControllerStyleAlert];
                         [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                     
                 }
             }
             else
             {
                 NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
             }
        }];
    }
}

#pragma mark WebViewDelegate methods

//---------------------------------------------------------------------------------------------
// WebViewDelegate Methods
//---------------------------------------------------------------------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		NSURL *url = [request URL];
		
		// mail/telephone/appstore
		if (([[url scheme] hasPrefix:@"mailto"]) || ([[url scheme] hasPrefix:@"tel"]) || ([[url scheme] hasPrefix:@"itms"]))
		{
			[[UIApplication sharedApplication] openURL:url];
			return (NO);
		}
		
		// YouTube
		if ([[url scheme] hasPrefix:@"vnd.youtube"])
		{
			NSURL *urlYouTube = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/v/%@",[url resourceSpecifier]]];
			[[UIApplication sharedApplication] openURL:urlYouTube];
			return (NO);
		}
	}
	
	return (YES);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    VIPSampleAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app sessionOpen];
    
    [UIView animateWithDuration:0.4f animations:^{
        [webLoading setAlpha:1.0f];
    }];
	[webLoading startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    VIPSampleAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app sessionClose];
    
    [UIView animateWithDuration:0.4f animations:^{
        [webLoading setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [webLoading stopAnimating];
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    VIPSampleAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app sessionClose];
    
    [webLoading stopAnimating];
	
	if (error.code == kCFURLErrorCancelled)
		return;
	
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, unable to load report content:\n\n%@",[error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
