//
//  UserNamecontroller.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/1/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "UserNamecontroller.h"
#import "LoginViewController.h"
#import "SharedUser.h"

@implementation UserNamecontroller


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];

    self.navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:11],NSFontAttributeName,nil];

}

-(IBAction)submit:(id)sender{

    
    if([_userNameTxtFeild.text length]>0){
        NSString *context = [[[SharedUser sharedManager] userObject] Contextid];
        [User setUserName:[NSDictionary dictionaryWithObjectsAndKeys:_userNameTxtFeild.text,@"AccountName",context,@"ContextID", nil] delegate:self completionBlock:^(id response) {
            
            [self->_userNameTxtFeild resignFirstResponder];
            if([response valueForKey:@"AccountName"]){
                self->_user.UserName=[response valueForKey:@"AccountName"];
            }
            [self->_loginDelegate startLoadingServicesFromChangePassword:self->_user];
            [self dismissViewControllerAnimated:NO completion:nil];
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    else
        [[UtilitiesHelper shareUtitlities] showToastWithMessage:@"Username can not be empty" title:@"Error" delegate:self];


}

- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
