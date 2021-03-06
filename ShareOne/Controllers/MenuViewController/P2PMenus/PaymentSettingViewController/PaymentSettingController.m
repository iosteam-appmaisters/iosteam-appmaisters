//
//  PaymentSettingController.m
//  ShareOne
//
//  Created by Qazi Naveed on 1/11/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "PaymentSettingController.h"
#import "EditContactCell.h"
#import "DeleteContactCell.h"
#import "IQKeyboardManager.h"


@interface PaymentSettingController ()<UITextFieldDelegate>{
    int selected;
    User *currentUser;
    NSMutableArray *contactsArr;
}

@property (nonatomic,weak) IBOutlet UILabel *contactsHeaderLbl;
@property (nonatomic,weak) IBOutlet UILabel *contactsHeaderMaxLbl;
@property (nonatomic,weak) IBOutlet UIView *contactsDetailsView;
@property (nonatomic,weak) IBOutlet UITextField *profileLinkTextFeild;
@property (nonatomic,weak) IBOutlet UITextField *profileNameTextFeild;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *favouriteLblYConstraint;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *yConstriantTblView;
@property float contactViewHeight;

-(IBAction)AddToFavouriteButtonClicked:(id)sender;

@end

@implementation PaymentSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    
    currentUser = [ShareOneUtility getUserObject];
    
    
    
    if(![ShareOneUtility getFavContactsForUser:currentUser]){
        contactsArr=[[NSMutableArray alloc] init];
    }
    else
        contactsArr=[ShareOneUtility getFavContactsForUser:currentUser];

    
    [_profileLinkTextFeild setText:@"paypal.me/"];
//    [_profileNameTextFeild setText:@"Asd"];


    // Do any additional setup after loading the view.
    self.favContactsTblView.allowMultipleSectionsOpen = NO;
    [self.favContactsTblView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactsHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:kContactsHeaderViewReuseIdentifier];
    //[self updateViewWithRefrenceOfContacts];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    _contactViewHeight = _contactsDetailsView.frame.size.height;
    
    [_favContactsTblView setBackgroundColor:[UIColor whiteColor]];
    
    [self updateViewWithRefrenceOfContacts];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;

    } completion:^(BOOL finished) {
        
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

-(void)updateViewWithRefrenceOfContacts{
    
    
    if([contactsArr count]>=5){
        
        [_contactsDetailsView setHidden:TRUE];
        [_profileLinkTextFeild setHidden:TRUE];
        [_profileNameTextFeild setHidden:TRUE];
        [_contactsHeaderLbl setHidden:TRUE];
        [_contactsHeaderMaxLbl setHidden:FALSE];
        _favouriteLblYConstraint.constant=-_contactViewHeight;
        
    }
    else{
        [_contactsDetailsView setHidden:FALSE];
        [_profileLinkTextFeild setHidden:FALSE];
        [_profileNameTextFeild setHidden:FALSE];
        [_contactsHeaderLbl setHidden:FALSE];
        [_contactsHeaderMaxLbl setHidden:TRUE];
        _favouriteLblYConstraint.constant=0;
    }
}

-(void)setEditModeActive:(BOOL)isActive{
    
    if(isActive){
        
        [_contactsDetailsView setHidden:TRUE];
        [_profileLinkTextFeild setHidden:TRUE];
        [_profileNameTextFeild setHidden:TRUE];
        [_contactsHeaderLbl setHidden:TRUE];
        [_contactsHeaderMaxLbl setHidden:FALSE];
        _favouriteLblYConstraint.constant=-_contactViewHeight;
    }
    else{
        [_contactsDetailsView setHidden:FALSE];
        [_profileLinkTextFeild setHidden:FALSE];
        [_profileNameTextFeild setHidden:FALSE];
        [_contactsHeaderLbl setHidden:FALSE];
        [_contactsHeaderMaxLbl setHidden:TRUE];
        _favouriteLblYConstraint.constant=0;
    }

}

-(IBAction)howDoesPaypalWorkAction:(id)sender{
    [_webViewParent setHidden:FALSE];
    [_closeBtn setHidden:FALSE];
    __weak PaymentSettingController *weakSelf = self;
    [ShareOneUtility showProgressViewOnView:weakSelf.webView];
    
    NSString *paypal_url = nil;
    paypal_url = @"https://www.paypal.me";
    
    
    NSMutableURLRequest  *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:paypal_url]];
    
    [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
    [_webView loadRequest:request];

}

-(IBAction)AddToFavouriteButtonClicked:(id)sender{
    
    if([_profileNameTextFeild.text length]==0){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Nickname can not be em pty" title:@"" delegate:self];
        return;
    }
    
    
    NSDictionary *contactDict = [ShareOneUtility makeContactsWithProfileLink:_profileLinkTextFeild.text AndNickName:_profileNameTextFeild.text];

    
    [contactsArr addObject:contactDict];
    
    [ShareOneUtility saveContactsForUser:currentUser withArray:contactsArr];
    [_favContactsTblView reloadData];
    [_profileNameTextFeild setText:@""];
    [_profileLinkTextFeild setText:@"paypal.me/"];

    [_profileNameTextFeild resignFirstResponder];
    [_profileLinkTextFeild resignFirstResponder];
    [self updateViewWithRefrenceOfContacts];

    //[self updateViewWithRefrenceOfContacts];
}

-(IBAction)closeWebView:(id)sender{
    [_webViewParent setHidden:TRUE];
    [_closeBtn setHidden:TRUE];
    __weak PaymentSettingController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    __weak PaymentSettingController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [ShareOneUtility hideProgressViewOnView:self.view];
    
    [[UtilitiesHelper shareUtitlities]showToastWithMessage:ERROR_MESSAGE title:@"" delegate:self];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if(_isFromDelete){
        
        DeleteContactCell *cellDelete =  (DeleteContactCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeleteContactCell class]) forIndexPath:indexPath];
        
        
        [cellDelete.delBtnNo setTag:indexPath.section];
        [cellDelete.delBtnYes setTag:indexPath.section];

        [cellDelete.delBtnNo addTarget:self action:@selector(deleteButtonNoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cellDelete.delBtnYes addTarget:self action:@selector(deleteButtonYesAction:) forControlEvents:UIControlEventTouchUpInside];

        
        cell=cellDelete;
    }
    else{
        EditContactCell *editCell =  (EditContactCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EditContactCell class]) forIndexPath:indexPath];
        
//        NSAttributedString *nickNamePlaceHolder = [[NSAttributedString alloc] initWithString:@"Enter the new Nickname" attributes:@{ NSForegroundColorAttributeName : DEFAULT_RED_COLOR }];
//        
//        NSAttributedString *urlPlaceHolder = [[NSAttributedString alloc] initWithString:@"Enter the new URL" attributes:@{ NSForegroundColorAttributeName : DEFAULT_RED_COLOR }];
//        editCell.nickNameTxtFeild.attributedPlaceholder = nickNamePlaceHolder;
//        editCell.urlTxtFeild.attributedPlaceholder = urlPlaceHolder;

        
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
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ContactsHeaderView *objFZAccordionTableViewHeaderView =(ContactsHeaderView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kContactsHeaderViewReuseIdentifier];
    
    NSDictionary *contactsDict = contactsArr[section];
    NSString *profileLink = [ShareOneUtility getFavouriteContactNickNameWithObject:contactsDict];
    
    [objFZAccordionTableViewHeaderView.editButton setTag:section];
    [objFZAccordionTableViewHeaderView.deleteButton setTag:section];
    
    [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
    [objFZAccordionTableViewHeaderView.contactNameLbl setText:profileLink];
    
    
    [objFZAccordionTableViewHeaderView.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [objFZAccordionTableViewHeaderView.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    return (UIView *)objFZAccordionTableViewHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark - Selector Methods
-(void)deleteButtonAction:(id)sender{
    
//    [self setEditModeActive:TRUE];

    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;

    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected] && !_isFromDelete){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    _isFromDelete = YES;
    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)editButtonAction:(id)sender{
//    [self setEditModeActive:TRUE];
    
    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;
    
    selected = sectionSelected;
    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected] && _isFromDelete){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    _isFromDelete = NO;
    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)deleteButtonYesAction:(id)sender{
    //[self updateViewWithRefrenceOfContacts];
    
    UIButton *btn = (UIButton *)sender;
    
    int buttonTag = (int)btn.tag;
    
    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];
    
    if([self.favContactsTblView isSectionOpen:buttonTag]){
        [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];
    }
    
    [contactsArr removeObjectAtIndex:buttonTag];
    
    [ShareOneUtility saveContactsForUser:currentUser withArray:contactsArr];
    
    [self updateViewWithRefrenceOfContacts];
    [_favContactsTblView reloadData];


}

-(void)deleteButtonNoAction:(id)sender{
    //[self updateViewWithRefrenceOfContacts];
    
    UIButton *btn = (UIButton *)sender;

    int buttonTag = (int)btn.tag;

    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];
    
    if([self.favContactsTblView isSectionOpen:buttonTag]){
        [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];
    }
}

-(void)confirmButtonClicked:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    int buttonTag = (int)btn.tag;
    
    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:buttonTag];

    EditContactCell *cell = (EditContactCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
    
    NSMutableDictionary *dict = [contactsArr[buttonTag] mutableCopy];
    [dict setValue:[cell.urlTxtFeild text] forKey:@"profie_link"];
    [dict setValue:[cell.nickNameTxtFeild text] forKey:@"nick_name"];
    
    [contactsArr replaceObjectAtIndex:buttonTag withObject:dict];
    
    [ShareOneUtility saveContactsForUser:currentUser withArray:contactsArr];
    [cell.urlTxtFeild resignFirstResponder];
    [cell.nickNameTxtFeild resignFirstResponder];

    _yConstriantTblView.constant=20;
    
    [self.favContactsTblView toggleSection:buttonTag withHeaderView:groupSectionHeaderView];

    [_favContactsTblView reloadData];

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

    if(![textField isEqual:_profileLinkTextFeild] && ![textField isEqual:_profileNameTextFeild]){
        if([contactsArr count]>=5)
            _yConstriantTblView.constant=-self.view.frame.size.height/3.5;
        else
            _yConstriantTblView.constant=-self.view.frame.size.height/2.5;
    }
    
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
//    int sectionSelected = (int) textField.tag;
//    
//    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
//    
//    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:sectionSelected];
//    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
////    [_favContactsTblView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//    
//    NSIndexSet *section = [NSIndexSet indexSetWithIndex:sectionSelected];
//    [_favContactsTblView reloadSections:section withRowAnimation:UITableViewRowAnimationTop];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self adjustTextFeildPositionForTextFeild:textField];

    return TRUE;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self adjustTextFeildPositionForTextFeild:textField];

}

-(void)adjustTextFeildPositionForTextFeild:(UITextField *)textField{
    
    int buttonTag = (int)textField.tag;
    
    [textField resignFirstResponder];
    
    EditContactCell *cell = (EditContactCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
    
    if([textField isEqual:cell.nickNameTxtFeild]){
        [cell.urlTxtFeild becomeFirstResponder];
    }
    
    if([textField isEqual:cell.urlTxtFeild]){
        [self confirmButtonClicked:textField];
    }

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
