//
//  MoneyTransferHeader.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/18/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZAccordionTableView.h"


static NSString *const kMoneyTransferHeaderViewReuseIdentifier = @"kMoneyTransferHeaderViewReuseIdentifier";

@interface MoneyTransferHeader : FZAccordionTableViewHeaderView


@property (nonatomic,weak)IBOutlet UIButton *transferBtn;
@property (nonatomic,weak)IBOutlet UILabel *headerTitleLbl;

@end
