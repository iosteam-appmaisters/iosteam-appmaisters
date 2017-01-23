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

@interface WeblinksController ()

@end

@implementation WeblinksController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ShareOneUtility showProgressViewOnView:self.view];

    [self updateWebLinks];
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

    
    [[UtilitiesHelper shareUtitlities]showToastWithMessage:ERROR_MESSAGE title:@"" delegate:self];
    
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
