//
//  LoadingController.h
//  ShareOne
//
//  Created by Qazi Naveed on 24/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface LoadingController : UIViewController
@property (nonatomic,weak)LoginViewController *controllerDelegate;
@end
