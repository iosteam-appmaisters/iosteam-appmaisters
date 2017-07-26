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


-(void)viewDidLoad{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showNextViewController];
}

-(void)showNextViewController{
    
    if([ShareOneUtility isConfigDataNotExistedOrReSkinSettingIsOn] || [[SharedUser sharedManager] isCallingNSConfigServices]){
        
        NSLog(@"FIRST TIME LAUNCH");
        [[SharedUser sharedManager] setIsCallingNSConfigServices:FALSE];

        [self showIndicaterView];
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
    else{
        NSLog(@"SKIPPED FIRST TIME LAUNCH");
        [self hideIndicaterView];
        [self goToLogin];
    }
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
    LoginViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginViewController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
