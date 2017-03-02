//
//  UserNamecontroller.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/1/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@class LoginViewController;
@interface UserNamecontroller : UIViewController
@property (nonatomic,assign) LoginViewController *loginDelegate;
@property (nonatomic,weak)IBOutlet UITextField *userNameTxtFeild;
@property (nonatomic,weak)IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) User *user;


@end
