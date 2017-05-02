
#import "BaseViewController.h"
#import <UIKit/UIKit.h>
#import "ConstantsShareOne.h"
#import "LeftMenuViewController.h"
#import "WebViewController.h"
#import "HomeViewController.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "AdvertisementController.h"
#import "VertifiAgreemantController.h"
#import "MobileDepositController.h"
#import "IQKeyboardManager.h"
#import "InAppBrowserController.h"


@interface BaseViewController ()<UIWebViewDelegate>{
    LeftMenuViewController* leftMenuViewController;
    UIButton* menuButton;
}

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:TRUE];

    UIView* dummyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [dummyView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:dummyView];
   
//    [self manageAds];

    [self createLefbarButtonItems];
    
    [self setNavigationBarImage];
    
    [self setTitleView];
    
    [self setBackgroundImage];

    [self setTitleTextAttribute];
    
    [self setGesturesToBringLeftMenu];
    
//    [self performSelector:@selector(addAdvertismentControllerOnBottomScreen) withObject:nil afterDelay:2];
}

-(void)setGesturesToBringLeftMenu{
    
    UISwipeGestureRecognizer* gesture=[[UISwipeGestureRecognizer alloc]init];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture addTarget:self action:@selector(userDidSwipe:)];
    [self.view setGestureRecognizers:[NSArray arrayWithObject:gesture]];
}

-(void)userDidSwipe:(UISwipeGestureRecognizer*)gesture
{
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
    
    [self setTitleOnNavBar:self.navigationItem.title];

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
    
//    float height = 50;
    
//    Configuration *config = [ShareOneUtility getConfigurationFile];
//    if([config.DisableShowOffers boolValue]){
//        return;
//    }
    
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
        CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height);
        
        
        UIWebView *webView =[[UIWebView alloc] initWithFrame:frame];
        webView.delegate=self;
        [webView setTag:ADVERTISMENT_WEBVIEW_TAG];
        
        Configuration *config = [ShareOneUtility getConfigurationFile];
        NSString *deepTargetUrl = config.DeepTargetId;
        
        NSString *url =[NSString stringWithFormat:@"%@/trgtframes.ashx?Method=M&DTA=%d&Channel=Mobile&Width=%.0f&Height=%.0f",deepTargetUrl,[[[[SharedUser sharedManager] userObject ] Account]intValue],[UIScreen mainScreen].bounds.size.width,height];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        [self.navigationController.view.window addSubview:webView];
        
        if(![ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            [self sendAdvertismentViewToBack];
        }
        else
            [self bringAdvertismentViewToFront];

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


-(void)createLefbarButtonItems{
    UIView* leftView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftView setBackgroundColor:[UIColor clearColor]];

    //rootview
    
    if([[self.navigationController viewControllers] count]>1){
        [leftView addSubview:[self getBackButton]];
//        [leftView addSubview:[self getMenuButton]];
    }
    else
    {
        UIButton* menuBtn=[self getMenuButton];
        [menuBtn setFrame:CGRectMake(0, 0, 30, 44)];
        [leftView addSubview:menuBtn];
    }
     
    
    
//    UIButton* menuBtn=[self getMenuButton];
//    [menuBtn setFrame:CGRectMake(0, 0, 30, 44)];
//    [leftView addSubview:menuBtn];

    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTitleTextAttribute{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];

    if(APPC_IS_IPAD){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:24],NSFontAttributeName,nil];
    }
    else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName,nil];
    }
}

-(void)setTitleOnNavBar:(NSString *)title{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width/2, 40)];
    titleLabel.text = title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor colorWithRed:170.0/255.0 green:31.0/255.0 blue:35.0/255.0 alpha:1.0];
    titleLabel.textColor = color;

    if(APPC_IS_IPAD){
        titleLabel.font=[UIFont boldSystemFontOfSize:24];
    }
    else{
        titleLabel.font=[UIFont boldSystemFontOfSize:11];
    }
    
    titleLabel.numberOfLines=0;
//    titleLabel.adjustsFontSizeToFitWidth = YES; // As alternative you can also make it multi-line.
//    titleLabel.minimumScaleFactor = 0.5;
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
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];

    UIImage *menuImage = [[UIImage imageNamed:@"menu_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ;

     menuButton=[[UIButton alloc]initWithFrame:CGRectMake(30, 0, 30, 44)];
    [menuButton setImage:menuImage    forState:UIControlStateNormal];
    [menuButton setTintColor:color];
    
    
//    if([[self.navigationController viewControllers] count]>1)
//        [menuButton addTarget:self action:@selector(popWithOutAnimation) forControlEvents:UIControlEventTouchUpInside];
//    else
        [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

-(void)menuButtonClicked:(id)sender{
    

    if([[self.navigationController viewControllers] count]>1){
        
        [self showSideMenu];

//        [self popWithOutAnimation];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MENU_NOTIFICATION object:nil];

    }
    else{
        [self showSideMenu];
    }
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
        [leftMenuViewController.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
    } completion:^(BOOL finished) {
        [menuButton setEnabled:TRUE];
    }];

}

-(UIButton*)getBackButton{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIColor *color = [UIColor colorWithHexString:config.variableTextColor];
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
    return UIStatusBarStyleLightContent; // your own style
}


-(void)setTitleView{
    
    UIImage* logoImage = [UIImage imageNamed:@"logo"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIImageView alloc] initWithImage:logoImage]];

}


#pragma mark - Custom Navigation Delegate

- (void)pushViewControllerWithObject:(NSDictionary *)dict{

    NSString *contrlollerName = [dict valueForKey:CONTROLLER_NAME];
    NSString *webUrl = [dict valueForKey:WEB_URL];
    NSString *screenTitle = [[dict valueForKey:SUB_CAT_TITLE] capitalizedString];
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
            [User postContextIDForSSOWithDelegate:nil withTabName:webUrl completionBlock:^(id urlPath) {
                
                NSMutableURLRequest *request =(NSMutableURLRequest *)[urlPath mutableCopy];
                
                InAppBrowserController *objInAppBrowserController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([InAppBrowserController class])];
                objInAppBrowserController.request=request;
                [self.navigationController pushViewController:objInAppBrowserController animated:NO];
                
                

                
            } failureBlock:^(NSError *error) {
            }];
        }
    }
    else{
     
        // If it is MOBILE_DEPOSIT screen check the vertifi status
        if([contrlollerName isEqualToString:MOBILE_DEPOSIT]){
            
            // Check whether current user has Accepted Vertifi Agreemant or not
            User *currentUser = [ShareOneUtility getUserObject];
            if(!currentUser.vertifyEUAContents){
                contrlollerName= [dict valueForKey:CONTROLLER_NAME];
                [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:dict];
            }
            else{
                // If Vertifi has not Acccepted Vertifi Yet show Agreemant Screen
                contrlollerName= NSStringFromClass([VertifiAgreemantController class]);
                screenTitle= @"Register";
                navigationTitle = @"Register";
                
                NSDictionary *dictVertify = [NSDictionary dictionaryWithObjectsAndKeys:contrlollerName,CONTROLLER_NAME,screenTitle,SUB_CAT_TITLE,screenTitle,SUB_CAT_CONTROLLER_TITLE,[NSNumber numberWithBool:FALSE],IS_OPEN_NEW_TAB, nil];
                [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:dictVertify];
            }
            
            [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:dict];

            
            UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
            objUIViewController.navigationItem.title=navigationTitle;
            self.navigationController.viewControllers = [NSArray arrayWithObject: objUIViewController];
        }
        
        else if([[dict valueForKey:MAIN_CAT_TITLE] isEqualToString:LOG_OFF]){
            
            // Show log out popup
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[dict valueForKey:MAIN_CAT_TITLE] capitalizedString]
                                                                           message:@"Are you sure you want to log off?"
                                                                    preferredStyle:UIAlertControllerStyleAlert]; // 1
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      NSLog(@"You pressed button one");
                                                                  }]; // 2
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:LOG_OFF
                                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       
                                                                       [ShareOneUtility showProgressViewOnView:self.view];
                                                                       
                                                                       [[ShareOneUtility shareUtitlities] cancelTimer];
                                                                       
                                                                       [self sendAdvertismentViewToBack];
                                                                       __weak BaseViewController *weakSelf = self;
                                                                       [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:TRUE];
                                                                       NSString *contextId= [[[SharedUser sharedManager] userObject] Contextid];
                                                                       [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:weakSelf completionBlock:^(BOOL sucess) {
                                                                           
                                                                           [ShareOneUtility hideProgressViewOnView:self.view];
                                                                           
                                                                           [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
                                                                               [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];
                                                                           }];
                                                                           
                                                                           
                                                                       } failureBlock:^(NSError *error) {
                                                                           
                                                                       }];
                                                                       
                                                                   }]; // 3
            
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
                
                //If webUrl is empty or nil load Native UI Screen
                UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
                objUIViewController.navigationItem.title=navigationTitle;
                controller = objUIViewController;
            }
            
            //rootview
            self.navigationController.viewControllers = [NSArray arrayWithObject: controller];
        }
    }
}

-(void)bringAdvertismentFront{
    
//    if(![[self.navigationController.viewControllers lastObject] isKindOfClass:[HomeViewController class]])
        [self bringAdvertismentViewToFront];
}

-(void)logoutOnGoingBackground{
    
    
    NSString *contextId= [[[SharedUser sharedManager] userObject] Contextid];
    
    [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:nil completionBlock:^(BOOL sucess) {
        
    } failureBlock:^(NSError *error) {
        
    }];
        


    [self sendAdvertismentViewToBack];

    [[ShareOneUtility shareUtitlities] cancelTimer];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)goBackToLoginView{
    
    [self sendAdvertismentViewToBack];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)appGoingToBackground{
    NSLog(@"appGoingToBackground from Home");
    [self unSetDelegeteForAdsWebView:TRUE];
    [[SharedUser sharedManager] setIsLogingOutFromHome:TRUE];

    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:TRUE];

    [self goBackToLoginView];

//    if(![ShareOneUtility getSettingsWithKey:TOUCH_ID_SETTINGS])
//        [self logoutOnGoingBackground];
//    else
//        [self goBackToLoginView];

    [[ShareOneUtility shareUtitlities] cancelTimer];
}

-(void)appComingFromBackground{
    NSLog(@"appComingFromBackground from home");
    
    [self unSetDelegeteForAdsWebView:FALSE];

    [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:FALSE];

    __weak BaseViewController *weakSelf = self;
    
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


//    [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
//        NSLog(@"keepAlive2");
//        if(!sucess){
//            [weakSelf logoutOnGoingBackground];
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];

//    [self startTimerForKeepAlive];
}

-(void)startTimerForKeepAlive{
    __weak BaseViewController *weakSelf = self;

    [[ShareOneUtility shareUtitlities] startTimerWithCompletionBlock:^(BOOL sucess) {
        [weakSelf logoutOnGoingBackground];
    }];
}

@end
