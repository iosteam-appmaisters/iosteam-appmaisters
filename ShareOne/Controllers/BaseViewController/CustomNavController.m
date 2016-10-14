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
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate
{
//    id currentViewController = self.topViewController;
//    
//    if ([currentViewController isKindOfClass:[MobileDepositController class]])
//        return NO;
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
