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
#import "ConstantsShareOne.h"
#import "CashDeposit.h"
#import "SharedUser.h"
#import "SuffixInfo.h"
#import "ConstantsShareOne.h"
#import "VertifiObject.h"



@interface MobileDepositController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePopUpDelegate,CameraViewControllerDelegate>
{
    NSMutableArray *imageErrors;
}

@property (nonatomic,strong) id objSender;
@property (nonatomic,strong) IBOutlet UIButton *View1btn;
@property (nonatomic,strong) IBOutlet UIButton *View2btn;
@property (nonatomic) BOOL isFrontorBack;
@property (nonatomic,strong) UIImage *showViewimg;
@property (nonatomic,strong) UIImage *showViewimgBW;

@property (nonatomic, weak) IBOutlet UIView *seperaterFrontCamView;
@property (nonatomic, weak) IBOutlet UIView *seperaterBackCamView;
@property (nonatomic, weak) IBOutlet UIButton *frontCamBtn;
@property (nonatomic, strong)  UIImage *frontImage;
@property (nonatomic, strong)  UIImage *backImage;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIView *pickerParentView;

@property (nonatomic, weak) IBOutlet UIButton *submittBtn;
@property (nonatomic, weak) IBOutlet UITextField *accountTxtFeild;
@property (nonatomic, weak) IBOutlet UITextField *ammountTxtFeild;
@property (nonatomic, weak) IBOutlet UIButton *accountTxtFeildBtn;
@property (nonatomic, weak) IBOutlet UILabel *accountStatusLbl;



@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, weak) NSArray *suffixArr;
@property (nonatomic, strong) SuffixInfo *objSuffixInfo;



-(IBAction)doneButtonClicked:(id)sender;

-(IBAction)accountButtonClicked:(id)sender;

-(IBAction)submittButtonClicked:(id)sender;




-(IBAction)captureFrontCardAction:(id)sender;
-(IBAction)captureBackCardAction:(id)sender;

-(void)showPicker;
-(void)setSelectedImageOnButton:(UIImage *)image;

@end

@implementation MobileDepositController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startUpMethod];
    [self loadDataOnPickerView];
    //[self getRegisterToVirtifi];
    //[self getListOfReviewDeposits];
    //[self getListOfPast6MonthsDeposits];
}

-(IBAction)submittButtonClicked:(id)sender{
    
    __weak MobileDepositController *weakSelf = self;

    if(![self getValidationStausMessage])
    {
        //[self vertifiPaymentInIt];
        [self getRegisterToVirtifi];

    }
    else{
        [[ShareOneUtility shareUtitlities] showToastWithMessage:[self getValidationStausMessage] title:@"" delegate:weakSelf];
    }
}

-(NSString *)getValidationStausMessage{
    
    NSString *status = nil;
    
    if(!_frontImage){
        status = @"Front Image is missing";
        return status;
    }

    if(!_backImage){
        status = @"Back Image is missing";
        return status;
    }
    if([_ammountTxtFeild.text length]<=0){
        status = @"Amount can not be empty";
        return status;
    }

    if([_accountTxtFeild.text length]<=0){
        status = @"Select Suffix";
        return status;
    }

    return status;
}

-(void)backButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"goToHome" sender:self];
}


-(void)getListOfPast6MonthsDeposits{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:REQUESTER_VALUE forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];
    
    [params setValue:ROUTING_VALUE forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:nil] forKey:@"account"];
    
    [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:nil] forKey:@"MAC"];
    
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:kVERTIFY_ALL_DEP_LIST_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        
    } failureBlock:^(NSError *error) {
        
    }];
    

}

-(void)getListOfReviewDeposits{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:REQUESTER_VALUE forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];
    
    [params setValue:ROUTING_VALUE forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo] forKey:@"MAC"];
    
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:kVERTIFI_DEP_LIST_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        [self getDetailsOfDepositWithObject:(VertifiObject *)user];

    } failureBlock:^(NSError *error) {
        
    }];

}


-(void)getDetailsOfDepositWithObject:(VertifiObject *)vertify{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:REQUESTER_VALUE forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];
    
    [params setValue:ROUTING_VALUE forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo] forKey:@"MAC"];
    
    [params setValue:vertify.Deposit_ID forKey:@"deposit_id"];


    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:KVERTIFY_DEP_DETAILS_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        
    } failureBlock:^(NSError *error) {
        
    }];

}
-(void)getRegisterToVirtifi{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];


    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo],@"account",[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:kVERTIFY_MONEY_REGISTER_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        
        if(success){
            VertifiObject *obj = (VertifiObject *)user;
            if(![obj.InputValidation isEqualToString:@"OK"]){
                //[[ShareOneUtility shareUtitlities] showToastWithMessage:obj.InputValidation title:@"" delegate:weakSelf completion:nil];
            }
            
            if([obj.LoginValidation isEqualToString:@"User Not Registered"]){
                [weakSelf VertifiRegAcceptance];
            }
            else if ([obj.LoginValidation isEqualToString:@"OK"]){
                [weakSelf vertifiPaymentInIt];
            }
            else
                [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.LoginValidation title:@"Status" delegate:weakSelf];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)vertifiPaymentInIt{
    
    __weak MobileDepositController *weakSelf = self;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:REQUESTER_VALUE forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];

    [params setValue:ROUTING_VALUE forKey:@"routing"];

    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:[ShareOneUtility getAccountTypeWithSuffix:_objSuffixInfo] forKey:@"accounttype"];
    [params setValue:_ammountTxtFeild.text forKey:@"amount"];
    [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo] forKey:@"MAC"];
    [params setValue:VERTIFI_MODE_TEST forKey:@"mode"];
    [params setValue:[ShareOneUtility getDeviceType] forKey:@"source"];
    
    
    
    
    NSData *imageDataPNG = UIImagePNGRepresentation([self getBWImagePath:@"img.png"]);
    [params setValue:imageDataPNG forKey:@"image"];
    
    
    NSData *imageDataJPG = UIImageJPEGRepresentation([self getBWImagePath:@"img_color.jpg"], 1.0);
    [params setValue:imageDataJPG forKey:@"imageColor"];

    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:kVERTIFI_DEP_ININT_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        [weakSelf vertifiComitWithObject:(VertifiObject *)user];
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(UIImage *)getBWImagePath:(NSString *)filename
{
    // load the image into the UIImageView - creating a scaled down thumbnail image would be more memory efficient here!
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *cacheFile;
   
    cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory,filename];
    
    return [self getimageFromDocumentsDirectory:cacheFile];
}

-(UIImage *)getimageFromDocumentsDirectory:(NSString *)path
{
    NSString *cacheFile=path;
    UIImage *image;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]){
        image = [UIImage imageWithContentsOfFile:cacheFile];
    }
    return image;
}



-(void)vertifiComitWithObject:(VertifiObject *)objVertifi{
    
    __weak MobileDepositController *weakSelf = self;


    if(objVertifi.SSOKey){
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
        [params setValue:REQUESTER_VALUE forKey:@"requestor"];
        
        [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];
        
        [params setValue:ROUTING_VALUE forKey:@"routing"];
        
        [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
        
        [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
        
        [params setValue:[ShareOneUtility getAccountTypeWithSuffix:_objSuffixInfo] forKey:@"accounttype"];
        [params setValue:_ammountTxtFeild.text forKey:@"amount"];
        [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo] forKey:@"MAC"];
        [params setValue:VERTIFI_MODE_TEST forKey:@"mode"];
        [params setValue:[ShareOneUtility getDeviceType] forKey:@"source"];
        
        
        NSData *imageDataPNG = UIImagePNGRepresentation([self getBWImagePath:@"backimg.png"]);
        [params setValue:imageDataPNG forKey:@"image"];
        
        [params setValue:objVertifi.SSOKey forKey:@"ssokey"];

        
        [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:kVERTIFI_COMMIT_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
            
            [ShareOneUtility hideProgressViewOnView:weakSelf.view];

            VertifiObject *obj =(VertifiObject *)user;
            
            if(![obj.InputValidation isEqualToString:@"OK"]){
                [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.InputValidation title:@"Status" delegate:weakSelf];
            }
            else
                [self showAlertWithTitle:@"Status" AndMessage:obj.DepositStatus];
//                [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.DepositStatus title:@"Status" delegate:weakSelf];
            
        } failureBlock:^(NSError *error) {
            
        }];

    }
    
}
-(void)VertifiRegAcceptance{
    
    __weak MobileDepositController *weakSelf = self;
    
    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo],@"account",[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:kVERTIFI_ACCEPTANCE_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        VertifiObject *obj = (VertifiObject *)user;
        if(![obj.InputValidation isEqualToString:@"OK"]){
            //[[ShareOneUtility shareUtitlities] showToastWithMessage:obj.InputValidation title:@"" delegate:weakSelf completion:nil];
        }
        else if ([obj.LoginValidation isEqualToString:@"OK"]){
            [weakSelf vertifiPaymentInIt];
        }

        
//        [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.LoginValidation title:@"Status" delegate:weakSelf];
        
        
    } failureBlock:^(NSError *error) {
        
    }];

}


-(void)loadDataOnPickerView{
    
    _suffixArr= [[SharedUser sharedManager] suffixInfoArr];
    [self.pickerView reloadAllComponents];
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self setStateOfSubmitButton];
}

-(IBAction)accountButtonClicked:(id)sender{
    [self managePickerView];
}


-(void)managePickerView{

    [_ammountTxtFeild resignFirstResponder];
    if (_bottomConstraint.constant<0){
        if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            _bottomConstraint.constant=50;
        }
        else{
            _bottomConstraint.constant=0;
        }

        [self.view layoutIfNeeded];
    }
    else{
        
        _bottomConstraint.constant=-500;
        [self.view layoutIfNeeded];
    }

}
-(IBAction)doneButtonClicked:(id)sender{
    
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self managePickerView];
    [self setStateOfSubmitButton];
}

-(void)setStateOfSubmitButton{
 
    NSRange rangeValue = [_objSuffixInfo.Access rangeOfString:@"D" options:NSCaseInsensitiveSearch];

    if(![_objSuffixInfo.Type isEqualToString:@"S"] && rangeValue.length > 0 ){
//        [_submittBtn setHidden:FALSE];
        [_accountStatusLbl setHidden:TRUE];
    }
    else{
//        [_submittBtn setHidden:TRUE];
        [_accountStatusLbl setHidden:FALSE];

    }
}


#pragma PickerView - Delegate
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _suffixArr.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    SuffixInfo *obj = _suffixArr[row];
    return  obj.Descr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 
     _objSuffixInfo = _suffixArr[row];
    [_accountTxtFeild setText:_objSuffixInfo.Descr];
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
    //CameraViewController_iPad
    NSString *strTitle = nil;
    
    if (_isFrontorBack)
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_FRONT_PHOTO" value:@"Front Check Image" table:@"VIPSample"];
    else
        strTitle = [[NSBundle mainBundle] localizedStringForKey:@"VIP_TITLE_BACK_PHOTO" value:@"Back Check Image" table:@"VIPSample"];
    
    
    CameraViewController *cameraViewController = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController_iPhone" bundle:nil delegate:self title:strTitle isFront:(_isFrontorBack == FRONT_BUTTON_TAG ? YES: NO)];
    
    else  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController_iPhone" bundle:nil delegate:self title:strTitle isFront:(_isFrontorBack == FRONT_BUTTON_TAG ? YES: NO)];
    
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
                           if (imageBW != nil && imageColor!=nil)
                           {
                               [self setSelectedImageOnButton:imageBW];
                               _showViewimgBW=imageBW;
                               _showViewimg=imageColor;
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


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if([textField isEqual:_ammountTxtFeild]){
        _bottomConstraint.constant=-500;
        [self.view layoutIfNeeded];    }
    return TRUE;
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

- (BOOL)shouldAutorotate{
    
    return YES;
}

#pragma mark - Status Alert Message
-(void)showAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:^{
                                 [self.navigationController popViewControllerAnimated:NO];
                             }];
                             
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];

}

@end
