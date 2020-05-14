//
//  PasswordChangeController.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/1/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "User.h"

@class LoginViewController;
@interface PasswordChangeController : UIViewController<WKNavigationDelegate>

@property (nonatomic, weak) IBOutlet WKWebView *webview;

@property (nonatomic,assign) LoginViewController *loginDelegate;
@property (nonatomic,strong) User *user;
@property (nonatomic,weak) IBOutlet UIButton *backButton;
@property (nonatomic,weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) NSString *withEndURL;


-(IBAction)backButtonClicked:(id)sender;


@property BOOL isComingFromPasswordExpire;




@end
