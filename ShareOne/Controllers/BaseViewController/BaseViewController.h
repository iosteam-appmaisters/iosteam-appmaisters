
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UtilitiesHelper.h"
#import "Services.h"
#import "Constants.h"
#import "AppServiceModel.h"
#import "SignInModel.h"
#import "HomeNavigationDelegate.h"

@interface BaseViewController : UIViewController<HomeNavigationDelegate>

-(void)setBackgroundImage;
-(void)setNavigationBarImage;
-(void)showNavigationBarWithBgImagename:(NSString*)imageName andLeftBarButtonItem:(UIButton*)leftBarButton andRightBarButtonArray:(NSArray*)rightBarButton andTitleText:(NSString*)title;
-(void)createOptionButton;
-(void)showToastWithMessage:(NSString*)text;
@end
