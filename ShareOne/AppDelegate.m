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
@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSASCIIStringEncoding
//    [GMSServices provideAPIKey:@"AIzaSyCk9jJ7SBm7NMTJNHXMxippS6LZ0MQxymw"];
    [TestFairy begin:@"0d214628fc17621672de9113b24e97cc48c454eb"];
    
    [GMSServices provideAPIKey:googleApiKey];
    
    
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
}

@end
