//
//  HomeViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"
#import <WebKit/WebKit.h>

@interface HomeViewController : BaseViewController<WKNavigationDelegate,WKUIDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webview;
//@property (copy) WKWebView *webviewC;
@property (nonatomic, strong) NSString *url;
@property (nonatomic,strong) NSString *lastUrl;
@property (nonatomic,strong) NSMutableURLRequest *webViewRequest;
-(IBAction)prepareForUnwindToHome:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UIButton *printPDFButton;
@property (weak, nonatomic) IBOutlet UIButton *backBtnForPDFs;

@end
