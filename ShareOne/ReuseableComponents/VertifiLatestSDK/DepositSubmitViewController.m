//
//  DepositSubmitViewController.m
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

#import "DepositSubmitViewController.h"
#import "MultiPartForm.h"
#import "XmlSimpleParser.h"
#import "ErrorViewController.h"
#import "TableView_SectionHeader.h"
#import "TableView_SectionFooter.h"
#import "VIPViewUtility.h"

@implementation DepositSubmitViewController

@synthesize progressView;
@synthesize tableViewResults;
@synthesize arrayResultCategories;
@synthesize timerProgress;
@synthesize dictResultsGeneral;
@synthesize dictResultsFrontImage;
@synthesize dictResultsBackImage;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
	{
        // get model and schema objects
        depositModel = [DepositModel sharedInstance];
        schema = [UISchema sharedInstance];

        self.title = @"Processing Deposit";
        bSuccess = false;
		
		self.arrayResultCategories = [NSArray arrayWithObjects:@"Deposit Information", @"Front Image", @"Back Image", nil];
    }
    return self;
}

// Implement viewDidLoad to launch thread to post deposit
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDepositInitComplete:) name:kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDepositCommitComplete:) name:kVIP_NOTIFICATION_DEPOSIT_COMMIT_COMPLETE object:nil];
    
	// display a Done button in the navigation bar for this view controller.
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onSubmitDone:)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.hidesBackButton = YES;
    [[self.navigationController interactivePopGestureRecognizer] setEnabled:NO];

    // table settings
    self.tableViewResults.estimatedSectionHeaderHeight = 32.0f;
    self.tableViewResults.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableViewResults.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableViewResults.estimatedRowHeight = 44.0f;
    self.tableViewResults.rowHeight = UITableViewAutomaticDimension;
    
    // set table footer view (logo)
    self.tableViewResults.tableFooterView = [VIPViewUtility getFooterWatermark:tableViewResults];

    self.dictResultsGeneral = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.dictResultsFrontImage = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.dictResultsBackImage = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    // front image already processed???
    if (depositModel.ssoKey != nil)
        [dictResultsFrontImage setValue:@"No Errors" forKey:@"NoError"];
    else
        [dictResultsFrontImage setValue:@"Pending" forKey:@"Pending"];

    [dictResultsGeneral setValue:@"Pending" forKey:@"Pending"];
    [dictResultsBackImage setValue:@"Pending" forKey:@"Pending"];

    // a faux progress timer
	self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];

    [depositModel.depositSubmitQueue onSubmitCommit];
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
	tableViewResults.delegate = nil;
	tableViewResults.dataSource = nil;
}

#pragma mark Popover content size

- (CGSize) preferredContentSize
{
    // set content size
    CGRect rectScreen = [[UIScreen mainScreen] bounds];             // get screen bounds
    return (CGSizeMake(MIN(rectScreen.size.width * 0.95f, 480), MIN(rectScreen.size.height * 0.95f, 540)));
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Actions
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Timer Fire
//-----------------------------------------------------------------------------

- (void)onTimer:(NSTimer*)timer
{
    // multiple operations?
    if (depositModel.depositSubmitQueue.operationQueue.operationCount > 1)
    {
        // slower progress, cap at 80%
        progressView.progress += 0.01;
        if (progressView.progress >= 0.80)
            progressView.progress = 0.80;
    }
    else
    {
        progressView.progress += 0.02;
    }

	if (progressView.progress > 0.90)				// kill timer if at 90%, we're stuck...
		[timer invalidate];
}

//-----------------------------------------------------------------------------
// Done Button
//-----------------------------------------------------------------------------

- (IBAction) onSubmitDone:(id)sender
{
    // send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_SUBMIT_COMPLETE object:nil];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];

	return;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Notifications
//-----------------------------------------------------------------------------

- (void) onDepositInitComplete:(NSNotification *)notification
{
    self.dictResultsFrontImage = [NSMutableDictionary dictionaryWithDictionary:depositModel.dictResultsFrontImage];
   
    // errors?
    if (dictResultsFrontImage.count == 0)
        [dictResultsFrontImage setValue:@"No Errors" forKey:@"NoError"];
    else
    {
        BOOL bErrors = NO;
        BOOL bWarnings = NO;
        for (id key in dictResultsFrontImage)
        {
            if (![key hasSuffix:@"Usability"])							// doesn't end in "Usability"
                bErrors = YES;
            else
                bWarnings = YES;
        }
        
        if (bErrors)
            [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:@"IQFrontError"] forKey:@"IQFrontError"];
        else if (bWarnings)
            [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:@"IQFrontWarning"] forKey:@"IQFrontWarning"];
        
        // cancel the commit operation
        [depositModel.depositSubmitQueue onSubmitCancel];
        [self onDepositCommitComplete:notification];
        return;
    }

    // main thread update UI
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [tableViewResults reloadData];
    });
}

- (void) onDepositCommitComplete:(NSNotification *)notification
{
    self.dictResultsGeneral = [NSMutableDictionary dictionaryWithDictionary:depositModel.dictResultsGeneral];
    self.dictResultsBackImage = [NSMutableDictionary dictionaryWithDictionary:depositModel.dictResultsBackImage];

    // no image errors?
    if ([dictResultsBackImage count] == 0)
		[dictResultsBackImage setValue:@"No Errors" forKey:@"NoError"];
	
	// image errors but no General info?
	if ([dictResultsGeneral count] == 0)
        [dictResultsGeneral setValue:@"Unknown error, please re-submit the deposit" forKey:@"SystemError"];

    // flag success/failure
    if ([dictResultsGeneral valueForKey:@"DepositID"] != nil)
    {
        bSuccess = true;
        [depositModel clearDeposit];
    }
    else
    {
        bSuccess = false;
    }

    // main thread update UI
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (bSuccess)
            self.title = @"Processed";
        else
            self.title = @"Not Processed";

        if (timerProgress.isValid)
            [timerProgress invalidate];
        [progressView setProgress:1.0f];							// progress 100%
        [tableViewResults reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    });
    
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Table View methods
//-----------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger n = (NSInteger)[arrayResultCategories count];
	return (n);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
            return (dictResultsGeneral.count);
		case 1:
            return (dictResultsFrontImage.count);
		case 2:
            return (dictResultsBackImage.count);
	}
	return (0);
}


//-----------------------------------------------------------------------------
// header View
//
//-----------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [arrayResultCategories objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ([[TableView_SectionHeader alloc] initWithTableView:tableView section:section canWrap:NO]);
}

//-----------------------------------------------------------------------------
// footer View
//
//-----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    if ((section == 0) && (progressView.progress >= 1.0) && (bSuccess))
    {
        NSString *strFootnote = [depositModel.dictMasterGeneral helpForKey:@"DepositDisposition"];
        
        // calculate size of rendered text to determine height of view
        CGSize szMaxLabel = CGSizeMake (tableView.frame.size.width - 30,999);
        CGRect rectLabelSize = [strFootnote boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: schema.fontBody} context:nil];
        return (rectLabelSize.size.height + schema.fontBody.lineHeight);
    }
    return (0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ((section == 0) && (progressView.progress >= 1.0) && (bSuccess))
    {
        NSAttributedString *strFootnote = [[NSAttributedString alloc] initWithString:[depositModel.dictMasterGeneral helpForKey:@"DepositDisposition"]];
        return ([[TableView_SectionFooter alloc] initWithTableView:tableView string:strFootnote]);
    }
    
    return (nil);
}

//-----------------------------------------------------------------------------
// display cell
//
// Customize the table view cells.
//
//-----------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value;
	NSString *key;
	NSUInteger accessoryType = UITableViewCellAccessoryNone;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellDepositResults"];
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDepositResults"];
        [cell.textLabel setFont:schema.fontBody];
        [cell.textLabel setTextColor:schema.colorDarkText];
	}
	
	switch (indexPath.section)
	{
		case 0:
            
            key = [[dictResultsGeneral allKeys] objectAtIndex:indexPath.row];
            value = [[dictResultsGeneral allValues] objectAtIndex:indexPath.row];
            accessoryType = [depositModel.dictMasterGeneral styleForKey:key];
 			break;
            
		case 1:
            
            key = [[dictResultsFrontImage allKeys] objectAtIndex:indexPath.row];
            value = [[dictResultsFrontImage allValues] objectAtIndex:indexPath.row];
            accessoryType = [depositModel.dictMasterFrontImage styleForKey:key];
            break;
            
		case 2:
            
            key = [[dictResultsBackImage allKeys] objectAtIndex:indexPath.row];
            value = [[dictResultsBackImage allValues] objectAtIndex:indexPath.row];
            accessoryType = [depositModel.dictMasterBackImage styleForKey:key];
 			break;
            
		default:
			//key = @"NoError";
			value = @"";
			accessoryType = UITableViewCellAccessoryNone;
			break;
	}
	
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", value]];
	
    switch (accessoryType)
	{
		case UITableViewCellAccessoryNone:
		case UITableViewCellAccessoryCheckmark:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;        // not selectable
            [cell.textLabel setFont:schema.fontBody];
			break;
            
        case UITableViewCellAccessoryDisclosureIndicator:
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;     // selectable
            [cell.textLabel setFont:schema.fontBody];
			break;
            
		case UITableViewCellAccessoryDetailDisclosureButton:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;        // not selectable
            [cell.textLabel setFont:schema.fontBody];
			break;
	}
	cell.accessoryType = accessoryType;
    
    // for Pending spinner
    if (([value caseInsensitiveCompare:@"Pending"] == NSOrderedSame) && (cell.accessoryType == UITableViewCellAccessoryNone))
    {
        // add UIActivityIndicatorView spinner
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        cell.accessoryView = spinner;
    }
    else
        cell.accessoryView = nil;

 	return (cell);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // operations in progress?
    if (depositModel.depositSubmitQueue.operationQueue.operationCount > 0)
		return (nil);
	else
		return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[tableView deselectRowAtIndexPath:indexPath	animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	NSString *value = @"";
	NSString *title = @"";
	NSString *key;
	
	switch (indexPath.section)
	{
		case 0:
			key = [[dictResultsGeneral allKeys] objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterGeneral helpForKey:key];
			title = [depositModel.dictMasterGeneral valueForKey:key];
            break;
		case 1:
            key = [[dictResultsFrontImage allKeys] objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterFrontImage helpForKey:key];
			title = [depositModel.dictMasterBackImage valueForKey:key];
			break;
		case 2:
            key = [[dictResultsBackImage allKeys] objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterBackImage helpForKey:key];
			title = [depositModel.dictMasterBackImage valueForKey:key];
			break;
	}
	
	
	if (![value isEqualToString:@""])
	{
		[self onShowErrors:self];
	}
}

//-----------------------------------------------------------------------------
// Show Errors
//-----------------------------------------------------------------------------

- (IBAction) onShowErrors:(id)sender
{
 	ErrorViewController *errorsViewController = [[ErrorViewController alloc] initWithNibName:@"ErrorView" bundle:nil forb:'A'];
	if (errorsViewController != nil)
	{
		errorsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:errorsViewController animated:YES completion:nil];
	}
}

@end
