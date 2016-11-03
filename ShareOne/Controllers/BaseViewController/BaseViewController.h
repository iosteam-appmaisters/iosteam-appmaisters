
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UtilitiesHelper.h"
#import "Services.h"
#import "ConstantsShareOne.h"
#import "AppServiceModel.h"
#import "SignInModel.h"
#import "HomeNavigationDelegate.h"
#import "ShareOneUtility.h"


@class HomeViewController;
@interface BaseViewController : UIViewController<HomeNavigationDelegate>

@property (nonatomic,strong) IBOutlet NSLayoutConstraint *bottomAdsConstraint;

-(void)setBackgroundImage;
-(void)setNavigationBarImage;
-(void)showNavigationBarWithBgImagename:(NSString*)imageName andLeftBarButtonItem:(UIButton*)leftBarButton andRightBarButtonArray:(NSArray*)rightBarButton andTitleText:(NSString*)title;
-(void)createOptionButton;
-(void)showToastWithMessage:(NSString*)text;
-(void)addAdvertismentControllerOnBottomScreen;
-(void)sendAdvertismentViewToBack;
-(void)bringAdvertismentViewToFront;



@end
