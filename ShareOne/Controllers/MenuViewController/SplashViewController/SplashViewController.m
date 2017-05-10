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
    
    
    
    if(![[SharedUser sharedManager] isLaunchFirstTime]){
        
        NSLog(@"FIRST TIME LAUNCH");

        [Configuration getConfigurationWithDelegate:self completionBlock:^(BOOL success, NSString *errorString) {
            if(success){
                [self goToLogin];
            }

        } failureBlock:^(NSError *error) {
            
        }];

    }
    else{
        NSLog(@"SKIPPED FIRST TIME LAUNCH");
        [self goToLogin];


    }
    

    return;
    if([SignInModel checkUserData]){
        UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:homeNavigationViewController animated:YES completion:nil];
        
    }else{
        LoginViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
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
