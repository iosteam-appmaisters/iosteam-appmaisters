//
//  WeblinksController.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/26/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "WeblinksController.h"
#import "ShareOneUtility.h"

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
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webLink]]];
}
-(IBAction)backButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [ShareOneUtility hideProgressViewOnView:self.view];
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
