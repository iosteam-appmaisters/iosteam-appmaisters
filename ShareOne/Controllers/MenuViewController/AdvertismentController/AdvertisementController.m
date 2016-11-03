//
//  AdvertisementController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/3/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "AdvertisementController.h"
#import "ConstantsShareOne.h"

@interface AdvertisementController ()


@end

@implementation AdvertisementController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://www.google.com.pk/webhp?sourceid=chrome-instant&rlz=1C5CHFA_enPK716PK716&ion=1&espv=2&ie=UTF-8#q=add+subview+on+uiwindow+objective+c"]]]];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSLog(@"Requested url: %@", webView.request.URL.absoluteString);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *myLoadedUrl = [[webView.request mainDocumentURL] absoluteString];
    NSLog(@"Loaded url: %@", myLoadedUrl);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
