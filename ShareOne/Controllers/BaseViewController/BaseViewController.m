
#import "BaseViewController.h"
#import <UIKit/UIKit.h>
#import "ConstantsShareOne.h"
#import "LeftMenuViewController.h"
#import "WebViewController.h"
#import "HomeViewController.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "AdvertisementController.h"



@interface BaseViewController (){
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
    
    if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
        _bottomAdsConstraint.constant=50;
    }
    else{
        _bottomAdsConstraint.constant=0;
    }

    
    
    UIView* dummyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [dummyView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:dummyView];
   
    [self createLefbarButtonItems];
    
    [self setNavigationBarImage];
    
    [self setTitleView];
    
    [self setBackgroundImage];

    [self setTitleTextAttribute];
    
    
//    [self performSelector:@selector(addAdvertismentControllerOnBottomScreen) withObject:nil afterDelay:2];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self addAdvertismentControllerOnBottomScreen];
}

-(void)addAdvertismentControllerOnBottomScreen{
    

    float height = 50;
//    AdvertisementController *objAdvertisementController=[self.storyboard instantiateViewControllerWithIdentifier:@"AdvertisementController"];
//
//    [[objAdvertisementController view] setBackgroundColor:[UIColor redColor]];
//    
//    [objAdvertisementController.view setFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height)];
//    
//    [self.navigationController.view.window addSubview:objAdvertisementController.view];
//
//    [UIView animateWithDuration:0.3 animations:^{
//        [objAdvertisementController.view setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height)];
//        
//    } completion:^(BOOL finished) {
//    }];
//    
    
    
    float isAlreadyAdded = FALSE;
    for(UIView *view in self.navigationController.view.window.subviews){
        if([view isKindOfClass:[UIWebView class]] && view.tag==ADVERTISMENT_WEBVIEW_TAG){
            isAlreadyAdded=TRUE;
            break;
        }
    }
    
    if(!isAlreadyAdded){
        CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height);
        
        
        UIWebView *webView =[[UIWebView alloc] initWithFrame:frame];
        [webView setTag:ADVERTISMENT_WEBVIEW_TAG];
        
        NSString *url =[NSString stringWithFormat:@"https://olb2.deeptarget.com/shareone/trgtframes.ashx?Method=M&DTA=%d&Channel=Mobile&Width=%.0f&Height=%.0f",[[[[SharedUser sharedManager] userObject ] Account]intValue],[UIScreen mainScreen].bounds.size.width,height];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        [self.navigationController.view.window addSubview:webView];
        
        if(![ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            [self sendAdvertismentViewToBack];
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
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTitleTextAttribute{
    if(APPC_IS_IPAD){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:170.0/255.0 green:31.0/255.0 blue:35.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:24],NSFontAttributeName,nil];
    }
    else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:170.0/255.0 green:31.0/255.0 blue:35.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName,nil];
    }
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
     menuButton=[[UIButton alloc]initWithFrame:CGRectMake(30, 0, 30, 44)];
    [menuButton setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

-(void)menuButtonClicked:(id)sender{
    
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
    UIButton* backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [backButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    [backButton setTitle:@"Account Summary >" forState:UIControlStateNormal];
    
    [backButton titleLabel].font = [UIFont fontWithName:@"ArialMT" size:10];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setContentMode:UIViewContentModeLeft];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

-(void)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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

    if([[dict valueForKey:CONTROLLER_NAME] length]>0){
        
        if([[dict valueForKey:CONTROLLER_NAME] isEqualToString:@"WebViewController"]){
            
            HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:[dict valueForKey:CONTROLLER_NAME]];
            objHomeViewController.url= [dict valueForKey:WEB_URL];
            objHomeViewController.navigationItem.title=[[dict valueForKey:SUB_CAT_TITLE] uppercaseString];
            [self.navigationController pushViewController:objHomeViewController animated:YES];

        }
        else{
            UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:[dict valueForKey:CONTROLLER_NAME]];
            objUIViewController.navigationItem.title=[[dict valueForKey:SUB_CAT_TITLE] uppercaseString];
            [self.navigationController pushViewController:objUIViewController animated:YES];
        }
    }
    else if([[dict valueForKey:MAIN_CAT_TITLE] isEqualToString:@"Log Out"]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[dict valueForKey:MAIN_CAT_TITLE] uppercaseString]
                                                                       message:@"ARE YOU SURE YOU WANT TO LOG OUT?"
                                                                preferredStyle:UIAlertControllerStyleAlert]; // 1
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"CANCEL "
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  NSLog(@"You pressed button one");
                                                              }]; // 2
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"LOG OUT"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   
                                                                   
                                                                   __weak BaseViewController *weakSelf = self;
                                                                   [[SharedUser sharedManager] setSkipTouchIDForJustLogOut:TRUE];
                                                                   NSString *contextId= [[[SharedUser sharedManager] userObject] ContextID];
                                                                   [User signOutUser:[NSDictionary dictionaryWithObjectsAndKeys:contextId,@"ContextID", nil] delegate:weakSelf completionBlock:^(BOOL sucess) {
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
}

-(void)bringAdvertismentFront{
    
    if(![[self.navigationController.viewControllers lastObject] isKindOfClass:[HomeViewController class]])
        [self bringAdvertismentViewToFront];
}

@end