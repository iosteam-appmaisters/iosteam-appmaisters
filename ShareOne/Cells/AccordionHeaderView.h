//
//  AccordionHeaderView.h
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "FZAccordionTableView.h"

static const CGFloat kDefaultAccordionHeaderViewHeight = 44.0;
static NSString *const kAccordionHeaderViewReuseIdentifier = @"AccordionHeaderViewReuseIdentifier";

@interface AccordionHeaderView : FZAccordionTableViewHeaderView

@property (nonatomic,weak) IBOutlet UILabel *sectionTitle;
@property (nonatomic,weak) IBOutlet UIImageView *sectionImageVw;
@property (nonatomic,weak) IBOutlet UIView *topSeperatorView;
@property (nonatomic,weak) IBOutlet UIImageView *arrowImageView;



@end
