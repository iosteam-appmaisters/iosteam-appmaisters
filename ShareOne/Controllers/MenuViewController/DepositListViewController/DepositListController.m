//
//  DepositListController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/23/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "DepositListController.h"
#import "CashDeposit.h"
#import "VertifiObject.h"
#import "DepositCell.h"
#import "VertifiDepositObject.h"
#import "SharedUser.h"


@implementation DepositListController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadDataOnPickerView];


}

-(void)loadDataOnPickerView{
    
    _suffixArr= [[SharedUser sharedManager] suffixInfoArr];
    [self.pickerView reloadAllComponents];
    
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self getDataFromVertifi];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(IBAction)accountButtonClicked:(id)sender{
    [self managePickerView];
}

-(void)managePickerView{
    
    if (_bottomConstraint.constant<0){
        
        if([ShareOneUtility getSettingsWithKey:SHOW_OFFERS_SETTINGS]){
            _bottomConstraint.constant=50;
        }
        else{
            _bottomConstraint.constant=0;
        }
        [self.view layoutIfNeeded];
    }
    else{
        
        _bottomConstraint.constant=-500;
        [self.view layoutIfNeeded];
    }
    
}
-(IBAction)doneButtonClicked:(id)sender{
    
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self managePickerView];
    [self getDataFromVertifi];
}

-(void)getListOfPast6MonthsDeposits{
    
    __weak DepositListController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:REQUESTER_VALUE forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]] forKey:@"timestamp"];
    
    [params setValue:ROUTING_VALUE forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:[ShareOneUtility  getMacForVertifiForSuffix:_objSuffixInfo] forKey:@"MAC"];
    
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:kVERTIFY_ALL_DEP_LIST_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        VertifiObject * obj = (VertifiObject *)user;
        weakSelf.contentArr = obj.depositArr;
        [weakSelf.tblView reloadData];
        [weakSelf reloadCustomData];
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)reloadCustomData{
    
    NSLog(@"reloadCustomData");
    [self.tblView reloadData];
    [self.tblView setNeedsLayout];
    [self.tblView layoutIfNeeded];
    [self.tblView reloadData];
    
}
-(void)getDataFromVertifi{
 
    [self getListOfPast6MonthsDeposits];

}


#pragma PickerView - Delegate
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _suffixArr.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    SuffixInfo *obj = _suffixArr[row];
    return  obj.Descr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    _objSuffixInfo = _suffixArr[row];
    [_accountTxtFeild setText:_objSuffixInfo.Descr];
}


#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_contentArr count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DepositCell *cell =  (DepositCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DepositCell class]) forIndexPath:indexPath];
    
    
    VertifiDepositObject  *objVertifiDepositObject = _contentArr[indexPath.row];
    
    [cell.headerLbl setText:[NSString stringWithFormat:@"Deposit # %@",objVertifiDepositObject.Deposit_ID]];
    [cell.dateLbl setText:[NSString stringWithFormat:@"Submitted %@",objVertifiDepositObject.Create_Timestamp]];
    [cell.amountLbl setText:[NSString stringWithFormat:@"$%@ >",objVertifiDepositObject.Amount]];
    
    
    return cell;
}

- (BOOL)shouldAutorotate{
    
    return NO;
}

@end