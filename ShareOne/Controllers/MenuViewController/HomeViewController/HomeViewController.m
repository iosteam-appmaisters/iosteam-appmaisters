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
    
    
//    if(!self.navigationItem.title){
//        self.navigationItem.title=@"Account Summary";
//    }
    
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

    
    __block NSMutableURLRequest *request = nil;
    
    
    if([_url containsString:@"nsmobiledemo"] || [_url isEqualToString:@"https://www.c2cfcu.com/rates.php"]){
        
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
//        [weakSelf.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
        
        [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
        [weakSelf.webview loadRequest:request];
        
    }
    
    else{
        
        [User postContextIDForSSOWithDelegate:weakSelf withTabName:_url completionBlock:^(id urlPath) {
            
            request =(NSMutableURLRequest *)[urlPath mutableCopy];
            
            [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];

            [weakSelf.webview loadRequest:request];
            
        } failureBlock:^(NSError *error) {
            
        }];

    }
    
    _webViewRequest = request;

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
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:FALSE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:FALSE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];

    
    [MemberDevices putMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"109",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
    } failureBlock:^(NSError *error) {
        
    }];


}

-(void)deleteMemberDevices{
    
    __weak HomeViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    
    [MemberDevices deleteMemberDevice:[NSDictionary dictionaryWithObjectsAndKeys:[[[SharedUser sharedManager] userObject]Contextid],@"ContextID",[ShareOneUtility getUUID],@"Fingerprint",@"109",@"ID",authArray,@"Authorizations", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
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
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    
    [self showAlertWithTitle:@"" AndMessage:ERROR_MESSAGE];
    
//    [[UtilitiesHelper shareUtitlities]showToastWithMessage:ERROR_MESSAGE title:@"" delegate:self];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad url: %@", webView.request.URL.absoluteString);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    NSLog(@"webViewDidFinishLoad url: %@", webView.request.URL.absoluteString);

    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([theTitle containsString:@"Account Summary"]){
        [self trackPrintingEventWithScheme:webView.request.URL.scheme];
    }

    __weak HomeViewController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    
    BOOL shouldReload = TRUE;
    
    
    NSLog(@"shouldStartLoadWithRequest : %@",request.URL.absoluteString);
    
    NSString *yourHTMLSourceCodeString_inner = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    
    if([[[request URL] absoluteString] containsString:@"Account/print"]){
        shouldReload = FALSE;
        [self printIt:yourHTMLSourceCodeString_inner];
    }
    
    if([webView tag]==ADVERTISMENT_WEBVIEW_TAG && ![request.URL.absoluteString containsString:@"deeptarget.com"]){
        shouldReload = FALSE;
        
        NSURL *url = [NSURL URLWithString:request.URL.absoluteString];
        [[UIApplication sharedApplication] openURL:url];
    }
    
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

                             [_webview loadRequest:_webViewRequest];
                             
                         }];
    [alert addAction:tryAgain];

    [self presentViewController:alert animated:YES completion:nil];
    
}


@end
