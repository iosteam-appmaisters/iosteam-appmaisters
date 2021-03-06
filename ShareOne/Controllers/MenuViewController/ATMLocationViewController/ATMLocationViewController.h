//
//  ATMLocationViewController.h
//  ShareOne
//
//  Created by Shahrukh Jamil on 9/22/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ATMLocationViewController : BaseViewController
@property BOOL showMyLocationOnly;

@property (nonatomic,strong)NSArray *locationArr;
@property int selectedIndex;
@property (nonatomic,weak)IBOutlet UIButton *getDirectionButton;

-(IBAction)getDirectionButtonAction:(id)sender;

@end
