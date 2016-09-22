//
//  QBHeaderCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 21/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBHeaderCell : UITableViewCell

@property (nonatomic,weak)IBOutlet UIImageView *sectionImgVew;

@property (nonatomic,weak)IBOutlet UILabel *sectionTitleLbl;

@property (nonatomic,weak)IBOutlet UILabel *sectionAmountLbl;

@end
