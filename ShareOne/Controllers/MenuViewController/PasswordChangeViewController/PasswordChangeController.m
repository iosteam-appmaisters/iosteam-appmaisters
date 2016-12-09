//
//  PasswordChangeController.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/1/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "PasswordChangeController.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "User.h"
#import "LoginViewController.h"

@implementation PasswordChangeController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    __weak PasswordChangeController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;
    
    [User postContextIDForSSOWithDelegate:weakSelf withTabName:@"" completionBlock:^(id urlPath) {
        
        [weakSelf.webview loadRequest:(NSMutableURLRequest *)urlPath];
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
//    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.navigationItem.title=theTitle;
    
    if([webView.request.URL.absoluteString containsString:@"Account/Summary"]){
        [_loginDelegate startLoadingServicesFromChangePassword:_user];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    __weak PasswordChangeController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}

- (BOOL)shouldAutorotate{
    
    return NO;
}

@end