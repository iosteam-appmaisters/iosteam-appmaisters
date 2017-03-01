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
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    NSURL *url = [NSURL URLWithString:config.SocialFacebookLink];
    [[UIApplication sharedApplication] openURL:url];

}
-(IBAction)goToLinkedIn:(id)sender{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    NSURL *url = [NSURL URLWithString:config.SocialLinkedinLink];
    [[UIApplication sharedApplication] openURL:url];

    
}
-(IBAction)goToTwitter:(id)sender{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    NSURL *url = [NSURL URLWithString:config.SocialTwitterLink];
    [[UIApplication sharedApplication] openURL:url];

}

@end
