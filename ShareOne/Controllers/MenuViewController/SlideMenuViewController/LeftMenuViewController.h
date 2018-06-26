

#import <UIKit/UIKit.h>
#import "HomeNavigationDelegate.h"
#import "FZAccordionTableView.h"



@interface LeftMenuViewController : UIViewController<FZAccordionTableViewDelegate>


@property (nonatomic, strong) IBOutlet FZAccordionTableView *fzaTblView;

@property (nonatomic, weak) id <HomeNavigationDelegate> homeDelegate;

-(IBAction)backgroundButtonClicked:(id)sender;
@end
