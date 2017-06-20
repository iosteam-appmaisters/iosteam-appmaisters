//
//  DepositCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface DepositCell : SWTableViewCell

@property (nonatomic,weak)IBOutlet UILabel *headerLbl;

@property (nonatomic,weak)IBOutlet UILabel *dateLbl;

@property (nonatomic,weak)IBOutlet UILabel *amountLbl;

@property (nonatomic,weak)IBOutlet UIButton *bocBtn;
@property (nonatomic,weak)IBOutlet UIButton *focBtn;
@property (nonatomic,weak)IBOutlet UIButton *delBtn;




@end
