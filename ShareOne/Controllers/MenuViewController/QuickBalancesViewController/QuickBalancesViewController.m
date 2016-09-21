//
//  QuickBalancesViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "QuickBalancesViewController.h"
#import "QBHeaderCell.h"
#import "QBDetailsCell.h"

@implementation QuickBalancesViewController

- (IBAction)dismissQuickBalances:(id)sender{
 
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView Delegate Methods
#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int subCatCount = 0;
    NSDictionary *dict = _qbArr[section];
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    if([subCatArr isKindOfClass:[NSArray class]] && [subCatArr count]>0)
        subCatCount = [subCatArr count];
    
    return subCatCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_qbArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QBDetailsCell *cell =  (QBDetailsCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBDetailsCell class]) forIndexPath:indexPath];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    QBHeaderCell *objFZAccordionTableViewHeaderView =(QBHeaderCell *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([QBHeaderCell class])];
    
    return (UIView *)objFZAccordionTableViewHeaderView;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

@end
