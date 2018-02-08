//
//  QuickBalancesViewController.h
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BaseViewController.h"
#import "FZAccordionTableView.h"


@interface QuickBalancesViewController : UIViewController<FZAccordionTableViewDelegate,NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>{
    NSMutableData *dataToDownload;
}


@property (nonatomic, weak) IBOutlet FZAccordionTableView *qbTblView;
@property (nonatomic, strong) NSArray *qbArr;

@property(nonatomic,strong) NSMutableArray * currentQTArray;

@property(nonatomic,strong) NSString * numOfQuickViewTransactions;

- (IBAction)dismissQuickBalances:(id)sender;

-(void)HeaderButtonAction:(id)sender;

@end
