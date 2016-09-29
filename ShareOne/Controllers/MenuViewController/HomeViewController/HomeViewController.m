//
//  HomeViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"

@implementation HomeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    if(!_url)
        _url = HOME_WEB_VIEW_URL;
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}
@end
