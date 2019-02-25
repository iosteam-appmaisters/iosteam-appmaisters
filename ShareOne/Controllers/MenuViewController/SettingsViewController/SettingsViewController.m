//
//  SettingsViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SettingsViewController.h"
#import "ShareOneUtility.h"
#import "TouchIDSettingsController.h"
#import "FaceIDSettingsController.h"
#import "NotifSettingsController.h"
#import "MemberDevices.h"
#import "SharedUser.h"
#import "AppDelegate.h"

@implementation SettingsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    _currentBiometric = [UtilitiesHelper isFaceIDAvailable] ? @"Face" : @"Touch";
    
    _versionLabel.text = [NSString stringWithFormat:@"Version: %@", [ShareOneUtility getVersionNumber]];
    _customerIDLabel.text = [NSString stringWithFormat:@"Customer ID: %@", [ShareOneUtility getCustomerId]];
    _appVersionLabel.text = [ShareOneUtility getApplicationVersion];
    
    ClientSettingsObject  *config = [Configuration getClientSettingsContent];
    
    if([config.hideshowoffersoption boolValue]){
        [_showOffersSwitch setHidden:TRUE];
        [_showOffersLbl setHidden:TRUE];
    }
    else{
        [_showOffersSwitch setHidden:FALSE];
        [_showOffersLbl setHidden:FALSE];
    }
    
    if ([config.allownotifications boolValue]) {
        [_pushNotifSwitch setHidden:FALSE];
        [_pushNotificationLabel setHidden:FALSE];
    }
    else {
        [_pushNotifSwitch setHidden:TRUE];
        [_pushNotificationLabel setHidden:TRUE];
        
    }
    
    if ([config.enablequickview boolValue]){
        [_quickBalanceSwitch setHidden:FALSE];
        [_quickBalanceLabel setHidden:FALSE];
    }
    else {
        [_quickBalanceSwitch setHidden:TRUE];
        [_quickBalanceLabel setHidden:TRUE];
    }
    
    
}

-(void)onNewTokenRegisteration:(NSNotification *) notification {
    
    __weak SettingsViewController *weakSelf = self;
    
    NSString * message = @"";
    if (notification.userInfo != nil){
        message = [(NSError*)[notification.userInfo valueForKey:@"error"] localizedDescription];
        [[ShareOneUtility shareUtitlities] showToastWithMessage:message title:@"" delegate:nil];
    }
    else {
        [self enablePushNotificationAgain:^(BOOL status, NSError* error){
            
            NSString * alertMessage = status == YES ?  @"Notifications enabled." : error.localizedDescription;
            [ShareOneUtility saveSettingsWithStatus:status AndKey:PUSH_NOTIF_SETTINGS];
            [self->_pushNotifSwitch setOn:status];
            [[ShareOneUtility shareUtitlities] showToastWithMessage:alertMessage title:@"" delegate:weakSelf];
            
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSettingsLocally];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewTokenRegisteration:) name:@"NewTokenRegisteration" object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NewTokenRegisteration" object:nil];
}

-(void)loadSettingsLocally{
    
    __weak SettingsViewController *weakSelf = self;
    
    [_touchIDLable setText:[NSString stringWithFormat:@"%@ ID",_currentBiometric]];
    
    [ShareOneUtility shouldHideTouchID:weakSelf completionBlock:^(BOOL success) {
        if(success){
            
            [self->_touchIDLable setHidden:TRUE];
            [self->_touchIDSwitch setHidden:TRUE];
        }
        else{
            [self->_touchIDLable setHidden:FALSE];
            [self->_touchIDSwitch setHidden:FALSE];
            
        }
    }];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:QUICK_BAL_SETTINGS]) {
        [_quickBalanceSwitch setOn:[ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
    }else{
        ClientSettingsObject  *config = [Configuration getClientSettingsContent];
        [_quickBalanceSwitch setOn:config.quickviewdefaultsetting];
    }
    
    [_showOffersSwitch setOn:[ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]];
    [_touchIDSwitch setOn:[ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]];
    [_pushNotifSwitch setOn:[ShareOneUtility getSettingsWithKey:PUSH_NOTIF_SETTINGS]];
}


-(IBAction)changeSettingsAction:(UISwitch *)sender{
    
    __weak SettingsViewController *weakSelf = self;
    
    __block NSString *key=nil;
    __block NSString *alertMesage= nil;
    if([sender isEqual:_quickBalanceSwitch]){
        key=QUICK_BAL_SETTINGS;
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:QUICK_BAL_SETTINGS];

        if([_quickBalanceSwitch isOn]){
            alertMesage = @"Quick View is a convenient way to review your balance and recent transactions. It is not recommended for devices you may share with others. It is your responsibility to ensure that you take precautions to protect your account information on your device.";
        }
        else{
            alertMesage=@"Quick View won't be shown on login screen.";
        }
    }
    else if([sender isEqual:_showOffersSwitch]){
        key=SHOW_OFFERS_SETTINGS;
        if([_showOffersSwitch isOn]){
            alertMesage=@"Offers will be displayed.";
        }
        else{
            alertMesage=@"Offers will not be displayed.";
        }
    }
    else if([sender isEqual:_touchIDSwitch]){
        
        [ShareOneUtility isTouchIDAvailableWithDelegate:weakSelf completionBlock:^(BOOL success) {
            if(success){
                key=TOUCH_ID_SETTINGS;
                if([self->_touchIDSwitch isOn]){
                    alertMesage= [NSString stringWithFormat:@"%@ ID will be requested.",self->_currentBiometric];
                    User *obj = [ShareOneUtility getUserObject];
                    if(!obj.hasUserUpdatedTouchIDSettings){
                        key=nil;
                        [self addBiometricAlertScreen];
                        return;
                    }
                    
                }
                else{
                    alertMesage= [NSString stringWithFormat:@"%@ ID will not be requested.",self->_currentBiometric];
                }
            }
            else {
                
                
            }
        }];
    }
    else if([sender isEqual:_pushNotifSwitch]){
        key=PUSH_NOTIF_SETTINGS;
        if([_pushNotifSwitch isOn]){
            
            User *obj = [ShareOneUtility getUserObject];
            if(!obj.hasUserUpdatedNotificationSettings){
                [self addNotifAlertScreen];
                return;
            }
            else {
                
                //Enable Notifications
                
                AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [appDelegate registerForPushNotifications:[UIApplication sharedApplication]];
                
                
            }
            
        }
        else{
            
            [self disablePushNotification:^(BOOL status, NSError* error){
                
                NSString * alertMessage = status == YES ?  @"Notifications disabled." : error.localizedDescription;
                [[ShareOneUtility shareUtitlities] showToastWithMessage:alertMessage title:@"" delegate:weakSelf];

                if (status) {
                    [ShareOneUtility saveSettingsWithStatus:NO AndKey:PUSH_NOTIF_SETTINGS];
                    [sender setOn:NO];
                    
                    [[UIApplication sharedApplication]unregisterForRemoteNotifications];
                    
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"device_token"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                
            }];
        }
    }
    
    if ([key isEqualToString:PUSH_NOTIF_SETTINGS]){
        return;
    }
    
    if(key){
        
        if(![key isEqualToString:TOUCH_ID_SETTINGS] && ![key isEqualToString:RE_SKIN_SETTINGS])
            [[ShareOneUtility shareUtitlities] showToastWithMessage:alertMesage title:@"" delegate:weakSelf];
        [ShareOneUtility saveSettingsWithStatus:[sender isOn] AndKey:key];
        if([key isEqualToString:SHOW_OFFERS_SETTINGS]){
            if([sender isOn]){
                [self bringAdvertismentViewToFront];
            }else{
                [self sendAdvertismentViewToBack];
            }
        }
    }
    else
        [sender setOn:FALSE];
}

-(void)addNotifAlertScreen{
    
    NotifSettingsController * obj = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NotifSettingsController class])];
    obj.navigationItem.title=@"ENABLE PUSH NOTIFICATION";
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(void)addBiometricAlertScreen{
    
    if ([_currentBiometric isEqualToString:@"Face"]){
        
        FaceIDSettingsController * obj = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([FaceIDSettingsController class])];
        obj.navigationItem.title=[NSString stringWithFormat:@"ENABLE %@ ID",[_currentBiometric uppercaseString]];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else {
        TouchIDSettingsController * obj = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TouchIDSettingsController class])];
        obj.navigationItem.title=[NSString stringWithFormat:@"ENABLE %@ ID",[_currentBiometric uppercaseString]];
        [self.navigationController pushViewController:obj animated:YES];
    }
}



-(void)enablePushNotificationAgain:(void(^)(BOOL status, NSError* error))completionBlock{
    
    __weak SettingsViewController *weakSelf = self;
    
    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        [ShareOneUtility getUUID];
        NSDictionary * response = (NSDictionary*)user;
        
        [MemberDevices getCurrentMemberDeviceObject:response completionBlock:^(MemberDevices * memberDevice){
            NSLog(@"%@",memberDevice.Id.stringValue);
            
            [self putMemberDevice:memberDevice.Id.stringValue withToken: YES block:^(BOOL status, NSError* error){
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

-(void)putMemberDevice:(NSString*)memberDeviceID withToken:(BOOL)isDeviceToken block:(void(^)(BOOL status, NSError* error))completionBlock {
    
    __weak SettingsViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    
    [MemberDevices putMemberDevices:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [[[SharedUser sharedManager] userObject]Contextid],@"ContextID",
                                     [ShareOneUtility getUUID],@"Fingerprint",
                                     PROVIDER_TYPE_VALUE,@"ProviderType",
                                     @"ios",@"DeviceType",
                                     memberDeviceID,@"ID",
                                     isDeviceToken ? [ShareOneUtility getDeviceNotifToken] : [NSNull null],@"DeviceToken",
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

-(void)disablePushNotification:(void(^)(BOOL status, NSError* error))completionBlock{
    
    __weak SettingsViewController *weakSelf = self;
    
    [MemberDevices getMemberDevices:nil delegate:weakSelf completionBlock:^(NSObject *user) {
        [ShareOneUtility getUUID];
        NSDictionary * response = (NSDictionary*)user;
        
        [MemberDevices getCurrentMemberDeviceObject:response completionBlock:^(MemberDevices * memberDevice){
            NSLog(@"%@",memberDevice.Id.stringValue);
            
            [self putMemberDevice:memberDevice.Id.stringValue withToken: NO block:^(BOOL status, NSError* error){
                completionBlock(status,nil);
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

-(void)deleteMemberDevice:(NSString*)memberDeviceID block:(void(^)(BOOL status))completionBlock {
    
    __weak SettingsViewController *weakSelf = self;
    
    NSDictionary *zuthDicForQB = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSDictionary *zuthDicForQT = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Type",[NSNumber numberWithBool:TRUE],@"Status", nil];
    NSArray *authArray= [NSArray arrayWithObjects:zuthDicForQB,zuthDicForQT, nil];
    
    
    [MemberDevices deleteMemberDevice:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [[[SharedUser sharedManager] userObject]Contextid],@"ContextID",
                                       memberDeviceID,@"ID",
                                       authArray,@"Authorization", nil]
                             delegate:weakSelf completionBlock:^(NSObject *user) {
                                 
                                 NSDictionary * result = (NSDictionary*)user;
                                 BOOL isDeviceDeleted = [result[@"MemberDeviceDeleted"]boolValue];
                                 completionBlock(isDeviceDeleted);
                                 
                             } failureBlock:^(NSError *error) {
                                 NSLog(@"%@",[error localizedDescription]);
                                 completionBlock(NO);
                             }];
    
}

@end
