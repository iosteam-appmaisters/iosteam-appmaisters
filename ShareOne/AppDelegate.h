//
//  AppDelegate.h
//  ShareOne
//
//  Created by Ali Akbar on 9/8/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)registerForPushNotifications:(UIApplication *)application;

@end

