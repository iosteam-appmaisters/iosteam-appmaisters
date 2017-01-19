//
//  PaymentSettingController.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/11/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FZAccordionTableView.h"
#import "ContactsHeaderView.h"


@interface PaymentSettingController : BaseViewController

@property (nonatomic, weak) IBOutlet FZAccordionTableView *favContactsTblView;
@property (nonatomic,weak) IBOutlet UIView *webViewParent;
@property (nonatomic,weak) IBOutlet UIButton *closeBtn;
@property (nonatomic,weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSArray *favouriteContactsArray;
@property BOOL isFromDelete;


@end
