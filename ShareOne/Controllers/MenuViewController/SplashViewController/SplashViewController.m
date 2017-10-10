//
//  SplashViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "SharedUser.h"

@implementation SplashViewController


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageLabelNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageLabelNotification" object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeMessageLabel:)
                                                 name:@"MessageLabelNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNextViewController) name:UIApplicationWillEnterForegroundNotification object:nil];
//
    [self showNextViewController];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self showNextViewController];
}

-(void)changeMessageLabel:(NSNotification*)notification {
    _messageLabel.text = notification.userInfo[@"MESSAGE"];
    _versionLabel.text = [NSString stringWithFormat:@"Version: %@",notification.userInfo[@"VERSION"]];
    _customerIDLabel.text = [NSString stringWithFormat:@"Customer ID: %@",notification.userInfo[@"CUSTOMER_ID"]];
    _appVersionLabel.text = [ShareOneUtility getApplicationVersion];
}

-(void)showNextViewController{
    
    //if([ShareOneUtility isConfigDataNotExistedOrReSkinSettingIsOn] || [[SharedUser sharedManager] isCallingNSConfigServices]){
        
        NSLog(@"FIRST TIME LAUNCH");
        [[SharedUser sharedManager] setIsCallingNSConfigServices:FALSE];

        [self showIndicaterView];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"MessageLabelNotification"
         object:self userInfo:@{@"MESSAGE":@"Please wait while we check for updates",
                                @"VERSION":[ShareOneUtility getVersionNumber],
                                @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
        
        [Configuration getConfigurationWithDelegate:self completionBlock:^(BOOL success, NSString *errorString) {
            [self hideIndicaterView];
            if(success){
                [self goToLogin];
            }
            else{
                [self showAlertWithTitle:nil AndMessage:errorString];
            }
            
        } failureBlock:^(NSError *error) {
        }];
    //}
    /*else{
        NSLog(@"SKIPPED FIRST TIME LAUNCH");
        [self hideIndicaterView];
        [self goToLogin];
    }*/
}

-(void)showAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* retryBtn = [UIAlertAction
                               actionWithTitle:@"Re Try"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self getConfigSettings];
                                   [alert dismissViewControllerAnimated:YES completion:^{
                                   }];
                               }];
    [alert addAction:retryBtn];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)getConfigSettings{
    
    [self showIndicaterView];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MessageLabelNotification"
     object:self userInfo:@{@"MESSAGE":@"Please wait while we check for updates",
                            @"VERSION":[ShareOneUtility getVersionNumber],
                            @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
    
    [Configuration getConfigurationWithDelegate:self completionBlock:^(BOOL success, NSString *errorString) {
        [self hideIndicaterView];
        if(success){
            [self goToLogin];
        }
        else{
            [self showAlertWithTitle:nil AndMessage:errorString];
        }
        
    } failureBlock:^(NSError *error) {
    }];

}
-(void)showIndicaterView{
    [_indicatorView setHidden:FALSE];
    [_indicatorView startAnimating];
}

-(void)hideIndicaterView{
    [_indicatorView setHidden:TRUE];
    [_indicatorView stopAnimating];
    
}
-(void)goToLogin{
    
    if (_isComingFromBackground){
        [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
    }
    
    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:homeNavigationViewController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
