//
//  PasswordChangeController.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/1/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class LoginViewController;
@interface PasswordChangeController : UIViewController<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webview;

@property (nonatomic,assign) LoginViewController *loginDelegate;
@property (nonatomic,strong) User *user;




@end
