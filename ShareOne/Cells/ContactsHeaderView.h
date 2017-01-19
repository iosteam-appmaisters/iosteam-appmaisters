//
//  ContactsHeaderView.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/11/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZAccordionTableView.h"


static const CGFloat kDefaultAccordionHeaderViewHeight = 25.0;
static NSString *const kContactsHeaderViewReuseIdentifier = @"kContactsHeaderViewReuseIdentifier";

@interface ContactsHeaderView : FZAccordionTableViewHeaderView
@property (nonatomic,strong)IBOutlet UIButton *editButton;
@property (nonatomic,strong)IBOutlet UIButton *deleteButton;
@property (nonatomic,strong)IBOutlet UILabel *contactNameLbl;

@property (nonatomic,strong)IBOutlet UIImageView *editImageView;
@property (nonatomic,strong)IBOutlet UIImageView *deleteImageView;




@end
