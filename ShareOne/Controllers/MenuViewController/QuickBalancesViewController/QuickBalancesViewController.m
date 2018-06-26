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
#import "ShareOneUtility.h"

#import "QuickBalances.h"
#import "QuickTransaction.h"
#import "LoaderServices.h"
#import "SharedUser.h"



@implementation QuickBalancesViewController

- (IBAction)dismissQuickBalances:(id)sender{
 
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)HeaderButtonAction:(id)sender{
    
    UIButton *btnCase = (UIButton *)sender;
    QBFooterView*    groupSectionHeaderView = (QBFooterView *)[self.qbTblView headerViewForSection:btnCase.tag];
    [self.qbTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}



-(void)viewDidLoad{
    [super viewDidLoad];
    
    _numOfQuickViewTransactions = [ShareOneUtility getNumberOfQuickViewTransactions];
    
    __weak QuickBalancesViewController *weakSelf = self;
    
    self.qbTblView.allowMultipleSectionsOpen = NO;
    
    [self.qbTblView registerNib:[UINib nibWithNibName:@"QBFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:kQBHeaderViewReuseIdentifier];
    
    [ShareOneUtility showProgressViewOnView:self.view];
    
    [QuickBalances getAllBalances:[NSDictionary dictionaryWithObjectsAndKeys:@"HomeBank",@"ServiceType", nil] delegate:weakSelf completionBlock:^(NSArray *qbObjects) {
        
        [ShareOneUtility hideProgressViewOnView:self.view];
        
        weakSelf.qbArr = qbObjects;
        
        [weakSelf.qbTblView reloadData];
        
    } failureBlock:^(NSError *error) {
        
        [ShareOneUtility hideProgressViewOnView:self.view];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)fetchAllQuickTransactions {
    
    __weak QuickBalancesViewController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:self.view];
    
    [LoaderServices setQTRequestOnQueueWithDelegate:weakSelf AndQuickBalanceArr:weakSelf.qbArr completionBlock:^(BOOL success,NSString *errorString) {

        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if(success && !errorString){
            [weakSelf.qbTblView reloadData];
        }
        else{
            [[UtilitiesHelper shareUtitlities] showToastWithMessage:errorString title:@"" delegate:weakSelf];
        }
        
    } failureBlock:^(NSError *error) {

        [ShareOneUtility hideProgressViewOnView:self.view];
    }];
    
}

-(void)appGoingToBackground{
    
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]){
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self dismissQuickBalances:nil];
}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    QuickBalances *obj = _qbArr[section];
    return obj.transArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_qbArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    float height = 0.0;
    if(APPC_IS_IPAD){
        height = 50.0;
    }
    else{
        height = 50.0;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QBDetailsCell *cell =  (QBDetailsCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBDetailsCell class]) forIndexPath:indexPath];
    cell.iconImageVew.hidden = YES;
    if(indexPath.row%2==0){
        [cell.contentView setBackgroundColor:DEFAULT_COLOR_WHITE];
    }
    else{
        [cell.contentView setBackgroundColor:DEFAULT_COLOR_GRAY];
    }

    QuickBalances *obj = _qbArr[indexPath.section];
    
    QuickTransaction *objQuickTransaction = obj.transArr[indexPath.row];
    
    [cell.tranTitleLbl setText:objQuickTransaction.Tran];
    [cell.tranDateLbl setText:objQuickTransaction.Post];
    
    NSString * amount = [self getFormattedAmount:@([objQuickTransaction.Amt floatValue])];
    
    [cell.tranAmountLbl setText:amount];
    
    NSString * dollarRemovedString = [amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
    if (dollarRemovedString.floatValue < 0.00){
        cell.tranAmountLbl.textColor = [UIColor redColor];
    }
    else {
        cell.tranAmountLbl.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    QBFooterView *objFZAccordionTableViewHeaderView =(QBFooterView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQBHeaderViewReuseIdentifier];
    
    QuickBalances *obj = _qbArr[section];
    
    objFZAccordionTableViewHeaderView.plusMinusIconBg.tag = section;
    [objFZAccordionTableViewHeaderView.plusMinusIconBg addTarget:self action:@selector(plusMinusTapped:) forControlEvents:UIControlEventTouchUpInside];
    objFZAccordionTableViewHeaderView.sectionImgVew.hidden = YES;
    
    StyleValuesObject *objStyleValuesObject= [Configuration getStyleValueContent];

    
    [objFZAccordionTableViewHeaderView.bgView setBackgroundColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolortop]];

    if(obj.Descr)
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:obj.Descr];
    else
        
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[ShareOneUtility getSectionTitleByCode:obj.Type]];
    
    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:[self getAmountWithFilters:obj]];
    
    [objFZAccordionTableViewHeaderView.headerBtn setTag:section];
    
    [objFZAccordionTableViewHeaderView.sectionImgVew setImage:[UIImage imageNamed:@"icon-dollar"]];
    
    UIView * sectionHeaderView = (UIView *)objFZAccordionTableViewHeaderView;
    sectionHeaderView.tag = section;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSectionTap:)];
    
    [sectionHeaderView addGestureRecognizer:singleFingerTap];
    
    return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {

    QBFooterView * qbView = (QBFooterView*)[tableView headerViewForSection:section];
    [qbView.plusMinusIcon setCustomImage:[UIImage imageNamed:@"qb_up_arrow"]];

    [self getQTForSelectedSection:(int)section];
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
  
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {

    QBFooterView * qbView = (QBFooterView*)[tableView headerViewForSection:section];
    [qbView.plusMinusIcon setCustomImage:[UIImage imageNamed:@"qb_down_arrow"]];
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

-(NSString*)getAmountWithFilters:(QuickBalances*) obj {
    
    NSLog(@"Descr:: %@, Type:: %@, Available:: %@, Balance:: %@",obj.Descr, obj.Type,obj.Available,obj.Balance);
    
    if ([obj.Type isEqualToString:@"V"]){
        return [self getFormattedAmount:obj.Balance];
    }
    else if ([obj.Type isEqualToString:@"S"]){
        return [self getFormattedAmount:obj.Available];
    }
    else {
        if ( [obj.Type isEqualToString:@"C"] || [obj.Type isEqualToString:@"L"]) {
            if (obj.Available.intValue == 0){
                return [self getFormattedAmount:obj.Balance];
            }
            else if (obj.Available.intValue > 0){
                return [NSString stringWithFormat:@"%@ (%@ Avl)",[self getFormattedAmount:obj.Balance],[self getFormattedAmount:obj.Available]];
            }
        }
    }
    return [self getFormattedAmount:obj.Available];
}


-(NSString *)getFormattedAmount:(NSNumber*)value {
    
    if (value == nil){
        return @"$0.00";
    }
    
    NSLog(@"VALUE:: %@",value);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setGroupingSeparator:groupingSeparator];
    [formatter setGroupingSize:3];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    NSString *formattedString = [formatter stringFromNumber:value];
    
    NSString * last = [[[NSString stringWithFormat:@"%.02f",value.floatValue] componentsSeparatedByString:@"."]lastObject];
    
    NSString * final = [NSString stringWithFormat:@"$%@%@",formattedString,last];
    
    return final;
    
}

- (void)handleSectionTap:(UITapGestureRecognizer *)recognizer {
    [self sectionTapped:(int)recognizer.view.tag];
}

-(void)plusMinusTapped:(UIButton*)sender {
    [self sectionTapped:(int)sender.tag];
}

-(void) sectionTapped:(int)section {
    
    /*QuickBalances *obj = _qbArr[section];
    if([obj.transArr count]<=0) {
        [self noTransaction];
        return;
    }
    else {
        [_qbTblView toggleSection:section];
    }*/
     [_qbTblView toggleSection:section];
}

- (void)getQTForSelectedSection:(int)section {
    
    [ShareOneUtility showProgressViewOnView:self.view];
    
    QuickBalances *obj = _qbArr[section];
    
    __weak QuickBalancesViewController *weakSelf = self;
    
    NSString *SuffixID = [NSString stringWithFormat:@"%d",obj.Suffixid.intValue];
    
    [QuickBalances getAllQuickTransaction:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getUUID],@"DeviceFingerprint",SuffixID,@"SuffixID",_numOfQuickViewTransactions,@"NumberOfTransactions", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
        NSMutableArray * transactionArray = [(NSArray*)user mutableCopy];
        
        if([transactionArray count]<=0) {
            [self noTransaction];
        }
        else {
            for (QuickBalances * qb in weakSelf.qbArr){
                if ([[qb.Suffixid stringValue] isEqualToString:SuffixID]) {
                    qb.transArr = transactionArray;
                    break;
                }
            }
        }
        [weakSelf.qbTblView reloadData];
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
    } failureBlock:^(NSError *error) {
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
    }];
    
}

-(void)noTransaction{
    __weak QuickBalancesViewController *weakSelf = self;
    
    [[ShareOneUtility shareUtitlities] showToastWithMessage:@"No Transaction" title:@"" delegate:weakSelf];
}

- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
