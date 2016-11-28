//
//  DepositCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepositCell : UITableViewCell

@property (nonatomic,weak)IBOutlet UILabel *headerLbl;

@property (nonatomic,weak)IBOutlet UILabel *dateLbl;

@property (nonatomic,weak)IBOutlet UILabel *amountLbl;

@end
