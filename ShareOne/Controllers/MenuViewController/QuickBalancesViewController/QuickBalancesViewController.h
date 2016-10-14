//
//  QuickBalancesViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"
#import "FZAccordionTableView.h"


@interface QuickBalancesViewController : UIViewController<FZAccordionTableViewDelegate>


@property (nonatomic, weak) IBOutlet FZAccordionTableView *qbTblView;
@property (nonatomic, strong) NSArray *qbArr;

- (IBAction)dismissQuickBalances:(id)sender;

@end
