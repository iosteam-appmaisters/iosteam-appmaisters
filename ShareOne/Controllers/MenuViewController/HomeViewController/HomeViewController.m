//
//  HomeViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "HomeViewController.h"

#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "MemberDevices.h"
#import "QuickBalances.h"
#import "SuffixInfo.h"
#import "User.h"

#import "UIPrintPageRenderer+PrintToPDF.h"

@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setBackBtnImage];
    
    __weak HomeViewController *weakSelf = self;
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    _webview.delegate=self;
    _printPDFButton.hidden = YES;
    _backBtnForPDFs.hidden = YES;
    
    if(!_url)
        _url = @"";

    
    __block NSMutableURLRequest *request = nil;
    
    
    if([_url containsString:@"http"]){
        
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
        [weakSelf.webview loadRequest:request];
        
    }
    
    else{
        
        if ([_url isEqualToString:[Configuration getMenuItemHomeURL]] && [[NSUserDefaults standardUserDefaults]boolForKey:SHOULD_SSO]){
            [User postContextIDForSSOWithDelegate:weakSelf withTabName:_url completionBlock:^(NSMutableURLRequest* request) {

                NSLog(@"SSO Generated");
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SHOULD_SSO];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
                
                [weakSelf.webview loadRequest:request];

            } failureBlock:^(NSError *error) {

            }];

        }
        else {
        
            NSString *siteurl = [NSString stringWithFormat:@"%@/%@",[Configuration getSSOBaseUrl],_url];
            
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:siteurl]];
            
            [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
            
            [weakSelf.webview loadRequest:request];
            
        }
        

    }
    
    _webViewRequest = request;
    self.title = [ShareOneUtility getNavBarTitle:@""];

    self.title = [ShareOneUtility getNavBarTitle:@""];
}

-(void)setBackBtnImage{
    UIImage *back_icon = [[UIImage imageNamed:@"back_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_backBtnForPDFs setTintColor:UIColor.blackColor];
    [_backBtnForPDFs setImage:back_icon forState:UIControlStateNormal];
}

-(void)showMenuFromHomeView{
    [self performSelector:@selector(showSideMenu) withObject:nil afterDelay:0.1];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self bringAdvertismentViewToFront];
}

- (void)dealloc {
    
    _webview.delegate = nil;
    [_webview stopLoading];
    
}

#define mark - UnWind Segue
-(IBAction)prepareForUnwindToHome:(UIStoryboardSegue *)segue{
    NSLog(@"prepareForUnwindToHome");
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




- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    
    BOOL shouldReload = TRUE;
    
    NSLog(@"shouldStartLoadWithRequest : %@",request.URL.absoluteString);
    
    if([[[request URL] absoluteString] containsString:@"/log/out"] || [[[request URL] absoluteString] containsString:@"/Log/Out"] || [[[request URL] absoluteString] containsString:@"/log/in"] || [[[request URL] absoluteString] containsString:@"/Log/In"]){
        
        shouldReload = TRUE;
        webView.hidden = YES;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:LOGOUT_BEGIN];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if (![[NSUserDefaults standardUserDefaults]boolForKey:NORMAL_LOGOUT]){
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:TECHNICAL_LOGOUT];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    
    if([[[request URL] absoluteString] containsString:@"/SecondaryAuth/"]) {
        NSLog(@"Security Challenge Detected...");
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        self.hideSideMenu = YES;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SIDEMENU_HIDDEN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:SIDEMENU_HIDDEN]) {
            [self createLefbarButtonItems];
            self.navigationItem.hidesBackButton = NO;
            self.hideSideMenu = NO;
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SIDEMENU_HIDDEN];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    
    if([webView tag]==ADVERTISMENT_WEBVIEW_TAG && ![request.URL.absoluteString containsString:@"deeptarget.com"]){
        shouldReload = FALSE;
        
        NSURL *url = [NSURL URLWithString:request.URL.absoluteString];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    //Testing purpose will be reset.
    NSString* const kOpenInNewTabPrefix = @"newtab:";//This NEEDS to end with ':'

    if ([[request.URL.absoluteString lowercaseString] hasPrefix:[kOpenInNewTabPrefix lowercaseString]])
    {
        // JS-hacked URl is a target=_blank url - manually open the browser.
        NSURL *url = [NSURL URLWithString:[request.URL.absoluteString substringFromIndex:[kOpenInNewTabPrefix length]]];
        [[UIApplication sharedApplication] openURL:url];

        return YES;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

    }
    if (navigationType == UIWebViewNavigationTypeReload) {

    }
    if (navigationType == UIWebViewNavigationTypeBackForward) {

    }
    if ([[[request URL] absoluteString] hasPrefix:@"newtab:"])
    {
        // JS-hacked URl is a target=_blank url - manually open the browser.
        NSURL *url = [NSURL URLWithString:[request.URL.absoluteString substringFromIndex:7]];
        [[UIApplication sharedApplication] openURL:url];
        shouldReload = FALSE;
    }
    //end testing code
    return shouldReload;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad url: %@", webView.request.URL.absoluteString);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSLog(@"webViewDidFinishLoad url: %@", webView.request.URL.absoluteString);
    NSString * contentType = [webView stringByEvaluatingJavaScriptFromString:@"document.contentType;"];
    if ([contentType isEqualToString:@"application/pdf"]){
        _printPDFButton.hidden = NO;
        _backBtnForPDFs.hidden = NO;
    }else{
        _printPDFButton.hidden = YES;
        _backBtnForPDFs.hidden = YES;
    }
    
    [self logoutAfterChecking];
    
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([theTitle containsString:@"Account Summary"]){
        [self trackPrintingEventWithScheme:webView.request.URL.scheme];
    }

    if([webView.request.URL.absoluteString containsString:@"print=True"]){
        [self savePDFToDocumentsDirectory];
    }
    
    __weak HomeViewController *weakSelf = self;
    if(![webView.request.URL.absoluteString containsString:@"deeptarget"])
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [self logoutAfterChecking];
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    
    if ([error code] != NSURLErrorCancelled) {
        [self showAlertWithTitle:@"" AndMessage:[Configuration getMaintenanceVerbiage]];
    }
    
    
}

-(void)logoutAfterChecking {
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:LOGOUT_BEGIN]) {
        
        BOOL isTechnicalLogout = [[NSUserDefaults standardUserDefaults]boolForKey:TECHNICAL_LOGOUT];
        
        if (isTechnicalLogout) {
            
            [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
                NSLog(@"keepAlive from validateSessionForTouchID_OffSession");
                [ShareOneUtility hideProgressViewOnView:self.view];
                
                if(sucess){
                    NSLog(@"Session Active After Technical Logout...");
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SESSION_ACTIVE_LOGOUT];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                else {
                    NSLog(@"Session Not Active After Technical Logout...");
                    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SESSION_ACTIVE_LOGOUT];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                [self logoutActions];
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Keep Alive Checking Failure After Technical Logout...");
                [self logoutActions];
            }];
        }
        else {
            [self logoutActions];
        }
    }
}

#define kPaperSizeA4 CGSizeMake(595.2,841.8)

- (IBAction)printPDF:(UIButton *)sender {
    
    [self savePDFToDocumentsDirectory];
}

-(void)savePDFToDocumentsDirectory {
    
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:self.webview.viewPrintFormatter startingAtPageAtIndex:0];
    
    //increase these values according to your requirement
    float topPadding = 10.0f;
    float bottomPadding = 10.0f;
    float leftPadding = 10.0f;
    float rightPadding = 10.0f;
    CGRect printableRect = CGRectMake(leftPadding,
                                      topPadding,
                                      kPaperSizeA4.width-leftPadding-rightPadding,
                                      kPaperSizeA4.height-topPadding-bottomPadding);
    CGRect paperRect = CGRectMake(0, 0, kPaperSizeA4.width, kPaperSizeA4.height);
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    NSData *pdfData = [render printToPDF];
    if (pdfData) {
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        documentsURL = [documentsURL URLByAppendingPathComponent:@"localFile.pdf"];
        [pdfData writeToURL:documentsURL  atomically: YES];
        [self connectPrinter];
    }
    else
    {
        NSLog(@"PDF couldnot be created");
    }
}


-(void)connectPrinter {
    
        [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
        
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        documentsURL = [documentsURL URLByAppendingPathComponent:@"localFile.pdf"];
        
        NSData *myData = [NSData dataWithContentsOfURL:documentsURL];
        
        UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
        
        if(pic && [UIPrintInteractionController canPrintData: myData] ) {
            
            //pic.delegate = self;
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = @"New";//[path lastPathComponent];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            pic.printInfo = printInfo;
            pic.showsPageRange = YES;
            pic.printingItem = myData;
            
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
                //self.content = nil;
                if (!completed && error) {
                    NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
                }
            };
            
            [pic presentAnimated:YES completionHandler:completionHandler];
            
        }
        
        
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

                             [self->_webview loadRequest:self->_webViewRequest];
                             
                         }];
    [alert addAction:tryAgain];

    [self presentViewController:alert animated:YES completion:nil];
    
}


@end
