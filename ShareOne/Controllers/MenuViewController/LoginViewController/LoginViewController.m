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
#import "LoadingController.h"
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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMetxtBtn;
@property (weak, nonatomic) IBOutlet UIButton *quickBalanceBtn;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *branchLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *applyLoanButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;


@property (weak, nonatomic) IBOutlet UIView *loadingView;




- (IBAction)scanTouchID:(id)sender ;

- (void)updateDataByDefaultValues;

- (void)startApplication;

- (void)getSignInWithUser:(User *)user;

-(IBAction)pinResetButtonClicked:(id)sender;



@end

@implementation LoginViewController


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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];

    [self updateDataByDefaultValues];
    
//    __weak LoginViewController *weakSelf = self;
//
//    [weakSelf.loadingView setHidden:FALSE];
//    [weakSelf startLoadingServices];

}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askAutoLoginOnEnteringBackGround) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackgroundFromLogin) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)appGoingToBackgroundFromLogin{
    NSLog(@"appGoingToBackgroundFromLogin");
    [[ShareOneUtility shareUtitlities] cancelTimer];


}
-(void)askAutoLoginOnEnteringBackGround{

    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
    NSLog(@"askAutoLoginOnEnteringBackGround");
    [self updateDataByDefaultValues];
}


-(void)updateDataByDefaultValues{
    
    [_quickBalanceBtn setHidden:![ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
    [_rememberMeBtn setSelected:[ShareOneUtility isUserRemembered]];
    [_rememberMeSwitch setOn:[ShareOneUtility isUserRemembered]];
    [_userFingerprintBtn setSelected:[ShareOneUtility isTouchIDEnabled]];
    if([ShareOneUtility isUserRemembered]){
        User *user = [ShareOneUtility getUserObject];
        [_userIDTxt setText:user.UserName];
        [_passwordTxt setText:@""];

//        [_passwordTxt setText:user.Password];
    }
    else{
        [_userIDTxt setText:@""];
        [_passwordTxt setText:@""];
    }
    
    /*
     **  Call login service auto only if touch is enabled
     
     if([ShareOneUtility getUserObject]  && [ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS] && ![[SharedUser sharedManager] skipTouchIDForJustLogOut]){
        //[self loginButtonClicked:nil];
        
        if(_isComingAfterPressedOpenUrlButton){
            _isComingAfterPressedOpenUrlButton= FALSE;
        }
        else{
            [self showTouchID];
            [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
        }
    }
    */

    /*
     **  Call login service auto only if touch is enabled
     */
    
    if([ShareOneUtility getUserObject] && ![[SharedUser sharedManager] skipTouchIDForJustLogOut]){
        
        __weak LoginViewController *weakSelf = self;

        if(_isComingAfterPressedOpenUrlButton){
            _isComingAfterPressedOpenUrlButton= FALSE;
        }
        else{
            
            if([[SharedUser sharedManager] isLaunchFirstTime]){
                // if is coming after calling didFinishLaunchingWithOptions
                
                if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
                    
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                    [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
                        
                        if(success){
                            
                            [ShareOneUtility removeCacheControllerName];

                            User *user = [ShareOneUtility getUserObject];
                            [_userIDTxt setText:user.UserName];
                            [_passwordTxt setText:user.Password];
                            [self loginButtonClicked:nil];
                        }
                    }];
                }
                else{
                    NSLog(@"isLaunchFirstTime Touch off");
                    
//                    [ShareOneUtility showProgressViewOnView:weakSelf.view];

                    
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                    NSString *contextId= [[[SharedUser sharedManager] userObject] Contextid];
                    
                    [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:nil completionBlock:^(BOOL sucess) {
                        
//                        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
                        
                        
//                        [self applyConditionsForSessionValidation];
                        
                    } failureBlock:^(NSError *error) {
                        
                    }];

                }
            }
            else{
                
                // if it is coming from Background
                
                // Remove last session if it is still exist
                if([ShareOneUtility isTerminated]){
                    

                    [ShareOneUtility setTerminateState:FALSE];
                    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
                    
                    [self applyConditionsForSessionValidation];


//                    NSString *contextId= [[[SharedUser sharedManager] userObject] Contextid];
//                    
//                    [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:nil completionBlock:^(BOOL sucess) {
//                        
//                        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
//
//                        
//                        [self applyConditionsForSessionValidation];
//                        
//                    } failureBlock:^(NSError *error) {
//                        
//                    }];

                }
                else{
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
    
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS])
        [self showTouchID];
    else
        [self validateSessionForTouchID_OffSession];

}
-(void)validateSessionForTouchID_OffSession{
    
    __weak LoginViewController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];


    [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];

    _isComingAfterAuthenticatingFromTouchID= TRUE;
    // check whether session is available or not
    [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
        NSLog(@"keepAlive from validateSessionForTouchID_OffSession");
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if(sucess){
            [weakSelf startApplication];
        }
        else{
            // if session not validated
            [[ShareOneUtility shareUtitlities] showToastWithMessage:@"Your session has been time out." title:@"" delegate:weakSelf];

            
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)showTouchID{
    
    __weak LoginViewController *weakSelf = self;
    
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
        
        [[SharedUser sharedManager] setUserObject:[ShareOneUtility getUserObject]];
        
        [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
            
            if(success){
                
                _isComingAfterAuthenticatingFromTouchID= TRUE;
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
                        [[ShareOneUtility shareUtitlities] showToastWithMessage:@"Your session has been time out." title:@"" delegate:weakSelf];

                        /*
                         User *user = [ShareOneUtility getUserObject];
                         [_userIDTxt setText:user.UserName];
                         [_passwordTxt setText:user.Password];
                         [self loginButtonClicked:nil];
                         */
                    }
                    
                } failureBlock:^(NSError *error) {
                    
                }];
                
            }
        }];
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
//    if(!savedUser || ![ShareOneUtility isUserRemembered])
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
        
        _isComingAfterAuthenticatingFromTouchID = FALSE;
        savedUser = [[User alloc] init];
        savedUser.UserName=_userIDTxt.text;
        savedUser.Password=_passwordTxt.text;
        [ShareOneUtility removeCacheControllerName];
    }

    [self getSignInWithUser:savedUser];


    /*
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
        [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
            
            if(success){
                
                // Call Sign In Service
                [self getSignInWithUser:savedUser];
            }
        }];
    }
    else{
        
     
         **  If touch ID is not enabled call the login service, touch ID verification skipped
         **
     
        
        // Call Sign In Service
        [self getSignInWithUser:savedUser];
    
    }
     */
}

- (void)startApplication{
    
    if(_isComingAfterAuthenticatingFromTouchID){
        
        UIViewController *controllerToPush =nil;
        _isComingAfterAuthenticatingFromTouchID=FALSE;
        
        NSDictionary *dict = [ShareOneUtility getMenuItemForTouchIDAuthentication];
        
        NSString *contrlollerName = [dict valueForKey:CONTROLLER_NAME];
        NSString *webUrl = [dict valueForKey:WEB_URL];
        NSString *screenTitle = [[dict valueForKey:SUB_CAT_TITLE] capitalizedString];

        UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];

        if([contrlollerName isEqualToString:@"WebViewController"]){
            
            HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
            controllerToPush = objHomeViewController;
            objHomeViewController.url= webUrl;
//            objHomeViewController.navigationItem.title=screenTitle;

        }
        else{
            
            UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
            
            controllerToPush = objUIViewController;

            objUIViewController.navigationItem.title=screenTitle;
            
        }
        
        
        homeNavigationViewController.viewControllers = [NSArray arrayWithObject: controllerToPush];

        homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
        
        [self presentViewController:homeNavigationViewController animated:YES completion:nil];
    }
    else{
        UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        
        homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
        
        [self presentViewController:homeNavigationViewController animated:YES completion:nil];
    }
}

-(void)addingLoadingScreen{
    

    LoadingController * objLoadingController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingController"];
    objLoadingController.controllerDelegate=self;
    [self presentViewController:objLoadingController animated:NO completion:^{

    }];
    
}



- (void)getSignInWithUser:(User *)user{
    
    __weak LoginViewController *weakSelf = self;
//    [weakSelf.loadingView setHidden:FALSE];
//    [weakSelf startLoadingServices];

//    [weakSelf startApplication];
//
//    return;
//    user.Password
    [User getUserWithParam:[NSDictionary dictionaryWithObjectsAndKeys:user.UserName,@"account",user.Password,@"password", nil] delegate:weakSelf completionBlock:^(User *user) {
        
        
        if(_objPinResetController){
            [_objPinResetController dismissViewControllerAnimated:NO completion:nil];
            _objPinResetController=nil;
            
            if(user.Requirements){
                if([user.Requirements count]>1){
                    NSString *status = user.Requirements[0];
                    
                    if([status isEqualToString:CHANGE_PIN]){
                        [weakSelf addPasswordChangeController:user];
                    }
                    
                }
                if([user.Requirements count]>0){
                    NSString *status = user.Requirements[0];
                    
                    if([status isEqualToString:CHANGE_PIN]){
                        [weakSelf addPasswordChangeController:user];
                    }
                    if([status isEqualToString:CHANGE_ACCOUNT_USER_NAME]){
                        [self addControllerToChangeUserName];
                    }
                }

            }
        }
        else{
            // Go though to thee application
            

            //asi flow
            [weakSelf.loadingView setHidden:FALSE];
            [weakSelf startLoadingServices];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}


-(void)startLoadingServicesFromChangePassword:(User *)user{
    
    if([user.Requirements containsObject:CHANGE_ACCOUNT_USER_NAME]){
        [self addControllerToChangeUserName];
    }
    else{
        [self.loadingView setHidden:FALSE];
        [self startLoadingServices];
    }
}

-(void)addControllerToChangeUserName{
 
    _isComingAfterPressedOpenUrlButton = TRUE;

    UserNamecontroller *objUserNamecontroller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([UserNamecontroller class])];
    objUserNamecontroller.loginDelegate=self;
    [self presentViewController:objUserNamecontroller animated:YES completion:nil];
}

-(void)addPasswordChangeController:(User *)user{
    _isComingAfterPressedOpenUrlButton = TRUE;

    PasswordChangeController *objPasswordChangeController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PasswordChangeController class])];
    objPasswordChangeController.loginDelegate=self;
    objPasswordChangeController.user=user;
    [self presentViewController:objPasswordChangeController animated:YES completion:nil];

}


-(void)startLoadingServices{
    
    __weak LoginViewController *weakSelf = self;

    [LoaderServices setRequestOnQueueWithDelegate:weakSelf completionBlock:^(BOOL success,NSString *errorString) {
        
        
        if(success && !errorString){
            NSArray *devicesArr = [[SharedUser sharedManager] memberDevicesArr];
            
            NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"Fingerprint == %@",[ShareOneUtility getUUID]];
            
            NSArray *deveiceExistArr = [devicesArr filteredArrayUsingPredicate:devicePredicate];
            
            if([deveiceExistArr count]>0){
                // Device Exist : No need to call PostDevices Api
                // Register Logged In User with Virtifi
                
                [QuickBalances getAllBalances:nil delegate:weakSelf completionBlock:^(NSObject *user) {
                    
                    
                    // Register Logged In User with Virtifi
                    [self registerToVertify];
                    
                    //Skip vertifi reg on login screen
                    //  [weakSelf startApplication];
                    
                } failureBlock:^(NSError *error) {
                    
                    [weakSelf.loadingView setHidden:TRUE];
                }];
                
                //Skip vertifi reg on login screen
                //[weakSelf startApplication];
                
            }
            else{
                // Device not exist : We need to call PostDevices Api with QuickBalance & QuickTransaction permissions
                __weak LoginViewController *weakSelf = self;
                
                NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
                NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
                
                NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
                
                [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",PROVIDER_TYPE_VALUE,@"ProviderType",@"ios",@"DeviceType",[ShareOneUtility getDeviceNotifToken],@"DeviceToken",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
                    
                    
                    [QuickBalances getAllBalances:nil delegate:weakSelf completionBlock:^(NSObject *user) {
                        
                        
                        // Register Logged In User with Virtifi
                        [self registerToVertify];
                        
                        //Skip vertifi reg on login screen
                        //  [weakSelf startApplication];
                        
                    } failureBlock:^(NSError *error) {
                        [weakSelf.loadingView setHidden:TRUE];
                    }];
                    
                } failureBlock:^(NSError *error) {
                    [weakSelf.loadingView setHidden:TRUE];
                }];
            }
        }
        else{
            [weakSelf.loadingView setHidden:TRUE];

            [[UtilitiesHelper shareUtitlities] showToastWithMessage:errorString title:@"" delegate:weakSelf];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)registerToVertify{
    
    __weak LoginViewController *weakSelf = self;
    
    
    
    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValue],@"account",[ShareOneUtility  getMacForVertifiForSuffix:nil],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:kVERTIFY_MONEY_REGISTER_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        
        if(success){
            VertifiObject *obj = (VertifiObject *)user;
            if(![obj.InputValidation isEqualToString:@"OK"]){
                //[[ShareOneUtility shareUtitlities] showToastWithMessage:obj.InputValidation title:@"" delegate:weakSelf completion:nil];
            }
            
            if([obj.LoginValidation isEqualToString:@"User Not Registered"]){
                //[weakSelf VertifiRegAcceptance];
                [weakSelf startApplication];
            }
            else if ([obj.LoginValidation isEqualToString:@"OK"]){
                [weakSelf startApplication];
            }
            else{
                
//                [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.LoginValidation title:@"Status" delegate:weakSelf];
                [weakSelf startApplication];

            }
        }
        else{
            
            [weakSelf.loadingView setHidden:TRUE];

            NSString *message = (NSString *)user;
            [[ShareOneUtility shareUtitlities] showToastWithMessage:message title:@"" delegate:weakSelf];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)VertifiRegAcceptance{
    
    __weak LoginViewController *weakSelf = self;
    
    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValue],@"account",[ShareOneUtility  getMacForVertifiForSuffix:nil],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:kVERTIFI_ACCEPTANCE_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        VertifiObject *obj = (VertifiObject *)user;
        if([obj.InputValidation isEqualToString:@"OK"]){
            [weakSelf startApplication];
        }
    } failureBlock:^(NSError *error) {
    }];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.loadingView setHidden:TRUE];
}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
}

- (IBAction)rememberMeButtonClicked:(id)sender {
//    UIButton *btnCast = (UIButton *)sender;
//    [btnCast setSelected:!btnCast.isSelected];
//    [ShareOneUtility setUserRememberedStatusWithBool:btnCast.isSelected];

    
    UISwitch *switchObj = (UISwitch *)sender;
    [ShareOneUtility setUserRememberedStatusWithBool:switchObj.isOn];

}

- (IBAction)fingerprintButtonClicked:(id)sender {
    
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

}


- (IBAction)openUrlButtonClicked:(id)sender{
    
    
    _isComingAfterPressedOpenUrlButton = TRUE;
    NSString *urlString =nil;
    NSString *screenTitle= nil;
    UIButton *btn = (UIButton *)sender;
    
    screenTitle=[btn titleForState:UIControlStateNormal];
    if([sender isEqual:_joinButton]){
        urlString=URL_JOIN_CREDIT_UNION;
//        screenTitle=JOIN_CREDIT_UNION_TITLE;
    }
    else if ([sender isEqual:_applyLoanButton]){
        urlString=URL_APPLY_FOR_LOAN;
//        screenTitle=APPLY_FOR_LOAN_TITLE;
    }
    else if ([sender isEqual:_branchLocationButton]){
        urlString=URL_BRANCH_LOCATION;
//        screenTitle=BRANCH_LOCATION_TITLE;
    }
    else if ([sender isEqual:_contactButton]){
        urlString=URL_CONTACT_US;
//        screenTitle=CONTACT_TITLE;
    }
    else if ([sender isEqual:_privacyButton]){
        urlString=URL_PRIVACY_POLICY;
//        screenTitle=PRIVACY_POLICY_TITLE;
    }

    WeblinksController *objWeblinksController  = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([WeblinksController class])];
    objWeblinksController.navTitle=screenTitle;
    objWeblinksController.webLink=urlString;
    [self presentViewController:objWeblinksController animated:YES completion:nil];


//    NSURL *url = [NSURL URLWithString:urlString];
//    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)quickBalanceButtonClicked:(id)sender
{
    _isComingAfterPressedOpenUrlButton = TRUE;

    QuickBalancesViewController* objQuickBalancesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuickBalancesViewController"];
    [self presentViewController:objQuickBalancesViewController animated:YES completion:nil];
}

-(IBAction)pinResetButtonClicked:(id)sender{
    
    _isComingAfterPressedOpenUrlButton = TRUE;

    BOOL isFromForgotUserName =FALSE;
    UIButton *btn = (UIButton *)sender;
    if(btn.tag==111){
        isFromForgotUserName=TRUE;
    }
    else{
        isFromForgotUserName=FALSE;
    }
    if(!_objPinResetController){
        
        _objPinResetController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PinResetController class])];
        
        _objPinResetController.isFromForgotUserName=isFromForgotUserName;
        _objPinResetController.loginDelegate=self;
        [self presentViewController:_objPinResetController animated:YES completion:nil];
    }
}


-(void)moveViewUp{
    if(_loginViewConstraintY.constant<=-20)
        _loginViewConstraintY.constant=-140;
}

-(void)moveViewDown{
    
    if(_loginViewConstraintY.constant>=-140)
        _loginViewConstraintY.constant=-20;
}

#pragma mark UITextFeildDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField isEqual:_passwordTxt]){
        [textField resignFirstResponder];
        [self moveViewDown];
    }
    else{
        [textField resignFirstResponder];
        [_passwordTxt becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self moveViewUp];
    return YES;
}


- (BOOL)shouldAutorotate{
    
    return NO;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
