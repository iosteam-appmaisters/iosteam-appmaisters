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
    
    _qbArr= [[SharedUser sharedManager] suffixInfoArr];
    
    if([_qbArr count]<=0){
        NSArray *suffixArr = [SuffixInfo getSuffixArrayWithObject:[ShareOneUtility getSuffixInfo]];
        _qbArr=suffixArr;
        [[SharedUser sharedManager] setSuffixInfoArr:suffixArr];
    }
    
    NSMutableArray * temp = [NSMutableArray array];
    
    for (SuffixInfo * info in _qbArr){
        
        if (![[info Hidden]boolValue] && ([info Closed] == nil || ![[info Closed] boolValue])) {
            [temp addObject:info];
            NSLog(@"Showing:: %@:%@:%@",[info Descr],[info Hidden],[info Closed]);
        }
        else {
            NSLog(@"Hiding:: %@:%@:%@",[info Descr],[info Hidden],[info Closed]);
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

//    _qbArr = [ShareOneUtility getDummyDataForQB];
    
    self.qbTblView.allowMultipleSectionsOpen = NO;
    [self.qbTblView registerNib:[UINib nibWithNibName:@"QBFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:kQBHeaderViewReuseIdentifier];
}



#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    SuffixInfo *qb = _qbArr[section];
    return  [qb.transArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_qbArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
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
    
    
    SuffixInfo  *objQuickBalances = _qbArr[indexPath.section];
    QuickTransaction *objQuickTransaction   =  objQuickBalances.transArray[indexPath.row];
    
    [cell.tranTitleLbl setText:objQuickTransaction.Tran];
    [cell.tranDateLbl setText:objQuickTransaction.Eff];
    [cell.tranAmountLbl setText:[self getFormattedAmount:@([objQuickTransaction.Amt floatValue])]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SuffixInfo *objQuickBalances =_qbArr[section];
//    NSDictionary *objSuffixInfo =_qbArr[section];

    
    /*
    
    QBHeaderCell *objQBHeaderCell = (QBHeaderCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QBHeaderCell class])];
    [objQBHeaderCell.sectionTitleLbl setText:[dict valueForKey:@"section_title"]];
    [objQBHeaderCell.sectionAmountLbl setText:[dict valueForKey:@"section_amt"]];
    return (UIView *)objQBHeaderCell;
     */
    

    
    QBFooterView *objFZAccordionTableViewHeaderView =(QBFooterView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQBHeaderViewReuseIdentifier];
    
    StyleValuesObject *objStyleValuesObject= [Configuration getStyleValueContent];

    
    [objFZAccordionTableViewHeaderView.contentView setBackgroundColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolortop]];

//    [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
    
    
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
    
    
    if(objQuickBalances.Descr)
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:objQuickBalances.Descr];
    else
        
        [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[ShareOneUtility getSectionTitleByCode:objQuickBalances.Type]];
    
    
    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:
     [self getFormattedAmount:objQuickBalances.Balance]
     ];
    
    [objFZAccordionTableViewHeaderView.headerBtn setTag:section];
    
//    [objFZAccordionTableViewHeaderView.headerBtn addTarget:self action:@selector(HeaderButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    [objFZAccordionTableViewHeaderView.sectionTitleLbl setText:[objSuffixInfo valueForKey:@"section_title"]];
//    [objFZAccordionTableViewHeaderView.sectionAmountLbl setText:[NSString stringWithFormat:@"%@",[objSuffixInfo valueForKey:@"section_amt"]]];


    [objFZAccordionTableViewHeaderView.sectionImgVew setImage:[UIImage imageNamed:@"icon-dollar"]];
    return (UIView *)objFZAccordionTableViewHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(NSString *)getFormattedAmount:(NSNumber*)value {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setGroupingSeparator:groupingSeparator];
    [formatter setGroupingSize:3];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setUsesGroupingSeparator:YES];

    NSString *formattedString = [formatter stringFromNumber:value];

    NSString * last = [[[NSString stringWithFormat:@"%.02f",value.floatValue] componentsSeparatedByString:@"."]lastObject];
    
    NSString * final = [NSString stringWithFormat:@"$ %@%@",formattedString,last];
    
    return final;
    
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"willOpenSection");
//    QuickBalances *obj = _qbArr[section];
//    
//    if([obj.transArr count]<=0){
//        [self noTransaction];
//    }

}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"didOpenSection");
    SuffixInfo *obj = _qbArr[section];
    
    if([obj.transArray count]<=0){
        [self noTransaction];
    }
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"willCloseSection");
//    QuickBalances *obj = _qbArr[section];
//    
//    if([obj.transArr count]<=0){
//        [self noTransaction];
//    }
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//        NSLog(@"didCloseSection");
}

- (void)getQTForSelectedSection:(int)section{
    
//    QuickBalances *obj = _qbArr[section];
    
    __weak QuickBalancesViewController *weakSelf = self;
//    NSString *SuffixID = [NSString stringWithFormat:@"%d",[obj.SuffixID intValue]];
    NSString *SuffixID = [NSString stringWithFormat:@"%d",0];

    
//    if(!obj.transArr)
    {
        
        [QuickBalances getAllQuickTransaction:[NSDictionary dictionaryWithObjectsAndKeys:@"HomeBank",@"ServiceType",[ShareOneUtility getUUID],@"DeviceFingerprint",SuffixID,@"SuffixID",@"0",@"NumberOfTransactions", nil] delegate:weakSelf completionBlock:^(NSObject *user) {
            
//            [self applyURLSessionOnReq:(NSMutableURLRequest *)user];
            
//            if(!obj.transArr){
//                obj.transArr= [[NSMutableArray alloc] init];
//                
//                obj.transArr=[(NSMutableArray *)user mutableCopy];
//                
//                if([obj.transArr count]>0){
//                    [_qbTblView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
//                    
//                }
//                else{
//                    [self noTransaction];
//                }
//                
//            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
//    else if ([obj.transArr count]<=0){
//        [self noTransaction];
//    }
    
}
-(void)noTransaction{
    __weak QuickBalancesViewController *weakSelf = self;
    
    [[ShareOneUtility shareUtitlities] showToastWithMessage:@"No Transaction " title:@"" delegate:weakSelf];
}
-(void)applyURLSessionOnReq:(NSMutableURLRequest *)req{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSURLSessionDataTask * task = [defaultSession dataTaskWithRequest:req];

    
//    NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//    }];
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

//- (void) URLSession:(NSURLSession *)session
//           dataTask:(NSURLSessionDataTask *)dataTask
// didReceiveResponse:(NSURLResponse *)response
//  completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
//{
//    completionHandler(NSURLSessionResponseAllow);
//}

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
