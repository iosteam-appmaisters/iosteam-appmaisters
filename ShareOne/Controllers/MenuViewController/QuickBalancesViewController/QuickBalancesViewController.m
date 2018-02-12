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
    
    __weak QuickBalancesViewController *weakSelf = self;
    
    _currentQTArray = [NSMutableArray array];
    
    _qbArr= [[SharedUser sharedManager] suffixInfoArr];
    
    
    if([_qbArr count]<=0){
        NSArray *suffixArr = [SuffixInfo getSuffixArrayWithObject:[ShareOneUtility getSuffixInfo]];
        _qbArr=suffixArr;
        [[SharedUser sharedManager] setSuffixInfoArr:suffixArr];
    }
    
    NSMutableArray * temp = [NSMutableArray array];
    
    for (SuffixInfo * info in _qbArr){
        
        if (![[info Hidden]boolValue] && ([info Closed] == nil || ![[info Closed] boolValue])) {
            if ([info.Access containsString:@"Q"]){
                NSLog(@"=== %@",info.Access);
                NSLog(@"Showing:: %@:%@:%@",[info Descr],[info Hidden],[info Closed]);
                [temp addObject:info];
            }
        }
    }
    
    _qbArr = temp;
    
    [ShareOneUtility showProgressViewOnView:self.view];

    [LoaderServices setQTRequestOnQueueWithDelegate:weakSelf AndQuickBalanceArr:weakSelf.qbArr completionBlock:^(BOOL success,NSString *errorString) {
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if(success && !errorString){
            [weakSelf.qbTblView reloadData];
        }
        else{
          //  [[UtilitiesHelper shareUtitlities] showToastWithMessage:errorString title:@"" delegate:weakSelf];
        }

        
    } failureBlock:^(NSError *error) {
        
    }];

    self.qbTblView.allowMultipleSectionsOpen = NO;
    [self.qbTblView registerNib:[UINib nibWithNibName:@"QBFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:kQBHeaderViewReuseIdentifier];
    
    ClientSettingsObject  *config = [Configuration getClientSettingsContent];
    
    _numOfQuickViewTransactions = @"5";
    if (config.quickviewnumoftransactions == nil){
        _numOfQuickViewTransactions = @"5";
    }
    else {
        _numOfQuickViewTransactions = config.quickviewnumoftransactions;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)appGoingToBackground{
    
    [self dismissQuickBalances:nil];
}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentQTArray.count ;
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
        height = 30.0;
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

    QuickTransaction *objQuickTransaction   =  _currentQTArray[indexPath.row];
    
    [cell.tranTitleLbl setText:objQuickTransaction.Tran];
    [cell.tranDateLbl setText:objQuickTransaction.Eff];
    
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
    
    SuffixInfo *objQuickBalances =_qbArr[section];
    
    QBFooterView *objFZAccordionTableViewHeaderView =(QBFooterView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQBHeaderViewReuseIdentifier];
    
    SuffixInfo *obj = _qbArr[section];
    
    if([obj.transArray count]<=0){
        objFZAccordionTableViewHeaderView.plusMinusIcon.hidden = YES;
        objFZAccordionTableViewHeaderView.plusMinusIconBg.hidden = YES;
        objFZAccordionTableViewHeaderView.labelTrailing.constant = 10;
        [objFZAccordionTableViewHeaderView layoutIfNeeded];
    }
    else {
        objFZAccordionTableViewHeaderView.plusMinusIcon.hidden = NO;
        objFZAccordionTableViewHeaderView.plusMinusIconBg.hidden = NO;
        objFZAccordionTableViewHeaderView.labelTrailing.constant = 40;
        [objFZAccordionTableViewHeaderView layoutIfNeeded];
    }
    
    objFZAccordionTableViewHeaderView.plusMinusIconBg.tag = section;
    [objFZAccordionTableViewHeaderView.plusMinusIconBg addTarget:self action:@selector(plusMinusTapped:) forControlEvents:UIControlEventTouchUpInside];
    objFZAccordionTableViewHeaderView.sectionImgVew.hidden = YES;
    
    StyleValuesObject *objStyleValuesObject= [Configuration getStyleValueContent];

    
    [objFZAccordionTableViewHeaderView.bgView setBackgroundColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolortop]];

    if(objQuickBalances.Descr)
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:objQuickBalances.Descr];
    else
        
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[ShareOneUtility getSectionTitleByCode:objQuickBalances.Type]];
    
    NSNumber * price = objQuickBalances.Balance;
    if ([objQuickBalances.Type isEqualToString:@"C"] || [objQuickBalances.Type isEqualToString:@"c"] ||
        [objQuickBalances.Type isEqualToString:@"S"] || [objQuickBalances.Type isEqualToString:@"s"]) {
        price = objQuickBalances.Available;
    }
    
    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:[self getFormattedAmount:price]];
    
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
    
    SuffixInfo *obj = _qbArr[section];
    if([obj.transArray count]<=0) {
        [self noTransaction];
        return;
    }
    if ([_numOfQuickViewTransactions intValue] > 0){
        [_qbTblView toggleSection:section];
    }
}

- (void)getQTForSelectedSection:(int)section {
    
    [ShareOneUtility showProgressViewOnView:self.view];
    
    SuffixInfo *obj = _qbArr[section];
    
    __weak QuickBalancesViewController *weakSelf = self;
    NSString *SuffixID = [NSString stringWithFormat:@"%d",obj.Suffixid.intValue];
    
    [QuickBalances getAllQuickTransaction:[NSDictionary dictionaryWithObjectsAndKeys:/*@"HomeBank",@"ServiceType",*/[ShareOneUtility getUUID],@"DeviceFingerprint",SuffixID,@"SuffixID",_numOfQuickViewTransactions,@"NumberOfTransactions", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
        
        _currentQTArray = [(NSArray*)user mutableCopy];
        
        [weakSelf.qbTblView reloadData];
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
    } failureBlock:^(NSError *error) {
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
    }];
    
}

-(void)noTransaction{
    __weak QuickBalancesViewController *weakSelf = self;
    
    [[ShareOneUtility shareUtitlities] showToastWithMessage:@"No Transaction " title:@"" delegate:weakSelf];
}

-(void)applyURLSessionOnReq:(NSMutableURLRequest *)req{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSURLSessionDataTask * task = [defaultSession dataTaskWithRequest:req];

    [task resume];

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%lld",[response expectedContentLength]);
    dataToDownload=[[NSMutableData alloc]init];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    [dataToDownload appendData:data];
    NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)dataToDownload encoding:NSUTF8StringEncoding];
    NSLog(@"%@",ErrorResponse);

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"didCompleteWithError");
}

- (BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
