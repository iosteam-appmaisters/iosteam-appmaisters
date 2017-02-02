//
//  CameraOverlayView.h
//  PreHunt
//
//  Created by Shahrukh Jamil on 18/05/2016.
//  Copyright © 2016 Shahrukh Jamil. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImagePopUpDelegate<NSObject>

-(void)dismissPopUP:(id)sender;
@end
@interface ImageViewPopUpController : UIViewController
{

}
@property(nonatomic,strong)UIImage *img;
@property BOOL isFront;
@property BOOL isComingFromDepositList;

@end
