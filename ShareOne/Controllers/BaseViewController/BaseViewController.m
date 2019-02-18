
#import "BaseViewController.h"
#import <UIKit/UIKit.h>
#import "ConstantsShareOne.h"
#import "LeftMenuViewController.h"
#import "HomeViewController.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "VertifiAgreemantController.h"
#import "MobileDepositController.h"
#import "IQKeyboardManager.h"
#import "InAppBrowserController.h"
#import "ClientSettingsObject.h"
#import "LoaderServices.h"

@interface BaseViewController ()<UIWebViewDelegate>{
    LeftMenuViewController* leftMenuViewController;
    UIButton* menuButton;
}

@end

@implementation BaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:TRUE];

    UIView* dummyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [dummyView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:dummyView];
   
    [self createLefbarButtonItems];
    
    [self setNavigationBarImage];
    
    [self setTitleView];
    
    [self setBackgroundImage];

    [self setTitleTextAttribute];
    
    [self setGesturesToBringLeftMenu];
    
}

-(void)setGesturesToBringLeftMenu{
    
    UISwipeGestureRecognizer* gesture=[[UISwipeGestureRecognizer alloc]init];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture addTarget:self action:@selector(userDidSwipe:)];
    [self.view setGestureRecognizers:[NSArray arrayWithObject:gesture]];
}

-(void)userDidSwipe:(UISwipeGestureRecognizer*)gesture
{
    if(self.hideSideMenu){
        return ;
    }

    if(gesture.state==UIGestureRecognizerStateEnded){
        [self showSideMenu];
    }

    if(gesture.state==UIGestureRecognizerStateBegan){
        
    }

}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startTimerForKeepAlive];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    [self setTitleOnNavBar:self.navigationItem.title];

    ClientSettingsObject *obj = [Configuration getClientSettingsContent];
    if ([obj.hideshowoffersoption boolValue]) {
        [ShareOneUtility saveSettingsWithStatus:NO AndKey:SHOW_OFFERS_SETTINGS];
    }
    
    [self addAdvertismentControllerOnBottomScreen];
    [self manageAds];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appComingFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)manageAds{
    
    float height =     [UIScreen mainScreen].bounds.size.width/6.4;

    if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
        _bottomAdsConstraint.constant=height;
    }
    else{
        _bottomAdsConstraint.constant=0;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)unSetDelegeteForAdsWebView:(BOOL)shouldDisabled{
    
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]] && view.tag==ADVERTISMENT_WEBVIEW_TAG){
            UIWebView *webView = (UIWebView *)view;
            if(shouldDisabled)
                webView.delegate=nil;
            else
                webView.delegate=self;

            break;
        }
    }

}

-(void)addAdvertismentControllerOnBottomScreen{
    
    ClientSettingsObject *obj = [Configuration getClientSettingsContent];
    
    float height =     [UIScreen mainScreen].bounds.size.width/6.4;

    float isAlreadyAdded = FALSE;
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]] && view.tag==ADVERTISMENT_WEBVIEW_TAG){
            UIWebView *webView = (UIWebView *)view;
            webView.delegate=self;
            isAlreadyAdded=TRUE;
            break;
        }
    }
    
    if(!isAlreadyAdded){
        CGRect frame = CGRectMake(0, 0, 0, 0);
        
        if (IS_IPHONE_X) {
            frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height-12, [UIScreen mainScreen].bounds.size.width, height);
        }else{
            frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height);
        }
        
        
        
        UIWebView *webView =[[UIWebView alloc] initWithFrame:frame];
        webView.delegate=self;
        [webView setTag:ADVERTISMENT_WEBVIEW_TAG];

        NSString *deepTargetUrl = obj.deeptargetid;

        if (![deepTargetUrl hasSuffix: @"/"]){
            deepTargetUrl = [deepTargetUrl stringByAppendingString:@"/"];
        }
        
        NSString *url =[NSString stringWithFormat:@"%@trgtframes.ashx?Method=M&DTA=%d&Channel=Mobile&Width=%.0f&Height=%.0f",deepTargetUrl,[[[[SharedUser sharedManager] userObject ] Account]intValue],[UIScreen mainScreen].bounds.size.width,height];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        [self.navigationController.view.window addSubview:webView];
        
        if(![ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            [self sendAdvertismentViewToBack];
        }
        else{
            [self bringAdvertismentViewToFront];
        }
        
    }
    if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
        [self bringAdvertismentViewToFront];
    }
    
}

#pragma mark WEB-VIEW Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"Ads Url shouldStartLoadWithRequest : %@ UIWebViewNavigationType: %ld",webView.request.URL.absoluteString,(long)navigationType);
    
    BOOL shouldReload = TRUE;
    if([webView tag]==ADVERTISMENT_WEBVIEW_TAG && ![request.URL.absoluteString containsString:@"deeptarget.com"]){
        shouldReload = FALSE;
        
        NSURL *url = [NSURL URLWithString:request.URL.absoluteString];
        [[UIApplication sharedApplication] openURL:url];
    }

    return shouldReload;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"Ads Url webViewDidStartLoad : %@",webView.request.URL.absoluteString);
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Ads Url webViewDidFinishLoad : %@",webView.request.URL.absoluteString);
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}


- (void)dealloc {
    
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]]){
            UIWebView *webView = (UIWebView *)view;
            webView.delegate = nil;
            [webView stopLoading];
            break;
        }
    }
    
}

- (UIWebView *)getAdverTismentView{
    
    UIWebView *webView = nil;
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]] && view.tag==ADVERTISMENT_WEBVIEW_TAG){
            webView=(UIWebView *)view;
            break;
        }
    }
    return webView;
}

-(void)sendAdvertismentViewToBack{
    UIWebView *view = [self getAdverTismentView];
    [view reload];
    [view setHidden:TRUE];
    [self.navigationController.view.window sendSubviewToBack:view];
}

-(void)bringAdvertismentViewToFront{
    UIWebView *view = [self getAdverTismentView];
    if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
        [self.navigationController.view.window bringSubviewToFront:view];
        [view setHidden:FALSE];
    }
}

-(void)removeAdsView{
    
    UIWebView *webView = nil;
    float isAlreadyAdded = FALSE;
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]] && view.tag==ADVERTISMENT_WEBVIEW_TAG){
            webView = (UIWebView *)view;
            isAlreadyAdded=TRUE;
            break;
        }
    }
    
    if(isAlreadyAdded){
        [webView removeFromSuperview];
    }
}

-(void)createLefbarButtonItems{
    UIView* leftView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftView setBackgroundColor:[UIColor clearColor]];

    //rootview
    if([[self.navigationController viewControllers] count]>2 && ![self.navigationController.viewControllers.lastObject isKindOfClass:[HomeViewController class]]){
        [leftView addSubview:[self getBackButton]];
        
    }
    else{
        UIButton* menuBtn=[self getMenuButton];
        [menuBtn setFrame:CGRectMake(0, 0, 30, 44)];
        [leftView addSubview:menuBtn];
    }
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftView];
}

-(void)setTitleTextAttribute{
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];

    UIColor *color = [UIColor colorWithHexString:obj.buttoncolortop];

    if(APPC_IS_IPAD){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:24],NSFontAttributeName,nil];
    }
    else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName,nil];
    }
}

-(void)setTitleOnNavBar:(NSString *)title{
    
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];

    UIColor *color = [UIColor colorWithHexString:obj.buttoncolortop];

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width/2, 40)];
    titleLabel.text = title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = color;

    if(APPC_IS_IPAD){
        titleLabel.font=[UIFont boldSystemFontOfSize:24];
    }
    else{
        titleLabel.font=[UIFont boldSystemFontOfSize:11];
    }
    
    titleLabel.numberOfLines=0;
    self.navigationItem.titleView = titleLabel;

}

-(void)setBackgroundImage{
    UIImageView* backgroundImageView;
    backgroundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_bg2"]];

    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
}

-(void)setNavigationBarImage{
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault ];
}

-(UIButton*)getMenuButton{
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];

    UIColor *color = [UIColor colorWithHexString:obj.buttoncolortop];

    UIImage *menuImage = [[UIImage imageNamed:@"menu_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ;

     menuButton=[[UIButton alloc]initWithFrame:CGRectMake(30, 0, 30, 44)];
    [menuButton setImage:menuImage    forState:UIControlStateNormal];
    [menuButton setTintColor:color];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return menuButton;
}

-(void)menuButtonClicked:(id)sender{
    [self showSideMenu];
}

-(void)showSideMenu{
    NSLog(@"showSideMenu");
    [self sendAdvertismentViewToBack];
    [menuButton setEnabled:FALSE];
    leftMenuViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    
    leftMenuViewController.homeDelegate=self;
    [leftMenuViewController.view setFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.navigationController addChildViewController:leftMenuViewController];
    [self.navigationController.view addSubview:leftMenuViewController.view];
    [UIView animateWithDuration:0.3 animations:^{
        [self->leftMenuViewController.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
    } completion:^(BOOL finished) {
        [self->menuButton setEnabled:TRUE];
    }];

}

-(UIButton*)getBackButton{
    
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];

    UIColor *color = [UIColor colorWithHexString:obj.buttoncolortop];
    UIImage *back_icon = [[UIImage imageNamed:@"back_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ;

    UIButton* backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setTintColor:color];
    [backButton setImage:back_icon forState:UIControlStateNormal];
    [backButton setContentMode:UIViewContentModeLeft];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

-(void)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)popWithOutAnimation{
    [self.navigationController popViewControllerAnimated:NO];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(void)setTitleView{
    
    UIImage* logoImage = [UIImage imageNamed:@"top_logo"];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIImageView alloc] initWithImage:logoImage]];
}


#pragma mark - Custom Navigation Delegate

- (void)pushViewControllerWithObject:(NSDictionary *)dict{

    NSString *contrlollerName = [dict valueForKey:CONTROLLER_NAME];
    NSString *webUrl = [dict valueForKey:WEB_URL];
    
    NSString *navigationTitle = [[dict valueForKey:SUB_CAT_CONTROLLER_TITLE] capitalizedString];
    BOOL isOpenInNewTab  = [[dict valueForKey:IS_OPEN_NEW_TAB] boolValue];
    NSString *webViewController = WEB_VIEWCONTROLLER_ID;
    
    // If isOpenInNewTab : TRUE than we need to open the current webview in InAppBrowser else proceed with other screen.

    if(isOpenInNewTab){
        
        if([webUrl containsString:@"http"]){
            
            NSURL *url = [NSURL URLWithString:webUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            InAppBrowserController *objInAppBrowserController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([InAppBrowserController class])];
            objInAppBrowserController.request=request;
            [self.navigationController pushViewController:objInAppBrowserController animated:NO];

        }
        else{
            NSString *siteurl = [NSString stringWithFormat:@"%@/%@",[Configuration getSSOBaseUrl],webUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:siteurl]];
            InAppBrowserController *objInAppBrowserController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([InAppBrowserController class])];
            objInAppBrowserController.request=request;
            [self.navigationController pushViewController:objInAppBrowserController animated:NO];
        }
    }
    else{
     
        if([contrlollerName isEqualToString:MOBILE_DEPOSIT]){
            
            contrlollerName= [dict valueForKey:CONTROLLER_NAME];
            
            NSDictionary *cacheControlerDict = [Configuration getAllMenuItemsIncludeHiddenItems:NO][0];
            [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:cacheControlerDict];

            UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
            objUIViewController.navigationItem.title= [ShareOneUtility getNavBarTitle:navigationTitle];
            self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], objUIViewController,nil];
        }
        
        else if([contrlollerName isEqualToString:@"logoff"]){
            
            // Show log out popup
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                        [[dict valueForKey:MAIN_CAT_TITLE] capitalizedString]
                                                                           message:@"Are you sure you want to log off?"
                                                                    preferredStyle:UIAlertControllerStyleAlert]; // 1
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      NSLog(@"You pressed button one");
                                                                  }]; // 2
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:LOG_OFF
                                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       
                   if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]) {
                       [[NSUserDefaults standardUserDefaults]setBool:YES forKey:TEMP_DISABLE_TOUCH_ID];
                       [[NSUserDefaults standardUserDefaults]synchronize];
                   }
                   
                  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:NORMAL_LOGOUT];
                  [[NSUserDefaults standardUserDefaults]synchronize];
                                                                       
                   UIViewController *controller = nil;
                   HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:webViewController];
                                                                       self->currentController = objHomeViewController;
                   objHomeViewController.url = [NSString stringWithFormat:@"%@/%@",[Configuration getSSOBaseUrl],@"/log/out"];
                   controller = objHomeViewController;
                                                                       
                   self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView],controller, nil];
                                                                                                                                           
               }];
            
            [alert addAction:firstAction];
            [alert addAction:secondAction]; 
            
            [self presentViewController:alert animated:YES completion:nil];
        }

        
        else{
            [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:dict];

            // If webUrl has a valid URL than we need to load HomeViewController with URL
            UIViewController *controller = nil;
            if(webUrl){
                
                HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:webViewController];
                currentController = objHomeViewController;
                objHomeViewController.url= webUrl;
                controller=objHomeViewController;
            }
            else{
                
                UIViewController * objUIViewController =nil;

                //If webUrl is empty or nil load Native UI Screen
                @try {
                    objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
                    objUIViewController.navigationItem.title=[ShareOneUtility getNavBarTitle: navigationTitle];
                    controller = objUIViewController;

                }
                @catch (NSException *exception) {
                    NSLog(@"Reason %@" , exception.reason);
                }
                @finally {
                    if (objUIViewController == nil) {
                        [ShareOneUtility removeCacheControllerName];
                        return;
                        NSLog(@"VC %@" , objUIViewController);
                    }
                }
            }
            
            //rootview
            self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView],controller, nil];
        }
    }
}

-(void)logoutActions {
    
    [self closeSideMenu];
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:LOGOUT_BEGIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [ShareOneUtility showProgressViewOnView:self.view];
    
    [[ShareOneUtility shareUtitlities] cancelTimer];
    
    [self removeAdsView];
    
    [self sendAdvertismentViewToBack];
    
    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:TRUE];
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    BOOL isTechnicalLogout = [[NSUserDefaults standardUserDefaults]boolForKey:TECHNICAL_LOGOUT];

    if (isTechnicalLogout) {
        
        if(![ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:TECHNICAL_LOGOUT];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[ShareOneUtility getTechnicalLogoutMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:TECHNICAL_LOGOUT];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


-(void)bringAdvertismentFront{
    [self bringAdvertismentViewToFront];
}

-(void)logoutOnGoingBackground{
    
    [self appGoingToBackground];

    [self logoutActions];
}


-(void)appGoingToBackground{
    NSLog(@"appGoingToBackground from Home");
    
    [leftMenuViewController backgroundButtonClicked:nil];
    [menuButton setEnabled:YES];
    
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]){
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self sendAdvertismentViewToBack];
    
    [self removeAdsView];
    [self unSetDelegeteForAdsWebView:TRUE];
    [[SharedUser sharedManager] setIsLogingOutFromHome:TRUE];
    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:TRUE];
    [[ShareOneUtility shareUtitlities] cancelTimer];
    
     [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)appComingFromBackground{
    NSLog(@"appComingFromBackground from home");
    
    [self unSetDelegeteForAdsWebView:FALSE];

    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];

    
    if([ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS]){
        
        [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
            NSLog(@"keepAlive2");
            if(sucess){
            }
            else{
                
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

-(void)startTimerForKeepAlive{
    __weak BaseViewController *weakSelf = self;

    [[ShareOneUtility shareUtitlities] startTimerWithCompletionBlock:^(BOOL sucess) {
        [weakSelf logoutOnGoingBackground];
    }];
}

-(UIViewController *)getLoginViewForRootView{
    
    UIViewController *loginController = nil;
    if(self.navigationController.viewControllers.count>1){
        loginController=self.navigationController.viewControllers[0];
    }
    return loginController;
}

-(void)closeSideMenu {
    [leftMenuViewController backgroundButtonClicked:nil];
}

@end
