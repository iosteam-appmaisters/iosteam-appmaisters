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
#import "Services.h"

@implementation PasswordChangeController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];
    
    self.navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:11],NSFontAttributeName,nil];

    
    _webview.delegate=self;
    [self loadRequestOnWebView];
    
    
}


-(IBAction)backButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadRequestOnWebView{
    
    __weak PasswordChangeController *weakSelf = self;

    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    if(_isComingFromPasswordExpire){
        
        [_backButton setHidden:FALSE];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],kPASSWORD_EXPIRE_URL]]];
        [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];

        [weakSelf.webview loadRequest:request];
        
    }
    else{
        
        [_backButton setHidden:TRUE];

        [User postContextIDForSSOWithDelegate:weakSelf withTabName:@"" completionBlock:^(id urlPath) {
            
            NSMutableURLRequest *req = [(NSMutableURLRequest *)urlPath mutableCopy];
            [req setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];

            [weakSelf.webview loadRequest:req];
            
        } failureBlock:^(NSError *error) {
            
        }];
    }

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
   
    __weak PasswordChangeController *weakSelf = self;

    NSLog(@"%@",webView.request.URL.absoluteString);
    if([webView.request.URL.absoluteString containsString:@"Account/Summary"]){
        _loginDelegate.isComingAfterPressedOpenUrlButton=TRUE;
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if([webView.request.URL.absoluteString isEqualToString:@"https://nsmobilecp.ns3web.com/"]){
        [self dismissViewControllerAnimated:NO completion:^{
        }];
        
    }
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}

-(void)showAlerWithDelay{
    __weak PasswordChangeController *weakSelf = self;

    [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Password has changed" title:@"" delegate:weakSelf];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    
    [self showAlertWithTitle:@"" AndMessage:[Configuration getMaintenanceVerbiage]];
}


#pragma mark - Status Alert Message
-(void)showAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:^{
                             }];
                             
                             
                         }];
    [alert addAction:ok];
    
    
    UIAlertAction* tryAgain = [UIAlertAction
                               actionWithTitle:@"Try Again"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:^{
                                   }];
                                   
                                   [self loadRequestOnWebView];
                
                               }];
    [alert addAction:tryAgain];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
