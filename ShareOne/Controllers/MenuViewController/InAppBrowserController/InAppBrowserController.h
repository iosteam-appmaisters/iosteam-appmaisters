//
//  InAppBrowserController.h
//  ShareOne
//
//  Created by Qazi Naveed on 3/28/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LeftMenuViewController.h"
#import <WebKit/WebKit.h>


@interface InAppBrowserController : BaseViewController<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) NSMutableURLRequest *request;
@end
