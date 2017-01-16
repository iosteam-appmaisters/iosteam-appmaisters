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


@interface PaymentSettingController ()

@property (nonatomic,weak) IBOutlet UILabel *contactsHeaderLbl;
@property (nonatomic,weak) IBOutlet UILabel *contactsHeaderMaxLbl;

@property (nonatomic,weak) IBOutlet UIView *contactsDetailsView;
@property (nonatomic,weak) IBOutlet UITextField *profileLinkTextFeild;
@property (nonatomic,weak) IBOutlet UITextField *profileNameTextFeild;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *favouriteLblYConstraint;
@property float contactViewHeight;


-(IBAction)AddToFavouriteButtonClicked:(id)sender;

@end

@implementation PaymentSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];

    // Do any additional setup after loading the view.
    self.favContactsTblView.allowMultipleSectionsOpen = NO;
    [self.favContactsTblView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactsHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:kContactsHeaderViewReuseIdentifier];
    //[self updateViewWithRefrenceOfContacts];
    
    
}

-(void)updateViewWithRefrenceOfContacts{
    
    _contactViewHeight = _contactsDetailsView.frame.size.height;
    
    if(_favouriteLblYConstraint.constant==0){
        
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

-(IBAction)AddToFavouriteButtonClicked:(id)sender{
    [self updateViewWithRefrenceOfContacts];
    

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
//    return [_favouriteContactsArray count];
    return 5;
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
        
        [cellDelete.delBtnNo addTarget:self action:@selector(deleteButtonNoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cellDelete.delBtnYes addTarget:self action:@selector(deleteButtonYesAction:) forControlEvents:UIControlEventTouchUpInside];

        
        cell=cellDelete;
    }
    else{
        EditContactCell *editCell =  (EditContactCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EditContactCell class]) forIndexPath:indexPath];
        
        NSAttributedString *nickNamePlaceHolder = [[NSAttributedString alloc] initWithString:@"Enter the new Nickname" attributes:@{ NSForegroundColorAttributeName : DEFAULT_RED_COLOR }];
        
        NSAttributedString *urlPlaceHolder = [[NSAttributedString alloc] initWithString:@"Enter the new URL" attributes:@{ NSForegroundColorAttributeName : DEFAULT_RED_COLOR }];
        
        
        editCell.nickNameTxtFeild.attributedPlaceholder = nickNamePlaceHolder;
        editCell.urlTxtFeild.attributedPlaceholder = urlPlaceHolder;
        editCell.nickNameTxtFeild.delegate=self;
        


        cell = editCell;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ContactsHeaderView *objFZAccordionTableViewHeaderView =(ContactsHeaderView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kContactsHeaderViewReuseIdentifier];
    [objFZAccordionTableViewHeaderView.editButton setTag:section];
    [objFZAccordionTableViewHeaderView.deleteButton setTag:section];
    
    [objFZAccordionTableViewHeaderView removeGestureRecognizer:objFZAccordionTableViewHeaderView.headerTapGesture];
    
    [objFZAccordionTableViewHeaderView.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [objFZAccordionTableViewHeaderView.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    return (UIView *)objFZAccordionTableViewHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark - Selector Methods
-(void)deleteButtonAction:(id)sender{
    
    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;

    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected] && !_isFromDelete){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    _isFromDelete = YES;
    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
}

-(void)deleteButtonYesAction:(id)sender{
    [self updateViewWithRefrenceOfContacts];
}

-(void)deleteButtonNoAction:(id)sender{
    [self updateViewWithRefrenceOfContacts];
}



-(void)editButtonAction:(id)sender{
    UIButton *btnCase = (UIButton *)sender;
    int sectionSelected = (int) btnCase.tag;

    ContactsHeaderView*    groupSectionHeaderView = (ContactsHeaderView *)[self.favContactsTblView headerViewForSection:sectionSelected];
    
    if([self.favContactsTblView isSectionOpen:sectionSelected] && _isFromDelete){
        [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
    }
    _isFromDelete = NO;
    [self.favContactsTblView toggleSection:btnCase.tag withHeaderView:groupSectionHeaderView];
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
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
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
