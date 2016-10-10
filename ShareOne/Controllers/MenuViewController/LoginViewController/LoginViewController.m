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


@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMetxtBtn;

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
}

-(void)updateDataByDefaultValues{
    
    [_rememberMeBtn setSelected:[ShareOneUtility isUserRemembered]];
    [_userFingerprintBtn setSelected:[ShareOneUtility isTouchIDEnabled]];
    if([ShareOneUtility isUserRemembered]){
        User *user = [ShareOneUtility getUserObject];
        [_userIDTxt setText:user.UserName];
        [_passwordTxt setText:user.Password];
    }
    /*
     **  Call login service auto only if touch is enabled
     **
     */
    if([ShareOneUtility getUserObject]  && [ShareOneUtility isTouchIDEnabled]){
        [self loginButtonClicked:nil];
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
    if(!savedUser || ![ShareOneUtility isUserRemembered]){
        savedUser = [[User alloc] init];
        savedUser.UserName=_userIDTxt.text;
        savedUser.Password=_passwordTxt.text;

    }
//    else{
//        savedUser = [[User alloc] init];
//        savedUser.UserName=_userIDTxt.text;
//        savedUser.Password=_passwordTxt.text;
//    }
    
   
    
    if([ShareOneUtility isTouchIDEnabled]){
        [[ShareOneUtility shareUtitlities] showLAContextWithDelegate:weakSelf completionBlock:^(BOOL success) {
            
            if(success){
                
                // Call Sign In Service
                [self getSignInWithUser:savedUser];
            }
        }];
    }
    else{
        
        /*
         **  If touch ID is not enabled call the login service, touch ID verification skipped
         **
         */
        
        // Call Sign In Service
        [self getSignInWithUser:savedUser];
    }
}

- (void)startApplication{
    
    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:homeNavigationViewController animated:YES completion:nil];
}


- (void)getSignInWithUser:(User *)user{
    
    __weak LoginViewController *weakSelf = self;

    [User getUserWithParam:[NSDictionary dictionaryWithObjectsAndKeys:user.UserName,@"account",user.Password,@"password", nil] delegate:weakSelf completionBlock:^(User *user) {
        
        // Go though to thee application
        [weakSelf startApplication];
        
    } failureBlock:^(NSError *error) {
        
    }];
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


- (IBAction)openUrlButtonClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://nsmobilecp.ns3web.com/Account/Tax"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)quickBalanceButtonClicked:(id)sender {
    QuickBalancesViewController* objQuickBalancesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuickBalancesViewController"];
    [self presentViewController:objQuickBalancesViewController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    
    return NO;
}


@end