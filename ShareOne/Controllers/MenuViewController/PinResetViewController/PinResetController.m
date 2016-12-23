//
//  PinResetController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/29/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "PinResetController.h"
#import "ShareOneUtility.h"
#import "ConstantsShareOne.h"
#import "LoginViewController.h"
#import "User.h"
@implementation PinResetController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    if(_isFromForgotUserName)
        _navBar.topItem.title = @"Forgot Username";
    else
        _navBar.topItem.title = @"Forgot Password";

//    [_accountNameTxtFeild setText:@"7"];
//    [_taxIDTxtFeild setText:@"9456"];
//    [_dateTxtFeild setText:@"01/01/1980"];
//    [_postalCodeTxtFeild setText:@"77777"];
}


-(void)manageKeyboard{
    
    
    if([_dateTxtFeild isFirstResponder]){
        [_dateTxtFeild resignFirstResponder];
    }

    if([_accountNameTxtFeild isFirstResponder]){
        [_accountNameTxtFeild resignFirstResponder];
    }

    if([_taxIDTxtFeild isFirstResponder]){
        [_taxIDTxtFeild resignFirstResponder];
    }

    if([_postalCodeTxtFeild isFirstResponder]){
        [_postalCodeTxtFeild resignFirstResponder];
    }

}


-(IBAction)backButtonClicked:(id)sender{
    _loginDelegate.objPinResetController=nil;
    [self manageKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)submittButtonClicked:(id)sender{
    
    [self manageKeyboard];
    
    __weak PinResetController *weakSelf = self;

    if(_isFromForgotUserName){
        
        [User userAccountName:[NSDictionary dictionaryWithObjectsAndKeys:_accountNameTxtFeild.text,@"AccountNumber",_taxIDTxtFeild.text,@"Last4",_dateTxtFeild.text,@"DateOfBirth",_postalCodeTxtFeild.text,@"PostalCode", nil] delegate:self completionBlock:^(id  response) {
            
            NSDictionary *dict =(NSDictionary *)response;
            [weakSelf showAlertWithTitle:@"Account Name" AndMessage:[NSString stringWithFormat:@"Your member account name is \"%@\"",dict[@"AccountName"]]];

        } failureBlock:^(NSError *error) {
            
        }];

        
    }
    else{
        
        [User userPinReset:[NSDictionary dictionaryWithObjectsAndKeys:_accountNameTxtFeild.text,@"Account",_taxIDTxtFeild.text,@"Last4",_dateTxtFeild.text,@"DateOfBirth",_postalCodeTxtFeild.text,@"PostalCode", nil] delegate:self completionBlock:^(id  response) {
            
            _accountInfoDict=(NSDictionary *)response;
            
            [_emailLbl setText:_accountInfoDict[@"EmailAddress"]];
            [_passLbl setText:_accountInfoDict[@"TempPassword"]];
            [_dateLbl setText:_accountInfoDict[@"NewExpiration"]];
            
            
            [_accountInfoView setHidden:FALSE];
            
            
        } failureBlock:^(NSError *error) {
            
        }];

    }

}
-(IBAction)okButtonClicked:(id)sender{
    
    [self manageKeyboard];

    User *user = [[User alloc] init];
    user.UserName=_accountNameTxtFeild.text;
    user.Password=_passLbl.text;
    user.Emailaddress=_emailLbl.text;
    user.Temppassword=_passLbl.text;
    user.Newexpiration=_dateLbl.text;
    user.Last4=_taxIDTxtFeild.text;
    user.dob=_dateTxtFeild.text;
    user.zip=_postalCodeTxtFeild.text;
    [ShareOneUtility saveUserObject:user];
    [ShareOneUtility saveUserObjectToLocalObjects:user];
    
    [_loginDelegate getSignInWithUser:user];
    
    

}

-(IBAction)doneButtonClickedOnPicker:(id)sender{
    [self managePickerView];
}

-(IBAction)dateButtonClicked:(id)sender{
    if([_dateTxtFeild.text length]<=0){
        [self updateTextField:_datePicker];
    }
    [self managePickerView];
}

-(IBAction)updateTextField:(UIDatePicker *)sender{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    [_dateTxtFeild setText:[self getDateStringFromPicker:datePicker]];
}


-(NSString *)getDateStringFromPicker:(UIDatePicker *)picker{
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    dateFormat.dateStyle=NSDateFormatterMediumStyle;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    return  [NSString stringWithFormat:@"%@",[dateFormat  stringFromDate:picker.date]];
}

-(void)managePickerView{
    
    if([_accountNameTxtFeild isFirstResponder]){
        [_accountNameTxtFeild resignFirstResponder];
    }

    if([_taxIDTxtFeild isFirstResponder]){
        [_taxIDTxtFeild resignFirstResponder];
    }

    if([_postalCodeTxtFeild isFirstResponder]){
        [_postalCodeTxtFeild resignFirstResponder];
    }

    
    
    if (_datePickerBottomConstraint.constant<0){
        
        _datePickerBottomConstraint.constant=0;
        [self.view layoutIfNeeded];
    }
    else{
        
        _datePickerBottomConstraint.constant=-500;
        [self.view layoutIfNeeded];
    }
    
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
                             }];
                             [self backButtonClicked:self];
                             
                             
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (BOOL)shouldAutorotate{
    
    return NO;
}


@end
