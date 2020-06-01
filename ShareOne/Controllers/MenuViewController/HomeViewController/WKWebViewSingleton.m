//
//  WKWebViewSingleton.m
//  ShareOne
//
//  Created by Ahmed Baloch on 20/05/2020.
//  Copyright © 2020 Ali Akbar. All rights reserved.
//

#import "WKWebViewSingleton.h"
#import <WebKit/WebKit.h>

@implementation WKWebViewSingleton

+ (instancetype) sharedInstance
{
    static WKWebViewSingleton *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[self alloc] init];
            instance.webviewSingle = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        }
    });
    
    return (instance);
}
+ (instancetype) baseSharedInstance
{
    static WKWebViewSingleton *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            float height =     [UIScreen mainScreen].bounds.size.width/5.0;
            instance = [[self alloc] init];
            instance.webviewSingle = [[WKWebView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height)];
        }
    });
    
    return (instance);
}

@end
