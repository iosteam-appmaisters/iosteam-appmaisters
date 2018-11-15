//
//  NotifSettingsController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/28/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "NotifSettingsController.h"
#import "MemberDevices.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"

@implementation NotifSettingsController

-(IBAction)countinueButtonClicked:(id)sender{
    
    __weak NotifSettingsController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    [MemberDevices postMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [[[SharedUser sharedManager] userObject]Contextid],@"ContextID",
                                      [ShareOneUtility getUUID],@"Fingerprint",
                                      PROVIDER_TYPE_VALUE,@"ProviderType",
                                      @"ios",@"DeviceType",
                                      [ShareOneUtility getDeviceNotifToken],@"DeviceToken",
                                      authArray,@"Authorizations", nil]
                             message: @"Please wait..."
                            delegate:weakSelf completionBlock:^(NSObject *user) {
                                
                                NSDictionary * result = (NSDictionary*)user;
                                BOOL isDeviceAdded = [result[@"MemberDeviceAdded"]boolValue];
                                if (isDeviceAdded){
                                    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:NOTIFICATION_SETTINGS_UPDATION];
                                    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:PUSH_NOTIF_SETTINGS];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                
                            } failureBlock:^(NSError *error) {
                                NSLog(@"%@",[error localizedDescription]);
                                
                            }];
    
    
}


@end
