//
//  HomeViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "MemberDevices.h"




@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    __weak HomeViewController *weakSelf = self;

    [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getUUID],@"Fingerprint", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
    

    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;
    if(!_url)
        _url = HOME_WEB_VIEW_URL;
    
    NSString *queryString = [NSString stringWithFormat:@"%@/%@",_url,[[[SharedUser sharedManager] userObject] ContextID]];
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:queryString]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSLog(@"Requested url: %@", _url);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    __weak HomeViewController *weakSelf = self;

    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
    NSString *myLoadedUrl = [[webView.request mainDocumentURL] absoluteString];
    NSLog(@"Loaded url: %@", myLoadedUrl);
    
    if(![_url isEqualToString:myLoadedUrl]){
        NSLog(@"It is Redirecting");
    }
}
@end
