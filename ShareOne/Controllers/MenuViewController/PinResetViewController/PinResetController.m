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

@implementation PinResetController

-(IBAction)submittButtonClicked:(id)sender{
    
    [_accountInfoView setHidden:FALSE];
}
-(IBAction)okButtonClicked:(id)sender{
    [_accountInfoView setHidden:TRUE];
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

@end
