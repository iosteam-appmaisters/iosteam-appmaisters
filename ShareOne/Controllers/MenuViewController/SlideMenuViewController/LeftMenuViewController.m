

#import "LeftMenuViewController.h"
#import "WebViewController.h"
#import "AccordionHeaderView.h"
#import "ShareOneUtility.h"
#import "SideMenuCell.h"


//static NSString *const kTableViewCellReuseIdentifier = @"TableViewCellReuseIdentifier";


@interface LeftMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *contentArr;
@end

@implementation LeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer* gesture=[[UISwipeGestureRecognizer alloc]init];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gesture addTarget:self action:@selector(userDidSwipe:)];
    [self.view setGestureRecognizers:[NSArray arrayWithObject:gesture]];
    
    
    _contentArr= [ShareOneUtility getSideMenuDataFromPlist];
    
    self.fzaTblView.allowMultipleSectionsOpen = YES;
//    [self.fzaTblView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellReuseIdentifier];
    [self.fzaTblView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];


}

-(void)userDidSwipe:(UISwipeGestureRecognizer*)gesture{
    if(gesture.state==UIGestureRecognizerStateEnded){
        [self backgroundButtonClicked:self];
    }
}

-(IBAction)backgroundButtonClicked:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
            [self.view setFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self.navigationController.childViewControllers.lastObject removeFromParentViewController];

        if([sender isKindOfClass:[NSIndexPath class]]){
            if (_homeDelegate != nil && [_homeDelegate respondsToSelector:@selector(pushViewControllerWithObject:)]){
                [[self homeDelegate] pushViewControllerWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Me",@"Key", nil]];
            }
        }
    }];
}

#pragma mark - UITableView Delegate Methods
#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int subCatCount = 0;
    NSDictionary *dict = _contentArr[section];
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    if([subCatArr isKindOfClass:[NSArray class]] && [subCatArr count]>0)
        subCatCount = [subCatArr count];
    
    return subCatCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_contentArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDefaultAccordionHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuCell *cell =  (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SideMenuCell class]) forIndexPath:indexPath];
    
    NSDictionary *dict = _contentArr[indexPath.section];
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    NSDictionary *dictSubCat = subCatArr[indexPath.row];
    cell.categorytitleLbl.text = [dictSubCat valueForKey:SUB_CAT_TITLE];
    [cell.iconImageVw setImage:[UIImage imageNamed:[dict valueForKey:MAIN_CAT_IMAGE]]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
   AccordionHeaderView *objFZAccordionTableViewHeaderView =(AccordionHeaderView *) [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    /* Condtion to check whether top septator view appears or not
     ** If(section==0) - Show seperator view as it shows in mockup
     **else -          - Hide seperator view
     */
    if(section==0)
        [objFZAccordionTableViewHeaderView.topSeperatorView setHidden:FALSE];
    else
        [objFZAccordionTableViewHeaderView.topSeperatorView setHidden:TRUE];
    
    NSDictionary* dict = _contentArr[section];
    
    
    /* Condtion to check whether categories has sub categories or not
     ** If(TRUE)    - Show right arrow in the section view
     **else -       - Hide right arrow view
     */
    
    if([[dict valueForKey:HAS_SECTIONS] boolValue]){
        [objFZAccordionTableViewHeaderView.arrowImageView setHidden:FALSE];
    }
    else{
        [objFZAccordionTableViewHeaderView.arrowImageView setHidden:TRUE];
    }
    
    [objFZAccordionTableViewHeaderView.sectionTitle setText:[dict valueForKey:MAIN_CAT_TITLE]];
    [objFZAccordionTableViewHeaderView.sectionImageVw setImage:[UIImage imageNamed:[dict valueForKey:MAIN_CAT_IMAGE]]];
    return (UIView *)objFZAccordionTableViewHeaderView;
    
    //    UIButton *cellButton = (UIButton*)[cell viewWithTag:1];
    //    [cellButton addTarget:self action:@selector(premiumSectionClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    [self backgroundButtonClicked:indexPath];
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"willOpenSection");
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
//    NSLog(@"didOpenSection");
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"willCloseSection");
    
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"didCloseSection");
    
    
}



@end
