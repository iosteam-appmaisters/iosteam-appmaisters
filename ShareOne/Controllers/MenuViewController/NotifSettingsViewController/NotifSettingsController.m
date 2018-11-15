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
    
    [self enablePushNotification:^(BOOL status, NSError * error){
        if (status && error == nil){
            [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:NOTIFICATION_SETTINGS_UPDATION];
            [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:PUSH_NOTIF_SETTINGS];
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (!status && error != nil) {
            [[ShareOneUtility shareUtitlities] showToastWithMessage:error.localizedDescription title:@"" delegate:weakSelf];
        }
    }];
}

-(void)enablePushNotification:(void(^)(BOOL status, NSError* error))completionBlock{
    
    __weak NotifSettingsController *weakSelf = self;
    
    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        [ShareOneUtility getUUID];
        NSDictionary * response = (NSDictionary*)user;
        
        [MemberDevices getCurrentMemberDeviceObject:response completionBlock:^(MemberDevices * memberDevice){
            NSLog(@"%@",memberDevice.Id.stringValue);
            
            [self putMemberDevice:memberDevice.Id.stringValue block:^(BOOL status, NSError* error){
                completionBlock(status,error);
            }];
            
        } failureBlock:^(NSError * error){
            NSLog(@"%@",[error localizedDescription]);
            completionBlock(NO,error);
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        completionBlock(NO,error);
    }];
}

-(void)putMemberDevice:(NSString*)memberDeviceID block:(void(^)(BOOL status, NSError* error))completionBlock {
    
    __weak NotifSettingsController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    
    [MemberDevices putMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [[[SharedUser sharedManager] userObject]Contextid],@"ContextID",
                                     [ShareOneUtility getUUID],@"Fingerprint",
                                     PROVIDER_TYPE_VALUE,@"ProviderType",
                                     @"ios",@"DeviceType",
                                     memberDeviceID,@"ID",
                                     [ShareOneUtility getDeviceNotifToken],@"DeviceToken",
                                     authArray,@"Authorization", nil]
                           delegate:weakSelf completionBlock:^(NSObject *user) {
                               
                               NSDictionary * result = (NSDictionary*)user;
                               BOOL isDeviceUpdated = [result[@"MemberDeviceEdited"]boolValue];
                               completionBlock(isDeviceUpdated,nil);
                               
                           } failureBlock:^(NSError *error) {
                               NSLog(@"%@",[error localizedDescription]);
                               completionBlock(NO,error);
                           }];
    
}



@end
