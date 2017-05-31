//
//  DepositTutorialController.m
//  ShareOne
//
//  Created by Qazi Naveed on 5/25/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "DepositTutorialController.h"
#import "UIColor+HexColor.h"
#import "Configuration.h"
#import "ShareOneUtility.h"


@interface DepositTutorialController ()
@property (nonatomic,weak) IBOutlet UIView *parentView;
@end

@implementation DepositTutorialController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    [_parentView setBackgroundColor:[UIColor colorWithHexString:config.variableTextColor]];
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
