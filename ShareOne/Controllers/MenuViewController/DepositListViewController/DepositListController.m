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
#import "ImageViewPopUpController.h"
#import "DepositTutorialController.h"


@implementation DepositListController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadDataOnPickerView];
}

-(void)loadDataOnPickerView{
    
    _suffixArr= [[SharedUser sharedManager] suffixInfoArr];
    
    if([_suffixArr count]==0){
        NSArray *suffixArr = [SuffixInfo getSuffixArrayWithObject:[ShareOneUtility getSuffixInfo]];
        _suffixArr=suffixArr;
        [[SharedUser sharedManager] setSuffixInfoArr:suffixArr];
    }
    [self.pickerView reloadAllComponents];
    
    if(!_objSuffixInfo){
        [_pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    
    [self getDataFromVertifi];
}

-(void)loadTutorial{
    
    if(![ShareOneUtility hasShownTutorialsBefore]){
        
        DepositTutorialController *objDepositTutorialController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DepositTutorialController class])];
        [self presentViewController:objDepositTutorialController animated:YES completion:nil];
        
    }
    
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

-(IBAction)deleteButtonClicked:(UIButton *)sendderButton{
    int selectedIndex = (int)sendderButton.tag;
    
    [self showAlertForDeleteDepositWithTitle:@"" AndMessage:VERTIFY_DEL_DEP_MESSAGE WithIndex:selectedIndex];
}

-(void)deleteDepositAndUpdateViewWithIndex:(int)index{
    
    VertifiDepositObject  *objVertifiDepositObject = _contentArr[index];
    
    __weak DepositListController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    int currentTimeStamp = [ShareOneUtility getTimeStamp];
    
    NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
    
    NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
    
    NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:[Configuration getVertifiRequesterKey] forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",currentTimeStamp] forKey:@"timestamp"];
    
    [params setValue:[Configuration getVertifiRouterKey] forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:calculatedMac forKey:@"MAC"];
    
    [params setValue:objVertifiDepositObject.Deposit_id forKey:@"deposit_id"];
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:[NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],kVERTIFI_DELETE_DEPOSIT] AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if(succes){
            
            VertifiObject * obj = (VertifiObject *)user;
            if(!obj.deletedError){
                
                [weakSelf.contentArr removeObjectAtIndex:index];
                [weakSelf.tblView reloadData];
                [weakSelf reloadCustomData];
            }
            else{
                [[UtilitiesHelper shareUtitlities]showToastWithMessage:obj.deletedError title:@"" delegate:weakSelf];
            }
        }
        else{
            NSString *error = (NSString *)user;
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error title:@"" delegate:weakSelf];
        }
        
        
    } failureBlock:^(NSError *error) {
        
    }];

}

-(void)getListOfPast6MonthsDeposits{
    
    __weak DepositListController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    int currentTimeStamp = [ShareOneUtility getTimeStamp];
    
    NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
    
    NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
    
    NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:[Configuration getVertifiRequesterKey] forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",currentTimeStamp] forKey:@"timestamp"];
    
    [params setValue:[Configuration getVertifiRouterKey] forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:calculatedMac forKey:@"MAC"];
    
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:[NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],kVERTIFY_ALL_DEP_LIST] AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        
        if(succes){
            
            VertifiObject * obj = (VertifiObject *)user;
            weakSelf.contentArr = [obj.depositArr mutableCopy];
            
            if([weakSelf.contentArr count]==0){
                [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"No Deposits for review" title:@"" delegate:weakSelf];
            }
            else{
                [weakSelf loadTutorial];
            }

            [weakSelf.tblView reloadData];
            [weakSelf reloadCustomData];

        }
        else{
            
            NSString *error = (NSString *)user;
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error title:@"" delegate:weakSelf];

        }

        
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
#pragma SWTableViewCell - Buttons Array methods

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0f] icon:[UIImage imageNamed:@"trash"]];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    
    Configuration *config = [ShareOneUtility getConfigurationFile];
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithHexString:config.variableTextColor]
                                                icon:[UIImage imageNamed:@"foc"]];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:70.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0]
                                                icon:[UIImage imageNamed:@"boc"]];
    
    return leftUtilityButtons;
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
    return (int)_suffixArr.count;
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
    
    [cell.headerLbl setText:[NSString stringWithFormat:@"Deposit # %@",objVertifiDepositObject.Deposit_id]];
    [cell.dateLbl setText:[NSString stringWithFormat:@"Submitted %@",objVertifiDepositObject.Create_timestamp]];
    [cell.amountLbl setText:[NSString stringWithFormat:@"$%@ >",objVertifiDepositObject.Amount]];
    
    [cell.bocBtn setTag:indexPath.row];
    [cell.focBtn setTag:indexPath.row];
    [cell.delBtn setTag:indexPath.row];
    [cell.bocBtn addTarget:self action:@selector(bocButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.focBtn addTarget:self action:@selector(focButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.rightUtilityButtons=[self rightButtons];
    cell.leftUtilityButtons=[self leftButtons];
    cell.delegate=self;

    return cell;
}

#pragma mark SWTableViewCell Delegate Methods
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath *path =  [_tblView indexPathForCell:cell];
    DepositCell *objDepositCell = [_tblView cellForRowAtIndexPath:path];
    
    switch (index) {
        case 0:{
            [self focButtonClicked:objDepositCell.focBtn];
        }
            break;
            
        case 1:{
            [self bocButtonClicked:objDepositCell.bocBtn];
        }
            break;
            
        default:
            break;
    }
    
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath *path =  [_tblView indexPathForCell:cell];
    DepositCell *objDepositCell = [_tblView cellForRowAtIndexPath:path];
    
    switch (index) {
        case 0:{
            [self deleteButtonClicked:objDepositCell.delBtn];
        }
            break;
            
        case 1:{
        }
            break;
            
        default:
            break;
    }
    
    [_tblView reloadData];
}



#pragma mark SelectorMethods of UITableViewCell
-(void)focButtonClicked:(id)sender{
    NSLog(@"focButtonClicked");
    UIButton *btn = (UIButton *)sender;
    int selectedIndex =(int)btn.tag;
    NSLog(@"selectedIndex : %d",selectedIndex);

    VertifiDepositObject  *objVertifiDepositObject = _contentArr[selectedIndex];
    if(objVertifiDepositObject.image_dict)
        [self showImageViewerWithSender:btn];
    else
        [self getDetailsOfDepositWithObject:objVertifiDepositObject sender:btn];
}

-(void)bocButtonClicked:(id)sender{
    NSLog(@"bocButtonClicked");
    UIButton *btn = (UIButton *)sender;
    int selectedIndex =(int)btn.tag;
    NSLog(@"selectedIndex : %d",selectedIndex);
    VertifiDepositObject  *objVertifiDepositObject = _contentArr[selectedIndex];
    
    if(objVertifiDepositObject.image_dict)
        [self showImageViewerWithSender:btn];
    else
        [self getDetailsOfDepositWithObject:objVertifiDepositObject sender:btn];

}


#pragma mark Vertifi Api Methods
-(void)getDetailsOfDepositWithObject:(VertifiDepositObject *)vertify sender:(UIButton *)button{
    
    __weak DepositListController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    int currentTimeStamp = [ShareOneUtility getTimeStamp];
    
    NSLog(@"Current Timestamp (Before): %d",currentTimeStamp);
    
    NSString * calculatedMac = [ShareOneUtility  getMacWithSuffix:_objSuffixInfo currentTimeStamp:currentTimeStamp];
    
    NSLog(@"Current Timestamp (After): %d",currentTimeStamp);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[ShareOneUtility getSessionnKey] forKey:@"session"];
    [params setValue:[Configuration getVertifiRequesterKey] forKey:@"requestor"];
    
    [params setValue:[NSString stringWithFormat:@"%d",currentTimeStamp] forKey:@"timestamp"];
    
    [params setValue:[Configuration getVertifiRouterKey] forKey:@"routing"];
    
    [params setValue:[ShareOneUtility getMemberValue] forKey:@"member"];
    
    [params setValue:[ShareOneUtility getAccountValueWithSuffix:_objSuffixInfo] forKey:@"account"];
    
    [params setValue:calculatedMac forKey:@"MAC"];
    
    [params setValue:vertify.Deposit_id forKey:@"deposit_id"];
    
    [params setValue:@"PNG" forKey:@"output_type"];
    
    
    [CashDeposit getRegisterToVirtifi:params delegate:weakSelf url:[NSString stringWithFormat:@"%@%@",[Configuration getVertifiRDCURL],KVERTIFY_DEP_DETAILS] AndLoadingMessage:nil completionBlock:^(NSObject *user, BOOL succes) {
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        if(user){
            VertifiObject *obj = (VertifiObject *)user;
            vertify.image_dict=obj.imageDictionary;
            [weakSelf getImageViewPopUpControllerWithSender:button];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

#pragma mark ImagePopOverViewController
/*********************************************************************************************************/
#pragma mark - Get ImageViewPopUpController ViewController Method
/*********************************************************************************************************/


-(void)showImageViewerWithSender:(UIButton *)button{
    __weak DepositListController *weakSelf = self;

    [weakSelf getImageViewPopUpControllerWithSender:button];
}

-(void)getImageViewPopUpControllerWithSender:(UIButton *)button{

    NSIndexPath *index = [NSIndexPath indexPathForRow:button.tag inSection:0];
    NSLog(@"index :%ld",(long)index.row);
    DepositCell *clickedCell =(DepositCell *)[self.tblView cellForRowAtIndexPath:index];
    ImageViewPopUpController* objImageViewPopUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewPopUpController"];
    objImageViewPopUpController.isComingFromDepositList=TRUE;
    
    VertifiDepositObject  *objVertifiDepositObject = _contentArr[button.tag];

    UIImage *imageToPass = nil;
    if([button isEqual:clickedCell.focBtn])
    {
        NSString *focImageString = [[objVertifiDepositObject.image_dict valueForKey:@"PNG"] valueForKey:@"Front"];
        imageToPass = [ShareOneUtility getImageFromBase64String:focImageString];
        
         objImageViewPopUpController.isFront=TRUE;
        objImageViewPopUpController.img=imageToPass;
    }
    else
    {
        NSString *focImageString = [[objVertifiDepositObject.image_dict valueForKey:@"PNG"] valueForKey:@"Back"];
        imageToPass = [ShareOneUtility getImageFromBase64String:focImageString];

        objImageViewPopUpController.isFront=FALSE;
        objImageViewPopUpController.img=imageToPass;
    }
    
    
    [self presentViewController:objImageViewPopUpController animated:YES completion:nil];
    
}

-(void)showAlertForDeleteDepositWithTitle:(NSString *)title AndMessage:(NSString *)message WithIndex:(int)index{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:^{
                             }];
                             [self deleteDepositAndUpdateViewWithIndex:index];
                         }];
    [alert addAction:ok];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:@"Cancel"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:^{
                             }];
                         }];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}


- (BOOL)shouldAutorotate{
    
    return NO;
}

@end
