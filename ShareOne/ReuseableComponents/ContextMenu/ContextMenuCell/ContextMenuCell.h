//
//  YALSideMenuCell.h
//  YALMenuAnimation
//
//  Created by Maksym Lazebnyi on 1/12/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//


@import UIKit;

#import "CustomButton.h"
#import "YALContextMenuCell.h"

@interface ContextMenuCell : UITableViewCell <YALContextMenuCell>
    
@property (weak, nonatomic) IBOutlet CustomButton *crossButton;
    
@property (strong, nonatomic) IBOutlet UIImageView *menuImageView;
@property (strong, nonatomic) IBOutlet UILabel *menuTitleLabel;

@end
