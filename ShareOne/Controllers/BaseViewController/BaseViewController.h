//BaseViewController.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UtilitiesHelper.h"
#import "Services.h"
#import "ConstantsShareOne.h"
#import "AppServiceModel.h"
#import "HomeNavigationDelegate.h"
#import "ShareOneUtility.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"
#import "CustomButton.h"

@protocol LogoutDelegate <NSObject>   //define delegate protocol
- (void) userDidLogout; //define delegate method to be implemented within another class
@end

@class HomeViewController;
@interface BaseViewController : UIViewController<HomeNavigationDelegate>{
    
    UIViewController *currentController;

}
@property (nonatomic, weak) id <LogoutDelegate> myDelegate;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *bottomAdsConstraint;
@property (nonatomic,assign) BOOL hideSideMenu ;

-(void)createLefbarButtonItems;
-(void)setBackgroundImage;
-(void)setNavigationBarImage;
-(void)addAdvertismentControllerOnBottomScreen;
-(void)sendAdvertismentViewToBack;
-(void)bringAdvertismentViewToFront;

-(void)logoutOnGoingBackground;
-(void)setTitleOnNavBar:(NSString *)title;
-(void)logoutActions;
-(void)showSideMenu;

-(void)appGoingToBackground;

-(UIViewController *)getLoginViewForRootView;



@end
