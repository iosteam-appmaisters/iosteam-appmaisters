//
//  SideMenuCell.m
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BranchLocationCell.h"

@implementation BranchLocationCell
@synthesize delegate;
- (void)awakeFromNib
{
    [super awakeFromNib];
    [_getDirectionbtn addTarget:self action:@selector(getDirectionbuttonClicked)
          forControlEvents:UIControlEventTouchUpInside];
}
-(void)getDirectionbuttonClicked
{
    if([self.delegate respondsToSelector:@selector(getDirectionButtonClicked:)])
    {
        [self.delegate getDirectionButtonClicked:self];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
