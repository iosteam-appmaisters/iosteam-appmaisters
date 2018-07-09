//
//  DepositSubmitViewController.m
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

#import "DepositSubmitViewController.h"
#import "MultiPartForm.h"
#import "ErrorViewController.h"
#import "TableView_SectionHeader.h"
#import "TableView_SectionFooter.h"
#import "VIPViewUtility.h"
#import "DepositCommitOperation.h"

@implementation DepositSubmitViewController

@synthesize progressView;
@synthesize tableViewResults;
@synthesize arrayResultCategories;
@synthesize timerProgress;
@synthesize resultsGeneral;
@synthesize resultsFrontImage;
@synthesize resultsBackImage;

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

    self.resultsGeneral = [[NSMutableArray alloc] initWithCapacity:5];
    self.resultsFrontImage = [[NSMutableArray alloc] initWithCapacity:5];
    self.resultsBackImage = [[NSMutableArray alloc] initWithCapacity:5];
    
    // front image already processed???
    if (depositModel.ssoKey != nil)
        [resultsFrontImage addObject:@"NoError"];
    else
        [resultsFrontImage addObject:@"Pending"];

    [resultsGeneral addObject:@"Pending"];
    [resultsBackImage addObject:@"Pending"];

    // a faux progress timer
	self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];

    // send Deposit Commit on queue
    [depositModel.networkQueue sendDepositCommit];
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
    if (depositModel.networkQueue.operationCount > 1)
    {
        // slower progress, cap at 80%
        progressView.progress += 0.025;
        if (progressView.progress >= 0.80)
            progressView.progress = 0.80;
    }
    else
    {
        progressView.progress += 0.05;
    }

	if (progressView.progress > 0.90)				// kill timer if at 90%, we're stuck...
        progressView.progress = 0.90;
}

//-----------------------------------------------------------------------------
// Timer Invalidate
//-----------------------------------------------------------------------------

- (void) timerInvalidate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timerProgress.isValid)
            [timerProgress invalidate];
        [progressView setProgress:1.0f];            // progress 100%
        self.navigationItem.rightBarButtonItem.enabled = YES;
    });
}

//-----------------------------------------------------------------------------
// Done Button
//-----------------------------------------------------------------------------

- (IBAction) onSubmitDone:(id)sender
{
    if (bSuccess)
        [depositModel clearDeposit];
    
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
    self.resultsGeneral = [NSMutableArray arrayWithArray:depositModel.resultsGeneral];
    self.resultsFrontImage = [NSMutableArray arrayWithArray:depositModel.resultsFrontImage];
   
    // no errors?
    if (resultsFrontImage.count == 0)
    {
        [resultsGeneral addObject:@"Pending"];              // still pending
        [resultsFrontImage addObject:@"NoError"];           // front image is good
    }
    else                                                    // we have errors!
    {
        // if we have an error, we need to update the results and let the user back out
        if ([depositModel hasError:depositModel.resultsFrontImage])
        {
            [self.resultsGeneral addObject:@"IQFrontError"]; // add a general error
            [self.resultsBackImage removeAllObjects];       // clear back
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self timerInvalidate];                     // invalidate timer on main thread
            });
        }
    }

    // main thread update UI
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [tableViewResults reloadData];                      // reload table
    });
}

- (void) onDepositCommitComplete:(NSNotification *)notification
{
    self.resultsGeneral = [NSMutableArray arrayWithArray:depositModel.resultsGeneral];
    self.resultsBackImage = [NSMutableArray arrayWithArray:depositModel.resultsBackImage];

    // no image errors?
    if (resultsBackImage.count == 0)
    {
        [resultsBackImage addObject:@"NoError"];
    }
    else
    {
        if ([depositModel hasError:depositModel.resultsBackImage])
            [self.resultsGeneral addObject:@"IQBackError"];
    }

    // flag success/failure
    if (depositModel.depositId != nil)                              // a DepositID returned indicates success!
        bSuccess = true;
    else
        bSuccess = false;

    // main thread update UI
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (bSuccess)
            self.title = @"Processed";
        else
            self.title = @"Not Processed";

        [self timerInvalidate];
        [tableViewResults reloadData];
        
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
            if (bSuccess)
                return (2);
            return (resultsGeneral.count);
		case 1:
            return (resultsFrontImage.count);
		case 2:
            return (resultsBackImage.count);
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
    if ((section == 0) && (bSuccess))
    {
        NSString *strFootnote = depositModel.depositDispositionMessage;
        
        // calculate size of rendered text to determine height of view
        CGSize szMaxLabel = CGSizeMake (tableView.frame.size.width - 30,999);
        CGRect rectLabelSize = [strFootnote boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: schema.fontFootnote} context:nil];
        return (rectLabelSize.size.height + schema.fontFootnote.lineHeight);
    }
    return (0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ((section == 0) && (bSuccess))
    {
        NSAttributedString *strFootnote = [[NSAttributedString alloc] initWithString:depositModel.depositDispositionMessage];
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
            
            if (bSuccess)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;        // not selectable
                cell.accessoryType = UITableViewCellAccessoryCheckmark;         // checkmark
                cell.accessoryView = nil;
                switch (indexPath.row)
                {
                    case 0:                                                     // Deposit Id
                        [cell.textLabel setText:[NSString stringWithFormat:@"Deposit Reference #%lli",depositModel.depositId.longLongValue]];
                        break;
                    case 1:                                                     // Deposit Disposition
                        [cell.textLabel setText:depositModel.depositDisposition];
                        break;
                }
                return (cell);
            }
            
            key = [resultsGeneral objectAtIndex:indexPath.row];
            value = [depositModel.dictMasterGeneral valueForKey:key];
            accessoryType = [depositModel.dictMasterGeneral styleForKey:key];
 			break;
            
		case 1:

            key = [resultsFrontImage objectAtIndex:indexPath.row];
            value = [depositModel.dictMasterFrontImage valueForKey:key];
            accessoryType = [depositModel.dictMasterFrontImage styleForKey:key];
            break;
            
		case 2:
  
            key = [resultsBackImage objectAtIndex:indexPath.row];
            value = [depositModel.dictMasterBackImage valueForKey:key];
            accessoryType = [depositModel.dictMasterBackImage styleForKey:key];
 			break;
            
		default:
            return (nil);                                                   // shouldn't get here!
	}
	
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", value]];
	
    cell.accessoryType = accessoryType;
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
    if (depositModel.networkQueue.operationCount > 0)
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
	NSString *key;
	
	switch (indexPath.section)
	{
		case 0:
			key = [resultsGeneral objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterGeneral helpForKey:key];
            break;
		case 1:
            key = [resultsFrontImage objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterFrontImage helpForKey:key];
			break;
		case 2:
            key = [resultsBackImage objectAtIndex:indexPath.row];
			value = [depositModel.dictMasterBackImage helpForKey:key];
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
        [self.navigationController pushViewController:errorsViewController animated:YES];
	}
}

@end
