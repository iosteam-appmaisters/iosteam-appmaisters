//
//  BranchLocationViewController.m
//  ShareOne
//
//  Created by Ali Akbar on 9/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "BranchLocationViewController.h"
#import "BranchLocationCell.h"
#import "UIImageView+AFNetworking.h"

@implementation BranchLocationViewController

/*********************************************************************************************************/
                            #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*********************************************************************************************************/
                    #pragma mark - Action Method
/*********************************************************************************************************/

-(IBAction)showAllBranchesonMapButtonClicked:(id)sender
{
    UINavigationController* homeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ATMLocationViewController"];
    homeNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:homeNavigationViewController animated:YES];

}

/*********************************************************************************************************/
                        #pragma mark - Table view delagte and data source Method
/*********************************************************************************************************/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowHeight=100;
    return rowHeight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BranchLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BranchLocationCell"];
    if(!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BranchLocationCell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BranchLocationCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   // cell.addrressLbl.text=@"Bartlett/Cordova Office 8am - 5pm Drive Thru 8am - 5pm";
  //  cell.streetAddressLbl.text=@"8058 US Highway 64 Bartlett, TN 38133";
   // cell.phoneNoLbl.text=@"(901) 452-7900";
   // cell.milesLbl.text=@"12 Miles away";
  //  cell.officestatusLbl.text=@"OPEN";
   // cell.drivestatusLbl.text=@"OPEN";
   // NSURL *imageURL = [NSURL URLWithString:@""];
   // [cell.branchlocationImgview setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"image_placeholder"]];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

@end
