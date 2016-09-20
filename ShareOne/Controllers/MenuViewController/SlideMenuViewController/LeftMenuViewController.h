

#import <UIKit/UIKit.h>
#import "HomeNavigationDelegate.h"
#import "FZAccordionTableView.h"
//#import "AccordionHeaderView.h"



@interface LeftMenuViewController : UIViewController<FZAccordionTableViewDelegate>


@property (nonatomic, strong) IBOutlet FZAccordionTableView *fzaTblView;

@property (nonatomic, weak) id <HomeNavigationDelegate> homeDelegate;

@end
