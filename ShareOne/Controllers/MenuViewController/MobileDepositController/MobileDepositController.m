//
//  MobileDepositController.m
//  ShareOne
//
//  Created by Qazi Naveed on 22/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "MobileDepositController.h"

@interface MobileDepositController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) id objSender;

-(IBAction)captureFrontCardAction:(id)sender;
-(IBAction)captureBackCardAction:(id)sender;

-(void)showPicker;
-(void)setSelectedImageOnButton:(UIImage *)image;

@end

@implementation MobileDepositController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - IBAction Methods

-(IBAction)captureFrontCardAction:(id)sender{
    _objSender=sender;
    [self showPicker];
}
-(IBAction)captureBackCardAction:(id)sender{
    _objSender=sender;
    [self showPicker];
}


-(void)setSelectedImageOnButton:(UIImage *)image{

    UIButton *castSenderButton = (UIButton *)_objSender;
    [castSenderButton setImage:image forState:UIControlStateNormal];
}

-(void)showPicker{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    [self presentViewController:picker animated:YES completion:Nil];
}


#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self setSelectedImageOnButton:chosenImage];
    
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
