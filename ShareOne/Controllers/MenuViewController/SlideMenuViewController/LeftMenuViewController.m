

#import "LeftMenuViewController.h"
#import "WebViewController.h"
#import "AccordionHeaderView.h"
#import "ShareOneUtility.h"
#import "SideMenuCell.h"
#import "StyleValuesObject.h"

@interface LeftMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,weak)IBOutlet UIView *parentView;

@property (nonatomic, strong) NSArray *contentArr;
@property (nonatomic, strong) NSDictionary *controllerInfoDict;
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
    
    
    
    _contentArr =     [Configuration getAllMenuItemsIncludeHiddenItems:FALSE];

    
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];
    [_parentView setBackgroundColor:[UIColor colorWithHexString:obj.menubackgroundcolor]];

    

    self.fzaTblView.allowMultipleSectionsOpen = NO;
    [self.fzaTblView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    self.fzaTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    //[self performSelector:@selector(reloadCustomData) withObject:nil afterDelay:2];


}

-(void)reloadCustomData{

    NSLog(@"reloadCustomData");
    [self.fzaTblView reloadData];
    [self.fzaTblView setNeedsLayout];
    [self.fzaTblView layoutIfNeeded];
    [self.fzaTblView reloadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        [[self homeDelegate] bringAdvertismentFront];

        if([sender isKindOfClass:[NSIndexPath class]]){
            if (_homeDelegate != nil && [_homeDelegate respondsToSelector:@selector(pushViewControllerWithObject:)]){
                [[self homeDelegate] pushViewControllerWithObject:_controllerInfoDict];
            }
        }
    }];
}

#pragma mark - UITableView Delegate Methods
#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger subCatCount = 0;
    NSDictionary *dict = _contentArr[section];
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    


//    if([subCatArr isKindOfClass:[NSArray class]] && [subCatArr count]>0 && [[dict valueForKey:HAS_SECTIONS] boolValue])
    if([subCatArr isKindOfClass:[NSArray class]] && [subCatArr count]>0)
        subCatCount = [subCatArr count];
    
    return subCatCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_contentArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
//    return UITableViewAutomaticDimension;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDefaultAccordionHeaderViewHeight;
    
//    return UITableViewAutomaticDimension ;
    

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    return 100.0;

    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
//    return 100.0;

    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuCell *cell =  (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SideMenuCell class]) forIndexPath:indexPath];
    

    StyleValuesObject *obj = [Configuration getStyleValueContent];

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict = _contentArr[indexPath.section];
    
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    NSDictionary *dictSubCat = subCatArr[indexPath.row];
    cell.categorytitleLbl.text = [dictSubCat valueForKey:MAIN_CAT_TITLE];
    [cell.iconImageVw setImage:[[UIImage imageNamed:@"slide-menu-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [cell.iconImageVw setTintColor:[UIColor colorWithHexString:obj.menutextcolor]];
    [cell.categorytitleLbl setTextColor:[UIColor colorWithHexString:obj.menutextcolor]];

    
    [cell.cellContentView setBackgroundColor:[UIColor colorWithHexString:obj.menubackgroundcolor]];
    
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
    
    
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    //    if([subCatArr isKindOfClass:[NSArray class]] && ![[dict valueForKey:HAS_SECTIONS] boolValue])
    if([subCatArr isKindOfClass:[NSArray class]])

//    if([[dict valueForKey:HAS_SECTIONS] boolValue])
    {
        [objFZAccordionTableViewHeaderView.arrowImageView setHidden:FALSE];
    }
    else{
        [objFZAccordionTableViewHeaderView.arrowImageView setHidden:TRUE];
    }
    
    UIImage *image = [[UIImage imageNamed:[dict valueForKey:MAIN_CAT_IMAGE]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImage *image_arrow = [[UIImage imageNamed:@"slide-menu-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];



    StyleValuesObject *obj = [Configuration getStyleValueContent];
    
    [objFZAccordionTableViewHeaderView.sectionTitle setTextColor:[UIColor colorWithHexString:obj.menutextcolor]];

    [objFZAccordionTableViewHeaderView.sectionTitle setText:[dict valueForKey:MAIN_CAT_TITLE]];
    [objFZAccordionTableViewHeaderView.sectionImageVw setImage:image];
    [objFZAccordionTableViewHeaderView.arrowImageView setImage:image_arrow];

    [objFZAccordionTableViewHeaderView.sectionImageVw setTintColor:[UIColor colorWithHexString:obj.menutextcolor]];
    [objFZAccordionTableViewHeaderView.arrowImageView setTintColor:[UIColor colorWithHexString:obj.menutextcolor]];

    
    objFZAccordionTableViewHeaderView.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [objFZAccordionTableViewHeaderView.contentView setBackgroundColor:[UIColor colorWithHexString:obj.menubackgroundcolor]];
    
    return (UIView *)objFZAccordionTableViewHeaderView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"didSelectRowAtIndexPath");
    
    NSDictionary *dict = _contentArr[indexPath.section];
    NSArray *catArr =  [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
    _controllerInfoDict = catArr[indexPath.row];
    
    [self backgroundButtonClicked:indexPath];
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSLog(@"willOpenSection");
    NSDictionary *dict = _contentArr[section];
    NSArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES];
//    if([subCatArr isKindOfClass:[NSArray class]] && ![[dict valueForKey:HAS_SECTIONS] boolValue])
    if(![subCatArr isKindOfClass:[NSArray class]])

    {
        _controllerInfoDict = _contentArr[section];
        [self backgroundButtonClicked:[NSIndexPath indexPathForRow:0 inSection:section]];
    }
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    NSLog(@"didOpenSection");
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    NSLog(@"willCloseSection");
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    NSLog(@"didCloseSection");
}
@end
