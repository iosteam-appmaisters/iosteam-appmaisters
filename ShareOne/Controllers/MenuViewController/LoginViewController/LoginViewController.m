//
//  LoginViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "LoginViewController.h"
#import "QuickBalancesViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIDTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userFingerprintBtn;


@end

@implementation LoginViewController


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _userFingerprintBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rememberMeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;

}

- (IBAction)loginButtonClicked:(id)sender {
    
    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:homeNavigationViewController animated:YES completion:nil];

}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
}

- (IBAction)rememberMeButtonClicked:(id)sender {
}

- (IBAction)fingerprintButtonClicked:(id)sender {
}

- (IBAction)openUrlButtonClicked:(id)sender {
}

- (IBAction)quickBalanceButtonClicked:(id)sender {
    QuickBalancesViewController* objQuickBalancesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuickBalancesViewController"];
    [self presentViewController:objQuickBalancesViewController animated:YES completion:nil];
}
@end
