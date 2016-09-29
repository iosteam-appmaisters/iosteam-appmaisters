//
//  HomeViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"
#import "AppServiceModel.h"


@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _webview.delegate=self;
    if(!_url)
        _url = HOME_WEB_VIEW_URL;
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSLog(@"Requested url: %@", _url);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //[[AppServiceModel sharedClient] hideProgressAlert];
    NSString *myLoadedUrl = [[webView.request mainDocumentURL] absoluteString];
    NSLog(@"Loaded url: %@", myLoadedUrl);
    
    if(![_url isEqualToString:myLoadedUrl]){
        NSLog(@"It is Redirecting");
    }
}
@end
