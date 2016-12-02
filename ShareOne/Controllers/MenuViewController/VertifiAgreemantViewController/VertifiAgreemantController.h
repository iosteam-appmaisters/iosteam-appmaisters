//
//  VertifiAgreemantController.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/24/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface VertifiAgreemantController :BaseViewController

@property (nonatomic,weak)IBOutlet UIWebView *webView;
-(IBAction)goAcceptAgreemant:(id)sender;
-(IBAction)goDeclineAgreemant:(id)sender;

@end
