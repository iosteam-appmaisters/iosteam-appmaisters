//
//  SocialMediaViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SocialMediaViewController.h"

@implementation SocialMediaViewController

-(IBAction)goToFacebook:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/ShareOneInc/?ref=hl"];
    [[UIApplication sharedApplication] openURL:url];

}
-(IBAction)goToLinkedIn:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"https://www.linkedin.com/company/home?report%2Efailure=97FtKHe01TXZqDCgSwRuDAgNTvtFmw4BIp13UzOz81TxIU0_mpSjJzEz71T0SxI_14ZseOdd6PTdIUg_m4RXeOXe6Ljz4r26IOv3a38J8A5UFd8h"];
    [[UIApplication sharedApplication] openURL:url];

    
}
-(IBAction)goToTwitter:(id)sender{
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/ShareOne_EDU"];
    [[UIApplication sharedApplication] openURL:url];

}

@end
