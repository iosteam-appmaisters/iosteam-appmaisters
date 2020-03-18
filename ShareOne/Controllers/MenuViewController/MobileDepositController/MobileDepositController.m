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
#import "VertifiImageProcessing.h"
#import "CameraViewController.h"
#import "ConstantsShareOne.h"
#import "CashDeposit.h"
#import "SharedUser.h"
#import "SuffixInfo.h"
#import "ConstantsShareOne.h"
#import "VertifiObject.h"
#import "HomeViewController.h"
//#import "CameraCropView.h"
//#import "TransparentToolbar.h"
#import "CameraInstructionViewController.h"
//#import "CameraGridView.h"
#import "VertifiAgreemantController.h"


@interface MobileDepositController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePopUpDelegate,CameraViewControllerDelegate>
{
    NSMutableArray *imageErrors;
}

@property (nonatomic,strong) id objSender;
@property (nonatomic) BOOL isRecapturing;
@property (nonatomic) BOOL isFrontorBack;

@property (nonatomic, strong)  UIImage *frontImage;
@property (nonatomic, strong)  UIImage *backImage;
@property (nonatomic, strong) NSArray *suffixArr;
@property (nonatomic, strong) NSString *depositLimt;

@property (nonatomic, strong) SuffixInfo *objSuffixInfo;
@property (nonatomic, strong) VertifiObject *objVertifiObject;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *parentViewHeight;

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIView *pickerParentView;

@property (nonatomic, weak) IBOutlet CustomButton *submittBtn;
@property (nonatomic, weak) IBOutlet UITextField *accountTxtFeild;
@property (nonatomic, weak) IBOutlet UITextField *ammountTxtFeild;
@property (nonatomic, weak) IBOutlet UIButton *accountTxtFeildBtn;

@property (weak, nonatomic) IBOutlet UIImageView *ncuaLogo;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *frontCheckImage;
@property (weak, nonatomic) IBOutlet UIImageView *backCheckImage;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet CustomButton *recaptureFrontCheckButton;
@property (weak, nonatomic) IBOutlet CustomButton *recaptureBackCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *frontCheckOverlayButton;
@property (weak, nonatomic) IBOutlet UIButton *backCheckOverlayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitTop;

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
    _isRecapturing = NO;
    [self startUpMethod];
    [self loadDataOnPickerView];
    
    _noteLabel.text = [Configuration getClientSettingsContent].rdcpostingmsg;
 
//    _ncuaLogo.hidden = ![[Configuration getClientSettingsContent].enablencualogo boolValue];
    _ncuaLogo.hidden = YES;
    [self checkVertifiStatus];
    
    if (IS_IPHONE_5){
        _scrollView.scrollEnabled = YES;
    }
    else {
        if (IS_IPHONE_6){
            
        }
        else if (IS_IPHONE_6P){
            _submitTop.constant = 40;
        }
        else if (IS_IPHONE_X){
            
        }
        _scrollView.scrollEnabled = NO;
    }
}

-(void)backButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"goToHome" sender:self];
}


-(void)showVertifyAgreementVC {
    
    NSString * contrlollerName= NSStringFromClass([VertifiAgreemantController class]);
    NSString * navigationTitle = @"Register";
    

    
    UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:contrlollerName];
    objUIViewController.navigationItem.title= [ShareOneUtility getNavBarTitle:navigationTitle];
    self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], objUIViewController,nil];

    
}

-(NSString *)getValidationStausMessage{
    
    NSString *status = nil;
    
    if(_depositLimt){
        
        if([_ammountTxtFeild.text intValue]>[_depositLimt intValue]){
            status = VERTIFI_DEPOSIT_LIMIT(_depositLimt);
            return status;
        }
    }
    if([_accountTxtFeild.text length]<=0){
        status = @"Select Account";
        return status;
    }
    
    if([_ammountTxtFeild.text length]<=0){
        status = @"Amount can not be empty";
        return status;
    }
    
    if(!_frontImage){
        status = @"Front Image is missing";
        return status;
    }

    if(!_backImage){
        status = @"Back Image is missing";
        return status;
    }
    

    return status;
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

-(UIImage *)getimageFromDocumentsDirectory:(NSString *)path{
    
    NSString *cacheFile=path;
    UIImage *image;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]){
        image = [UIImage imageWithContentsOfFile:cacheFile];
    }
    return image;
}

-(void)loadDataOnPickerView{
    
    NSArray *allSuffixArray = [[SharedUser sharedManager] suffixInfoArr];
    _suffixArr = [ShareOneUtility getFilterSuffixArray:allSuffixArray];

    
    if([_suffixArr count]<=0){
        NSArray *allSuffixArray = [SuffixInfo getSuffixArrayWithObject:[ShareOneUtility getSuffixInfo]];
        _suffixArr = [ShareOneUtility getFilterSuffixArray:allSuffixArray];
        [[SharedUser sharedManager] setSuffixInfoArr:allSuffixArray];
    }

    if (_loadAccountIndex != nil){
        [_pickerView selectRow:_loadAccountIndex.intValue inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:_loadAccountIndex.intValue inComponent:0];
    }
    
    [self.pickerView reloadAllComponents];
   
}

-(void)managePickerView{
    
    float height =     [UIScreen mainScreen].bounds.size.width/6.4;
    
    [_ammountTxtFeild resignFirstResponder];
    if (_bottomConstraint.constant<0){
        if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            _bottomConstraint.constant=height;
        }
        else{
            _bottomConstraint.constant=0;
        }
        
        [self.view layoutIfNeeded];
    }
    else{
        
        _bottomConstraint.constant=-250;
        [self.view layoutIfNeeded];
    }
    
}

-(BOOL)checkIfTransactionInProgress {
    
    if ([_frontCheckOverlayButton.currentTitle isEqualToString:@"View"] || [_backCheckOverlayButton.currentTitle isEqualToString:@"View"] || ([_ammountTxtFeild.text intValue] > 0)) {
        return YES;
    }
    return NO;
}

-(void)askForScreenClearWithIndex:(NSNumber*)selectedIndex {
    
    [[UtilitiesHelper shareUtitlities]showOptionWithMessage:@"Do you want to clear current Check Details?" title:@"" delegate:self completion:^(bool success){
        if (success) {
            [self reloadMobileDepositControllerWithIndex:selectedIndex];
        }
        else {
            [self managePickerView];
        }
    }];
}



#pragma mark - Vertifi Calls

-(void)checkVertifiStatus{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    int currentTimeStamp = [ShareOneUtility getTimeStamp];
    
    NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
    
    NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
    
    NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
    
    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility calculatedMacSessionKey],@"session",[Configuration getVertifiRequesterKey],@"requestor",[NSString stringWithFormat:@"%d",currentTimeStamp],@"timestamp",[Configuration getVertifiRouterKey],@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo],@"account",calculatedMac,@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:[NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],kVERTIFY_MONEY_REGISTER] AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if(success){
            VertifiObject *obj = (VertifiObject *)user;
            weakSelf.depositLimt=obj.DepositLimit;
            
            [weakSelf.depositLimitLbl setText:[NSString stringWithFormat:@"(Deposit Limit $%.2f)",[weakSelf.depositLimt floatValue]]];
            
            if(![obj.InputValidation isEqualToString:@"OK"]){
                [self showAlertWithTitle:@"" AndMessage:obj.InputValidation];
            }
            if ([obj.LoginValidation isEqualToString:@"User Not Registered"]){
                [self showVertifyAgreementVC];
            }
            else {
                if(![obj.LoginValidation isEqualToString:@"OK"]){
                    [self showAlertWithTitle:@"" AndMessage:obj.LoginValidation];
                }
            }
            
        }
        else{
            
            [ShareOneUtility hideProgressViewOnView:weakSelf.view];
            
            NSString *localizeErrorMessage=[Configuration getMaintenanceVerbiage];
            
            [self showAlertWithTitle:@"" AndMessage:localizeErrorMessage];
            
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)vertifiPaymentInIt{
    
    __weak MobileDepositController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    int currentTimeStamp = [ShareOneUtility getTimeStamp];
    
    NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
    
    NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
    
    NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility calculatedMacSessionKey] forKey:@"session"];
    [params setValue:[Configuration getVertifiRequesterKey] forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",currentTimeStamp] forKey:@"timestamp"];
    
    [params setValue:[Configuration getVertifiRouterKey] forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:[ShareOneUtility getAccountTypeWithSuffix:_objSuffixInfo] forKey:@"accounttype"];
    if([_ammountTxtFeild.text floatValue]>0.0)
        [params setValue:_ammountTxtFeild.text forKey:@"amount"];
    
    [params setValue:calculatedMac forKey:@"MAC"];
    [params setValue:[Configuration getVertifiRDCTestMode] forKey:@"mode"];
    [params setValue:[ShareOneUtility getDeviceType] forKey:@"source"];
    
    NSData *imageDataPNG = UIImagePNGRepresentation([self getBWImagePath:@"img.png"]);
    [params setValue:imageDataPNG forKey:@"image"];
    
    NSData *imageDataJPG = UIImageJPEGRepresentation([self getBWImagePath:@"img_color.jpg"], 0.6);
    [params setValue:imageDataJPG forKey:@"imageColor"];
    
    [params setValue:@"true" forKey:@"checkDups"];
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:  [NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],kVERTIFI_DEP_ININT] AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if(succes){
            weakSelf.objVertifiObject=(VertifiObject *)user;
            
            if(![weakSelf.objVertifiObject.InputValidation isEqualToString:@"OK"]){
                [self showAlertWithTitle:@"" AndMessage:weakSelf.objVertifiObject.InputValidation];
            }
            
             if([weakSelf.objVertifiObject.dupSuspectUsability isEqualToString:@"Failed"]){
                 
                 [ShareOneUtility showLMAlertforTitle:@"" withMessage:@"this check appears to have been previously deposited." forDelegate:self];
                 
//                 [ShareOneUtility showPromptAlertforTitle:@"" withMessage:@"this check appears to have been previously deposited." forDelegate:self];
//                            [self showAlertWithTitle:@"" AndMessage:@"this check appears to have been previously deposited."];
                        }
                        
            
            if([weakSelf.objVertifiObject.CARMismatch isEqualToString:CAR_MISMATCH_PASSED] || [weakSelf.objVertifiObject.CARMismatch isEqualToString:CAR_MISMATCH_FAILED]){
                
                float CARAmount = [weakSelf.objVertifiObject.CARAmount floatValue];
                float _ammountTxtFeild_value = [[weakSelf.ammountTxtFeild text] floatValue];
                if(_ammountTxtFeild_value >0.0){
                    
                    if(CARAmount!=_ammountTxtFeild_value){
                        [self showOKAlertWithTitle:@"Amount Mismatch" AndMessage:VERTIFI_AMOUNT_MISMATCH(CARAmount, _ammountTxtFeild_value)];
                    }
                }
                else if (CARAmount>0)
                    [weakSelf.ammountTxtFeild setText:[NSString stringWithFormat:@"%.2f",CARAmount]];
            }
            
            /*if([_objVertifiObject.CARMismatch isEqualToString:CAR_MISMATCH_NOT_TESTED]){
                [self showAlertForRescanOrIgnoreTitle:@"" AndMessage:VERTIFY_CAR_MISMATCH_NOT_TESTED_MESSAGE];
            }*/
            
        }
        else{
            NSString *localizeErrorMessage=[Configuration getMaintenanceVerbiage];
            [ShareOneUtility hideProgressViewOnView:weakSelf.view];
            [[ShareOneUtility shareUtitlities] showToastWithMessage:localizeErrorMessage title:@"" delegate:weakSelf];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



-(void)vertifiComitWithObject:(VertifiObject *)objVertifi{
    
    __weak MobileDepositController *weakSelf = self;
    
    if(objVertifi.SSOKey){
        
        [ShareOneUtility showProgressViewOnView:weakSelf.view];
        
        int currentTimeStamp = [ShareOneUtility getTimeStamp];
        
        NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
        
        NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
        
        NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:[ShareOneUtility calculatedMacSessionKey] forKey:@"session"];
        [params setValue:[Configuration getVertifiRequesterKey] forKey:@"requestor"];
        [params setValue:[NSString stringWithFormat:@"%d",currentTimeStamp] forKey:@"timestamp"];
        [params setValue:[Configuration getVertifiRouterKey] forKey:@"routing"];
        [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
        [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
        [params setValue:[ShareOneUtility getAccountTypeWithSuffix:_objSuffixInfo] forKey:@"accounttype"];
        [params setValue:_ammountTxtFeild.text forKey:@"amount"];
        [params setValue:calculatedMac forKey:@"MAC"];
        [params setValue:[Configuration getVertifiRDCTestMode] forKey:@"mode"];
        [params setValue:[ShareOneUtility getDeviceType] forKey:@"source"];
         [params setValue:@"0" forKey:@"Iurearendorsement"];
       
        
        NSData *imageDataJpeg = UIImageJPEGRepresentation([self getBWImagePath:@"backimg.png"], 0.6);
        
       
        
        UIImage *img= [UIImage imageWithData:imageDataJpeg];
        
        
        
        NSLog(@"Image ------===----backB&W");
        NSLog(@"%f" , img.scale);;
        NSLog(@"Image ------===----backB&W");
        
         NSData *imageDataPNG = UIImagePNGRepresentation(img);
        
        [params setValue:imageDataPNG forKey:@"image"];
      
        //Add Color image of back side cheqeue
//        NSData *imageDataJPG = UIImagePNGRepresentation([self getBWImagePath:@"backimg_color.jpg"]);
//
        NSData *backImgDataJPG = UIImageJPEGRepresentation([self getBWImagePath:@"backimg_color.jpg"], 0.4);


//
//        UIImage *imgback = [UIImage imageWithData:backImgDataJPG];
//
//        NSLog(@"Image ------===----backColor");
//
//
//
//        NSLog(@"%f" , imgback.scale);
//         NSLog(@"Image ------===----backColor");
//
//        NSData *imageDataJPGPNG = UIImagePNGRepresentation(imgback);

        [params setValue:backImgDataJPG forKey:@"imageColor"];
   
        [params setValue:objVertifi.SSOKey forKey:@"ssokey"];
        
      
        
        [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:[NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],kVERTIFI_COMMIT] AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
            
            [ShareOneUtility hideProgressViewOnView:weakSelf.view];
            
            if(succes){
                VertifiObject *obj =(VertifiObject *)user;
                
                if(![obj.InputValidation isEqualToString:@"OK"]){
                    [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.InputValidation title:@"Status" delegate:weakSelf];
                }
                else if(obj.DepositIDCurrentCheck){
                    
                    [self reloadMobileDepositController];
                    [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.DepositStatus title:@"Thank You" delegate:weakSelf];
                }
                else
                    [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.DepositStatus title:@"" delegate:weakSelf];
            }
            else{
                NSString *error =(NSString *)user;
                
                [[ShareOneUtility shareUtitlities] showToastWithMessage:error title:@"Error" delegate:weakSelf];
                
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
}


#pragma mark - PickerView - Delegate

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)_suffixArr.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    SuffixInfo *obj = _suffixArr[row];
    return  obj.Descr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 
    if ([self checkIfTransactionInProgress]){
        [self askForScreenClearWithIndex: [NSNumber numberWithInteger:row]];
    }
    else {
        if ([_suffixArr count] > 0) {
            _objSuffixInfo = _suffixArr[row];
            [_accountTxtFeild setText:_objSuffixInfo.Descr];
        }
    }
}


#pragma mark - IBAction Methods

-(IBAction)captureFrontCardAction:(id)sender{
    
     __weak MobileDepositController *weakSelf = self;
    if([_accountTxtFeild.text length]<=0){
        [[ShareOneUtility shareUtitlities] showToastWithMessage:@"Select Account" title:@"" delegate:weakSelf];
        return;
    }
    
    _isFrontorBack=TRUE;
    _objSender=sender;
    [self onCameraClick:_objSender];
}

-(IBAction)captureBackCardAction:(id)sender{
    
    __weak MobileDepositController *weakSelf = self;
    if([_accountTxtFeild.text length]<=0){
        [[ShareOneUtility shareUtitlities] showToastWithMessage:@"Select Account" title:@"" delegate:weakSelf];
        return;
    }
    
    _isFrontorBack=FALSE;

    _objSender=sender;
    [self onCameraClick:_objSender];
}

-(IBAction)accountButtonClicked:(id)sender{
    [self managePickerView];
}

-(IBAction)doneButtonClicked:(id)sender{
    
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self managePickerView];
}

-(IBAction)submittButtonClicked:(id)sender{
    
    __weak MobileDepositController *weakSelf = self;
    
    if(![self getValidationStausMessage])
    {
        [self vertifiComitWithObject:_objVertifiObject];
    }
    else{
        [[ShareOneUtility shareUtitlities] showToastWithMessage:[self getValidationStausMessage] title:@"" delegate:weakSelf];
    }
}

- (IBAction)recaptureFrontCheckButtonTapped:(CustomButton *)sender {
    _isRecapturing = YES;
    [self captureFrontCardAction:_frontCheckOverlayButton];
}

- (IBAction)recaptureBackCheckButtonTapped:(CustomButton *)sender {
    [self captureBackCardAction:_backCheckOverlayButton];
}

- (IBAction)frontCheckOverlayTapped:(UIButton *)sender {
    
    if ([_frontCheckOverlayButton.currentTitle isEqualToString:@"Scan Front Of Check"]){
        [self captureFrontCardAction:sender];
    }
    if ([_frontCheckOverlayButton.currentTitle isEqualToString:@"View"]){
        [self getImageViewPopUpControllerWithSender:sender];
    }
    
}

- (IBAction)backCheckOverlayTapped:(UIButton *)sender {
    
    if ([_backCheckOverlayButton.currentTitle isEqualToString:@"Scan Back Of Check"]){
        [self captureBackCardAction:sender];
    }
    if ([_backCheckOverlayButton.currentTitle isEqualToString:@"View"]){
        [self getImageViewPopUpControllerWithSender:sender];
    }
}


/*********************************************************************************************************/
                        #pragma mark - CameraButton Selected Method
/*********************************************************************************************************/

-(void)setSelectedImageOnButton:(UIImage *)image{
    
    UIButton *castSenderButton = (UIButton *)_objSender;
    [castSenderButton setSelected:TRUE];
    if([castSenderButton isEqual:_frontCheckOverlayButton]){
        _frontImage = image;
    }
    else{
        _backImage = image;
    }
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
        [self showOKAlertWithTitle:@"Error" AndMessage:@"No Camera Detected!"];
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
            NSString *prodName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
             NSString *strTitle = [NSString stringWithFormat:@"Give Permission for %@ to Use Your Camera",prodName];
             UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"" message:strTitle preferredStyle:UIAlertControllerStyleAlert];
             [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
             [sheet addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
             
             }]];
             
             [self presentViewController:sheet animated:YES completion:nil];
            
            
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
    CameraViewController *cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil delegate:self title:strTitle isFront:_isFrontorBack];
    if (cameraViewController != nil)
    {
        cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
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
    _isRecapturing = NO;
    [self dismissViewControllerAnimated:YES completion:^(void){
    } ];
    return;
}

//--------------------------------------------------------------------------------------------------------
// CameraViewControllerDelegate onPictureTaken
//--------------------------------------------------------------------------------------------------------

- (void) onPictureTaken:(UIImage *)imageColor withBWImage:(UIImage *)imageBW results:(NSDictionary *)dictResults isFront:(BOOL)isFront
{
    __weak MobileDepositController *weakSelf = self;
    
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
        
        if (cacheFileColor != nil) {
            [UIImageJPEGRepresentation(imageColor,0.3f) writeToFile:cacheFileColor atomically:NO];
            [UIImagePNGRepresentation(imageBW) writeToFile:cacheFile atomically:NO];
        
            NSError* error;
            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFileColor error: &error];
            NSNumber *size = [fileDictionary objectForKey:NSFileSize];
            
            NSLog(@"%@",size);
            
            NSError* error2;
            NSDictionary *fileDictionary2 = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFile error: &error2];
            NSNumber *size2 = [fileDictionary2 objectForKey:NSFileSize];
            
            NSLog(@"%@",size2);
        }
        // UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (imageBW != nil && imageColor!=nil)
                           {
                               [self setSelectedImageOnButton:imageBW];
                               
                               if(weakSelf.isFrontorBack && self->imageErrors.count == 0)
                               {
                                   if (weakSelf.isRecapturing){
                                       weakSelf.isRecapturing = NO;
                                       weakSelf.ammountTxtFeild.text = @"";
                                       weakSelf.backCheckImage.image = [UIImage imageNamed:@"back_check_placeholder"];;
                                       [self viewDisabled:weakSelf.recaptureBackCheckButton];
                                       [weakSelf.backCheckOverlayButton setTitle:@"Scan Back Of Check" forState:UIControlStateNormal];
                                   }
                                   [self viewEnabled:weakSelf.recaptureFrontCheckButton];
                                   weakSelf.frontCheckImage.image = weakSelf.frontImage;
                                   [weakSelf.frontCheckOverlayButton setTitle:@"View" forState:UIControlStateNormal];
                                   [self vertifiPaymentInIt];
                               }
                               else{
                                   if(self->imageErrors.count == 0){
                                       [self viewEnabled:weakSelf.recaptureBackCheckButton];
                                       weakSelf.backCheckImage.image = weakSelf.backImage;
                                       [weakSelf.backCheckOverlayButton setTitle:@"View" forState:UIControlStateNormal];
                                   }
                               }

                               [self onShowErrors];
                           }
                           
                       });
    });
    
    return;
}

-(void)deleteFile:(NSString*) strFileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [enumerator nextObject])) {
        NSLog(@"The file name is - %@",[filename pathExtension]);
        if ([[filename pathExtension] isEqualToString:strFileName]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            NSLog(@"The sqlite is deleted successfully");
        }
    }
}

/*********************************************************************************************************/
                    #pragma mark - Startup Method
/*********************************************************************************************************/

-(void)startUpMethod
{
    imageErrors=[[NSMutableArray alloc] init];
    [self viewDisabled:_recaptureFrontCheckButton];
    [self viewDisabled:_recaptureBackCheckButton];
}
/*********************************************************************************************************/
                        #pragma mark - View Buttons Enabled and Disabled State Method
/*********************************************************************************************************/

-(void)viewEnabled:(UIButton *)viewBtn
{
    viewBtn.hidden = NO;
    viewBtn.userInteractionEnabled=TRUE;
    
}
-(void)viewDisabled:(UIButton *)viewBtn
{
    viewBtn.hidden = YES;
    viewBtn.userInteractionEnabled=FALSE;

}

/*********************************************************************************************************/
                    #pragma mark - Get ImageViewPopUpController ViewController Method
/*********************************************************************************************************/

-(void)getImageViewPopUpControllerWithSender:(UIButton *)button
{
    ImageViewPopUpController* objImageViewPopUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewPopUpController"];

    UIImage *imageToPass = nil;
    if([button isEqual:_frontCheckOverlayButton])
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
   
    if(_isFrontorBack){
        [self viewEnabled:_recaptureFrontCheckButton];
    }
    else{
        [self viewEnabled:_recaptureBackCheckButton];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if([textField isEqual:_ammountTxtFeild]){
        _bottomConstraint.constant=-250;
        [self.view layoutIfNeeded];    }
    return TRUE;
}

- (BOOL)shouldAutorotate{
    
    return YES;
}

#pragma mark - Status Alert Message

-(void)showOKAlertWithTitle:(NSString *)title AndMessage:(NSString *)message{
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
                             }];
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

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
                             }];
                             [self navigateToLastController];
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showAlertForRescanOrIgnoreTitle:(NSString *)title AndMessage:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ignoreBtn = [UIAlertAction
                         actionWithTitle:@"Ignore"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:^{
                             }];
                         }];
    [alert addAction:ignoreBtn];

    
    UIAlertAction* retryBtn = [UIAlertAction
                                actionWithTitle:@"Re Try"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [alert dismissViewControllerAnimated:YES completion:^{
                                    }];
                                    [self reloadMobileDepositController];
                                }];
    [alert addAction:retryBtn];

    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark Utility functions

- (void) onShowErrors {
    if (imageErrors.count > 0)
    {
        [self showOKAlertWithTitle:@"Error" AndMessage:[NSString stringWithFormat:@"Image Errors:\n\n%@",[imageErrors componentsJoinedByString:@"\n"]]];
        [imageErrors removeAllObjects];
    }
    
}

-(void)navigateToLastController{
    
    NSDictionary *cacheControlerDict = [Configuration getAllMenuItemsIncludeHiddenItems:NO][0];
    
    NSString *webUrl = [cacheControlerDict valueForKey:WEB_URL];
    
    HomeViewController *objHomeViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    currentController = objHomeViewController;
    objHomeViewController.url= webUrl;
    
    [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:cacheControlerDict];
    //rootview
    self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], objHomeViewController,nil];
    
}

-(void)reloadMobileDepositController{
    
    UIViewController * objUIViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mobileDeposit"];
    currentController = objUIViewController;
    objUIViewController.navigationItem.title=[ShareOneUtility getNavBarTitle: @"Mobile Deposit"];
    self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], objUIViewController, nil];
}

-(void)reloadMobileDepositControllerWithIndex:(NSNumber*)loadedIndex{
    
    MobileDepositController * mobileDepositVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mobileDeposit"];
    mobileDepositVC.loadAccountIndex = loadedIndex;
    currentController = mobileDepositVC;
    mobileDepositVC.navigationItem.title=[ShareOneUtility getNavBarTitle: @"Mobile Deposit"];
    self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], mobileDepositVC, nil];
}

@end
