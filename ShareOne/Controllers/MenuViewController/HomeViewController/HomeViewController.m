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
#import "QuickBalances.h"
#import "SuffixInfo.h"




@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    __weak HomeViewController *weakSelf = self;
    
    
    NSLog(@"UDID : %@",[ShareOneUtility getUUID]);

    [self getMemberDevices];
    //[self putMemberDevice];
    //[self postMemberDevices];
    
    
    [self getQB];
    //[self getSuffixInfo];
    //[self postSuffixPrepherences];



    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;
    if(!_url)
        _url = HOME_WEB_VIEW_URL;
    
    NSString *queryString = [NSString stringWithFormat:@"%@/%@",_url,[[[SharedUser sharedManager] userObject] ContextID]];
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:queryString]]];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

-(void)getMemberDevices{
    __weak HomeViewController *weakSelf = self;

    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)postMemberDevices{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDic, nil];
    
    [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint"/*,authArray,@"Authorizations"*/, nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}


-(void)putMemberDevice{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDic, nil];

    
    [MemberDevices putMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"1",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];


}

-(void)deleteMemberDevices{
    
}

-(void)getQB{
    __weak HomeViewController *weakSelf = self;
    
    [QuickBalances getAllBalances:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"DeviceFingerprint",@"HomeBank",@"ServiceType", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)getSuffixInfo{
    
    __weak HomeViewController *weakSelf = self;

    [SuffixInfo getSuffixInfo:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}


-(void)postSuffixPrepherences{
    
    __weak HomeViewController *weakSelf = self;
    [SuffixInfo postSuffixInfo:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",@"123456",@"SuffixID", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];

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
