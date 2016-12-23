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

-(IBAction)submit:(id)sender{

    
    if([_userNameTxtFeild.text length]>0){
        NSString *context = [[[SharedUser sharedManager] userObject] Contextid];
        [User setUserName:[NSDictionary dictionaryWithObjectsAndKeys:_userNameTxtFeild.text,@"AccountName",context,@"ContextID", nil] delegate:self completionBlock:^(id response) {
            
            [_loginDelegate startLoadingServicesFromChangePassword:nil];
            
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    else
        [[UtilitiesHelper shareUtitlities] showToastWithMessage:@"Username can not be empty" title:@"Error" delegate:self];


}

- (BOOL)shouldAutorotate{
    
    return NO;
}
@end
