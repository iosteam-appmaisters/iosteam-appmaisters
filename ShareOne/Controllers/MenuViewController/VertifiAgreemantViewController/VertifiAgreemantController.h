//
//  VertifiAgreemantController.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/24/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BaseViewController.h"

@interface VertifiAgreemantController :BaseViewController

@property (nonatomic,weak)IBOutlet WKWebView *webView;
@property (nonatomic, weak) IBOutlet UIButton *acceptBtn;
@property (nonatomic, weak) IBOutlet UIButton *declineBtn;

-(IBAction)goAcceptAgreemant:(id)sender;
-(IBAction)goDeclineAgreemant:(id)sender;

@end
