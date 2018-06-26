//
//  CustomNavController.m
//  ShareOne
//
//  Created by Qazi Naveed on 04/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "CustomNavController.h"
#import "MobileDepositController.h"

@interface CustomNavController ()

@end

@implementation CustomNavController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
