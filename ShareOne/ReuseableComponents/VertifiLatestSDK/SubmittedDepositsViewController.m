//
//  SubmittedDepositsViewController.m
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

#import "DepositViewController.h"
#import "SubmittedDepositsViewController.h"
#import "FormPostHandler.h"
#import "MultiPartForm.h"
#import "SubmittedDepositReportViewController.h"
#import "TableView_SectionHeader.h"
#import "TableView_SectionFooter.h"
#import "TableViewCell_ImgLblSubtitleValue.h"
#import "VIPViewUtility.h"
#import "XmlSimpleParser.h"

static NSString *kDepositCellID = @"TableViewCell_ILSV";

@implementation SubmittedDepositsViewController

// Properties
@synthesize tableDeposits;
@synthesize submittedDeposits;
@synthesize submittedDeposit;
@synthesize xmlValue;

// Methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil)
	{
        // get Model and Schema objects
        depositModel = [DepositModel sharedInstance];
        schema = [UISchema sharedInstance];

        self.title = @"Review";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

	// custom Back button
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
	
    // Done button
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = buttonDone;

    // UI
    [self.tableDeposits registerClass:[TableViewCell_ImgLblSubtitleValue class] forCellReuseIdentifier:kDepositCellID];

    self.tableDeposits.estimatedSectionHeaderHeight = 32;
    self.tableDeposits.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableDeposits.estimatedRowHeight = 44.0f;
    self.tableDeposits.rowHeight = UITableViewAutomaticDimension;

	tableDeposits.delegate = self;
	tableDeposits.dataSource = self;
    
    // set table footer view (watermark)
    self.tableDeposits.tableFooterView = [VIPViewUtility getFooterWatermark:self.tableDeposits];

	[self getSubmittedDeposits];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[tableDeposits flashScrollIndicators];
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

#pragma mark Notifications

//-----------------------------------------------------------------------------
// onFontSizeChanged notification
//-----------------------------------------------------------------------------

- (void) onFontSizeChanged:(NSNotification *)notification
{
    [self.tableDeposits reloadData];
}

#pragma mark Get Submitted Deposits list from server

- (void) getSubmittedDeposits
{
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];
    
	// perform server call
	if ((account.MAC != nil))
	{
        
        FormPostHandler *postHandler = [[FormPostHandler alloc] init];
        NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_HeldForReviewQuery"]];

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
		
        // Post the message
        [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
        {
             
             if (success)
             {
                 NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
                 if (xmlParser != nil)
                 {
                     // parse the XML
                     [xmlParser setDelegate:self];
                     if ([xmlParser parse])
                     {
                     }
                 }
                 
                 // update UI on main thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [tableDeposits reloadData];
                 });
             }
             else
             {
                 NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
                 
             }
        }];
	}
}

#pragma mark delete deposit

- (void) deleteDeposit:(NSInteger)idx
{
    SubmittedDeposit *deposit = [self.submittedDeposits objectAtIndex:idx];
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];

    // perform server call
    if ((account.MAC != nil))
    {
        
        FormPostHandler *postHandler = [[FormPostHandler alloc] init];
        NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_HeldForReviewDeleteDeposit"]];
        
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
        [form addFormField:@"deposit_id" withStringData:deposit.deposit_ID];

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
                     // Success?  Update model objects
                     NSString *strValue = (NSString *)[parser.dictElements valueForKey:@"Deleted"];
                     if ((strValue != nil) && ([strValue longLongValue] == [deposit.deposit_ID longLongValue]))
                     {
                         [self.submittedDeposits removeObjectAtIndex:idx];
                         depositModel.submittedDeposits--;
                     }
                 }
                 
                 // update UI on main thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [tableDeposits reloadData];
                 });
             }
             else
             {
                 NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
             }
        }];
    }
}


#pragma mark -
#pragma mark NSXMLParser delegate

//----------------------------------------------------------------------------------------------------------------
// Parser delegate methods
//----------------------------------------------------------------------------------------------------------------

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.submittedDeposits = [NSMutableArray arrayWithCapacity:10];
	self.xmlValue = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict 
{
	// Deposits
	if ( [elementName isEqualToString:@"Response"]) 
	{
		// clear array
		[submittedDeposits removeAllObjects];
		
		depositModel.submittedDeposits = 0;                         // reset counter
	}
	
	// Deposit
	if ( [elementName isEqualToString:@"Deposit"]) 
	{
		self.submittedDeposit = [[SubmittedDeposit alloc] init];	// create SubmittedDeposit object
		[self.submittedDeposits addObject:submittedDeposit];		// add to array

		depositModel.submittedDeposits++;							// increment counter
	}
	
	[xmlValue setString:@""];
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
	if ((string != nil) && (string.length > 0))
	{
		[xmlValue appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
	}	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if ((xmlValue == nil) || (xmlValue.length <= 0))
		return;

	NSString *s = [NSString stringWithString:xmlValue];
	
	if ([elementName isEqualToString:@"Deposit_ID"]) 
		self.submittedDeposit.deposit_ID = s;
	else if ([elementName isEqualToString:@"Release_Timestamp_UTC"]) 
	{
		// sent as time interval since 1/1/1970, convert to local time
		NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:[s doubleValue]];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"MM/dd/yyyy h:mm:ss a";
		self.submittedDeposit.release_Timestamp = [dateFormatter stringFromDate:localDate];
	}
	else if ([elementName isEqualToString:@"Amount"]) 
		self.submittedDeposit.amount = [NSNumber numberWithDouble:[s doubleValue]];
	
	else if ([elementName isEqualToString:@"Error"]) 
	{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:s preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
	}
	
	[xmlValue setString:@""];
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
	if (self.submittedDeposits == nil)
		return (1);
	return (self.submittedDeposits.count);
}

//-----------------------------------------------------------------------------
// header title for Section
//
//-----------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (@"Deposits Held for Review");
}

//-----------------------------------------------------------------------------
// header View
//
//-----------------------------------------------------------------------------

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ([[TableView_SectionHeader alloc] initWithTableView:tableView section:section canWrap:NO]);
}

//-----------------------------------------------------------------------------
// cell for Row in Section
//
// Customize the appearance of table view cells.
//
//-----------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	SubmittedDeposit *deposit = [self.submittedDeposits objectAtIndex:indexPath.row];
	if (deposit != nil)
	{
        TableViewCell_ImgLblSubtitleValue *cell = (TableViewCell_ImgLblSubtitleValue *)[tableView dequeueReusableCellWithIdentifier:kDepositCellID];
        [cell setDefaults];
        
		[cell.label setText:[NSString stringWithFormat:@"Deposit #%@",deposit.deposit_ID]];
		[cell.labelSubtitle setText:[NSString stringWithFormat:@"Submitted %@",deposit.release_Timestamp]];
		[cell.labelValue setText:[schema.currencyFormat stringFromNumber:deposit.amount]];
        
		[cell.imageView setImage:[UIImage imageNamed:@"pdf"]];

        return (cell);
	}
	else 
	{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
		
		cell.accessoryType = UITableViewCellAccessoryNone;

		[cell.textLabel setFont:schema.fontBody];
		[cell.textLabel setText:@"Loading..."];
		[cell.textLabel setTextColor:schema.colorDarkText];
		
		// add UIActivityIndicatorView spinner
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[spinner startAnimating];
		cell.accessoryView = spinner;
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
	
	// create SubmittedDepositReportViewController and push it
	SubmittedDepositReportViewController *sdrvc = [[SubmittedDepositReportViewController alloc] initWithNibName:@"SubmittedDepositReportViewController" bundle:nil];
	if (sdrvc != nil)
	{
		sdrvc.submittedDeposit = [self.submittedDeposits objectAtIndex:indexPath.row];			// set deposit
		[self.navigationController pushViewController:sdrvc animated:YES];
	}
	return;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (YES);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Handle a row delete
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteDeposit:indexPath.row];
    }
}

#pragma mark Actions

//-----------------------------------------------------------------------------
// Done
//-----------------------------------------------------------------------------

- (IBAction) onDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
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
