//
//  QBDetailsCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 21/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBDetailsCell : UITableViewCell

@property (nonatomic,weak)IBOutlet UIImageView *iconImageVew;

@property (nonatomic,weak)IBOutlet UILabel *tranTitleLbl;

@property (nonatomic,weak)IBOutlet UILabel *tranDateLbl;

@property (nonatomic,weak)IBOutlet UILabel *tranAmountLbl;


@end
