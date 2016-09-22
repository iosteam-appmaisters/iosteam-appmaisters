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
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
}
@end
