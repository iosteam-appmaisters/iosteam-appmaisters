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
#import "TransferSomeOneElseCell.h"
#import "PaymentCell.h"
#import "MoneyTransferHeader.h"
#import "IQKeyboardManager.h"

@interface PaymentController ()<UITextFieldDelegate>{
    
    int selected;
    User *currentUser;
    NSMutableArray *contactsArr;

}


@property (nonatomic,weak)IBOutlet NSLayoutConstraint *addFavouriteHeightConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *yConstriantTblView;


-(IBAction)closeWebView:(id)sender;

-(IBAction)goToAddFavouriteController:(id)sender;
-(IBAction)howDoesPaypalWorkAction:(id)sender;
@end

@implementation PaymentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];

    self.favContactsTblView.allowMultipleSectionsOpen = NO;
    
    [self.favContactsTblView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactsHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:kContactsHeaderViewReuseIdentifier];
    
    [self.favContactsTblView registerNib:[UINib nibWithNibName:NSStringFromClass([MoneyTransferHeader class]) bundle:nil] forHeaderFooterViewReuseIdentifier:kMoneyTransferHeaderViewReuseIdentifier];

    [_favContactsTblView setBackgroundColor:[UIColor whiteColor]];
    

    
}

-(IBAction)goToAddFavouriteController:(id)sender{
    
    PaymentSettingController* objPaymentSettingController = [self.storyboard instantiateViewControllerWithIdentifier:@"p2psettings"];
    objPaymentSettingController.navigationItem.title=[ShareOneUtility getNavBarTitle: @"Send Money (P2P)"];
    [self.navigationController pushViewController:objPaymentSettingController animated:YES];

}

-(IBAction)howDoesPaypalWorkAction:(id)sender{
    [self loadUrlWithName:@"https://www.paypal.me" AndAmount:nil];
}


-(IBAction)closeWebView:(id)sender{
    
    [_webViewParent setHidden:TRUE];
    [_closeBtn setHidden:TRUE];
    __weak PaymentController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.view];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateViewWithRefrenceOfContacts];
}

-(void)updateViewWithRefrenceOfContacts{
    
    currentUser = [ShareOneUtility getUserObject];
    
    if(![ShareOneUtility getFavContactsForUser:currentUser]){
        contactsArr=[[NSMutableArray alloc] init];
    }
    else
        contactsArr=[ShareOneUtility getFavContactsForUser:currentUser];

    if([contactsArr count]>0){
        _addFavouriteHeightConstraint.constant=0;
        
    }
    else{
        _addFavouriteHeightConstraint.constant=22;
    }
    
    [_favContactsTblView reloadData];

}

-(void)loadUrlWithName:(NSString *)name AndAmount:(NSString *)amount{
    
    [_webViewParent setHidden:FALSE];
    [_closeBtn setHidden:FALSE];
    __weak PaymentController *weakSelf = self;
    [ShareOneUtility showProgressViewOnView:weakSelf.webView];
    
    

    NSString *paypal_url = nil;
    
    NSMutableURLRequest *request;
    if(amount)
        paypal_url = [NSString stringWithFormat:@"https://www.%@/%.2f",name,[amount floatValue]];
    else
        paypal_url = name;
    
    request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:paypal_url]];
    
    [request setTimeoutInterval:RESPONSE_TIME_OUT_WEB_VIEW];
    [_webView loadRequest:request];
    
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:paypal_url]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    __weak PaymentController *weakSelf = self;
    [ShareOneUtility hideProgressViewOnView:weakSelf.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"didFailLoadWithError : %@",error);
    
    [ShareOneUtility hideProgressViewOnView:self.webView];
    
    [[UtilitiesHelper shareUtitlities]showToastWithMessage:[Configuration getMaintenanceVerbiage] title:@"" delegate:self];
    
}


#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [contactsArr count]+1;
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
    
    __weak PaymentController *weakSelf = self;

    UITableViewCell *cell = nil;
    
    if(indexPath.section+1>[contactsArr count]){
        
        TransferSomeOneElseCell *editCell =  (TransferSomeOneElseCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TransferSomeOneElseCell class]) forIndexPath:indexPath];
        
        
        [editCell.profileLinkTxtFeild setTag:indexPath.section];
        [editCell.amountTxtFeild setTag:indexPath.section];
        
//        NSDictionary *contactDict = contactsArr[indexPath.section];
//        NSString *profileLink = [ShareOneUtility getFavouriteContactProfileLinkWithObject:contactDict];
//        NSString *profileNickname = [ShareOneUtility getFavouriteContactNickNameWithObject:contactDict];
//        
//        
//        [editCell.nickNameTxtFeild setText:profileNickname];
//        [editCell.urlTxtFeild setText:profileLink];
        
        editCell.profileLinkTxtFeild.delegate=self;
        editCell.amountTxtFeild.delegate=self;
        
        [editCell.amountTxtFeild setText:@""];

        [ShareOneUtility setAccesoryViewForTextFeild:editCell.amountTxtFeild WithDelegate:weakSelf AndSelecter:@"textViewDoneButtonPressed:"];
        
        [editCell.payButtonBtn setTag:indexPath.section];
        [editCell.payButtonBtn addTarget:self action:@selector(transferMoneyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell = editCell;

        
    }
    else{
        
        PaymentCell *paymentCell =  (PaymentCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PaymentCell class]) forIndexPath:indexPath];
        
        [paymentCell.amountTxtFeild setTag:indexPath.section];
        paymentCell.amountTxtFeild.delegate=self;
        
        [paymentCell.amountTxtFeild setText:@""];
        
        [ShareOneUtility setAccesoryViewForTextFeild:paymentCell.amountTxtFeild WithDelegate:weakSelf AndSelecter:@"textViewDoneButtonPressed:"];

        
        [paymentCell.payButtonBtn setTag:indexPath.section];
        [paymentCell.payButtonBtn addTarget:self action:@selector(sendMoney:) forControlEvents:UIControlEventTouchUpInside];



        cell = paymentCell;


        
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = nil;
    if(section+1>[contactsArr count]){
        
        MoneyTransferHeader *objFZAccordionTableViewHeaderView =(MoneyTransferHeader *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kMoneyTransferHeaderViewReuseIdentifier];
        
        [objFZAccordionTableViewHeaderView.transferBtn setTag:section];
        
        [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
        [objFZAccordionTableViewHeaderView.transferBtn addTarget:self action:@selector(transferButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        headerView = objFZAccordionTableViewHeaderView;

    }
    else{
        
        ContactsHeaderView *objFZAccordionTableViewHeaderView =(ContactsHeaderView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kContactsHeaderViewReuseIdentifier];
        
        NSDictionary *contactsDict = contactsArr[section];
        NSString *profileName = [ShareOneUtility getFavouriteContactNickNameWithObject:contactsDict];
        
        [objFZAccordionTableViewHeaderView.editImageView setHidden:TRUE];
        [objFZAccordionTableViewHeaderView.deleteButton setTag:section];
        
        UIImage *image =[UIImage imageNamed:@"pay_btn_payment"];
        image= [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [objFZAccordionTableViewHeaderView.deleteImageView setImage:image];
        
        [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
        [objFZAccordionTableViewHeaderView.contactNameLbl setText:profileName];
        [objFZAccordionTableViewHeaderView.deleteButton setTitle:@"PAY" forState:UIControlStateNormal];
        
        [objFZAccordionTableViewHeaderView.deleteButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        headerView = objFZAccordionTableViewHeaderView;

    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


-(void)textViewDoneButtonPressed:(id)sender{
    
    [self.view endEditing:TRUE];
    _yConstriantTblView.constant=0;
}

#pragma mark - Selector Methods
-(void)payButtonAction:(id)sender{
    
    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;
    
    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected]){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    else
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)sendMoney:(id)sender{
    
    _yConstriantTblView.constant=0;

    UIButton *btn = (UIButton *)sender;
    int selectedIndex = (int)btn.tag;
    
    
    PaymentCell *cell = (PaymentCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedIndex]];

    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:selectedIndex];

    NSDictionary *dict = contactsArr[selectedIndex];
    NSString *name =[dict valueForKey:@"profie_link"];
    NSString *amount = cell.amountTxtFeild.text;
    
    [cell.amountTxtFeild resignFirstResponder];

    [self loadUrlWithName:name AndAmount:amount];
    
    [self.favContactsTblView toggleSection:selectedIndex withHeaderView:groupSectionHeaderView];

    [_favContactsTblView reloadData];

}
-(void)transferButtonAction:(id)sender{
    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;
    
    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected]){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    else
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];

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

-(void)transferMoneyButtonClick:(id)sender{
    
    _yConstriantTblView.constant=0;

    UIButton *btn = (UIButton *)sender;
    int buttonTag = (int)btn.tag;
    
    TransferSomeOneElseCell*cell = (TransferSomeOneElseCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
    
    NSString *name =cell.profileLinkTxtFeild.text;
    NSString *amount = cell.amountTxtFeild.text;
    
    [cell.amountTxtFeild resignFirstResponder];
    [cell.profileLinkTxtFeild resignFirstResponder];
    
    [self loadUrlWithName:name AndAmount:amount];
    
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
    
    _yConstriantTblView.constant=-self.view.frame.size.height/4.5;
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    
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
    
    UITableViewCell *cell = (UITableViewCell *)[_favContactsTblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonTag]];
    
    if([cell isKindOfClass:[PaymentCell class]]){
//        PaymentCell *pCell = (PaymentCell *)cell;
        _yConstriantTblView.constant=0;
    }
    
    
    if([cell isKindOfClass:[TransferSomeOneElseCell class]]){
        
        TransferSomeOneElseCell *tCell = (TransferSomeOneElseCell *)cell;
        
        if([textField isEqual:tCell.profileLinkTxtFeild]){
            [tCell.amountTxtFeild becomeFirstResponder];
        }
        
        if([textField isEqual:tCell.amountTxtFeild]){
            
            _yConstriantTblView.constant=0;
        }
    }

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
