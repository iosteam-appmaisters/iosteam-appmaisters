//
//  CameraOverlayView.m
//  PreHunt
//
//  Created by Shahrukh Jamil on 18/05/2016.
//  Copyright © 2016 Shahrukh Jamil. All rights reserved.
//

#import "ImageViewPopUpController.h"

@interface ImageViewPopUpController (){
    
    
}
@property(nonatomic,strong)IBOutlet UIImageView *imgview;

@end
@implementation ImageViewPopUpController

/*********************************************************************************************************/
                        #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/


- (void)viewDidLoad{
    [super viewDidLoad];

    [_imgview setImage:_img];
}
- (void)didReceiveMemoryWarnirng {
    [super didReceiveMemoryWarning];
}

-(IBAction)ClosebuttonClicked:(id)sender{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
