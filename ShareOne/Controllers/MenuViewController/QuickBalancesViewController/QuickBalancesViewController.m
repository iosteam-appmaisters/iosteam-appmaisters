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
#import "QBFooterView.h"
#import "SuffixInfo.h"
#import "ShareOneUtility.h"

#import "QuickBalances.h"


@implementation QuickBalancesViewController

- (IBAction)dismissQuickBalances:(id)sender{
 
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    _qbArr = [QuickBalances getQBObjects:[ShareOneUtility getSuffixInfoSavesLocally]];
    

//    _qbArr = [ShareOneUtility getDummyDataForQB];
    
    self.qbTblView.allowMultipleSectionsOpen = YES;
    [self.qbTblView registerNib:[UINib nibWithNibName:@"QBFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:kQBHeaderViewReuseIdentifier];


}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
//    NSDictionary *objSuffixInfo = _qbArr[section];
//    NSArray *array = [objSuffixInfo valueForKey:@"section_details"];
//    return  [array count];
    
    QuickBalances *qb = _qbArr[section];
    return  [qb.transArr count];
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
//    NSArray *array = [dict valueForKey:@"section_details"];
//    NSDictionary *detailsDict = array[indexPath.row];
//    [cell.tranTitleLbl setText:[detailsDict valueForKey:@"tran_title"]];
//    [cell.tranDateLbl setText:[detailsDict valueForKey:@"tran_date"]];
//    [cell.tranAmountLbl setText:[detailsDict valueForKey:@"tran_amt"]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    QuickBalances *objQuickBalances =_qbArr[section];
//    NSDictionary *objSuffixInfo =_qbArr[section];

    
    /*
    
    QBHeaderCell *objQBHeaderCell = (QBHeaderCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBHeaderCell class])];
    [objQBHeaderCell.sectionTitleLbl setText:[dict valueForKey:@"section_title"]];
    [objQBHeaderCell.sectionAmountLbl setText:[dict valueForKey:@"section_amt"]];
    return (UIView *)objQBHeaderCell;
     */
    

    
    QBFooterView *objFZAccordionTableViewHeaderView =(QBFooterView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQBHeaderViewReuseIdentifier];
    
    /* Condtion to check whether top septator view appears or not
     ** If(section==0) - Show seperator view as it shows in mockup
     **else -          - Hide seperator view
     */
    
    /*
    if(section==0)
        [objFZAccordionTableViewHeaderView.topSeperatorView setHidden:FALSE];
    else
        [objFZAccordionTableViewHeaderView.topSeperatorView setHidden:TRUE];
     */
    
    
    
    /* Condtion to check whether categories has sub categories or not
     ** If(TRUE)    - Show right arrow in the section view
     **else -       - Hide right arrow view
     */
    

    
    
    [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[ShareOneUtility getSectionTitleByCode:objQuickBalances.Type]];
    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:[NSString stringWithFormat:@"$ %.02f",[objQuickBalances.Balance floatValue]]];
    
//    [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[objSuffixInfo valueForKey:@"section_title"]];
//    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:[NSString stringWithFormat:@"%@",[objSuffixInfo valueForKey:@"section_amt"]]];


    [objFZAccordionTableViewHeaderView.sectionImgVew setImage:[UIImage imageNamed:@"icon-dollar"]];
    return (UIView *)objFZAccordionTableViewHeaderView;
    

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"willOpenSection");

    QuickBalances *obj = _qbArr[section];
    
    __weak QuickBalancesViewController *weakSelf = self;
    NSString *SuffixID = [NSString stringWithFormat:@"%d",[obj.SuffixID intValue]];
    
    if(!obj.transArr){
        [QuickBalances getAllQuickTransaction:[NSDictionary dictionaryWithObjectsAndKeys:@"HomeBank",@"ServiceType",[ShareOneUtility getUUID],@"DeviceFingerprint",SuffixID,@"SuffixID",@"5",@"NumberOfTransactions", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
            
            if(!obj.transArr){
                obj.transArr= [[NSMutableArray alloc] init];
                
                obj.transArr=[(NSMutableArray *)user mutableCopy];
                [obj.transArr addObject:@""];
                [obj.transArr addObject:@""];
                [obj.transArr addObject:@""];
                
                [_qbTblView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

-(void)getQuickTransaction{
    
    
}
- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"didOpenSection");

    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"willCloseSection");
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"didCloseSection");
}


@end
