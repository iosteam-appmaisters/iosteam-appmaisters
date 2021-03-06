//
//  ImageProcSampleAppDelegate.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2016 Vertifi Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//--------------------------------------------------------------------------------------------------------------------------------------------------

#import "VIPSampleAppDelegate.h"
#import "UISchema.h"
#import "GoogleAnalytics.h"
#import "AccountsViewController.h"
#import <libkern/OSAtomic.h>

//------------------------------------------------------------------------------------------
// Navigation Controller
//
// a UINavigation controller subclass that changes status bar behaviors
//------------------------------------------------------------------------------------------

@implementation VIPNavigationController

- (BOOL) prefersStatusBarHidden
{
    if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
        return (YES);
    return (NO);
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return (UIStatusBarStyleLightContent);
}

@end

//------------------------------------------------------------------------------------------
// App Delegate
//------------------------------------------------------------------------------------------

@implementation VIPSampleAppDelegate

@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [GoogleAnalytics init];                     // initialize Google Analytics
    
    [self setColorScheme];                      // color scheme
    uploadSessions = 0;                         // upload sessions
    
    // setup root view controller
    AccountsViewController *rootViewController = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:nil];
    VIPNavigationController *nav = [[VIPNavigationController alloc] initWithRootViewController:rootViewController];
    [nav.navigationBar setTranslucent:NO];
    self.window.rootViewController = nav;

    [self.window makeKeyAndVisible];
    
    return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DepositModel *depositModel = [DepositModel sharedInstance];                                        // initialize global
    [depositModel clearDeposit];
}

//-------------------------------------------------------------------------------------------------------------------------------
// Color scheme
//-------------------------------------------------------------------------------------------------------------------------------

- (void) setColorScheme
{
    UISchema *schema = [UISchema sharedInstance];
    
    [[UIBarButtonItem appearance] setTintColor:schema.colorTint];
    [[UIButton appearance] setTintColor:schema.colorTint];
    [[UISegmentedControl appearance] setTintColor:schema.colorTint];
    [[UISlider appearance] setTintColor:schema.colorTint];
    //[[UISwitch appearance] setTintColor:schema.colorTint];
    [[UISwitch appearance] setOnTintColor:schema.colorTint];
    [[UIProgressView appearance] setTintColor:schema.colorTint];
    [[UINavigationBar appearance] setBarTintColor:schema.colorNavigation];
    [[UIToolbar appearance] setBarTintColor:schema.colorNavigation];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:schema.colorBlack];
    [shadow setShadowOffset:CGSizeMake(1,-1)];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(id)schema.colorWhite, NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName, nil]];

    [[UIWindow appearance] setTintColor:schema.colorTint];
}

#pragma mark Networking

//----------------------------------------------------------------------------------------
// sessionOpen
//
// increment session counter, start network activity spinner
//----------------------------------------------------------------------------------------

- (void) sessionOpen
{
    if (uploadSessions == 0)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    OSAtomicIncrement32(&uploadSessions);
}

//----------------------------------------------------------------------------------------
// sessionClose
//
// decrement session counter, stop network activity spinner
//----------------------------------------------------------------------------------------

- (void) sessionClose
{
    if (uploadSessions)
        OSAtomicDecrement32(&uploadSessions);
    if (uploadSessions == 0)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
