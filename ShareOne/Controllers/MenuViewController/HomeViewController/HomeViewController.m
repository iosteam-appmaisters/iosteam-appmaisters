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
#import "User.h"
#import "LoadingController.h"



@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    __weak HomeViewController *weakSelf = self;
    
    if(!self.navigationItem.title){
        self.title=@"HOME";
    }
    //NSLog(@"UDID : %@",[ShareOneUtility getUUID]);

    //[self getMemberDevices];
    //[self putMemberDevice];
    //[self postMemberDevices];
    //[self deleteMemberDevices];
    
    [self getQB];
    //[self getSuffixInfo];
    //[self postSuffixPrepherences];
    
    
    //[self keepMeAlive];
    
    //[self getQuickTransaction];


    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;
    if(!_url)
        _url = HOME_WEB_VIEW_URL;
    
    NSString *queryString = [NSString stringWithFormat:@"%@/%@",_url,[[[SharedUser sharedManager] userObject] ContextID]];
    
    NSLog(@"queryString: %@",queryString);
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
    
    NSDictionary *zuthDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDic, nil];
    
    [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
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
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDic, nil];
    
    
    [MemberDevices deleteMemberDevice:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"14",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];

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
    [SuffixInfo postSuffixInfo:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]ContextID],@"ContextID",@"55078",@"SuffixID", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];

}

-(void)keepMeAlive{
    
    __weak HomeViewController *weakSelf = self;

    [User keepAlive:nil delegate:weakSelf completionBlock:^(BOOL sucess) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}


-(void)getQuickTransaction{
    
    __weak HomeViewController *weakSelf = self;
    

    [QuickBalances getAllQuickTransaction:[NSDictionary dictionaryWithObjectsAndKeys:@"HomeBank",@"ServiceType",[ShareOneUtility getUUID],@"DeviceFingerprint",@"55220",@"SuffixID",@"2",@"NumberOfTransactions", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
//    NSLog(@"Requested url: %@", webView.request.URL.absoluteString);
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
