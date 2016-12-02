//
//  LoginViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"
#import "PinResetController.h"

@interface LoginViewController : UIViewController


//@property(nonatomic,strong)UINavigationController* homeNavigationViewController;
- (void)startApplication;

- (void)getSignInWithUser:(User *)user;

-(void)startLoadingServicesFromChangePassword:(User *)user;


@property (strong, nonatomic) PinResetController *objPinResetController;



@end
