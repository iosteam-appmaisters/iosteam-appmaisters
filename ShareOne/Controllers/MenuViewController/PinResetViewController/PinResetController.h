//
//  PinResetController.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/29/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;

@interface PinResetController : UIViewController


@property (nonatomic,weak)   IBOutlet UIView *accountInfoView;
@property (nonatomic,weak)   IBOutlet UITextField *dateTxtFeild;
@property (nonatomic,weak)   IBOutlet UITextField *accountNameTxtFeild;
@property (nonatomic,weak)   IBOutlet UITextField *taxIDTxtFeild;
@property (nonatomic,weak)   IBOutlet UITextField *postalCodeTxtFeild;

@property (nonatomic,weak)   IBOutlet UIDatePicker *datePicker;

@property (nonatomic,strong) IBOutlet NSLayoutConstraint *datePickerBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@property (weak, nonatomic) IBOutlet UILabel *accountLbl;


@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;


@property (weak, nonatomic) IBOutlet UILabel *passLbl;
@property (nonatomic,strong) NSDictionary *accountInfoDict;

@property (nonatomic,assign) LoginViewController *loginDelegate;


@property BOOL         isFromForgotUserName;


-(IBAction)submittButtonClicked:(id)sender;
-(IBAction)okButtonClicked:(id)sender;
-(IBAction)doneButtonClickedOnPicker:(id)sender;
-(IBAction)dateButtonClicked:(id)sender;
-(IBAction)updateTextField:(UIDatePicker *)sender;
-(IBAction)backButtonClicked:(id)sender;


@end
