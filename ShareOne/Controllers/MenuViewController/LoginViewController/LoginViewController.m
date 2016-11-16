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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMetxtBtn;
@property (weak, nonatomic) IBOutlet UIButton *quickBalanceBtn;

@property (weak, nonatomic) IBOutlet UIView *loadingView;



- (IBAction)scanTouchID:(id)sender ;

- (void)updateDataByDefaultValues;

- (void)startApplication;

- (void)getSignInWithUser:(User *)user;



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
    [self updateDataByDefaultValues];

}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askAutoLogin)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

}

-(void)askAutoLogin{
    [self updateDataByDefaultValues];
}
-(void)updateDataByDefaultValues{
    
    [_quickBalanceBtn setHidden:![ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
    [_rememberMeBtn setSelected:[ShareOneUtility isUserRemembered]];
    [_userFingerprintBtn setSelected:[ShareOneUtility isTouchIDEnabled]];
    if([ShareOneUtility isUserRemembered]){
        User *user = [ShareOneUtility getUserObject];
        [_userIDTxt setText:user.UserName];
        [_passwordTxt setText:user.Password];
    }
    else{
        [_userIDTxt setText:@""];
        [_passwordTxt setText:@""];

    }
    /*
     **  Call login service auto only if touch is enabled
     **
     */
    if([ShareOneUtility getUserObject]  && [ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS] && ![[SharedUser sharedManager] skipTouchIDForJustLogOut]){
        //[self loginButtonClicked:nil];
        [self showTouchID];
        [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
    }

}

-(void)showTouchID{
    
    __weak LoginViewController *weakSelf = self;

    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
        [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
            
            if(success){
                
                // Call Sign In Service
                [self loginButtonClicked:nil];
            }
        }];
    }

}

- (IBAction)loginButtonClicked:(id)sender
{
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
    
    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    
    
    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:homeNavigationViewController animated:YES completion:nil];
}

-(void)addingLoadingScreen{
    

    LoadingController * objLoadingController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingController"];
    objLoadingController.controllerDelegate=self;
    [self presentViewController:objLoadingController animated:NO completion:^{

    }];
    
}



- (void)getSignInWithUser:(User *)user{
    
    __weak LoginViewController *weakSelf = self;
//    [weakSelf startApplication];
//
//    return;
    
    [User getUserWithParam:[NSDictionary dictionaryWithObjectsAndKeys:user.UserName,@"account",user.Password,@"password", nil] delegate:weakSelf completionBlock:^(User *user) {
        
        // Go though to thee application
        [weakSelf.loadingView setHidden:FALSE];
        [weakSelf startLoadingServices];
        
        //[weakSelf registerToVertify];
        
//        [weakSelf startApplication];

        
    } failureBlock:^(NSError *error) {
        
    }];
    
}


-(void)startLoadingServices{
    
    __weak LoginViewController *weakSelf = self;

    [LoaderServices setRequestOnQueueWithDelegate:weakSelf completionBlock:^(BOOL success) {
        
       NSArray *devicesArr = [[SharedUser sharedManager] memberDevicesArr];
        
        NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"Fingerprint == %@",[ShareOneUtility getUUID]];
        
        NSArray *deveiceExistArr = [devicesArr filteredArrayUsingPredicate:devicePredicate];
        
        if([deveiceExistArr count]>0){
            // Device Exist : No need to call PostDevices Api
            // Register Logged In User with Virtifi
            //[self registerToVertify];
            
            //Skip vertifi reg on login screen
            [weakSelf startApplication];

        }
        else{
            // Device not exist : We need to call PostDevices Api with QuickBalance & QuickTransaction permissions
            __weak LoginViewController *weakSelf = self;
            
            NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
            NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
            
            NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
            
            [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
                
                
                [QuickBalances getAllBalances:nil delegate:weakSelf completionBlock:^(NSObject *user) {
                    
                    
                    // Register Logged In User with Virtifi
                    //[self registerToVertify];
                    
                    //Skip vertifi reg on login screen
                    [weakSelf startApplication];

                    
                } failureBlock:^(NSError *error) {
                    
                }];
                
            } failureBlock:^(NSError *error) {
                
            }];

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
                [weakSelf VertifiRegAcceptance];
            }
            else if ([obj.LoginValidation isEqualToString:@"OK"]){
                [weakSelf startApplication];
            }
            else
                [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.LoginValidation title:@"Status" delegate:weakSelf];
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
    UIButton *btnCast = (UIButton *)sender;
    [btnCast setSelected:!btnCast.isSelected];
    [ShareOneUtility setUserRememberedStatusWithBool:btnCast.isSelected];

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


- (IBAction)openUrlButtonClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://nsmobilecp.ns3web.com/Account/Tax"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)quickBalanceButtonClicked:(id)sender
{
    QuickBalancesViewController* objQuickBalancesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuickBalancesViewController"];
    [self presentViewController:objQuickBalancesViewController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    
    return NO;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end