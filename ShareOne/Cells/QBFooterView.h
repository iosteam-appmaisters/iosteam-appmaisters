//
//  QBFooterView.h
//  ShareOne
//
//  Created by Qazi Naveed on 14/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZAccordionTableView.h"
#import "CustomImageView.h"

static const CGFloat kDefaultAccordionHeaderViewHeight = 25.0;
static NSString *const kQBHeaderViewReuseIdentifier = @"kQBHeaderViewReuseIdentifier";


@interface QBFooterView : FZAccordionTableViewHeaderView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTrailing;

@property (weak, nonatomic) IBOutlet CustomImageView *plusMinusIcon;

@property (weak, nonatomic) IBOutlet UIButton *plusMinusIconBg;

@property (nonatomic,weak)IBOutlet UIImageView *sectionImgVew;

@property (nonatomic,weak)IBOutlet UILabel *sectionTitleLbl;

@property (nonatomic,weak)IBOutlet UILabel *sectionAmountLbl;

@property (nonatomic,weak)IBOutlet UIButton *headerBtn;

@property (nonatomic,weak)IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *bgView;



@end
