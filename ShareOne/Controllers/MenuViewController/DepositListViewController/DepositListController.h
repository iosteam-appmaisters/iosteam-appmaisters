//
//  DepositListController.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/23/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface DepositListController : BaseViewController

@property (nonatomic,weak)IBOutlet UITableView *tblView;
@property (nonatomic,strong) NSArray *contentArr;


@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic,weak)IBOutlet UITextField *accountTxtFeild;
@property (nonatomic, weak) NSArray *suffixArr;
@property (nonatomic, strong) SuffixInfo *objSuffixInfo;


@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIView *pickerParentView;


@end
