//
//  SideMenuCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BranchLocationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *branchlocationImgview;
@property (nonatomic, weak) IBOutlet UILabel *addrressLbl;
@property (nonatomic, weak) IBOutlet UILabel *streetAddressLbl;
@property (nonatomic, weak) IBOutlet UILabel *phoneNoLbl;
@property (nonatomic, weak) IBOutlet UILabel *milesLbl;
@property (nonatomic, weak) IBOutlet UILabel *officestatusLbl;
@property (nonatomic, weak) IBOutlet UILabel *drivestatusLbl;

@end
