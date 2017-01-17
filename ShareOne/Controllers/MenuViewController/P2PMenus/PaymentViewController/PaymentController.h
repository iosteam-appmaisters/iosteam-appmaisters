//
//  PaymentController.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/11/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FZAccordionTableView.h"


@interface PaymentController : BaseViewController

@property (nonatomic, weak) IBOutlet FZAccordionTableView *favContactsTblView;
@property (nonatomic, strong) NSArray *favouriteContactsArray;

@end
