//
//  WKWebViewSingleton.h
//  ShareOne
//
//  Created by Ahmed Baloch on 20/05/2020.
//  Copyright © 2020 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewSingleton : NSObject
@property (retain ,nonatomic) WKWebView *webviewSingle;
+ (instancetype) sharedInstance;
+ (instancetype) baseSharedInstance;
@end

NS_ASSUME_NONNULL_END
