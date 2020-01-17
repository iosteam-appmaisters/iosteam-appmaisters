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
#import "SplashViewController.h"
#import "Configuration.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate

/* TEST COMMIT FROM SHAREONE-NSCONFIG*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    [[SharedUser sharedManager] setIsLaunchFirstTime:TRUE];
    
    [Fabric with:@[[Crashlytics class]]];
    
    if (![ShareOneUtility shouldUseProductionEnviroment]){
        //[TestFairy begin:[ShareOneUtility getTestFairyID]];
    }
    [GMSServices provideAPIKey:[ShareOneUtility getGoogleMapKey_old]];
    
    [self registerForPushNotifications:application];

    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
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

    return YES;
}


- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
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
//    if([self topViewController]){
//        // get current rootViewController object
//        UIViewController *controller = [self topViewController];
//        if([controller isKindOfClass:[BaseViewController class]]){
//            // handling in-app events like ads handling/keep alive service session
//            [(BaseViewController *)controller appGoingToBackground];
//        }
//
//        // dismiss current rootViewController
//        [controller dismissViewControllerAnimated:NO completion:^{
//            // dismiss controller till SplashViewController appears to be rootViewController
//            UIViewController *controller = [self topViewController];
//            if(![controller isKindOfClass:[SplashViewController class]]){
//                [controller dismissViewControllerAnimated:NO completion:nil];
//            }
//        }];
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([ShareOneUtility shouldCallNSConfigServices]){
        
        if ([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]) {
            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:RESTRICT_TOUCH_ID];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        [self showSplash];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [ShareOneUtility setTerminateState:TRUE];

}

-(void)showSplash {
    NSLog(@"TopVC :: %@",[[self topViewController]class]);
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SplashViewController * splash = (SplashViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"SplashViewController"];
    
    if ([self topViewController] != nil && ![[self topViewController]isKindOfClass:[SplashViewController class]]){
        splash.isComingFromBackground = YES;
        [[self topViewController]dismissViewControllerAnimated:NO completion:^{
            
            [[UIApplication sharedApplication].keyWindow setRootViewController:splash];

        }];

    }
    else {
        splash.isComingFromBackground = NO;
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.rootViewController = splash;
        [self.window makeKeyAndVisible];
    }
    
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    BOOL pushEnabled = notificationSettings.types & UIUserNotificationTypeAlert;
    
    if (pushEnabled){
        NSLog(@"Push Notification Allowed From Default PopUp.");

        
    }else{
        
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
   
    
      [ShareOneUtility saveDeviceToken:[NSString stringWithFormat:@"%@" , hexToken] ];
    
//    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"deviceToken---%@", token);
  
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NewTokenRegisteration" object:self userInfo:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NewTokenRegisteration" object:self userInfo:@{@"error":error}];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

#pragma mark NOTIFICATION FOR IOS TEN

-(void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}


@end
