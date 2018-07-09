//
//  DepositViewController.m
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
#import "DepositViewController.h"
#import "DepositModel.h"
#import "RegistrationViewController.h"
#import "ErrorViewController.h"
#import "DepositSubmitViewController.h"
#import "DepositHistoryViewController.h"
#import "TableView_SectionHeaderChkPhoto.h"
#import "TableViewCell_ChkPhoto.h"
#import "TableViewCell_Button.h"
#import "VIPViewUtility.h"
#import "TextChangeFormatters.h"
#import "DepositInitOperation.h"
#import "RegistrationQueryOperation.h"

// control tags
static const int kFRONT_BUTTON_TAG = 1;
static const int kBACK_BUTTON_TAG = 2;
static const int kFRONT_IMAGE_VIEW_TAG = 10;
static const int kBACK_IMAGE_VIEW_TAG = 11;

static NSString *kChkImgCellID = @"TableViewCell_CP";
static NSString *kButtonCellID = @"TableViewCell_Button";

@implementation DepositViewController

@synthesize buttonHistory;
@synthesize buttonTrash;
@synthesize buttonTerms;
@synthesize textAmount;
@synthesize buttonSubmit;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    depositModel = [DepositModel sharedInstance];						// model
    schema = [UISchema sharedInstance];                                 // schema
    
    nSectionRegistration = -1;
    nSectionFrontImage = -1;
    nSectionBackImage = -1;
    nSectionSubmit = -1;

    // show color & deposit limit settings in App Settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    bShowColor = [defaults boolForKey:kVIP_PREFERENCE_SHOW_COLOR];
    depositModel.allowDepositsExceedingLimit = [defaults boolForKey:kVIP_PREFERENCE_ALLOW_DEPOSITS_EXCEEDING_LIMIT];
    
    return (self);
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationQueryNotification:) name:kVIP_NOTIFICATION_DEPOSIT_REGISTRATION_QUERY_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDepositInitComplete:) name:kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDepositSubmitComplete:) name:kVIP_NOTIFICATION_DEPOSIT_SUBMIT_COMPLETE object:nil];
    
    //--------------------------------------------------------------------------------------------------
    // Navigation Bar
    //--------------------------------------------------------------------------------------------------
    [self setTitle:@"Deposit"];

    // History button
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,32,32)];
    [customButton addTarget:self action:@selector(onHistory:) forControlEvents:UIControlEventTouchUpInside];
    [customButton setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    self.buttonHistory = [[BadgeBarButtonItem alloc] initWithCustomUIButton:customButton];

    // Trash can button
    self.buttonTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onTrash:)];
    buttonTrash.enabled = NO;
    
    // Terms & Conditions button
    self.buttonTerms = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:depositModel.debugMode ? @selector(onDebug:) : @selector(onTerms:)];
    self.navigationItem.rightBarButtonItems = @[buttonTerms];
    
    //--------------------------------------------------------------------------------------------------
    // TableView
    //--------------------------------------------------------------------------------------------------

    [self.tableView registerClass:[TableViewCell_ChkPhoto class] forCellReuseIdentifier:kChkImgCellID];
    [self.tableView registerClass:[TableViewCell_Button class] forCellReuseIdentifier:kButtonCellID];

    // tableView delegate/datasource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 32;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.estimatedSectionFooterHeight = 0;

    // set table footer view (logo)
    self.tableView.tableFooterView = [VIPViewUtility getFooterWatermark:self.tableView];

}

//-----------------------------------------------------------------------------
// viewDidAppear
//-----------------------------------------------------------------------------

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateBarButtons];                               // refresh held for review
}

//-----------------------------------------------------------------------------
// dealloc
//-----------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

//-----------------------------------------------------------------------------
// viewWillTransitionToSize
//-----------------------------------------------------------------------------

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
         [self.tableView reloadData];                  // reload the table
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    return;
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

#pragma mark NSUserDefaultsDidChangeNotification

//-----------------------------------------------------------------------------------
// onSettingsChanged notification
//-----------------------------------------------------------------------------------

- (void) onSettingsChanged:(NSNotification *)notification
{
    // read "show color" setting in App Settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    bShowColor = [defaults boolForKey:kVIP_PREFERENCE_SHOW_COLOR];
    depositModel.allowDepositsExceedingLimit = [defaults boolForKey:kVIP_PREFERENCE_ALLOW_DEPOSITS_EXCEEDING_LIMIT];

    [self.tableView reloadData];
}

//-----------------------------------------------------------------------------
// Registration Query notification
//-----------------------------------------------------------------------------

- (void) onRegistrationQueryNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        // pop EUA if unregistered
        if (depositModel.registrationStatus == kVIP_REGSTATUS_UNREGISTERED)
            [self onTerms:self.buttonTerms];
        
        // update held for review bar button
        [self updateBarButtons];
    });
}

//-----------------------------------------------------------------------------
// Deposit init complete notification
//-----------------------------------------------------------------------------

- (void) onDepositInitComplete:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:nSectionFrontImage] withRowAnimation:UITableViewRowAnimationNone];
        
        // plug CAR amount?
        if ((depositModel.depositAmountCAR.doubleValue > 0) && (depositModel.depositAmount.doubleValue == 0))
        {
            [self.view endEditing:YES];
            depositModel.depositAmount = [NSNumber numberWithDouble:depositModel.depositAmountCAR.doubleValue];;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:nSectionSubmit]] withRowAnimation:UITableViewRowAnimationNone];
            [self onActivateSubmit];
        }
    });
}

//-----------------------------------------------------------------------------
// Deposit Submit Complete
//-----------------------------------------------------------------------------

- (void) onDepositSubmitComplete:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.tableView reloadData];
        [self onActivateSubmit];

    });
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Table View
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma mark UITableViewDelegate/UITableViewDataSource

//-----------------------------------------------------------------------------
// numberOfSectionsInTableView=2
//-----------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nSections = 0;
    nSectionRegistration = -1;
    nSectionFrontImage = -1;
    nSectionBackImage = -1;
    nSectionSubmit = -1;
    
    switch (depositModel.registrationStatus)
    {
        case kVIP_REGSTATUS_REGISTERED:						// registered - OK
            break;
        case kVIP_REGSTATUS_DISABLED:						// disabled
        case kVIP_REGSTATUS_PENDING:						// registered - not approved
        case kVIP_REGSTATUS_UNREGISTERED:					// not registered
            nSectionRegistration = nSections++;
            break;
        default:
            break;
    }
    
    nSectionFrontImage = nSections++;
    nSectionBackImage = nSections++;
    nSectionSubmit = nSections++;
    
    return (nSections);
}

//-----------------------------------------------------------------------------
// numberOfRowsInSection=2
//-----------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == nSectionRegistration)                    // registration
        return (1);
    else if (section == nSectionFrontImage)                 // front image
        return (depositModel.resultsFrontImage.count == 0 ? 1 : 2);
    else if (section == nSectionBackImage)                  // back image
        return (depositModel.resultsBackImage.count == 0 ? 1 : 2);
    return (2);                                             // submit (amount and submit button row)
}

//-----------------------------------------------------------------------------
// Section headers
//-----------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == nSectionRegistration)
        return (@"REGISTRATION");
    else if (section == nSectionFrontImage)
        return (@"FRONT IMAGE");
    else if (section == nSectionBackImage)
        return (@"BACK IMAGE");
    return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // NOTE: displaying the image dimensions in a production app isn't terribly useful!  End users don't care about this...
    TableView_SectionHeaderChkPhoto *viewHeader = [[TableView_SectionHeaderChkPhoto alloc] initWithTableView:tableView section:section];
    if (section == nSectionFrontImage)
    {
        if (depositModel.rectFront.size.width == 0)
            [viewHeader.labelValue setText:@""];
        else
            [viewHeader.labelValue setText: [NSString stringWithFormat:@"%dw x %dh", (int)depositModel.rectFront.size.width, (int)depositModel.rectFront.size.height]];
    }
    else if (section == nSectionBackImage)
    {
        if (depositModel.rectBack.size.width == 0)
            [viewHeader.labelValue setText:@""];
        else
            [viewHeader.labelValue setText: [NSString stringWithFormat:@"%dw x %dh", (int)depositModel.rectBack.size.width, (int)depositModel.rectBack.size.height]];
    }
    return (viewHeader);
}

//-----------------------------------------------------------------------------
// cellForRowAtIndexPath
//-----------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //-----------------------------------------------------------------------------------------
    // REGISTRATION STATUS
    //-----------------------------------------------------------------------------------------
    if (indexPath.section == nSectionRegistration)
    {
        UITableViewCell *cell;
        
        switch (indexPath.row)
        {
            case 0:                                     // Status
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;		// not selectable
                
                [cell.textLabel setFont:schema.fontBody];
                [cell.textLabel setTextColor:schema.colorDarkText];
                
                switch (depositModel.registrationStatus)
                {
                case kVIP_REGSTATUS_REGISTERED:						// registered - OK
                    
                    [cell.textLabel setText:@"Terms & Conditions"];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    break;
                    
                case kVIP_REGSTATUS_DISABLED:							// disabled
                    
                    [cell.textLabel setText:@"Access Disabled"];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    [cell.imageView setImage:[UIImage imageNamed:@"caution"]];
                    break;
                    
                case kVIP_REGSTATUS_PENDING:							// registered - not approved
                    
                    [cell.textLabel setText:@"Registration Pending"];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    [cell.imageView setImage:[UIImage imageNamed:@"caution"]];
                    break;
                    
                case kVIP_REGSTATUS_UNREGISTERED:						// not registered
                    
                    [cell.textLabel setText:@"Not Registered"];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    [cell.imageView setImage:[UIImage imageNamed:@"caution"]];
                    break;
                    
                default:											// unknown - error
                   
                    if ([depositModel.networkQueue hasRunningOperationOfClass:RegistrationQueryOperation.class])
                    {
                        [cell.textLabel setText:@"Checking registration status..."];
                        
                        // add UIActivityIndicatorView spinner
                        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        [spinner startAnimating];
                        cell.accessoryView = spinner;
                    }
                    
                    break;
                }
                
                break;
            }
        }
        
        return (cell);
    }
    
    //-----------------------------------------------------------------------------------------
    // IMAGE ROWS
    //-----------------------------------------------------------------------------------------
    if ((indexPath.section == nSectionFrontImage) || (indexPath.section == nSectionBackImage))
    {
        switch (indexPath.row)
        {
            case 0:                                         // IMAGE
            {
                // create a new cell
                TableViewCell_ChkPhoto *cellImage = (TableViewCell_ChkPhoto *)[tableView dequeueReusableCellWithIdentifier:kChkImgCellID];
                [cellImage setDefaults];
                
                // tag this image view to help identify front vs. back
                cellImage.thumb.tag = (indexPath.section == nSectionFrontImage ? kFRONT_IMAGE_VIEW_TAG : kBACK_IMAGE_VIEW_TAG);
                [cellImage.label setText:(indexPath.section == nSectionFrontImage ? @"Front Image" : @"Back Image")];

                // make a bit taller for extra touch surface
                UIButton *buttonCamera = [[UIButton alloc] initWithFrame:CGRectMake(0,0,44,88)];
                [buttonCamera setImage:[[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [buttonCamera setShowsTouchWhenHighlighted:YES];
                
                [buttonCamera setTag:(indexPath.section == nSectionFrontImage ? kFRONT_BUTTON_TAG : kBACK_BUTTON_TAG)];
                [buttonCamera addTarget:self action:@selector(onCameraClick:) forControlEvents:UIControlEventTouchUpInside];
                
                if (indexPath.section == nSectionFrontImage)
                {
                    if ([depositModel.networkQueue hasRunningOperationOfClass:DepositInitOperation.class])
                    {
                        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        [spinner setFrame:buttonCamera.frame];                      // make same size as buttonCamera
                        [spinner startAnimating];
                        [cellImage setAccessoryView:spinner];
                    }
                    else
                    {
                        [cellImage setAccessoryView:buttonCamera];
                    }
                    
                    if (bShowColor)
                        [cellImage.thumb setImage:depositModel.frontImageColorThumb];
                    else
                        [cellImage.thumb setImage:depositModel.frontImageThumb];
                }
                else if (indexPath.section == nSectionBackImage)
                {
                    [cellImage setAccessoryView:buttonCamera];
                    
                    if (depositModel.rectFront.size.width == 0)                     // disable back image button if no front image!
                        [buttonCamera setEnabled:NO];
                    else
                        [buttonCamera setEnabled:YES];
                    
                    if (bShowColor)
                        [cellImage.thumb setImage:depositModel.backImageColorThumb];
                    else
                        [cellImage.thumb setImage:depositModel.backImageThumb];
                }
                
                if (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED)   // disable button for unregistered users
                    [buttonCamera setEnabled:NO];
                
                [cellImage updateConstraints];
                [cellImage setNeedsLayout];
                [cellImage layoutIfNeeded];
                
                return (cellImage);
            }
                
            case 1:                                         // ERRORS
            {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell.textLabel setFont:schema.fontBody];
                [cell.textLabel setTextColor:schema.colorDarkText];
                
                BOOL bErrors = [depositModel hasError:(indexPath.section == nSectionFrontImage) ? depositModel.resultsFrontImage : depositModel.resultsBackImage];
                BOOL bWarnings = [depositModel hasWarning:(indexPath.section == nSectionFrontImage) ? depositModel.resultsFrontImage : depositModel.resultsBackImage];
                
                // set cell text
                if ((bWarnings) && (!bErrors))
                {
                    [cell.textLabel setText:@"Image Warnings"];
                    [cell.imageView setImage:[UIImage imageNamed:@"caution"]];
                }
                else if ((bWarnings) && (bErrors))
                {
                    [cell.textLabel setText:@"Image Errors/Warnings"];
                    [cell.imageView setImage:[UIImage imageNamed:@"stop"]];
                }
                else
                {
                    [cell.textLabel setText:@"Image Errors"];
                    [cell.imageView setImage:[UIImage imageNamed:@"stop"]];
                }
                
                return (cell);
            }
        }

    }

    if (indexPath.section == nSectionSubmit)
    {
        switch (indexPath.row)
        {
            case 0:                                         // Amount
            {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell.textLabel setFont:schema.fontBody];
                [cell.textLabel setTextColor:schema.colorDarkText];
                [cell.detailTextLabel setFont:schema.fontCaption2];
                [cell.detailTextLabel setTextColor:schema.colorLightGray];
                
                [cell.textLabel setText:@"Amount:"];
                
                if ((!depositModel.allowDepositsExceedingLimit) && (depositModel.depositLimit.doubleValue > 0) && (depositModel.registrationStatus == kVIP_REGSTATUS_REGISTERED))
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Deposit limit: %@",[schema.currencyFormat stringFromNumber:depositModel.depositLimit]]];
                
                // create a UITextField edit control as accessoryView
                UITextField *textFieldDepositAmount = [[UITextField alloc] initWithFrame:CGRectMake(0,0,140,44)];
                textFieldDepositAmount.delegate = self;
                textFieldDepositAmount.keyboardType = UIKeyboardTypeDecimalPad;
                textFieldDepositAmount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textFieldDepositAmount.clearsOnBeginEditing = YES;
                [textFieldDepositAmount setFont:schema.fontBodyLarge];
                textFieldDepositAmount.textColor = schema.colorValue;
                textFieldDepositAmount.adjustsFontSizeToFitWidth = YES;
                textFieldDepositAmount.minimumFontSize = 0.8f;
                textFieldDepositAmount.textAlignment = NSTextAlignmentRight;
                textFieldDepositAmount.placeholder = @" $$$$$$.¢¢";
                textFieldDepositAmount.borderStyle = UITextBorderStyleNone;
                
                // set amount
                if (depositModel.depositAmount.doubleValue > 0)
                    [textFieldDepositAmount setText:[schema.currencyFormat stringFromNumber:depositModel.depositAmount]];
                else
                    [textFieldDepositAmount setText:@""];

                [textFieldDepositAmount sizeToFit];

                // and update edit control
//                if ((!depositModel.allowDepositsExceedingLimit) && (depositModel.depositAmount.doubleValue > depositModel.depositLimit.doubleValue))
//                    textFieldDepositAmount.textColor = schema.colorWarning;
//                else
//                    textFieldDepositAmount.textColor = schema.colorValue;
                
                self.textAmount = textFieldDepositAmount;
                cell.accessoryView = textFieldDepositAmount;
                
                return (cell);
            }
            case 1:                                         // Submit button
            {
                TableViewCell_Button *cell = [[TableViewCell_Button alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonCellID];
                [cell setDefaults];
                
                self.buttonSubmit = cell.button;
                
                [cell.button setTitle:@"Submit" forState:UIControlStateNormal];
                
                __weak DepositViewController *weakSelf = self;
                [cell setDidPress:^(UIButton *sender)
                 {
                     [weakSelf onActivateSubmit];
                     [weakSelf onSubmit:sender];
                 }];
                [cell.button setTintColor:schema.colorTint];
                
                [self onActivateSubmit];
                return (cell);
            }
                
        }
        
    }
    
    return (nil);                                               // shouldn't get here!

}

//-----------------------------------------------------------------------------
// accessoryButtonTappedForRowWithIndexPath
//
// (i) button for displaying details on Registration and Errors
//-----------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == nSectionRegistration)
    {
        switch (depositModel.registrationStatus)
        {
            case kVIP_REGSTATUS_REGISTERED:						// registered - OK
            case kVIP_REGSTATUS_DISABLED:						// disabled
            case kVIP_REGSTATUS_PENDING:						// registered - not approved
            case kVIP_REGSTATUS_UNREGISTERED:					// not registered
            {
                [self onTerms:self.buttonTerms];
                break;
            }
            default:											// unknown - error
                break;
        }
    }
    
    else if ((indexPath.section == nSectionFrontImage) && (indexPath.row == 1))
    {
        [self onShowErrors:self frontOrBack:'F'];
    }
    
    else if ((indexPath.section == nSectionBackImage) && (indexPath.row == 1))
    {
        [self onShowErrors:self frontOrBack:'B'];
    }
    
    return;
}

#pragma mark CameraViewControllerDelegate

//--------------------------------------------------------------------------------------------------------
// CameraViewControllerDelegate onCameraClose
//--------------------------------------------------------------------------------------------------------

- (void) onCameraClose
{
    [self dismissViewControllerAnimated:YES completion:^(void){
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(nSectionFrontImage,2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    } ];
    return;
}

//--------------------------------------------------------------------------------------------------------
// CameraViewControllerDelegate onPictureTaken
//--------------------------------------------------------------------------------------------------------

- (void) onPictureTaken:(UIImage *)imageColor withBWImage:(UIImage *)imageBW results:(NSArray *)results isFront:(BOOL)isFront
{
    // dismiss CameraViewController
    [self dismissViewControllerAnimated:YES completion:^(void){} ];
    
    if ((imageColor == nil) || (imageBW == nil))
        return;
    
    if (isFront)
        depositModel.resultsFrontImage = [NSMutableArray arrayWithArray:results];
    else
        depositModel.resultsBackImage = [NSMutableArray arrayWithArray:results];

    // save files on background thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{

        // save the images
        if (isFront)
        {
            // if errors, we don't want the files
            if (depositModel.resultsFrontImage.count > 0)
            {
                [depositModel setFrontImage:nil];
                [depositModel setFrontImageColor:nil];
            }
            else
            {
                [depositModel setFrontImage:imageBW];
                [depositModel setFrontImageColor:imageColor];
                
                // if front image and rear image already taken, re-test for dimension mismatch on rear image
                if ([depositModel backImagePresent])
                {
                    // v7.5 ; better handling of front image re-take when back image present
                    [depositModel.resultsBackImage removeObject:@"OutOfScale"];   // remove if present
                    if (((fabs(depositModel.rectBack.size.height - depositModel.rectFront.size.height) >= 100) ||
                         (fabs(depositModel.rectBack.size.width - depositModel.rectFront.size.width) >= 80)))
                    {
                        [depositModel.resultsBackImage addObject:@"OutOfScale"];
                    }
                }
                
                [depositModel.networkQueue sendDepositInit];          // submit front image
            }
        }
        else
        {
            if (depositModel.resultsBackImage.count > 0)
            {
                [depositModel setBackImage:nil];
                [depositModel setBackImageColor:nil];
            }
            else
            {
                [depositModel setBackImage:imageBW];
                [depositModel setBackImageColor:imageColor];
            }
        }

        // UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            // v7.5, reload entire table, reloadSections doesn't work when # of rows changes
            [self.tableView reloadData];                                // reload table
            [self onActivateSubmit];
            
            // if Submit not enabled, yet we have front and back images, scroll the Submit button into view (so user can see the Amount field)
            if ((!self.buttonSubmit.enabled) && (depositModel.frontImagePresent) && (depositModel.backImagePresent))
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:nSectionSubmit] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                });
            }

        });
    });
    
    return;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// UI Handlers
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma mark UI handlers

//-----------------------------------------------------------------------------
// Camera Click
//-----------------------------------------------------------------------------

- (void) onCameraClick:(UIButton *)sender
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Camera Detected!" preferredStyle:UIAlertControllerStyleAlert];
        [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:sheet animated:YES completion:nil];
		return;
	}
    
    // check authorization status of camera
    __block AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined)               // first time use
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadCamera:sender];
                });
            }
        }];
    }
    
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
            [self loadCamera:sender];
            break;
        case AVAuthorizationStatusDenied:
        {
            NSString *strTitle = [NSString stringWithFormat:@"Give Permission for %@ to Use Your Camera",@"VIPSample"];
            UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"" message:strTitle preferredStyle:UIAlertControllerStyleAlert];
            [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [sheet addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                
            }]];
            
            [self presentViewController:sheet animated:YES completion:nil];
            
            return;
        }
        default:
            return;
    }
   
   	return;
}

//-----------------------------------------------------------------------------
// Camera Click
//-----------------------------------------------------------------------------

- (void) loadCamera:(UIButton *)sender
{
    NSString *strTitle = nil;
    
    if (sender.tag == kFRONT_BUTTON_TAG)
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_FRONT_PHOTO" value:@"Front Check Image" table:@"VIPSample"];
    else
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_BACK_PHOTO" value:@"Back Check Image" table:@"VIPSample"];

    CameraViewController *cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil delegate:self title:strTitle isFront:(sender.tag == kFRONT_BUTTON_TAG ? YES: NO)];
    if (cameraViewController != nil)
    {
        cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:cameraViewController animated:YES completion:^{
        }];
    }
    
    return;
}

//-----------------------------------------------------------------------------
// Show held for review button and other bar button items
//-----------------------------------------------------------------------------

- (void) updateBarButtons
{
    // set badge
    self.buttonHistory.badgeValue = [[NSNumber numberWithInt:depositModel.heldForReviewDepositsCount] stringValue];

    // only show T&C button if not registered
    if (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED)
    {
        self.navigationItem.rightBarButtonItems = @[ buttonTerms ];
        return;
    }
    
    // choose bar buttons to appear
    self.navigationItem.rightBarButtonItems = buttonTrash.isEnabled ? @[ buttonHistory, buttonTrash, buttonTerms ] : @[ buttonHistory, buttonTerms ];
}

#pragma mark SUbmit button

//-----------------------------------------------------------------------------
// Activate Submit Buttons
//-----------------------------------------------------------------------------

- (void) onActivateSubmit
{
    BOOL isTrashEnabled = buttonTrash.isEnabled;
    
    // Trash button
    if ((depositModel.frontImagePresent) ||
        (depositModel.backImagePresent) ||
        (depositModel.depositAmount.doubleValue != 0))
    {
        buttonTrash.enabled = YES;
    }
    else
    {
        buttonTrash.enabled = NO;
    }
    
    // change in trash can state?
    if (buttonTrash.isEnabled != isTrashEnabled)
    {
        [self updateBarButtons];
    }

    // Submit button
    if ((depositModel.frontImage == nil) ||
        (depositModel.backImage == nil) ||
        (depositModel.depositAmount.doubleValue <= 0) ||
        (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED) ||
        ([depositModel hasError:depositModel.resultsFrontImage]) ||
        ([depositModel hasError:depositModel.resultsBackImage]))
    {
        buttonSubmit.enabled = NO;
    }
    else
    {
        if (!buttonSubmit.enabled)
        {
            // enable button and auto-scroll
            buttonSubmit.enabled = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:nSectionSubmit] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
        }
    }
    return;
}

//-----------------------------------------------------------------------------
// Submit deposit
//-----------------------------------------------------------------------------

- (void) onSubmit:(id)sender
{
    // dismiss the Submit modal
    if (self.presentedViewController != nil)
        [self dismissViewControllerAnimated:YES completion:nil];
    
    // ensure we're good to go
    if (buttonSubmit.enabled == NO)
        return;

    [self.view endEditing:YES];
    
    // CAR Mismatch
    if ([self checkCARMismatch])
    {
        [self showCARMismatch:sender];
        return;
    }
 
    // Deposit limit check
    if ((!depositModel.allowDepositsExceedingLimit) && (depositModel.depositAmount.doubleValue > depositModel.depositLimit.doubleValue))
    {
        [self showDepositLimit:sender];
        return;
    }
    
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];

    if (account.MAC == nil)
    {
        [self showNoCredentials];
        return;
    }
    
    // ActionSheet messaging
    NSMutableAttributedString *strInfo;
    NSString *strMessage = [NSString stringWithFormat:@"\rTo: %@\rAmount: %@",
                            account.name,
                            [schema.currencyFormat stringFromNumber:depositModel.depositAmount]];
    
    strInfo = [[NSMutableAttributedString alloc] initWithString:@"\rTo: " attributes:@{NSFontAttributeName:schema.fontFootnote, NSForegroundColorAttributeName:schema.colorDarkText}];
    [strInfo appendAttributedString:[[NSAttributedString alloc] initWithString:account.name attributes:@{NSFontAttributeName:schema.fontFootnoteBold, NSForegroundColorAttributeName:schema.colorDarkText}]];
    
    [strInfo appendAttributedString:[[NSAttributedString alloc] initWithString:@"\rAmount: " attributes:@{NSFontAttributeName:schema.fontFootnote, NSForegroundColorAttributeName:schema.colorDarkText}]];
    [strInfo appendAttributedString:[[NSAttributedString alloc] initWithString:[schema.currencyFormat stringFromNumber:depositModel.depositAmount] attributes:@{NSFontAttributeName:schema.fontFootnoteBold, NSForegroundColorAttributeName:schema.colorDarkText}]];
    
    // present the action sheet
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"SUBMIT DEPOSIT" message:strMessage preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // push Submit View controller
        DepositSubmitViewController *depositSubmitViewController = [[DepositSubmitViewController alloc] initWithNibName:@"DepositSubmitView" bundle:nil];
        if (depositSubmitViewController != nil)
        {
            VIPNavigationController *navController = [[VIPNavigationController alloc] initWithRootViewController:depositSubmitViewController];
            [navController.navigationBar setTranslucent:NO];
            navController.preferredContentSize = depositSubmitViewController.preferredContentSize;
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
        
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [sheet setValue:strInfo forKey:@"attributedMessage"];                       // KVC to get attributed string in there
    
    sheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = sheet.popoverPresentationController;
    presentationController.sourceView = sender;
    presentationController.sourceRect = [sender frame];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.delegate = self;
    [self.navigationController presentViewController:sheet animated:YES completion:nil];
}

#pragma mark Deposit limit

//-----------------------------------------------------------------------------
// Deposit limit
//-----------------------------------------------------------------------------

- (void) showDepositLimit:(id)sender
{
    // CAR Mismatch
    NSString *strTitle = @"DEPOSIT LIMIT EXCEEDED";
    NSString *strMessage = @"Cannot submit a deposit exceeding your per deposit limit";
    NSMutableAttributedString *strInfo = [[NSMutableAttributedString alloc] initWithString:@"\rYour per deposit limit: " attributes:@{NSFontAttributeName:schema.fontFootnote, NSForegroundColorAttributeName:schema.colorDarkText}];
    [strInfo appendAttributedString:[[NSAttributedString alloc] initWithString:[schema.currencyFormat stringFromNumber:depositModel.depositLimit] attributes:@{NSFontAttributeName:schema.fontFootnoteBold, NSForegroundColorAttributeName:schema.colorDarkText}]];
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:strTitle message:strMessage preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    
    [sheet setValue:strInfo forKey:@"attributedMessage"];                       // KVC to get attributed string in there
    
    sheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = sheet.popoverPresentationController;
    presentationController.sourceView = self.textAmount;
    presentationController.sourceRect = CGRectMake(0,0,self.textAmount.frame.size.width, self.textAmount.frame.size.height);
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.delegate = self;
    
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark No Credentials

- (void) showNoCredentials
{
    // present the alert
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Error" message:@"No account credentials" preferredStyle:UIAlertControllerStyleAlert];
    [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark CAR Mismatch

//-----------------------------------------------------------------------------
// CAR Mismatch
//-----------------------------------------------------------------------------

- (BOOL) checkCARMismatch
{
    // CAR Mismatch
    if ((depositModel.depositAmount.doubleValue > 0) && (depositModel.depositAmountCAR.doubleValue > 0) && (depositModel.depositAmount.doubleValue != depositModel.depositAmountCAR.doubleValue))
        return (YES);
    return (NO);
}

- (void) showCARMismatch:(id)sender
{
    // CAR Mismatch
    NSString *strTitle = [NSString stringWithFormat:@"Amount on check: %@", [schema.currencyFormat stringFromNumber:depositModel.depositAmountCAR]];
    
    NSMutableAttributedString *strInfo = [[NSMutableAttributedString alloc] initWithString:@"\rAmount on check: " attributes:@{NSFontAttributeName:schema.fontFootnote, NSForegroundColorAttributeName:schema.colorDarkText}];
    [strInfo appendAttributedString:[[NSAttributedString alloc] initWithString:[schema.currencyFormat stringFromNumber:depositModel.depositAmountCAR] attributes:@{NSFontAttributeName:schema.fontFootnoteBold, NSForegroundColorAttributeName:schema.colorDarkText}]];
 
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"AMOUNT MISMATCH" message:strTitle preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        depositModel.depositAmountCAR = [NSNumber numberWithDouble:0];          // clear CAR amount
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Fix" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        depositModel.depositAmount = [NSNumber numberWithDouble:depositModel.depositAmountCAR.doubleValue];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:nSectionSubmit]] withRowAnimation:UITableViewRowAnimationNone];
        
    }]];
    
    [sheet setValue:strInfo forKey:@"attributedMessage"];                       // KVC to get attributed string in there

    sheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = sheet.popoverPresentationController;
    presentationController.sourceView = self.textAmount;
    presentationController.sourceRect = CGRectMake(0,0,self.textAmount.frame.size.width, self.textAmount.frame.size.height);
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.delegate = self;
    
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark Utility functions

//-----------------------------------------------------------------------------
// Show Errors
//-----------------------------------------------------------------------------

- (IBAction) onShowErrors:(id)sender frontOrBack:(char)forb
{
    ErrorViewController *errorsViewController = [[ErrorViewController alloc] initWithNibName:@"ErrorView" bundle:nil forb:forb];
    if (errorsViewController != nil)
    {
        VIPNavigationController *nav = [[VIPNavigationController alloc] initWithRootViewController:errorsViewController];
        [nav.navigationBar setTranslucent:NO];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

//-----------------------------------------------------------------------------
// History
//-----------------------------------------------------------------------------

- (void) onHistory:(id)sender
{
    DepositHistoryViewController *sdvc = [[DepositHistoryViewController alloc] initWithNibName:@"DepositHistoryViewController" bundle:nil];
    if (sdvc != nil)
    {
        VIPNavigationController *nav = [[VIPNavigationController alloc] initWithRootViewController:sdvc];
        [nav.navigationBar setTranslucent:NO];
        nav.preferredContentSize = sdvc.preferredContentSize;
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.navigationController presentViewController:nav animated:YES completion:^{
        }];
    }
}

#pragma mark Trash Can

//-----------------------------------------------------------------------------
// Delete deposit
//-----------------------------------------------------------------------------

- (IBAction) onTrash:(UIBarButtonItem *)sender
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:@"DELETE DEPOSIT?" preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [depositModel clearDeposit];
        [self.tableView reloadData];
        
    }]];
    
    sheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = sheet.popoverPresentationController;
    presentationController.barButtonItem = sender;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.delegate = self;
    [self.navigationController presentViewController:sheet animated:YES completion:nil];
}

#pragma mark Terms & Conditions

//-----------------------------------------------------------------------------
// Terms and Conditions
//-----------------------------------------------------------------------------

- (IBAction) onTerms:(UIBarButtonItem *)sender
{
    if (self.presentedViewController != nil)
    {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];
    if (account.MAC == nil)
    {
        [self showNoCredentials];
        return;
    }
    
    RegistrationViewController *registrationViewController = [[RegistrationViewController alloc] initWithNibName:@"RegistrationView" bundle:nil];
    if (registrationViewController != nil)
    {
        VIPNavigationController *navController = [[VIPNavigationController alloc] initWithRootViewController:registrationViewController];
        [navController.navigationBar setTranslucent:NO];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark Debug

//-----------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------

- (IBAction) onDebug:(UIBarButtonItem *)sender
{
    if (self.presentedViewController != nil)
    {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    if (depositModel.debugMode)
    {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:depositModel.debugString preferredStyle:UIAlertControllerStyleActionSheet];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        
        sheet.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *presentationController = sheet.popoverPresentationController;
        presentationController.barButtonItem = sender;
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        presentationController.delegate = self;
        [self.navigationController presentViewController:sheet animated:YES completion:nil];
        
        return;
    }
}

#pragma mark Keyboard continued

//-----------------------------------------------------------------------------
// Keyboard Dismiss
//-----------------------------------------------------------------------------

- (void) onDismissKeyboard:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark Text Field Delegates

//-----------------------------------------------------------------------------
// UITextFieldDelegate
//-----------------------------------------------------------------------------

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // cancel previous auto-close
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onDismissKeyboard:) object:textField];
    
    [self onActivateSubmit];
    
    BOOL result = TextChangeFormatters.formatterAmount(textField, range, string);
    [self performSelector:@selector(onDismissKeyboard:) withObject:textField afterDelay:6.0];
    return (result);
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return (YES);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self performSelector:@selector(onDismissKeyboard:) withObject:textField afterDelay:8.0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onDismissKeyboard:) object:textField];
    
    NSString *text = [textField text];
    
    // perhaps non-US locale, try a localized formatted
    NSNumber *number = [[NSNumberFormatter new] numberFromString:text];
    if (number == nil)
    {
        number = [NSNumber numberWithDouble:[text doubleValue]];
        if (number == nil)
            number = [NSNumber numberWithInt:0];
    }
    text = [schema.currencyFormat stringFromNumber:number];
    [textField setText:text];

    // save to model
    if ([textField.text length] > 0)
        depositModel.depositAmount = [NSNumber numberWithDouble:number.doubleValue];
    else
        depositModel.depositAmount = [NSNumber numberWithDouble:0];
  
    [textField sizeToFit];

    [self onActivateSubmit];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return (YES);
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
