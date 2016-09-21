//
//  QuickBalancesViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"

@interface QuickBalancesViewController : UIViewController


@property (nonatomic, weak) IBOutlet UITableView *qbTblView;
@property (nonatomic, strong) NSArray *qbArr;

- (IBAction)dismissQuickBalances:(id)sender;

@end
