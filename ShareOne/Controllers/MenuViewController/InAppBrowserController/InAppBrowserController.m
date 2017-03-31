//
//  InAppBrowserController.m
//  ShareOne
//
//  Created by Qazi Naveed on 3/28/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "InAppBrowserController.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"
#import "ConstantsShareOne.h"

@interface InAppBrowserController ()

@property (nonatomic,weak) IBOutlet UIButton *backButton;
@property (nonatomic,weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic,weak) IBOutlet UIWebView *webView;


-(IBAction)backButtonPressed:(id)sender;
@end

@implementation InAppBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadRequestOnWebView];
    
    self.navigationItem.rightBarButtonItem=nil;
    
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy =
    NSHTTPCookieAcceptPolicyAlways;

    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];
    
    self.navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:11],NSFontAttributeName,nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self sendAdvertismentViewToBack];

}

-(void)loadRequestOnWebView{
 
    __weak InAppBrowserController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    

    NSMutableURLRequest *request = _request;
    [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
    [_webView loadRequest:request];

}

-(IBAction)backButtonPressed:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    __weak InAppBrowserController *weakSelf = self;

    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    
    [self showAlertWithTitle:@"" AndMessage:ERROR_MESSAGE];
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
