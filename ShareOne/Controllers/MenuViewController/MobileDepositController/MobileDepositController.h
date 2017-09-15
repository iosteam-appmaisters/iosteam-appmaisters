//
//  MobileDepositController.h
//  ShareOne
//
//  Created by Qazi Naveed on 22/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MobileDepositController : BaseViewController

@property (nonatomic,weak) IBOutlet UILabel *depositLimitLbl;

@end

@protocol CameraViewControllerDelegate

- (void) onCameraClose;
- (void) onPictureTaken:(UIImage *)imageJPEG withBWImage:(UIImage *)imageBW results:(NSArray *)dictionary isFront:(BOOL)isFront;

@end
