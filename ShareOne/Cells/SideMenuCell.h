//
//  SideMenuCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconImageVw;
@property (nonatomic, weak) IBOutlet UILabel *categorytitleLbl;
@property (nonatomic, weak) IBOutlet UIView *upperSepratorView;
@property (nonatomic, weak) IBOutlet UIView *bottomSeperatorView;
@property (nonatomic, weak) IBOutlet UIView *cellContentView;



@end
