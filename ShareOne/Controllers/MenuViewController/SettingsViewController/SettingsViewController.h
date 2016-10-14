//
//  SettingsViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController

-(IBAction)changeSettingsAction:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UISwitch *quickBalanceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showOffersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *retinaScanSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotifSwitch;

@end
