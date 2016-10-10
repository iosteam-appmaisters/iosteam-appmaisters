//
//  MobileDepositController.m
//  ShareOne
//
//  Created by Qazi Naveed on 22/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "MobileDepositController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ImageViewPopUpController.h"
#import "CameraGridView.h"
#import "VertifiImageProcessing.h"
#import "Global.h"
#import "CameraViewController.h"
#import "Constants.h"
@interface MobileDepositController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePopUpDelegate,CameraViewControllerDelegate>
{
    NSMutableArray *imageErrors;
}

@property (nonatomic,strong) id objSender;
@property (nonatomic,strong) IBOutlet UIButton *View1btn;
@property (nonatomic,strong) IBOutlet UIButton *View2btn;
@property (nonatomic) BOOL isFrontorBack;
@property (nonatomic,strong) UIImage *showViewimg;
@property (nonatomic, weak) IBOutlet UIView *seperaterFrontCamView;
@property (nonatomic, weak) IBOutlet UIView *seperaterBackCamView;
@property (nonatomic, weak) IBOutlet UIButton *frontCamBtn;
@property (nonatomic, strong)  UIImage *frontImage;
@property (nonatomic, strong)  UIImage *backImage;




-(IBAction)captureFrontCardAction:(id)sender;
-(IBAction)captureBackCardAction:(id)sender;

-(void)showPicker;
-(void)setSelectedImageOnButton:(UIImage *)image;

@end

@implementation MobileDepositController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startUpMethod];
}


#pragma mark - IBAction Methods

-(IBAction)captureFrontCardAction:(id)sender{
    _isFrontorBack=TRUE;
    _objSender=sender;
    // [self showPicker];  // IOS Camera
    [self onCameraClick:_objSender]; //Vertify Camera
}
-(IBAction)captureBackCardAction:(id)sender{
    _isFrontorBack=FALSE;

    _objSender=sender;
    //[self showPicker];  // IOS Camera
    [self onCameraClick:_objSender]; //Vertify Camera
}
-(IBAction)viewButtonClicked:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    [self getImageViewPopUpControllerWithSender:btn];

}
/*********************************************************************************************************/
                        #pragma mark - CameraButton Selected Method
/*********************************************************************************************************/

-(void)setSelectedImageOnButton:(UIImage *)image{
    
    UIButton *castSenderButton = (UIButton *)_objSender;
    [castSenderButton setSelected:TRUE];
    if([castSenderButton isEqual:_frontCamBtn]){
        _frontImage = image;
    }
    else{
        _backImage = image;
    }
//    [castSenderButton setImage:image forState:UIControlStateNormal];
}
/*********************************************************************************************************/
                            #pragma mark - Show IOS Camera Picker
/*********************************************************************************************************/

-(void)showPicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate=self;
        [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)];
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

/*********************************************************************************************************/
                            #pragma mark - Show Vertify Camera
/*********************************************************************************************************/

//-----------------------------------------------------------------------------
// Camera Click
//-----------------------------------------------------------------------------

- (void) onCameraClick:(UIButton *)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Camera Detected!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    // check authorization status of camera
    __block AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined)               // first time use
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadCamera:sender];
                });
            }
        }];
    }
    
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
            [self loadCamera:sender];
            break;
        case AVAuthorizationStatusDenied:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera Use Not Authorized!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            // for iOS8, this code snippet is a nice alternative to the UIAlertView, as it allows for user to launch to the App Settings screen to enable the camera
            /*
             NSString *strTitle = [NSString stringWithFormat:@"Give Permission for %@ to Use Your Camera",@"yourProductName"];
             UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"" message:strTitle preferredStyle:UIAlertControllerStyleAlert];
             [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
             [sheet addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
             
             }]];
             
             [self presentViewController:sheet animated:YES completion:nil];
             */
            
            return;
        }
        default:
            return;
    }
    
   	return;
}

//-----------------------------------------------------------------------------
// Camera Click
//-----------------------------------------------------------------------------

- (void) loadCamera:(UIButton *)sender
{
    NSString *strTitle = nil;
    
    if (_isFrontorBack)
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_FRONT_PHOTO" value:@"Front Check Image" table:@"VIPSample"];
    else
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_BACK_PHOTO" value:@"Back Check Image" table:@"VIPSample"];
    
    
    CameraViewController *cameraViewController = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController_iPhone" bundle:nil delegate:self title:strTitle isFront:(_isFrontorBack == FRONT_BUTTON_TAG ? YES: NO)];
    else  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController_iPad" bundle:nil delegate:self title:strTitle isFront:(_isFrontorBack == FRONT_BUTTON_TAG ? YES: NO)];
    
    if (cameraViewController != nil)
    {
        [self presentViewController:cameraViewController animated:YES completion:^{
        }];
    }
    
    return;
}

/*********************************************************************************************************/
                                #pragma mark  Vertify CameraViewControllerDelegate
/*********************************************************************************************************/

//--------------------------------------------------------------------------------------------------------
// CameraViewControllerDelegate onCameraClose
//--------------------------------------------------------------------------------------------------------

- (void) onCameraClose
{
    [self dismissViewControllerAnimated:YES completion:^(void){
    } ];
    return;
}

//--------------------------------------------------------------------------------------------------------
// CameraViewControllerDelegate onPictureTaken
//--------------------------------------------------------------------------------------------------------

- (void) onPictureTaken:(UIImage *)imageColor withBWImage:(UIImage *)imageBW results:(NSDictionary *)dictResults isFront:(BOOL)isFront
{
    // dismiss CameraViewController
    [self dismissViewControllerAnimated:YES completion:^(void){} ];
    NSLog(@"%@",dictResults);
    // Save images to file system
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *cacheFile;
    NSString *cacheFileColor;
    
    if (isFront)
    {
        cacheFile = [NSString stringWithFormat:@"%@/img.png", cacheDirectory];
        cacheFileColor = [NSString stringWithFormat:@"%@/img_color.jpg", cacheDirectory];
        
    }
    else
    {
        cacheFile = [NSString stringWithFormat:@"%@/backimg.png", cacheDirectory];
        cacheFileColor = [NSString stringWithFormat:@"%@/backimg_color.jpg", cacheDirectory];

    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // save files on background thread
    dispatch_group_async(group, queue, ^{
        
        if (cacheFileColor != nil)
            [UIImageJPEGRepresentation(imageColor,0.3f) writeToFile:cacheFileColor atomically:NO];
        [UIImagePNGRepresentation(imageBW) writeToFile:cacheFile atomically:NO];
        
        // UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (imageBW != nil)
                           {
                               [self setSelectedImageOnButton:imageBW];
                               _showViewimg=imageBW;
                               if(_isFrontorBack)
                               {
                                   [self viewEnabled:_View1btn];
                               }
                               else{
                                   [self viewEnabled:_View2btn];
                               }

                               [self onShowErrors];
                           }
                           
                       });
    });
    
    return;
}

#pragma mark Utility functions

//-----------------------------------------------------------------------------
// Show Errors
//-----------------------------------------------------------------------------

- (void) onShowErrors
{
    if (imageErrors.count > 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Image Errors:\n\n%@",[imageErrors componentsJoinedByString:@"\n"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [imageErrors removeAllObjects];
    }
    
}

/*********************************************************************************************************/
                    #pragma mark - Startup Method
/*********************************************************************************************************/

-(void)startUpMethod
{
    imageErrors=[[NSMutableArray alloc] init];
    [self viewDisabled:_View1btn];
    [self viewDisabled:_View2btn];
}
/*********************************************************************************************************/
                        #pragma mark - View Buttons Enabled and Disabled State Method
/*********************************************************************************************************/

-(void)viewEnabled:(UIButton *)viewBtn
{
    viewBtn.userInteractionEnabled=TRUE;
    [viewBtn setTitleColor:_frontCamBtn.tintColor forState:UIControlStateNormal];
    if([_objSender isEqual:_frontCamBtn]){
        [_seperaterFrontCamView setBackgroundColor:_frontCamBtn.tintColor];
    }
    else{
        [_seperaterBackCamView setBackgroundColor:_frontCamBtn.tintColor];
    }
}
-(void)viewDisabled:(UIButton *)viewBtn
{
    viewBtn.userInteractionEnabled=FALSE;
//    viewBtn.titleLabel.textColor=[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1];

}

/*********************************************************************************************************/
                    #pragma mark - Get ImageViewPopUpController ViewController Method
/*********************************************************************************************************/

-(void)getImageViewPopUpControllerWithSender:(UIButton *)button
{
    ImageViewPopUpController* objImageViewPopUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewPopUpController"];

    UIImage *imageToPass = nil;
    if([button isEqual:_View1btn])
    {
        imageToPass = _frontImage;
        objImageViewPopUpController.isFront=TRUE;
        objImageViewPopUpController.img=imageToPass;
    }
    else
    {
        imageToPass = _backImage;
        objImageViewPopUpController.isFront=FALSE;
        objImageViewPopUpController.img=imageToPass;
    }
    

    [self presentViewController:objImageViewPopUpController animated:YES completion:nil];

}
-(void)dismissPopUP:(id)sender
{
    [self dismissPopupViewControllerWithanimationType:2];

}

/*********************************************************************************************************/
                                            #pragma mark - UIImagePickerDelegate
/*********************************************************************************************************/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self setSelectedImageOnButton:chosenImage];
    _showViewimg=chosenImage;
    if(_isFrontorBack){
        [self viewEnabled:_View1btn];
    }
    else{
        [self viewEnabled:_View2btn];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
