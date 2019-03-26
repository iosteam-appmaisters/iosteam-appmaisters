 //
//  LoginViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "LoginViewController.h"
#import "QuickBalancesViewController.h"
#import "AppServiceModel.h"
#import "ShareOneUtility.h"
#import "User.h"
#import "SharedUser.h"
#import "LoaderServices.h"
#import "MemberDevices.h"
#import "QuickBalances.h"
#import "CashDeposit.h"
#import "VertifiObject.h"
#import "PinResetController.h"
#import "PasswordChangeController.h"
#import "UserNamecontroller.h"
#import "IQKeyboardManager.h"
#import "Location.h"
#import "WeblinksController.h"
#import "SettingsViewController.h"
#import "HomeViewController.h"
#import "UIColor+HexColor.h"
#import "ClientSettingsObject.h"

#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "UtilitiesHelper.h"
#import "DeviceUtil.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface LoginViewController () <YALContextMenuTableViewDelegate,UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSMutableArray *menuTitles;
@property (nonatomic, strong) NSMutableArray *menuIcons;

@property (weak, nonatomic) IBOutlet CustomButton *addMenuIcon;
@property (weak, nonatomic) IBOutlet UIButton *addMenuBulletIcon;
    
@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMetxtBtn;
@property (weak, nonatomic) IBOutlet UIButton *quickBalanceBtn;
@property (weak, nonatomic) IBOutlet UIImageView *quickBalanceArrowIcon;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *branchLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *applyLoanButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;


@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@property(nonatomic,strong) UITextField * currentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *loginBG;


- (void)updateDataByDefaultValues;

- (void)startApplication;

- (void)getSignInWithUser:(User *)user;

-(IBAction)pinResetButtonClicked:(id)sender;



@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    
    [self loadLocalCacheOnView];
    
    [self updateDataByDefaultValues];
    
    self.navigationController.navigationBarHidden = YES;
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:NORMAL_LOGOUT];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *systemLanguage = [UtilitiesHelper getSystemLanguageCode];
    [[NSUserDefaults standardUserDefaults]setValue:systemLanguage forKey:CURRENT_LANG];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self initiateMenuOptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askAutoLoginOnEnteringBackGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackgroundFromLogin) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    _loginBG.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [_loginBG addGestureRecognizer:tap];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _userFingerprintBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rememberMeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rememberMetxtBtn.titleLabel.numberOfLines = 1;
    _rememberMetxtBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rememberMetxtBtn.titleLabel.lineBreakMode = NSLineBreakByClipping;
    _forgotPasswordBtn.titleLabel.numberOfLines = 1;
    _forgotPasswordBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _forgotPasswordBtn.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_passwordTxt setText:@""];
    [self.loadingView setHidden:TRUE];
}

-(void)dismissKeyboard {
    if (_currentTextField == _userIDTxt){
        [_userIDTxt resignFirstResponder];
    }
    else if (_currentTextField == _passwordTxt){
        [_passwordTxt resignFirstResponder];
    }
}

-(void)askAutoLoginOnEnteringBackGround{
    
    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
    NSLog(@"askAutoLoginOnEnteringBackGround");
    [self updateDataByDefaultValues];
}

-(void)appGoingToBackgroundFromLogin{
    NSLog(@"appGoingToBackgroundFromLogin");
    [[ShareOneUtility shareUtitlities] cancelTimer];
    
}

-(void)loadLocalCacheOnView{
    
    ClientSettingsObject  *config = [Configuration getClientSettingsContent];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_QB_SETTINGS]){
        [[NSUserDefaults standardUserDefaults] setValue:config.quickviewdefaultsetting forKey:DEFAULT_QB_SETTINGS];
    }
    
    if(![config.enablequickview boolValue]){
        [_quickBalanceArrowIcon setHidden:![config.quickviewdefaultsetting boolValue]];
        [_quickBalanceBtn setHidden:![config.quickviewdefaultsetting boolValue]];
    }else{
        if ([[NSUserDefaults standardUserDefaults] valueForKey:QUICK_BAL_SETTINGS]) {
            [_quickBalanceArrowIcon setHidden:![ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
            [_quickBalanceBtn setHidden:![ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
        }else{
            [_quickBalanceArrowIcon setHidden:![config.quickviewdefaultsetting boolValue]];
            [_quickBalanceBtn setHidden:![config.quickviewdefaultsetting boolValue]];
        }
        
        bool previousVal = [[NSUserDefaults standardUserDefaults]boolForKey:DEFAULT_QB_SETTINGS];
        
        if (previousVal != [config.quickviewdefaultsetting boolValue]){
            [ShareOneUtility saveSettingsWithStatus:[config.quickviewdefaultsetting boolValue] AndKey:QUICK_BAL_SETTINGS];
            [_quickBalanceArrowIcon setHidden:![config.quickviewdefaultsetting boolValue]];
            [_quickBalanceBtn setHidden:![config.quickviewdefaultsetting boolValue]];
        }
    }
    
    [_rememberMeBtn setSelected:[ShareOneUtility isUserRemembered]];
    [_rememberMeSwitch setOn:[ShareOneUtility isUserRemembered]];
    [_userFingerprintBtn setSelected:[ShareOneUtility isTouchIDEnabled]];
    if([ShareOneUtility isUserRemembered]){
        User *user = [ShareOneUtility getUserObject];
        [_userIDTxt setText:user.UserName];
    }
    else{
        [_userIDTxt setText:@""];
        [_passwordTxt setText:@""];
    }

    _passwordTxt.returnKeyType = UIReturnKeyGo;
}


-(void)updateDataByDefaultValues{
    
    [self loadLocalCacheOnView];
    
    if([ShareOneUtility getUserObject] && ![[SharedUser sharedManager] skipTouchIDForJustLogOut]){
        
        __weak LoginViewController *weakSelf = self;

        if(_isComingAfterPressedOpenUrlButton){
            _isComingAfterPressedOpenUrlButton= FALSE;
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Please login again with your new credentials" title:@"" delegate:weakSelf];
        }
        else{
            
            if([[SharedUser sharedManager] isLaunchFirstTime])
            {
                // if is coming after calling didFinishLaunchingWithOptions
                
                if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
                    
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                    [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
                        
                        if(success){
                            
                            [ShareOneUtility showProgressOnLoginViewForReAuthentication:weakSelf.view];
                            [ShareOneUtility removeCacheControllerName];

                            User *user = [ShareOneUtility getUserObject];
                            [weakSelf.userIDTxt setText:user.UserName];
                            [weakSelf.passwordTxt setText:user.Password];
                            [self loginButtonClicked:nil];
                        }
                    }];
                    
                    
                }
                else{
                    NSLog(@"isLaunchFirstTime Touch off");
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                }
            }
            else{
                
                // if it is coming from Background
                
                // Remove last session if it is still exist
                if([ShareOneUtility isTerminated]){
                    

                    [ShareOneUtility setTerminateState:FALSE];
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                    [self applyConditionsForSessionValidation];

                }
                else{
                    // if coming from background when touch id is off
                    [self applyConditionsForSessionValidation];
                }
            }
            
            [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
        }
    }

    
    // trick : set flag when user not saved and app lauch first time
    if([[SharedUser sharedManager] isLaunchFirstTime]){
        [[SharedUser sharedManager] setIsLaunchFirstTime:FALSE];
    }

}


-(void)applyConditionsForSessionValidation{
    
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS] && ![[NSUserDefaults standardUserDefaults]boolForKey:RESTRICT_TOUCH_ID]){
            [self showTouchID];
        return;
    }
    // If comes from Dashboard Screen
    if([[SharedUser sharedManager] isLogingOutFromHome]){
        
        [self validateSessionForTouchID_OffSession];
        [[SharedUser sharedManager] setIsLogingOutFromHome:FALSE];
    }
    
}

-(void)validateSessionForTouchID_OffSession{
    
    __weak LoginViewController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];


    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];

    _isComingAfterAuthenticatingFromTouchID= TRUE;

    // check whether session is available or not. If its not 24 hours from NSConfig updates
    [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
        NSLog(@"keepAlive from validateSessionForTouchID_OffSession");
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if(sucess){
            [weakSelf startApplication];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];

}

-(void)reAuthenticateLoginWithDelay{
    
    __weak LoginViewController *weakSelf = self;

    [ShareOneUtility showProgressOnLoginViewForReAuthentication:weakSelf.view];
    
    User *user = [ShareOneUtility getUserObject];
    [_userIDTxt setText:user.UserName];
    [_passwordTxt setText:user.Password];
    [self loginButtonClicked:nil];

}
-(void)showTouchID{
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:TECHNICAL_LOGOUT] && ![[NSUserDefaults standardUserDefaults]boolForKey:TEMP_DISABLE_TOUCH_ID]){

    __weak LoginViewController *weakSelf = self;
    
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
        
        [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
        
        [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
            
            if(success){
                
                weakSelf.isComingAfterAuthenticatingFromTouchID= TRUE;
                // check whether session is available or not
                [ShareOneUtility showProgressViewOnView:weakSelf.view];

                [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
                    [ShareOneUtility hideProgressViewOnView:weakSelf.view];

                    NSLog(@"keepAlive from showTouchID");
                    if(sucess){
                        [weakSelf startApplication];
                    }
                    else{
                        // if session not validated
                        [self performSelector:@selector(reAuthenticateLoginWithDelay) withObject:nil afterDelay:0.2];
                    }
                    
                } failureBlock:^(NSError *error) {
                    
                }];
            }
        }];
    }
    }
    else {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:TECHNICAL_LOGOUT];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:TEMP_DISABLE_TOUCH_ID];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    NSLog(@"loginButtonClicked");

    [_passwordTxt resignFirstResponder];
    [_userIDTxt resignFirstResponder];
    [self moveViewDown];
    __weak LoginViewController *weakSelf = self;
    /*
     **  Check if Touch ID is enabled than verify touch first if its verified than call login service
     **
     */
    
    
    // Validation is only for user who clicked button manually.
    if(sender){
        
        if([_userIDTxt.text length]<=0 || [_passwordTxt.text length]<=0){
            
            [[ShareOneUtility shareUtitlities] showToastWithMessage:@"Username or password can not be empty" title:@"Error" delegate:weakSelf];
            return;
        }
    }
    
    __block User *savedUser = [ShareOneUtility getUserObject];
    
    
    // Get value from text feilds if user object is not locally saved or user did not remember hisself.
    if(![ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS])

    {
        savedUser = [[User alloc] init];
        savedUser.UserName=_userIDTxt.text;
        savedUser.Password=_passwordTxt.text;

    }
    
    else if(![savedUser.UserName isEqualToString:_userIDTxt.text]){
        savedUser = [[User alloc] init];
        savedUser.UserName=_userIDTxt.text;
        savedUser.Password=_passwordTxt.text;
    }
    
    if(sender){
        
        savedUser = [[User alloc] init];
        savedUser.UserName=_userIDTxt.text;
        savedUser.Password=_passwordTxt.text;
        [ShareOneUtility removeCacheControllerName];
        [ShareOneUtility showProgressViewOnView:weakSelf.view];

        if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]) {
            //commited override if user selected yes in settings. just for Emery FCU
//           [[NSUserDefaults standardUserDefaults]setBool:YES forKey:OVERRIDE_TOUCH_ID];
//           [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
    }
    [self getSignInWithUser:savedUser];
}



- (void)getSignInWithUser:(User *)local_user{
    
    __weak LoginViewController *weakSelf = self;

    NSLog(@"username : %@  password: %@",local_user.UserName,local_user.Password);
    
    
    NSString *deviceName = [NSString stringWithFormat:@"%@ (%@)",
                            [DeviceUtil hardwareString], [[UIDevice currentDevice] systemVersion]];
    
    NSDictionary *memberAnalytics = @{@"AbsoluteUri": [Configuration getSSOBaseUrl],
                                      @"IsMobile":@YES,
                                      @"IsNsMobile":@YES,
                                      @"UserHostAddress":[UtilitiesHelper GetOurIpAddress],
                                      @"DeviceName":deviceName};
    
    NSDictionary * loginParams = @{@"account":local_user.UserName,
                                   @"password":local_user.Password,
                                   @"MemberAnalytics":memberAnalytics};
    
    [User getUserWithParam:loginParams delegate:weakSelf completionBlock:^(User *user) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if([user isKindOfClass:[User class]]){
            
            if(weakSelf.objPinResetController){
                [weakSelf.objPinResetController dismissViewControllerAnimated:NO completion:nil];
                weakSelf.objPinResetController=nil;
            }
            
            // if user has any requirment like PinChange or ChangeAccountName process it before continuing.
                if(user.Requirements){
                    for (NSString* currentString in user.Requirements)
                    {
                        NSLog(@"%@", currentString);
                        
                        if([currentString isEqualToString:CHANGE_PIN]){
                            [weakSelf addPasswordChangeController:user withURL:KPIN_CHANGE];
                            break;
                        }
                        else if([currentString isEqualToString:CHANGE_ACCOUNT_USER_NAME]){
                            [weakSelf addPasswordChangeController:user withURL:KACCOUNT_NAME_CHANGE];
                            break;
                        }
                        else if([currentString isEqualToString:SIGN_UP]){
                            [weakSelf addPasswordChangeController:user withURL:KSIGN_UP_CHANGE];
                            break;
                        }
                        else{
                            NSLog(@"No user Requirement value is matching.");
                        }
                    }
                    
                }
            
            else{
                // Go though to thee application
                //asi flow
                [weakSelf.loadingView setHidden:FALSE];
                [weakSelf checkToSendDeviceToken];
            }
        }
        else if([user isKindOfClass:[NSString class]]){
            
            NSString *errorString = (NSString *)user;
            
            NSString *errorCodeString = [ShareOneUtility parseCustomErrorObject:errorString forKey:@"code"];
            NSString *errorMessage = [ShareOneUtility parseCustomErrorObject:errorString forKey:@"text"];

            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:errorMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     int errorCode = [errorCodeString intValue];
                                     if(errorCode ==PASSWORD_EXPIRED_ERROR_CODE){
                                         [weakSelf adPasswordExpireController];
                                     }

                                     
                                 }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];

            
        }
        else if (!user){
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:[Configuration getMaintenanceVerbiage] title:@"" delegate:self];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)checkToSendDeviceToken {
    
    __weak LoginViewController *weakSelf = self;
    
    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        [ShareOneUtility getUUID];
        NSDictionary * response = (NSDictionary*)user;
        
        [MemberDevices iterateMemberDevices:response completionBlock:^(BOOL status, MemberDevices * memberDevice){
            
            if (!status){
                
                ClientSettingsObject  *config = [Configuration getClientSettingsContent];
                if ([config.allownotifications boolValue]) {
                 
                    if([ShareOneUtility getSettingsWithKey:PUSH_NOTIF_SETTINGS]) {
                        [self startLoadingServices:YES];
                    }
                    else {
                        [self startLoadingServices:NO];
                    }
                    
                }
                else {
                    [self startLoadingServices:NO];
                }
                
            }
            else {
                NSLog(@"%@",memberDevice.Id.stringValue);
                 [weakSelf startApplication];
            }
            
            
        } failureBlock:^(NSError * error){
            NSLog(@"%@",[error localizedDescription]);
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}


-(void)startLoadingServices:(BOOL) shouldSendDeviceToken{
    
    __weak LoginViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [[[SharedUser sharedManager] userObject]Contextid],@"ContextID",
                                 [ShareOneUtility getUUID],@"Fingerprint",
                                 PROVIDER_TYPE_VALUE,@"ProviderType",
                                 @"ios",@"DeviceType",
                                 authArray,@"Authorizations", nil];
    
    if (shouldSendDeviceToken){
        [dic setObject:[ShareOneUtility getDeviceNotifToken] forKey:@"DeviceToken"];
    }
    
    [MemberDevices postMemberDevices:[dic copy]
                             message:@""
                            delegate:weakSelf completionBlock:^(NSObject *user) {
        
        
        [weakSelf startApplication];
        
    } failureBlock:^(NSError *error) {
        [weakSelf.loadingView setHidden:TRUE];
    }];
}

- (void)startApplication{
    
    UIViewController *controllerToPush =nil;
    
    NSDictionary *dict = [ShareOneUtility getMenuItemForTouchIDAuthentication];
    
    NSString *contrlollerName = [dict valueForKey:CONTROLLER_NAME];
    NSString *webUrl = [dict valueForKey:WEB_URL];
    
    NSString *navigationTitle = [[dict valueForKey:SUB_CAT_CONTROLLER_TITLE] capitalizedString];
    
    NSString *webViewController = WEB_VIEWCONTROLLER_ID;
    
    if(webUrl){
        HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:webViewController];
        objHomeViewController.url= webUrl;
        controllerToPush=objHomeViewController;
        [self checkVersionUpdate];
    }
    else{
        //If webUrl is empty or nil load Native UI Screen
        UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
        objUIViewController.navigationItem.title=[ShareOneUtility getNavBarTitle: navigationTitle];
        controllerToPush = objUIViewController;
    }
    [self.navigationController pushViewController:controllerToPush animated:YES];
    
}

-(void)checkVersionUpdate{
    
    NSDictionary *getAfterLoginVersionNoDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AFTER_LOGIN_VERSION_NUMBER];
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *getAfterLoginVersionNo = getAfterLoginVersionNoDic[@"Version"];
    
    if ([getAfterLoginVersionNo compare:currentVersion options:NSNumericSearch] == NSOrderedDescending && getAfterLoginVersionNoDic[@"Date"]) {
        
        [[UtilitiesHelper shareUtitlities] showMessageWithOptions:getAfterLoginVersionNoDic[@"Prompt"] title:@"" rightBtnTitle:@"Upgrade" leftBtnTitle:@"Continue" completion:^(bool success){
            if (success) {
                NSLog(@"Contiune Pressed");
            }
            else {
                NSLog(@"Upgrade Pressed");
                NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
        }];
        
    }
}

-(void)showAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}



-(void)startLoadingServicesFromChangePassword:(User *)user{
    
    [[SharedUser sharedManager] setUserObject:user];
    [ShareOneUtility changeToExistingUser:user];
    [ShareOneUtility saveUserObject:user];
    
    [self.loadingView setHidden:FALSE];
//    [self startLoadingServices];

}

-(void)addControllerToChangeUserName:(User *)user{
 
    UserNamecontroller *objUserNamecontroller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([UserNamecontroller class])];
    objUserNamecontroller.user=user;
    objUserNamecontroller.loginDelegate=self;
    [self presentViewController:objUserNamecontroller animated:YES completion:nil];
}

-(void)addPasswordChangeController:(User *)user withURL:(NSString*)withEndUrl{
    
    user.isTouchIDOpen=FALSE;
    
    [[SharedUser sharedManager] setUserObject:user];
    [ShareOneUtility changeToExistingUser:user];
    [ShareOneUtility saveUserObject:user];

    PasswordChangeController *objPasswordChangeController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PasswordChangeController class])];
    objPasswordChangeController.loginDelegate=self;
    objPasswordChangeController.user=user;
    objPasswordChangeController.withEndURL = withEndUrl;
    [self presentViewController:objPasswordChangeController animated:YES completion:nil];

}






- (IBAction)forgotPasswordButtonClicked:(id)sender {
}

- (IBAction)rememberMeButtonClicked:(id)sender {
    
    UISwitch *switchObj = (UISwitch *)sender;
    [ShareOneUtility setUserRememberedStatusWithBool:switchObj.isOn];

}

/*- (IBAction)fingerprintButtonClicked:(id)sender {
    
    __weak LoginViewController *weakSelf = self;

    [ShareOneUtility isTouchIDAvailableWithDelegate:weakSelf completionBlock:^(BOOL success) {
        
        if(success){
            UIButton *btnCast = (UIButton *)sender;
            [btnCast setSelected:!btnCast.isSelected];
            [ShareOneUtility setTouhIDStatusWithBool:btnCast.isSelected];
        }
    }];
}

- (IBAction)scanTouchID:(id)sender{
    
     __weak LoginViewController *weakSelf = self;
    [[UtilitiesHelper shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
        if(success){
            NSLog(@"Verification Success!");
        }else{
            NSLog(@"Unable to Verify");
        }
    }];

}*/


- (IBAction)openUrlButtonClicked:(id)sender{

}

- (IBAction)quickBalanceButtonClicked:(id)sender
{
    QuickBalancesViewController* objQuickBalancesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuickBalancesViewController"];
    [self presentViewController:objQuickBalancesViewController animated:YES completion:nil];
}

-(IBAction)pinResetButtonClicked:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if(btn.tag==111){
        [self openForgotPasswordInWebView:YES];
        return;
    }
    else{
        [self openForgotPasswordInWebView:NO];
        return;
    }
}

-(void)openForgotPasswordInWebView:(BOOL)isUsername {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSString * connectingURL = [Configuration getClientSettingsContent].forgotpassword;
    if (isUsername){
        connectingURL =[Configuration getClientSettingsContent].forgotusername;
    }
    WeblinksController *objWeblinksController  = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([WeblinksController class])];
    objWeblinksController.navTitle = [ShareOneUtility getNavBarTitle:isUsername ? @"Forgot Username" : @"Forgot Password"];
    if (connectingURL != nil){
        NSString * urlString = [[Configuration getClientSettingsContent].basewebviewurl stringByAppendingString:connectingURL];
        objWeblinksController.webLink= urlString;
        NSLog(@"Forgot Password URL: %@",urlString);
    }
    else {
        return;
    }
    
    [self presentViewController:objWeblinksController animated:YES completion:nil];
}

-(void)moveViewUp{
    
    float value =0.0;
    if(APPC_IS_IPAD){
        value=-80.0;
    }
    else{
        value=-30.0;
    }
        
    if(_loginViewConstraintY.constant<=value)
        if(!APPC_IS_IPAD)
            _loginViewConstraintY.constant=-140;
}

-(void)moveViewDown{
    float value =0.0;
    if(APPC_IS_IPAD){
        value=-80.0;
    }
    else{
        value=-30.0;
    }

    if(_loginViewConstraintY.constant>=-140)
        if(!APPC_IS_IPAD)
            _loginViewConstraintY.constant=value;
}



-(void)adjustTextFeildPositionForTextFeild:(UITextField *)textField{
    if([textField isEqual:_passwordTxt]){
        [textField resignFirstResponder];
        [self moveViewDown];
    }
    else{
        [textField resignFirstResponder];
        [_passwordTxt becomeFirstResponder];
    }

}
- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)adPasswordExpireController{
    
    PasswordChangeController *objPasswordChangeController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PasswordChangeController class])];
    objPasswordChangeController.loginDelegate=self;
    objPasswordChangeController.isComingFromPasswordExpire=TRUE;
    [self presentViewController:objPasswordChangeController animated:YES completion:nil];

}

#pragma mark UITextFeildDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self adjustTextFeildPositionForTextFeild:textField];
    
    if (textField == _passwordTxt){
        [self loginButtonClicked:[UIButton buttonWithType:UIButtonTypeCustom]];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self adjustTextFeildPositionForTextFeild:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self moveViewUp];
    return YES;
}

/*#pragma mark - Context Menu

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.contextMenuTableView updateAlongsideRotation];
}*/

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
    
}

#pragma mark - IBAction
- (IBAction)infoButtonTapped:(UIButton *)sender {

    _addMenuIcon.hidden = YES;
    _addMenuBulletIcon.hidden = YES;
    
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.02;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Left;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromBottomToTop;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsZero animated:YES];

}


#pragma mark - Local methods

#define kJoinTheCreditUnion @"Join The Credit Union"
#define kBranchLocation @"Branch Locations"
#define kPrivacyPolicy @"Privacy Policy"
#define kApplyForALoan @"Apply For A Loan"
#define kContact @"Contact Us"

- (void)initiateMenuOptions {
    
    _menuTitles = [NSMutableArray array];
    [_menuTitles addObject:@"Close"];
    
    _menuIcons = [NSMutableArray array];
    [_menuIcons addObject:[UIImage imageNamed:@"cross_image"]];
    
    ClientSettingsObject *objClientSettingsObject = [Configuration getClientSettingsContent];
    if (objClientSettingsObject.contactculink.length > 0){
        [_menuTitles addObject:kContact];
        [_menuIcons addObject:[UIImage imageNamed:@"contact"]];
    }
    if (objClientSettingsObject.applyloanlink.length > 0){
        [_menuTitles addObject:kApplyForALoan];
        [_menuIcons addObject:[UIImage imageNamed:@"apply_for_loan"]];
    }
    if (objClientSettingsObject.privacylink.length > 0){
        [_menuTitles addObject:kPrivacyPolicy];
        [_menuIcons addObject:[UIImage imageNamed:@"privacy_policy"]];
    }
    if (objClientSettingsObject.branchlocationlink.length > 0){
        [_menuTitles addObject:kBranchLocation];
        [_menuIcons addObject:[UIImage imageNamed:@"branch_location"]];
    }
    if (objClientSettingsObject.joinculink.length > 0){
        [_menuTitles addObject:kJoinTheCreditUnion];
        [_menuIcons addObject:[UIImage imageNamed:@"join_credit_union"]];
    }
  
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %ld", (long)indexPath.row);
    _addMenuIcon.hidden = NO;
    _addMenuBulletIcon.hidden = NO;
    if (indexPath.row > 0){
        [self openLinks: [ShareOneUtility getNavBarTitle: self.menuTitles[indexPath.row]]];
    }
}

-(void)openLinks:(NSString*)menuTitle {

    ClientSettingsObject *objClientSettingsObject = [Configuration getClientSettingsContent];
    
    NSString *urlString = nil;
    
    NSString * menuHeading = menuTitle;
    if (![ShareOneUtility shouldUseProductionEnviroment]){
       menuHeading = [menuTitle stringByReplacingOccurrencesOfString:@"PreProd-" withString:@""];
    }
    
    if([menuHeading isEqualToString:kJoinTheCreditUnion]){
        urlString=objClientSettingsObject.joinculink;
    }
    else if ([menuHeading isEqualToString:kApplyForALoan]){
        urlString=objClientSettingsObject.applyloanlink;
    }
    else if ([menuHeading isEqualToString:kBranchLocation]){
        urlString=objClientSettingsObject.branchlocationlink;
    }
    else if ([menuHeading isEqualToString:kContact]){
        urlString=objClientSettingsObject.contactculink;
    }
    else if ([menuHeading isEqualToString:kPrivacyPolicy]){
        urlString=objClientSettingsObject.privacylink;
    }
    
    WeblinksController *objWeblinksController  = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([WeblinksController class])];
    objWeblinksController.navTitle=menuTitle;
    objWeblinksController.webLink=urlString;
    [self presentViewController:objWeblinksController animated:YES completion:nil];
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if(cell!=nil){
        
        NSString * menuHeading = [self.menuTitles objectAtIndex:indexPath.row];
        if ([menuHeading isEqualToString:@"Close"]){
            cell.crossButton.hidden = NO;
        }
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
        cell.menuTitleLabel.text = menuHeading;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    return [[UITableViewCell alloc]init];
}




@end
