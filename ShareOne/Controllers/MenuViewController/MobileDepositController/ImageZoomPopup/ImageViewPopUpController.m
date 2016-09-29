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
@synthesize delegate;

/*********************************************************************************************************/
                        #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/


- (void)viewDidLoad
{
    [_imgview setImage:_img];
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarnirng {
    [super didReceiveMemoryWarning];
}

-(IBAction)ClosebuttonClicked:(id)sender
{
    if([self.delegate respondsToSelector:@selector(dismissPopUP:)])
    {
        [self.delegate dismissPopUP:self];
    }
}

@end
