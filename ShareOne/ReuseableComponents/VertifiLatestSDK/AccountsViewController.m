//
//  AccountsViewController.m
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

#import "AccountsViewController.h"
#import "VertifiImageProcessing.h"
#import "DepositViewController.h"
#import "TableView_SectionHeader.h"
#import "TableViewCell_LblSubtitle.h"
#import "FormPostHandler.h"
#import "DataAccountsDelegate.h"
#import "VIPViewUtility.h"

static NSString *kLblSubtitleCellID = @"TableViewCell_LblSubtitle";

@interface AccountsViewController ()

@end

@implementation AccountsViewController

//--------------------------------------------------------------------------------------------------
// initWithNibName
//
// The designated initializer. Override to perform setup that is required before the view is loaded.
//--------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    depositModel = [DepositModel sharedInstance];						// get global
    return (self);
}

//--------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //--------------------------------------------------------------------------------------------------
    // Notifications
    //--------------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    //--------------------------------------------------------------------------------------------------
    // Navigation Bar
    //--------------------------------------------------------------------------------------------------
    [self setTitle:[NSString stringWithFormat:@"VIP Sample v%@",[VertifiImageProcessing getVersion]]];
    
    // back button
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Accounts" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    // settings button
    UIBarButtonItem *buttonSettings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(onSettings:)];
    self.navigationItem.leftBarButtonItem = buttonSettings;

    // refresh button
    UIBarButtonItem *buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefreshAccounts:)];
    self.navigationItem.rightBarButtonItem = buttonRefresh;
    
    //--------------------------------------------------------------------------------------------------
    // TableView
    //--------------------------------------------------------------------------------------------------
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 32;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerClass:[TableViewCell_LblSubtitle class] forCellReuseIdentifier:kLblSubtitleCellID];

    // set table footer view (logo)
    self.tableView.tableFooterView = [VIPViewUtility getFooterWatermark:self.tableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Notifications
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma mark UIContentSizeCategoryDidChangeNotification

//-----------------------------------------------------------------------------------
// onFontSizeChanged notification
//-----------------------------------------------------------------------------------

- (void) onFontSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Button Handlers
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// onSettings
//
// launches app settings
//
//-----------------------------------------------------------------------------

- (void) onSettings:(UIBarButtonItem *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

//-----------------------------------------------------------------------------
// onRefreshAccounts
//
// retrieves a list of deposit accounts with proper credentials for Vertifi
//
// routing
// requestor
// session
// timestamp
// member
// account
// accounttype
//-----------------------------------------------------------------------------

- (void) onRefreshAccounts:(UIBarButtonItem *)sender
{
    __block UIBarButtonItem *buttonRefresh = sender;
    
    buttonRefresh.enabled = NO;                     // disable the button
    
    // post the request to the configured URL
    FormPostHandler *postHandler = [[FormPostHandler alloc] init];
    NSURL *postURL = [NSURL URLWithString:[depositModel.dictSettings valueForKey:@"URL_AccountEnumeration"]];
    
    NSLog(@"postURL : %@",postURL.absoluteString);
    MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
    
    // password in App Settings, use the Settings app to configure a password to send to your handler
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    NSString *password = [defaults stringForKey:kVIP_PREFERENCE_PASSWORD];

    NSLog(@"Password : %@",password);

    // fields
    [form addFormField:@"Password" withStringData:password];

    // Post the message
    [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
    {
        if (success)
        {
            DataAccountsDelegate *dad = [[DataAccountsDelegate alloc] init];
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            if (xmlParser != nil)
            {
                // parse the XML
                [xmlParser setDelegate:dad];
                [xmlParser parse];
                depositModel.depositAccountSelected = -1;    // clear selected account
                [self.tableView reloadData];
            }
        }
        else
        {
             NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        }
        
        buttonRefresh.enabled = YES;                // enable the button
    }];
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Table View
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma mark UITableViewDelegate/UITableViewDataSource

//-----------------------------------------------------------------------------
// numberOfSectionsInTableView
//-----------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (1);                                     // accounts
}

//-----------------------------------------------------------------------------
// numberOfRowsInSection=2
//-----------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (depositModel.depositAccounts.count);
}

//-----------------------------------------------------------------------------
// Section headers
//-----------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (@"ACCOUNTS");
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableView_SectionHeader *viewHeader = [[TableView_SectionHeader alloc] initWithTableView:tableView section:section canWrap:NO];
    return (viewHeader);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepositAccount *account = [depositModel.depositAccounts objectAtIndex:indexPath.row];
    
    TableViewCell_LblSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:kLblSubtitleCellID];
    [cell.label setText:account.name];
    [cell.labelSubtitle setText:account.account];
    [cell setDefaults];
    
    [cell updateConstraints];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return (cell);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DepositAccount *accountBefore = (depositModel.depositAccountSelected >= 0) ? (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected] : nil;
    depositModel.depositAccountSelected = indexPath.row;                   // set selected account
    DepositAccount *accountSelected = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];

    // perform a Registration Query when an account is selected, but only when:
    
    // * this is a first-time use
    // * the selected account is for a different <member> than the previously selected account
    // * the selected account is not in a registered status (force a requery in case the status has changed)
    if ( (accountBefore == nil) ||                                                                          // First time use?
         ((accountBefore != nil) && (![accountBefore.member isEqualToString:accountSelected.member])) ||    // different member?
         (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED) )                                   // not Registered?, should refresh
    {
        // perform a registration query
        [depositModel registrationQuery];
    }

    // push the DepositViewController
    DepositViewController *depositViewController = [[DepositViewController alloc] initWithNibName:@"DepositViewController" bundle:nil];
    [self.navigationController pushViewController:depositViewController animated:YES];
}

@end
