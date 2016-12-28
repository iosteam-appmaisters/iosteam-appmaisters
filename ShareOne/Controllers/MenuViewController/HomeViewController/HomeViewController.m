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
//#import "WebViewProxyURLProtocol.h"



@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenuFromHomeView) name:SHOW_MENU_NOTIFICATION object:nil];

    __weak HomeViewController *weakSelf = self;
    
    
    if(!self.navigationItem.title){
        self.navigationItem.title=@"Account Summary";
    }
    
//    _isLoadedFirstTime= TRUE;
    
//    NSLog(@"UDID : %@",[ShareOneUtility getUUID]);

    //[self getMemberDevices];
    //[self putMemberDevice];
    //[self postMemberDevices];
    //[self deleteMemberDevices];
    
    //[self getQB];
    //[self getSuffixInfo];
    //[self postSuffixPrepherences];
    
    
    //[self keepMeAlive];
    
    //[self getQuickTransaction];
    
    //[self setUserName];
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;

    if(!_url)
        _url = @"";

    
    
    
    if([_url containsString:@"nsmobiledemo"]){
        [weakSelf.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }
    
    else{
        
        [User postContextIDForSSOWithDelegate:weakSelf withTabName:_url completionBlock:^(id urlPath) {
            
            [weakSelf.webview loadRequest:(NSMutableURLRequest *)urlPath];
            
        } failureBlock:^(NSError *error) {
            
        }];

    }
    

}

-(void)showMenuFromHomeView{
    
    [self performSelector:@selector(showSideMenu) withObject:nil afterDelay:0.1];
//    [self showSideMenu];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if([_webview.request.URL.absoluteString containsString:@"Account/Summary"])
//    if([self.navigationItem.title isEqualToString:@"Account Summary"] && !_isLoadedFirstTime){
//        [self showMenuFromHomeView];
//    }
//    else
//        _isLoadedFirstTime= FALSE;
//    [self sendAdvertismentViewToBack];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self sendAdvertismentViewToBack];
    [self bringAdvertismentViewToFront];

}


#define mark - UnWind Segue
-(IBAction)prepareForUnwindToHome:(UIStoryboardSegue *)segue{
    NSLog(@"prepareForUnwindToHome");
}

-(void)getMemberDevices{
    __weak HomeViewController *weakSelf = self;

    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)postMemberDevices{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];

    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}


-(void)putMemberDevice{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDic, nil];

    
    [MemberDevices putMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"1",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];


}

-(void)deleteMemberDevices{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    
    [MemberDevices deleteMemberDevice:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"96",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];

}

-(void)getQB{
    __weak HomeViewController *weakSelf = self;
    
    [QuickBalances getAllBalances:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"DeviceFingerprint",@"HomeBank",@"ServiceType", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
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
    [SuffixInfo postSuffixInfo:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",@"55078",@"SuffixID", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
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

-(void)setUserName{
    
    NSString *context = [[[SharedUser sharedManager] userObject] Contextid];
    [User setUserName:[NSDictionary dictionaryWithObjectsAndKeys:/*@"",@"AccountName",*/context,@"ContextID", nil] delegate:self completionBlock:^(id response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    

    NSLog(@"webViewDidStartLoad url: %@", webView.request.URL.absoluteString);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    NSLog(@"webViewDidFinishLoad url: %@", webView.request.URL.absoluteString);

    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([theTitle containsString:@"Account Summary"]){
        theTitle = [theTitle componentsSeparatedByString:@"-"][0];
    }
    

    self.navigationItem.title=theTitle;

    [self setTitleOnNavBar:theTitle];
    

    //NSString *yourHTMLSourceCodeString_inner = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //NSLog(@"yourHTMLSourceCodeString: %@",yourHTMLSourceCodeString_inner);
    
    
    //NSString *yourHTMLSourceCodeString_outer = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    //NSLog(@"yourHTMLSourceCodeString: %@",yourHTMLSourceCodeString_outer);



    __weak HomeViewController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
    [self trackPrintingEventWithScheme:webView.request.URL.scheme];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    
    BOOL shouldReload = TRUE;
    
    NSLog(@"shouldStartLoadWithRequest : %@",request.URL.absoluteString);
    
    NSString *yourHTMLSourceCodeString_inner = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    
    if([[[request URL] absoluteString] isEqualToString:@"https://nsmobilecp.ns3web.com/Account/print"]){
        shouldReload = FALSE;
        [self printIt:yourHTMLSourceCodeString_inner];
    }
    
//    NSString* clicked = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('memberInfo').click();"];
//    
//    NSLog(@"CLICK %@",clicked);
//    return TRUE;
    return shouldReload;
}

-(void)printIt:(NSString *)html{
    
    __weak HomeViewController *weakSelf = self;

    if ([UIPrintInteractionController class]) {
        // Create an instance of the class and use it.
        
        [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];

        UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:html];
        
        htmlFormatter.contentInsets = UIEdgeInsetsMake(0, 20, 0, 20);

        UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
        [printController setPrintFormatter:htmlFormatter];
        [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
            if(completed && !error){
                NSLog(@"Print done");
            }
            else{
                if(error)
                    [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:weakSelf];
            }
        }];

    } else {
        // Alternate code path to follow when the
        // class is not available.
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Printer not found" title:@"" delegate:weakSelf];
    }
}


-(void)trackPrintingEventWithScheme:(NSString * )scheme{
    
    NSLog(@"trackPrintingEventWithScheme");
    NSString *jsString = [NSString stringWithFormat:@"(function(){var originalPrintFn = window.print;window.print = function(){window.location = '%@:print';}})();",scheme];
    [self.webview stringByEvaluatingJavaScriptFromString:jsString];
}

@end
