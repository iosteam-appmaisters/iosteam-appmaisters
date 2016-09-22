
#import "BaseViewController.h"
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LeftMenuViewController.h"
#import "WebViewController.h"


@interface BaseViewController (){
    LeftMenuViewController* leftMenuViewController;
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
    
    UIView* dummyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [dummyView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:dummyView];
   
    [self createLefbarButtonItems];
    
    [self setNavigationBarImage];
    
    [self setTitleView];
    
    [self setBackgroundImage];

    [self setTitleTextAttribute];
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
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:24],NSFontAttributeName,nil];
    }
    else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName,nil];
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
    UIButton* menuButton=[[UIButton alloc]initWithFrame:CGRectMake(30, 0, 30, 44)];
    [menuButton setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

-(void)menuButtonClicked:(id)sender{
        leftMenuViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];

    leftMenuViewController.homeDelegate=self;
    [leftMenuViewController.view setFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.navigationController addChildViewController:leftMenuViewController];
    [self.navigationController.view addSubview:leftMenuViewController.view];
    [UIView animateWithDuration:0.3 animations:^{
        [leftMenuViewController.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    }];
}


-(UIButton*)getBackButton{
    UIButton* backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 44)];
    [backButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
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
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
}


#pragma mark - Custom Navigation Delegate

- (void)pushViewControllerWithObject:(NSDictionary *)dict{

    if([[dict valueForKey:CONTROLLER_NAME] length]>0){
        UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:[dict valueForKey:CONTROLLER_NAME]];
        [self.navigationController pushViewController:objUIViewController animated:YES];
    }
    else if([[dict valueForKey:MAIN_CAT_TITLE] isEqualToString:@"Log Off"]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[dict valueForKey:MAIN_CAT_TITLE] uppercaseString]
                                                                       message:@"ARE YOU SURE YOU WANT TO LOG OFF?"
                                                                preferredStyle:UIAlertControllerStyleAlert]; // 1
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Stay in "
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  NSLog(@"You pressed button one");
                                                              }]; // 2
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Logout"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                               }]; // 3
        
        [alert addAction:firstAction]; // 4
        [alert addAction:secondAction]; // 5
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end