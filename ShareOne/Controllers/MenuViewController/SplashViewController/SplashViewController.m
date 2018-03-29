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
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeMessageLabel:)
                                                 name:@"MessageLabelNotification"
                                               object:nil];

    if ([ShareOneUtility shouldCallNSConfigServices]){
        [self getNSConfigData];
    }
    else {
        
        [self shouldShowSplashInfo:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self goToLogin];
        });
    }
}

-(void)shouldShowSplashInfo:(BOOL)value {
    
    _versionLabel.hidden = !value;
    _customerIDLabel.hidden = !value;
    _appVersionLabel.hidden = !value;
    _messageLabel.hidden = !value;
}


-(void)changeMessageLabel:(NSNotification*)notification {
    _messageLabel.text = notification.userInfo[@"MESSAGE"];
    if ([notification.userInfo[@"STATUS"] isEqualToString:@"0"]){
        _messageLabel.textColor = [UIColor whiteColor];
    }
    else if ([notification.userInfo[@"STATUS"] isEqualToString:@"1"]){
        _messageLabel.textColor = [UIColor greenColor];
    }
    else if ([notification.userInfo[@"STATUS"] isEqualToString:@"2"]){
        _messageLabel.textColor = [UIColor redColor];
    }
    
    _versionLabel.text = [NSString stringWithFormat:@"Version: %@",notification.userInfo[@"VERSION"]];
    _customerIDLabel.text = [NSString stringWithFormat:@"Customer ID: %@",notification.userInfo[@"CUSTOMER_ID"]];
    _appVersionLabel.text = [ShareOneUtility getApplicationVersion];
}

-(void)getNSConfigData{

    [self showIndicaterView];
        
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MessageLabelNotification"
     object:self userInfo:@{@"MESSAGE":@"Please wait while we check for updates",
                            @"STATUS":@"0",
                            @"VERSION":[ShareOneUtility getVersionNumber],
                            @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
    
    [Configuration getConfigurationWithDelegate:self completionBlock:^(BOOL success, NSString *errorString) {
        [self hideIndicaterView];
        if(success){
            
            [ShareOneUtility saveDateForNSConfigAPI];
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"nconfig_called"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"MessageLabelNotification"
             object:self userInfo:@{@"MESSAGE":@"Please wait while we update app",
                                    @"STATUS":@"1",
                                    @"VERSION":[ShareOneUtility getVersionNumber],
                                    @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
                [self goToLogin];
            });
 
        }
        else{
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"nconfig_called"]){
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"MessageLabelNotification"
                 object:self userInfo:@{@"MESSAGE":@"Please wait while we update app",
                                        @"STATUS":@"2",
                                        @"VERSION":[ShareOneUtility getVersionNumber],
                                        @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    
                    [self goToLogin];
                });
            }
            else {
                [self showAlertWithTitle:nil AndMessage:errorString];
            }
        }
        
    } failureBlock:^(NSError *error) {
    }];
   
}

-(void)showAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"nconfig_called"]){
        UIAlertAction* ignoreBtn = [UIAlertAction
                                   actionWithTitle:@"Ignore"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self goToLogin];
                                       [alert dismissViewControllerAnimated:YES completion:^{
                                       }];
                                   }];
        [alert addAction:ignoreBtn];
    }
    
    
    UIAlertAction* retryBtn = [UIAlertAction
                               actionWithTitle:@"Try Again"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self getNSConfigData];
                                   [alert dismissViewControllerAnimated:YES completion:^{
                                   }];
                               }];
    [alert addAction:retryBtn];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    if ([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]) {
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:RESTRICT_TOUCH_ID];
        [[NSUserDefaults standardUserDefaults]synchronize];
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
