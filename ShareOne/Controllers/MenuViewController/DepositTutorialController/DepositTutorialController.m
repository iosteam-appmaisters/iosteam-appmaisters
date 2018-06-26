//
//  DepositTutorialController.m
//  ShareOne
//
//  Created by Qazi Naveed on 5/25/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "DepositTutorialController.h"
#import "ShareOneUtility.h"
#import "UIColor+HexColor.h"

@interface DepositTutorialController ()

@end

@implementation DepositTutorialController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_parentView setBackgroundColor:[UIColor colorWithHexString:[ShareOneUtility getConfigurationFile].variableTextColor]];
}

-(void)animateToLeftSwap{
    UIImage * toImage = [UIImage imageNamed:@"swap-left"];
    [UIView transitionWithView:self.imageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
}

-(IBAction)actionButtonClicked:(id)sender{
 
    UIButton *senderBtn = (UIButton *)sender;
    
    if([[senderBtn titleForState:UIControlStateNormal] isEqualToString:@"Next"]){
        
        UIImage *bgImage = [[UIImage imageNamed:@"got_it"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self animateToLeftSwap];
        [senderBtn setTitle:@"Got It" forState:UIControlStateNormal];
        [senderBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

@end
