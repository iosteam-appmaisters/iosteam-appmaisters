//
//  QBFooterView.h
//  ShareOne
//
//  Created by Qazi Naveed on 14/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZAccordionTableView.h"

static const CGFloat kDefaultAccordionHeaderViewHeight = 25.0;
static NSString *const kQBHeaderViewReuseIdentifier = @"kQBHeaderViewReuseIdentifier";


@interface QBFooterView : FZAccordionTableViewHeaderView


@property (nonatomic,weak)IBOutlet UIImageView *sectionImgVew;

@property (nonatomic,weak)IBOutlet UILabel *sectionTitleLbl;

@property (nonatomic,weak)IBOutlet UILabel *sectionAmountLbl;


@end
