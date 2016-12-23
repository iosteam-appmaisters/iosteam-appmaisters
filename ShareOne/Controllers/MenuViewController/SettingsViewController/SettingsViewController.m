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
#import "NotifSettingsController.h"


@implementation SettingsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    if([[UIApplication sharedApplication] isProtectedDataAvailable])
        NSLog(@"appComingFromBackground: TRUE");
    
    else
        NSLog(@"appComingFromBackground: FALSE");

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSettingsLocally];

}
-(void)loadSettingsLocally{
    
    [_quickBalanceSwitch setOn:[ShareOneUtility getSettingsWithKey:QUICK_BAL_SETTINGS]];
    [_showOffersSwitch setOn:[ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]];
    [_touchIDSwitch setOn:[ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]];
    [_retinaScanSwitch setOn:[ShareOneUtility getSettingsWithKey:RETINA_SCAN_SETTINGS]];
    [_pushNotifSwitch setOn:[ShareOneUtility getSettingsWithKey:PUSH_NOTIF_SETTINGS]];
}


-(IBAction)changeSettingsAction:(UISwitch *)sender{
    
    User *obj = [ShareOneUtility getUserObject];

    __weak SettingsViewController *weakSelf = self;

    __block NSString *key=nil;
    __block NSString *alertMesage= nil;
    if([sender isEqual:_quickBalanceSwitch]){
        key=QUICK_BAL_SETTINGS;
        
        if([_quickBalanceSwitch isOn]){
            alertMesage=@"Quick Balance will be shown on login screen.";
        }
        else{
            alertMesage=@"Quick Balance won't be shown on login screen.";
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
                if([_touchIDSwitch isOn]){
                    alertMesage=@"Touch ID will be requested.";
                    User *obj = [ShareOneUtility getUserObject];
                    if(!obj.hasUserUpdatedTouchIDSettings){
                        key=nil;
                        [self addTouchIDAlertScreen];
                        return;
                    }

                }
                else{
                    
                    alertMesage=@"Touch ID will not not be requested.";
                }

            }
        }];
    }
    else if([sender isEqual:_retinaScanSwitch]){
        key=RETINA_SCAN_SETTINGS;
        if([_retinaScanSwitch isOn]){
            alertMesage=@"Retina Scan will be active after your next login.";
        }
        else{
            alertMesage=@"Retina Scan won't be active.";
        }

    }
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

-(void)addTouchIDAlertScreen{
    
    TouchIDSettingsController * obj = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TouchIDSettingsController class])];
    obj.navigationItem.title=@"ENABLE TOUCH ID";
    [self.navigationController pushViewController:obj animated:YES];
}

@end
