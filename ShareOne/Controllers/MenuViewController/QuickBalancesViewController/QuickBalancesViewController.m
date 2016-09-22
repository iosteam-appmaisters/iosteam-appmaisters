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
#import "ShareOneUtility.h"



@implementation QuickBalancesViewController

- (IBAction)dismissQuickBalances:(id)sender{
 
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _qbArr = [ShareOneUtility getDummyDataForQB];
}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = _qbArr[section];
    NSArray *array = [dict valueForKey:@"section_details"];
    return  [array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_qbArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QBDetailsCell *cell =  (QBDetailsCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBDetailsCell class]) forIndexPath:indexPath];
    if(indexPath.row%2==0){
        [cell.contentView setBackgroundColor:DEFAULT_COLOR_WHITE];
    }
    else{
        [cell.contentView setBackgroundColor:DEFAULT_COLOR_GRAY];
    }
    
    NSDictionary *dict = _qbArr[indexPath.section];
    NSArray *array = [dict valueForKey:@"section_details"];
    NSDictionary *detailsDict = array[indexPath.row];
    [cell.tranTitleLbl setText:[detailsDict valueForKey:@"tran_title"]];
    [cell.tranDateLbl setText:[detailsDict valueForKey:@"tran_date"]];
    [cell.tranAmountLbl setText:[detailsDict valueForKey:@"tran_amt"]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSDictionary *dict =_qbArr[section];
    QBHeaderCell *objQBHeaderCell = (QBHeaderCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBHeaderCell class])];
    [objQBHeaderCell.sectionTitleLbl setText:[dict valueForKey:@"section_title"]];
    [objQBHeaderCell.sectionAmountLbl setText:[dict valueForKey:@"section_amt"]];
    return (UIView *)objQBHeaderCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

@end
