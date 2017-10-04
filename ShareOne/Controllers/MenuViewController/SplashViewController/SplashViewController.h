//
//  SplashViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"


@interface SplashViewController : UIViewController

@property (nonatomic,weak)IBOutlet UIActivityIndicatorView *indicatorView;
//@property (nonatomic,strong)LoginViewController *objLoginViewController;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@property (nonatomic) BOOL isComingFromBackground;

@end
