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
#import "SignInModel.h"
#import "BranchLocationViewController.h"

@implementation SplashViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self showNextViewController];
}

-(void)showNextViewController{
    
    if([SignInModel checkUserData]){
        UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:homeNavigationViewController animated:YES completion:nil];
        
    }else{
        
        LoginViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        self.objLoginViewController=loginViewController;
        
        loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentViewController:loginViewController animated:YES completion:nil];
  
    }
        
}

- (BOOL)shouldAutorotate{
    
    return NO;
}


@end
