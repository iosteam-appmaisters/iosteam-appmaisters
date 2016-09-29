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

@interface MobileDepositController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePopUpDelegate>

@property (nonatomic,strong) id objSender;
@property (nonatomic,strong) IBOutlet UIButton *View1btn;
@property (nonatomic,strong) IBOutlet UIButton *View2btn;
@property (nonatomic) BOOL isFrontorBack;
@property (nonatomic,strong) UIImage *showViewimg;

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
    [self showPicker];
}
-(IBAction)captureBackCardAction:(id)sender{
    _isFrontorBack=FALSE;

    _objSender=sender;
    [self showPicker];
}
-(IBAction)viewButtonClicked:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==1)
    {
        [self getImageViewPopUpController];
    }
    else if(btn.tag==2)
    {
        [self getImageViewPopUpController];

    }
}

-(void)setSelectedImageOnButton:(UIImage *)image{
    
    UIButton *castSenderButton = (UIButton *)_objSender;
    [castSenderButton setSelected:!castSenderButton.isSelected];
//    [castSenderButton setImage:image forState:UIControlStateNormal];
}

-(void)showPicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate=self;
        [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)];
        [self presentViewController:picker animated:YES completion:Nil];
    }
    
}
-(void)startUpMethod
{
    [self viewDisabled:_View1btn];
    [self viewDisabled:_View2btn];
}
-(void)viewEnabled:(UIButton *)viewBtn
{
    viewBtn.userInteractionEnabled=TRUE;
    viewBtn.titleLabel.textColor=[UIColor redColor];
}
-(void)viewDisabled:(UIButton *)viewBtn
{
    viewBtn.userInteractionEnabled=FALSE;
    viewBtn.titleLabel.textColor=[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1];

}

/*********************************************************************************************************/
                    #pragma mark - Get ImageViewPopUpController ViewController Method
/*********************************************************************************************************/

-(void)getImageViewPopUpController
{
    ImageViewPopUpController *obj=[[ImageViewPopUpController alloc] initWithNibName:@"ImageViewPopUpController" bundle:nil];
    obj.delegate=self;
    obj.img=_showViewimg;
    [self presentPopupViewController:obj animationType:0];
}
-(void)dismissPopUP:(id)sender
{
    [self dismissPopupViewControllerWithanimationType:2];

}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self setSelectedImageOnButton:chosenImage];
    _showViewimg=chosenImage;
    if(_isFrontorBack)
    {

        [self viewEnabled:_View1btn];
    }
    else
    {

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
