//
//  PayPersonController.m
//  ShareOne
//
//  Created by Qazi Naveed on 22/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "PayPersonController.h"

@interface PayPersonController ()

@property (nonatomic,strong) IBOutlet UIWebView *webView;
@property (nonatomic,strong) IBOutlet UIView *webViewParent;
@property (nonatomic,strong) IBOutlet UIButton *closeBtn;


- (IBAction)submittButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation PayPersonController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)submittButtonClicked:(id)sender{
    
    __weak PayPersonController *weakSelf = self;
    

    [ShareOneUtility showProgressViewOnView:weakSelf.view];

    [_webViewParent setHidden:FALSE];
    [_closeBtn setHidden:FALSE];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com.pk"]]];
}


- (IBAction)closeButtonClicked:(id)sender{
    
    __weak PayPersonController *weakSelf = self;
    
    
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];

    [_webViewParent setHidden:TRUE];
    [_closeBtn setHidden:TRUE];

}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    __weak PayPersonController *weakSelf = self;
    
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
    
    
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
