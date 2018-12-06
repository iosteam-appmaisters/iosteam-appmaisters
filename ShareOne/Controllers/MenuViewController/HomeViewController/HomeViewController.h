//
//  HomeViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeViewController : BaseViewController<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, strong) NSString *url;
@property (nonatomic,strong) NSMutableURLRequest *webViewRequest;
-(IBAction)prepareForUnwindToHome:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UIButton *printPDFButton;

@end
