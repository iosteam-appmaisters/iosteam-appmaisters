//
//  LoadingController.m
//  ShareOne
//
//  Created by Qazi Naveed on 24/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "LoadingController.h"
#import "LoginViewController.h"
#import "AppServiceModel.h"
#import "LoaderServices.h"
#import "MemberDevices.h"
#import "SuffixInfo.h"

@interface LoadingController ()

@end

@implementation LoadingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view..
    
 //   __weak LoadingController *weakSelf = self;
//    [LoaderServices setRequestOnQueueWithDelegate:weakSelf completionBlock:^(BOOL success,NSString *errorMessage) {
//        
//        [weakSelf dismisLoader];
//    } failureBlock:^(NSError *error) {
//        
//    }];
   
    //[self performSelector:@selector(dismisLoader) withObject:nil afterDelay:2];
}

-(void)getMemberDevices{
    __weak LoadingController *weakSelf = self;
    
    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)getSuffixInfo{
    
    __weak LoadingController *weakSelf = self;
    
    [SuffixInfo getSuffixInfo:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}



-(void)dismisLoader{
    
    
//    UIViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
//    [self.navigationController pushViewController:loginViewController animated:NO];

    

    [self dismissViewControllerAnimated:NO completion:^{
    }];
    
    [_controllerDelegate startApplication];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
