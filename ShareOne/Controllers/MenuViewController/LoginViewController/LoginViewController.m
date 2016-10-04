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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMetxtBtn;

- (IBAction)scanTouchID:(id)sender ;

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

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
//    [[AppServiceModel sharedClient] postRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST] AndParam:[NSDictionary dictionaryWithObjectsAndKeys:@"spike",@"account",@"5656",@"password", nil] progressMessage:@"Pleas Wait..." urlString:KWEB_SERVICE_LOGIN delegate:self completionBlock:^(NSObject *response) {
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    
    
//    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
//    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:homeNavigationViewController animated:YES completion:nil];
//    return;
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT] AndParam:[NSDictionary dictionaryWithObjectsAndKeys:_userIDTxt.text,@"account",_passwordTxt.text,@"password", nil] progressMessage:@"Pleas Wait..." urlString:KWEB_SERVICE_MEMBER_VALIDATE delegate:self completionBlock:^(NSObject *response) {
        
        UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:homeNavigationViewController animated:YES completion:nil];

        
    } failureBlock:^(NSError *error) {
        
    }];

}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
}

- (IBAction)rememberMeButtonClicked:(id)sender {
    UIButton *btnCast = (UIButton *)sender;
    [btnCast setSelected:!btnCast.isSelected];
}

- (IBAction)fingerprintButtonClicked:(id)sender {
    UIButton *btnCast = (UIButton *)sender;
    [btnCast setSelected:!btnCast.isSelected];
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
@end
