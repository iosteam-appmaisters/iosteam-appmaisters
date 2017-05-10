//
//  SocialMediaViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SocialMediaViewController.h"
#import "ClientSettingsObject.h"

@implementation SocialMediaViewController

-(IBAction)goToFacebook:(id)sender{
    
    ClientSettingsObject *obj =     [Configuration getClientSettingsContent];
    NSURL *url = [NSURL URLWithString:obj.sociallinkfacebook];
    [[UIApplication sharedApplication] openURL:url];

}
-(IBAction)goToLinkedIn:(id)sender{
    
    ClientSettingsObject *obj =     [Configuration getClientSettingsContent];
    NSURL *url = [NSURL URLWithString:obj.sociallinklinkedin];
    [[UIApplication sharedApplication] openURL:url];

    
}
-(IBAction)goToTwitter:(id)sender{
    
    ClientSettingsObject *obj =     [Configuration getClientSettingsContent];
    NSURL *url = [NSURL URLWithString:obj.sociallinktwitter];
    [[UIApplication sharedApplication] openURL:url];

}

@end
