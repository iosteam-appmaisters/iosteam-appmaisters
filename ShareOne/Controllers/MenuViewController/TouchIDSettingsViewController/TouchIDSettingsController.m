//
//  TouchIDSettingsController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/28/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "TouchIDSettingsController.h"

@implementation TouchIDSettingsController

-(IBAction)yesButtonClicked:(id)sender{
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:TOUCH_ID_SETTINGS_UPDATION];
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:TOUCH_ID_SETTINGS];
    [self.navigationController popViewControllerAnimated:YES];

}
-(IBAction)noButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
