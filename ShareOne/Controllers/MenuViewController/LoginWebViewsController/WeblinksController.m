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
    // Do any additional setup after loading the view.
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];
    
    self.navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:11],NSFontAttributeName,nil];

    [ShareOneUtility showProgressViewOnView:self.view];
    [self updateWebLinks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


-(void)appGoingToBackground{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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



- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [ShareOneUtility hideProgressViewOnView:self.view];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    [self showAlertWithTitle:@"" AndMessage:ERROR_MESSAGE];
}




- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                   
                                   NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:_webLink]];
                                   
                                   [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
                                   [_webView loadRequest:request];
                                   
                               }];
    [alert addAction:tryAgain];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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
