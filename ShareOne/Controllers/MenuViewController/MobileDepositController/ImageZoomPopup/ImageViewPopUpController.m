//
//  CameraOverlayView.m
//  PreHunt
//
//  Created by Shahrukh Jamil on 18/05/2016.
//  Copyright © 2016 Shahrukh Jamil. All rights reserved.
//

#import "ImageViewPopUpController.h"
#import "ShareOneUtility.h"

@interface ImageViewPopUpController (){
    
   IBOutlet UISegmentedControl *switchColor;                        // b&w / color toggle for front image

}
@property(nonatomic,strong)IBOutlet UIImageView *imgview;

@end
@implementation ImageViewPopUpController

/*********************************************************************************************************/
                        #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setimageFromDocumentsDirectory];
}
- (void)didReceiveMemoryWarnirng {
    [super didReceiveMemoryWarning];
}
-(IBAction)createSegmentedSwitchColorButton
{
    [self setimageFromDocumentsDirectory];
}
-(void)setimageFromDocumentsDirectory
{
    NSString *cacheFile=[self retriveColorFileFromDocumentsDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
        
        UIImage * portraitImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];

        
        [_imgview setImage:portraitImage];
    }
    else{
        
        [switchColor setHidden:TRUE];
        UIImage * portraitImage = [[UIImage alloc] initWithCGImage: _img.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
        [_imgview setImage:portraitImage];


    }


}
-(NSString *)retriveColorFileFromDocumentsDirectory
{
    // load the image into the UIImageView - creating a scaled down thumbnail image would be more memory efficient here!
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *cacheFile;
    if (self.isFront)
    {
            if (switchColor.selectedSegmentIndex == 1)
                cacheFile = [NSString stringWithFormat:@"%@/img_color.jpg", cacheDirectory];
            else
                cacheFile = [NSString stringWithFormat:@"%@/img.png", cacheDirectory];
            
    }
    else
    {       if (switchColor.selectedSegmentIndex == 1)
                cacheFile = [NSString stringWithFormat:@"%@/backimg.png", cacheDirectory];
            else
                cacheFile = [NSString stringWithFormat:@"%@/backimg_color.jpg", cacheDirectory];
    }

    return cacheFile;
}

-(IBAction)ClosebuttonClicked:(id)sender{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    
    return NO;
}


@end
