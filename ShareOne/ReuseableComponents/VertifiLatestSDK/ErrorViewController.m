//
//  HelpViewController.m
//  VIPSample
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
#import "DepositViewController.h"
#import "ErrorViewController.h"
#import "CFNetwork/CFNetworkErrors.h"

//---------------------------------------------------------------------------------------------
// ErrorViewController implementation
//---------------------------------------------------------------------------------------------

@implementation ErrorViewController

// Properties

@synthesize webViewErrors;
@synthesize webLoading;

// Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forb:(char)forb
{	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
	{
        // Custom initialization
        depositModel = [DepositModel sharedInstance];
		self.title = @"Errors/Warnings";
		cFrontOrBack = forb;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];	
	
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onErrorsDone:)];
    self.navigationItem.rightBarButtonItem = buttonDone;
    
    UISchema *schema = [UISchema sharedInstance];
    
    // build up error text as HTML

	NSMutableString *strContent = [[NSMutableString alloc] initWithCapacity:2048];
	[strContent appendFormat:@"%@\n%@",
		@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n",
		@"<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n"];

    [strContent appendFormat:@"<head><meta name=\"viewport\" content=\"initial-scale=1.0, minimum-scale=1.0, maximum-scale=2.0\" /><style type=\"text/css\">body { font-family: Helvetica-Neue,sans-serif; font-size: %.0fpt; padding: 8pt; line-height:1.3em; -webkit-text-size-adjust:none; } h1 { font-size: 110%%; } h2 { font-size: 105%%; } h3 { font-weight: bold; } .small { font-size: %.0fpt; } </style></head>\n<body>\n",
        ceil(schema.fontFootnote.pointSize * 1.0f),
        ceil(schema.fontFootnote.pointSize * 1.0f) - 2];

    //-----------------------------------------------------------------------------------
	// GENERAL
	//-----------------------------------------------------------------------------------

    NSUInteger nGeneralErrors = depositModel.dictResultsGeneral.count;
    
    if ((nGeneralErrors) && (cFrontOrBack == 'A'))
    {
        [strContent appendString:@"<h1>General Errors:</h1>"];
		
        [strContent appendString:@"<ul>"];
        for (id key in depositModel.dictResultsGeneral)
        {
            [strContent appendFormat:@"<li>%@</li>\n", [depositModel.dictResultsGeneral objectForKey:key]];
        }
        [strContent appendString:@"</ul>\n"];
        [strContent appendString:@"<p>Errors occurred during processing of the deposit.  Please resubmit the deposit.</p>\n"];
    }

	//-----------------------------------------------------------------------------------
	// FRONT IMAGE
	//-----------------------------------------------------------------------------------

	if ((cFrontOrBack == 'F') || (cFrontOrBack == 'A'))
	{
		NSUInteger nFrontErrors = depositModel.dictResultsFrontImage.count;
		int nFrontUsability = 0;
		for (id key in depositModel.dictResultsFrontImage)
		{
			if ([key hasSuffix:@"Usability"])						// does end in "Usability"
				nFrontUsability++;
		}
		nFrontErrors -= nFrontUsability;

		if (nFrontErrors)
		{
			[strContent appendString:@"<h1>Front Image Errors:</h1>"];
		
			[strContent appendString:@"<ul>"];
			for (id key in depositModel.dictResultsFrontImage)
			{
				if (![key hasSuffix:@"Usability"])						// doesn't end in "Usability"
				{
					[strContent appendFormat:@"<li>%@</li>\n", [depositModel.dictResultsFrontImage objectForKey:key]];
				}
			}	
			[strContent appendString:@"</ul>\n"];
            [strContent appendString:@"<p>Take a new photo of the front of the check.</p>\n"];
		}
	
		if (nFrontUsability)
		{
            // change navbar title
            if (!nFrontErrors)
                [self.navigationItem setTitle:@"Image Warnings"];

			[strContent appendString:@"<h1>Front Image Warnings:</h1>"];
		
			[strContent appendString:@"<ul>"];
			for (id key in depositModel.dictResultsFrontImage)
			{
				if ([key hasSuffix:@"Usability"])						// does end in "Usability"
				{
					[strContent appendFormat:@"<li>%@</li>\n", [depositModel.dictResultsFrontImage objectForKey:key]];
				}
			}	
			[strContent appendString:@"</ul>\n"];
			[strContent appendString:@"<p>The warnings above indicate specific information on the check that could not be located or clearly read.  Please carefully review the photo to ensure that it is a clear image of the check, taking a new photo if necessary.  If the photo is already clear and legible, you may continue with the deposit and ignore any warnings.</p>\n"];
		}
        
        if ((!nFrontErrors) && (!nFrontUsability))
        {
            // front image exists?
            if (!depositModel.frontImagePresent)
            {
                [strContent appendString:@"<h1>Front Image Missing:</h1>"];
                [strContent appendString:@"<ul>"];
                [strContent appendString:@"<li>Tap the Camera button to take a photograph of the front of the check.</li>"];
                [strContent appendString:@"</ul>\n"];
            }
       }
	}
	
	//-----------------------------------------------------------------------------------
	// BACK IMAGE
	//-----------------------------------------------------------------------------------
	
	if ((cFrontOrBack == 'B') || (cFrontOrBack == 'A'))
	{
		NSUInteger nBackErrors = depositModel.dictResultsBackImage.count;
		
		if (nBackErrors)
		{
			[strContent appendString:@"<h1>Back Image Errors:</h1>"];
		
			[strContent appendString:@"<ul>"];
			for (id key in depositModel.dictResultsBackImage)
			{
				[strContent appendFormat:@"<li>%@</li>\n", [depositModel.dictResultsBackImage objectForKey:key]];
			}	
			[strContent appendString:@"</ul>\n"];
            [strContent appendString:@"<p>Take a new photo of the back of the check.  For 'image is not in scale' errors, either the front or back image did not crop correctly, take a new photo of the front of the check if necessary.</p>\n"];
		}
        else
        {
            // back image exists?
            if (!depositModel.backImagePresent)
            {
                [strContent appendString:@"<h1>Back Image Missing:</h1>"];
                [strContent appendString:@"<ul>"];
                [strContent appendString:@"<li>Tap the Camera button to take a photograph of the back of the check.</li>"];
                [strContent appendString:@"</ul>\n"];
            }
        }
	}
	
	[strContent appendString:@"</body></html>"];
	 
    // set delegate and load html
    webViewErrors.delegate = self;
	[webViewErrors loadHTMLString:strContent baseURL:nil];
	 
	return;
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

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	webViewErrors.delegate = nil;				// clear delegate before release
}

//---------------------------------------------------------------------------------------------
// Errors Done
//---------------------------------------------------------------------------------------------

- (void) onErrorsDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
