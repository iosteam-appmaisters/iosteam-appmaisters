//
//  BranchLocationViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"

@interface BranchLocationViewController : BaseViewController

-(IBAction)showAllBranchesonMapButtonClicked:(id)sender;

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@end
