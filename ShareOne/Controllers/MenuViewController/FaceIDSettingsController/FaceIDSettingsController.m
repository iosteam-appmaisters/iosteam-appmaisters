//
//  FaceIDSettingsController.m
//  ShareOne
//
//  Created by Malik Wahaj Ahmed on 22/05/2018.
//  Copyright © 2018 Ali Akbar. All rights reserved.
//

#import "FaceIDSettingsController.h"

@interface FaceIDSettingsController ()

@end

@implementation FaceIDSettingsController

-(IBAction)yesButtonClicked:(id)sender{
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:TOUCH_ID_SETTINGS_UPDATION];
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:TOUCH_ID_SETTINGS];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(IBAction)noButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
