//
//  VertifiAgreemantController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/24/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "VertifiAgreemantController.h"
#import "MobileDepositController.h"

@implementation VertifiAgreemantController

-(void)viewDidLoad{
    [super viewDidLoad];
}


-(IBAction)goAcceptAgreemant:(id)sender{

    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:VERTIFI_AGREEMANT_KEY];
    
    MobileDepositController *objMobileDepositController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MobileDepositController class])];
    objMobileDepositController.navigationItem.title=[ShareOneUtility getTitleOfMobileDeposit];
    [self.navigationController pushViewController:objMobileDepositController animated:YES];
}

-(IBAction)goDeclineAgreemant:(id)sender{

    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
@end
