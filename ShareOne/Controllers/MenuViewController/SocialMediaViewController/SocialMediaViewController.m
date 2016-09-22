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
    
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/"];
    [[UIApplication sharedApplication] openURL:url];

}
-(IBAction)goToLinkedIn:(id)sender{
    
    NSURL *url = [NSURL URLWithString:@"https://www.linkedin.com/"];
    [[UIApplication sharedApplication] openURL:url];

    
}
-(IBAction)goToTwitter:(id)sender{
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/"];
    [[UIApplication sharedApplication] openURL:url];

}

@end
