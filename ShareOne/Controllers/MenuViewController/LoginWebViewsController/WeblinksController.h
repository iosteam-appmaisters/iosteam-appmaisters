//
//  WeblinksController.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/26/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeblinksController : UIViewController

@property (nonatomic,weak)IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic,strong) NSString *navTitle;
@property (nonatomic,strong) NSString *webLink;


-(IBAction)backButtonClicked:(id)sender;

@end
