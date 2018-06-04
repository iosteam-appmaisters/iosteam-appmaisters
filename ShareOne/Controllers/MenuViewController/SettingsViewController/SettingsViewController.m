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


@implementation SettingsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    _currentBiometric = [UtilitiesHelper isFaceIDAvailable] ? @"Face" : @"Touch";
    
    _versionLabel.text = [NSString stringWithFormat:@"Version: %@", [ShareOneUtility getVersionNumber]];
    _customerIDLabel.text = [NSString stringWithFormat:@"Customer ID: %@", [ShareOneUtility getCustomerId]];
    _appVersionLabel.text = [ShareOneUtility getApplicationVersion];
    
    
    ClientSettingsObject  *config = [Configuration getClientSettingsContent];
    
    if([config.disableadsglobally boolValue]){
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSettingsLocally];

}
-(void)loadSettingsLocally{
    
    __weak SettingsViewController *weakSelf = self;

    [_touchIDLable setText:[NSString stringWithFormat:@"%@ ID",_currentBiometric]];
    
    [ShareOneUtility shouldHideTouchID:weakSelf completionBlock:^(BOOL success) {
        if(success){
            
            [_touchIDLable setHidden:TRUE];
            [_touchIDSwitch setHidden:TRUE];
        }
        else{
            [_touchIDLable setHidden:FALSE];
            [_touchIDSwitch setHidden:FALSE];

        }
    }];

    [_quickBalanceSwitch setOn:[ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
    [_showOffersSwitch setOn:[ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]];
    [_touchIDSwitch setOn:[ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]];
    //[_retinaScanSwitch setOn:[ShareOneUtility getSettingsWithKey:RETINA_SCAN_SETTINGS]];
    [_pushNotifSwitch setOn:[ShareOneUtility getSettingsWithKey:PUSH_NOTIF_SETTINGS]];
    //[_reSkinSwitch setOn:[ShareOneUtility getSettingsWithKey:RE_SKIN_SETTINGS]];
}


-(IBAction)changeSettingsAction:(UISwitch *)sender{
    
//    User *obj = [ShareOneUtility getUserObject];

    __weak SettingsViewController *weakSelf = self;

    __block NSString *key=nil;
    __block NSString *alertMesage= nil;
    if([sender isEqual:_quickBalanceSwitch]){
        key=QUICK_BAL_SETTINGS;
        
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
    /*else if([sender isEqual:_reSkinSwitch]){
        key=RE_SKIN_SETTINGS;

    }*/
    else if([sender isEqual:_touchIDSwitch]){
        
        [ShareOneUtility isTouchIDAvailableWithDelegate:weakSelf completionBlock:^(BOOL success) {
            if(success){
                key=TOUCH_ID_SETTINGS;
                if([_touchIDSwitch isOn]){
                    alertMesage= [NSString stringWithFormat:@"%@ ID will be requested.",_currentBiometric];
                    User *obj = [ShareOneUtility getUserObject];
                    if(!obj.hasUserUpdatedTouchIDSettings){
                        key=nil;
                        [self addBiometricAlertScreen];
                        return;
                    }

                }
                else{
                    alertMesage= [NSString stringWithFormat:@"%@ ID will not not be requested.",_currentBiometric];
                }
            }
            else {
                
                
            }
        }];
    }
    /*else if([sender isEqual:_retinaScanSwitch]){
        key=RETINA_SCAN_SETTINGS;
        if([_retinaScanSwitch isOn]){
            alertMesage=@"Retina Scan will be active after your next login.";
        }
        else{
            alertMesage=@"Retina Scan won't be active.";
        }

    }*/
    else if([sender isEqual:_pushNotifSwitch]){
        key=PUSH_NOTIF_SETTINGS;
        if([_pushNotifSwitch isOn]){
            
            User *obj = [ShareOneUtility getUserObject];
            if(!obj.hasUserUpdatedNotificationSettings){
                [self addNotifAlertScreen];
                return;
            }
            alertMesage=@"Notifications enabled.";
        }
        else{
            
            alertMesage=@"Notifications disabled.";
        }
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

@end
