//
//  DepositHistoryViewController.h
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

#import "DepositViewController.h"
#import "DepositHistoryViewController.h"
#import "DepositReportViewController.h"
#import "TableView_SectionHeader.h"
#import "TableView_SectionFooter.h"
#import "TableViewCell_ImgLblSubtitleValue.h"
#import "VIPViewUtility.h"
#import "HistoryAuditQueryOperation.h"

static NSString *kDepositCellID = @"TableViewCell_ILSV";

@implementation DepositHistoryViewController

// Properties
@synthesize tableDeposits;

// Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
	{
        // get Model and Schema objects
        depositModel = [DepositModel sharedInstance];
        schema = [UISchema sharedInstance];

        self.title = @"Deposit History";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyAuditQueryComplete:) name:kVIP_NOTIFICATION_HISTORY_AUDIT_QUERY_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heldForReviewDeleteComplete:) name:kVIP_NOTIFICATION_HELD_FOR_REVIEW_DELETE_COMPLETE object:nil];

	// custom Back button
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
	
    // Done button
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = buttonDone;

    // UI
    [self.tableDeposits registerClass:[TableViewCell_ImgLblSubtitleValue class] forCellReuseIdentifier:kDepositCellID];

    self.tableDeposits.estimatedSectionHeaderHeight = 0;
    self.tableDeposits.sectionHeaderHeight = 0;
    self.tableDeposits.estimatedRowHeight = 44.0f;
    self.tableDeposits.rowHeight = UITableViewAutomaticDimension;

	tableDeposits.delegate = self;
	tableDeposits.dataSource = self;
    
    // set table footer view (watermark)
    self.tableDeposits.tableFooterView = [VIPViewUtility getFooterWatermark:self.tableDeposits];

    // refresh control
    self.tableDeposits.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableDeposits.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableDeposits.refreshControl setTintColor:schema.colorTint];
    [self.tableDeposits.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to refresh"
                                                                            attributes:@{NSFontAttributeName : schema.fontCaption2, NSForegroundColorAttributeName : schema.colorLightGray}]];
    
    // send the query
	[depositModel.networkQueue sendHistoryAuditQuery];
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

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    [self.tableDeposits flashScrollIndicators];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Popover content size

- (CGSize) preferredContentSize
{
    // set content size
    CGRect rectScreen = [[UIScreen mainScreen] bounds];             // get screen bounds
    return (CGSizeMake(MIN(rectScreen.size.width * 0.95f, 480), MAX(rectScreen.size.height * 0.95f, 480)));
}

#pragma mark Actions

//-----------------------------------------------------------------------------
// Done
//-----------------------------------------------------------------------------

- (IBAction) onDone:(id)sender
{
    [depositModel clearHeldForReviewDeposits];                      // clear model
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//-----------------------------------------------------------------------------
// Refresh
//-----------------------------------------------------------------------------

- (IBAction) onRefresh:(id)sender
{
    [depositModel.networkQueue sendHistoryAuditQuery];
}

#pragma mark Notifications

//-----------------------------------------------------------------------------
// onFontSizeChanged notification
//-----------------------------------------------------------------------------

- (void) onFontSizeChanged:(NSNotification *)notification
{
    [self.tableDeposits reloadData];
}

//-----------------------------------------------------------------------------
// heldForReviewQueryComplete notification
//-----------------------------------------------------------------------------

- (void) historyAuditQueryComplete:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableDeposits.refreshControl endRefreshing];
        [self.tableDeposits reloadData];
    });
}

//-----------------------------------------------------------------------------
// heldForReviewDeleteComplete notification
//-----------------------------------------------------------------------------

- (void) heldForReviewDeleteComplete:(NSNotification *)notification
{
    // the object is a dictionary with {kVIP_KEY_DELETED_ROW:{row#}}
    NSNumber *row = [notification.object valueForKey:kVIP_KEY_DELETED_ROW];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        // row # is valid?  The model is already updated so has one less row than table
        if ((row.intValue >= 0) && (row.intValue <= depositModel.depositHistory.count))
        {
            // deleted last record?
            if (depositModel.depositHistory.count == 0)
                [tableDeposits reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row.intValue inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [tableDeposits deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row.intValue inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to delete deposit" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

#pragma mark TableViewDelegate

//-----------------------------------------------------------------------------
// number of Sections
//-----------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return (1);
}

//-----------------------------------------------------------------------------
// number of Rows in Section
//-----------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Loading or Empty
	if ((depositModel.depositHistory == nil) || (depositModel.depositHistory.count == 0))
		return (1);

    // # of elements in array
	return (depositModel.depositHistory.count);
}

//-----------------------------------------------------------------------------
// section header View
//
//-----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return (0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ([[UIView alloc] initWithFrame:CGRectZero]);
}

//-----------------------------------------------------------------------------
// cell for Row in Section
//
// Customize the appearance of table view cells.
//
//-----------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (((depositModel.depositHistory == nil) || (depositModel.depositHistory.count == 0)) || (indexPath.row >= depositModel.depositHistory.count))
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [cell.textLabel setFont:schema.fontBody];
        [cell.textLabel setTextColor:schema.colorDarkText];

        if ([depositModel.networkQueue hasRunningOperationOfClass:HistoryAuditQueryOperation.class])
        {
            [cell.textLabel setText:@"Loading..."];
            
            // add UIActivityIndicatorView spinner
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            cell.accessoryView = spinner;

        }
        else
        {
            [cell.textLabel setText:@"No deposits"];
            cell.accessoryView = nil;
        }
        
        return (cell);
    }
    else
    {
        TableViewCell_ImgLblSubtitleValue *cell = (TableViewCell_ImgLblSubtitleValue *)[tableView dequeueReusableCellWithIdentifier:kDepositCellID];
        [cell setDefaults];

        DepositHistory *deposit = [depositModel.depositHistory objectAtIndex:indexPath.row];

		[cell.label setText:[NSString stringWithFormat:@"%@ #%@",deposit.depositStatus, deposit.depositId]];
		[cell.labelSubtitle setText:[NSString stringWithFormat:@"Submitted %@",deposit.releaseTimestamp]];
		[cell.labelValue setText:[schema.currencyFormat stringFromNumber:deposit.amount]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_DELETED])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"delete"]];
            [cell.imageView setTintColor:schema.colorWarning];
        }
        else if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_ACCEPTED])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"accept"]];
            [cell.imageView setTintColor:schema.colorTint];
        }
        else if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_HELD_FOR_REVIEW])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"review"]];
            [cell.imageView setTintColor:schema.colorTint];
        }

        [cell updateConstraints];
        return (cell);
	}

    return (nil);
}

//-----------------------------------------------------------------------------
// Row selected
//
//-----------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if ((depositModel.depositHistory == nil) || (depositModel.depositHistory.count == 0))
        return;
    
    DepositHistory *deposit = [depositModel.depositHistory objectAtIndex:indexPath.row];
    
    // Deleted deposit?
    if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_DELETED])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Deposit Deleted" message:deposit.notes preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
	// else Held for Review or Accepted, create DepositReportViewController and push it
	DepositReportViewController *sdrvc = [[DepositReportViewController alloc] initWithNibName:@"DepositReportViewController" bundle:nil];
	if (sdrvc != nil)
	{
        sdrvc.deposit = deposit;                        // set deposit
		[self.navigationController pushViewController:sdrvc animated:YES];
	}
	return;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((depositModel.depositHistory == nil) || (depositModel.depositHistory.count == 0))
        return (NO);

    // can only delete Held for Review deposits
    DepositHistory *deposit = [depositModel.depositHistory objectAtIndex:indexPath.row];
    if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_HELD_FOR_REVIEW])
        return (YES);
    return (NO);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Handle a row delete
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DepositHistory *deposit = [depositModel.depositHistory objectAtIndex:indexPath.row];
        [depositModel.networkQueue sendHeldForReviewDelete:deposit];
    }
}

#pragma mark UIPopoverPresentationControllerDelegate

//---------------------------------------------------------------------------------------------------
// popoverPresentationControllerShouldDismissPopover
//---------------------------------------------------------------------------------------------------

- (BOOL) popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return (YES);
}

#pragma mark UIAdaptivePresentationControllerDelegate

//---------------------------------------------------------------------------------------------------
// adaptivePresentationStyleForPresentationController
//---------------------------------------------------------------------------------------------------

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return (UIModalPresentationNone);               // force popover
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return (UIModalPresentationNone);               // force popover
}

@end
