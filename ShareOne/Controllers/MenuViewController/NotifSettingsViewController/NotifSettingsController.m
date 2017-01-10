//
//  NotifSettingsController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/28/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "NotifSettingsController.h"

@implementation NotifSettingsController

-(IBAction)countinueButtonClicked:(id)sender{
    
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:NOTIFICATION_SETTINGS_UPDATION];
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:PUSH_NOTIF_SETTINGS];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
