//
//  AppDelegate.m
//  ShareOne
//
//  Created by Ali Akbar on 9/8/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareOneUtility.h"
#import "ConstantsShareOne.h"
#import "CashDeposit.h"
#import "SharedUser.h"
#import "ConstantsShareOne.h"
#import "TestFairy.h"
#import "SplashViewController.h"
#import "Configuration.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [GMSServices provideAPIKey:@"AIzaSyCk9jJ7SBm7NMTJNHXMxippS6LZ0MQxymw"];
    
    [[SharedUser sharedManager] setIsLaunchFirstTime:TRUE];
//    [TestFairy begin:[ShareOneUtility getTestFairyID]];
    
        
    [GMSServices provideAPIKey:[ShareOneUtility getGoogleMapKey]];
    
    [self registerForPushNotifications:application];

    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else{
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                                  | UIUserNotificationTypeBadge
                                                                                                  | UIUserNotificationTypeSound)
                                                                                      categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
    }


    
    
//    NSLog(@"%f",[UIScreen mainScreen].bounds.size.width/6.4);
    //[self testService];
    return YES;
}

-(void)testService{
    
//    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValue],@"account",[ShareOneUtility  getMacForVertifi],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:nil url:kVERTIFY_MONEY_REGISTER AndLoadingMessage:@"Registering" completionBlock:^(NSObject *user) {
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];

}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application{
    NSLog(@"applicationProtectedDataWillBecomeUnavailable");
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application{
    NSLog(@"applicationProtectedDataDidBecomeAvailable");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    SplashViewController* mainController = (SplashViewController*)  self.window.rootViewController;
//    [mainController.objLoginViewController.homeNavigationViewController popToRootViewControllerAnimated:NO];
//    [mainController.navigationController popToRootViewControllerAnimated:NO];
//    NSLog(@"%@",mainController);

//    NSString *contextId= [[[SharedUser sharedManager] userObject] ContextID];
//    [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:nil completionBlock:^(BOOL sucess) {
//        
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [ShareOneUtility setTerminateState:TRUE];

}

#pragma mark Push Notification

-(void)registerForPushNotifications:(UIApplication *)application {
    
    // Register the supported interaction types.
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken---%@", token);
    [ShareOneUtility saveDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

#pragma mark NOTIFICATION FOR IOS TEN

-(void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}


@end
