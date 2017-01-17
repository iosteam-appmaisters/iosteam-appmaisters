//
//  PaymentController.m
//  ShareOne
//
//  Created by Qazi Naveed on 1/11/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "PaymentController.h"
#import "PaymentSettingController.h"
#import "ContactsHeaderView.h"
#import "EditContactCell.h"

@interface PaymentController (){
    
    int selected;
    User *currentUser;
    NSMutableArray *contactsArr;

}

@end

@implementation PaymentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentUser = [ShareOneUtility getUserObject];
    
    
    
    if(![ShareOneUtility getFavContactsForUser:currentUser]){
        contactsArr=[[NSMutableArray alloc] init];
    }
    else
        contactsArr=[ShareOneUtility getFavContactsForUser:currentUser];

    self.favContactsTblView.allowMultipleSectionsOpen = NO;
    [self.favContactsTblView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactsHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:kContactsHeaderViewReuseIdentifier];
    
    [_favContactsTblView setBackgroundColor:[UIColor whiteColor]];

}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [contactsArr count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 25.0;
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
    //    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    EditContactCell *editCell =  (EditContactCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EditContactCell class]) forIndexPath:indexPath];
    
    
    [editCell.nickNameTxtFeild setTag:indexPath.section];
    [editCell.urlTxtFeild setTag:indexPath.section];
    
    NSDictionary *contactDict = contactsArr[indexPath.section];
    NSString *profileLink = [ShareOneUtility getFavouriteContactProfileLinkWithObject:contactDict];
    NSString *profileNickname = [ShareOneUtility getFavouriteContactNickNameWithObject:contactDict];
    
    
    
    [editCell.nickNameTxtFeild setText:profileNickname];
    [editCell.urlTxtFeild setText:profileLink];
    
    editCell.nickNameTxtFeild.delegate=self;
    editCell.urlTxtFeild.delegate=self;
    [editCell.confirmContactNameBtn setTag:indexPath.section];
    [editCell.confirmContactNameBtn addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell = editCell;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ContactsHeaderView *objFZAccordionTableViewHeaderView =(ContactsHeaderView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kContactsHeaderViewReuseIdentifier];
    
    NSDictionary *contactsDict = contactsArr[section];
    NSString *profileName = [ShareOneUtility getFavouriteContactNickNameWithObject:contactsDict];
    
    [objFZAccordionTableViewHeaderView.editButton setHidden:TRUE];
    [objFZAccordionTableViewHeaderView.deleteButton setTag:section];
    
    [objFZAccordionTableViewHeaderView.deleteButton setImage:[UIImage imageNamed:@"pay_btn_payment"] forState:UIControlStateNormal];
    
    [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
    [objFZAccordionTableViewHeaderView.contactNameLbl setText:profileName];
    
    
    [objFZAccordionTableViewHeaderView.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return (UIView *)objFZAccordionTableViewHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark - Selector Methods
-(void)deleteButtonAction:(id)sender{
    
//    UIButton *btnCase = (UIButton *)sender;
//    int sectionSelected = (int) btnCase.tag;
//    
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
//    
//    if([self.favContactsTblView isSectionOpen:sectionSelected] && !_isFromDelete){
//        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
//    }
//    _isFromDelete = YES;
//    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)editButtonAction:(id)sender{
    
//    UIButton *btnCase = (UIButton *)sender;
//    int sectionSelected = (int) btnCase.tag;
//    
//    selected = sectionSelected;
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
//    
//    if([self.favContactsTblView isSectionOpen:sectionSelected] && _isFromDelete){
//        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
//    }
//    _isFromDelete = NO;
//    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)deleteButtonYesAction:(id)sender{
    
//    UIButton *btn = (UIButton *)sender;
//    
//    int buttonTag = (int)btn.tag;
//    
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];
//    
//    if([self.favContactsTblView isSectionOpen:buttonTag]){
//        [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];
//    }
//    
//    [contactsArr removeObjectAtIndex:buttonTag];
//    
//    [ShareOneUtility saveContactsForUser:currentUser withArray:contactsArr];
//    
//    [self updateViewWithRefrenceOfContacts];
//    [_favContactsTblView reloadData];
    
    
}

-(void)deleteButtonNoAction:(id)sender{
    //[self updateViewWithRefrenceOfContacts];
    
//    UIButton *btn = (UIButton *)sender;
//    
//    int buttonTag = (int)btn.tag;
//    
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];
//    
//    if([self.favContactsTblView isSectionOpen:buttonTag]){
//        [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];
//    }
}

-(void)confirmButtonClicked:(id)sender{
    
//    UIButton *btn = (UIButton *)sender;
//    int buttonTag = (int)btn.tag;
//    
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];
//    
//    EditContactCell *cell = (EditContactCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
//    
//    NSMutableDictionary *dict = [contactsArr[buttonTag] mutableCopy];
//    [dict setValue:[cell.urlTxtFeild text] forKey:@"profie_link"];
//    [dict setValue:[cell.nickNameTxtFeild text] forKey:@"nick_name"];
//    
//    [contactsArr replaceObjectAtIndex:buttonTag withObject:dict];
//    
//    [ShareOneUtility saveContactsForUser:currentUser withArray:contactsArr];
//    [cell.urlTxtFeild resignFirstResponder];
//    [cell.nickNameTxtFeild resignFirstResponder];
//    
//    _yConstriantTblView.constant=20;
//    
//    [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];
//    
//    [_favContactsTblView reloadData];
    
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    //        NSLog(@"didOpenSection");
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    //        NSLog(@"didCloseSection");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
//    if(![textField isEqual:_profileLinkTextFeild] && ![textField isEqual:_profileNameTextFeild]){
//        if([contactsArr count]>=5)
//            _yConstriantTblView.constant=-self.view.frame.size.height/3.5;
//        else
//            _yConstriantTblView.constant=-self.view.frame.size.height/2.5;
//    }
    
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
//    int buttonTag = (int)textField.tag;
//    
//    [textField resignFirstResponder];
//    
//    EditContactCell *cell = (EditContactCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
//    
//    if([textField isEqual:cell.nickNameTxtFeild]){
//        [cell.urlTxtFeild becomeFirstResponder];
//    }
//    
//    if([textField isEqual:cell.urlTxtFeild]){
//        [self confirmButtonClicked:textField];
//    }
    
    
    return TRUE;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
