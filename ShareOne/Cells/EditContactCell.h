//
//  EditContactCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/13/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditContactCell : UITableViewCell
@property (nonatomic,weak)IBOutlet UITextField *nickNameTxtFeild;
@property (nonatomic,weak)IBOutlet UITextField *urlTxtFeild;
@property (nonatomic,weak)IBOutlet UIButton *confirmContactNameBtn;
@property (nonatomic,weak)IBOutlet UIButton *confirmUrlBtn;

@end
