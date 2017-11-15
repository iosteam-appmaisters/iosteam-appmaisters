//
//  SideMenuCell.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol branchLocationDelegate<NSObject>
-(void)getDirectionButtonClicked:(id)sender;
@end

@interface BranchLocationCell : UITableViewCell
{
    __weak id<branchLocationDelegate> delegate;

}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *driveThruHeadingLabel;
@property (nonatomic, weak) id<branchLocationDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *branchlocationImgview;
@property (nonatomic, weak) IBOutlet UILabel *addrressLbl;
@property (nonatomic, weak) IBOutlet UILabel *locationNameLbl;
@property (nonatomic, weak) IBOutlet UILabel *phoneNoLbl;
@property (nonatomic, weak) IBOutlet UILabel *milesLbl;
@property (nonatomic, weak) IBOutlet UILabel *officestatusLbl;
@property (nonatomic, weak) IBOutlet UILabel *officeHourLbl;
@property (nonatomic, weak) IBOutlet UILabel *driveThruHoursLbl;
@property (nonatomic, weak) IBOutlet UILabel *drivestatusLbl;
@property (nonatomic, weak) IBOutlet UIButton *getDirectionbtn;
@property (nonatomic, weak) IBOutlet UIButton *currentLocationBtn;
@property (nonatomic, weak) IBOutlet UILabel *cityStateLbl;



@end
