//
//  WeblinksController.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/26/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "WeblinksController.h"
#import "ShareOneUtility.h"
#import "ConstantsShareOne.h"
#import "UIColor+HexColor.h"

@interface WeblinksController ()

@end

@implementation WeblinksController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];
    
    self.navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:11],NSFontAttributeName,nil];

    [ShareOneUtility showProgressViewOnView:self.view];
    [self updateWebLinks];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackgroundFromWebLink) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)appGoingToBackgroundFromWebLink{
   
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)updateWebLinks{
    _navBar.topItem.title = _navTitle;
    
   NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:_webLink]];
    
    [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
    [_webView loadRequest:request];

}
-(IBAction)backButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
     NSLog(@"%@",[[webView URL] absoluteString]);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [ShareOneUtility hideProgressViewOnView:self.view];

}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"didFailLoadWithError : %@",error);
      
      [ShareOneUtility hideProgressViewOnView:self.view];
      
      if ([error code] != NSURLErrorCancelled) {
          [self showAlertWithTitle:@"" AndMessage:[Configuration getMaintenanceVerbiage]];
      }
}


- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
                                   
                                   [ShareOneUtility showProgressViewOnView:self.view];
                                   
                                   NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self->_webLink]];
                                   
                                   [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
                                   [self->_webView loadRequest:request];
                                   
                               }];
    [alert addAction:tryAgain];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)dealloc {
    
    _webView.navigationDelegate = nil;
    [_webView stopLoading];
    
}

@end
