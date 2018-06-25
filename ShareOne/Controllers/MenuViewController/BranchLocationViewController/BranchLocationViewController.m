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
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "ShareOneUtility.h"
#import "GetDirectionViewController.h"
#import "ATMLocationViewController.h"
#import "Location.h"


@interface BranchLocationViewController ()<CLLocationManagerDelegate,branchLocationDelegate>{
    
    CLLocationManager *locationManager;
    NSString *sourceaddress;
    NSString *Destinationaddress;
}

@property (nonatomic,strong)NSArray *contentArr;
@end

@implementation BranchLocationViewController

/*********************************************************************************************************/
                            #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad{
    
    //_contentArr = [[NSMutableArray alloc] init];
    
    [self createCurrentLocation];
    [self setData];
    [self getData];
    [super viewDidLoad];
}


-(void)getData{
    
    __weak BranchLocationViewController *weakSelf = self;

    /*
    NSDictionary *searchByZipCode =[NSDictionary dictionaryWithObjectsAndKeys:@"91730",@"ZipCode", nil];
    
    NSDictionary *searchByStateNCity =[NSDictionary dictionaryWithObjectsAndKeys:@"CA",@"state",@"Hermosa Beach",@"city", nil];
    
    NSDictionary *searchByCoordinate =[NSDictionary dictionaryWithObjectsAndKeys:@"34.104369",@"latitude",@"117.573459",@"longitude", nil];
    
    NSDictionary *maxResultsNRadiousNZip =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"20",@"maxResults",@"91730",@"zip", nil];
     */

    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    [Location getShareOneBranchLocations:nil delegate:nil completionBlock:^(NSArray *locations) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        if([locations count]>0){
            weakSelf.contentArr=locations;
            [weakSelf.tableView reloadData];
        }

        
    } failureBlock:^(NSError *error) {
        
    }];


//    [Location getAllBranchLocations:maxResultsNRadiousNZip delegate:weakSelf completionBlock:^(NSArray *locations) {
//        
//        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
//        if([locations count]>0){
//            weakSelf.contentArr=locations;
//            [weakSelf.tableView reloadData];
//        }
//
//    } failureBlock:^(NSError *error) {
//        
//    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*********************************************************************************************************/
                                        #pragma mark - StartUp Method
/*********************************************************************************************************/

-(void)setData
{
//    sourceaddress=@"";
//    Destinationaddress=@"South San Francisco";
}
/*********************************************************************************************************/
                        #pragma mark - Create Current Location
/*********************************************************************************************************/

-(void)createCurrentLocation
{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];

    
    CLLocationCoordinate2D user = [location coordinate];
    NSLog(@"longitude :%f",user.longitude);
    NSLog(@"latitude  :%f",user.latitude);
    
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",user.latitude ,user.longitude];
    
    sourceaddress = CoordinateStr;
    
}

/*********************************************************************************************************/
                    #pragma mark - Action Method
/*********************************************************************************************************/

-(IBAction)showAllBranchesonMapButtonClicked:(id)sender
{
    ATMLocationViewController* atmNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"surchargeFreeAtms"];
    atmNavigationViewController.locationArr=_contentArr;
    atmNavigationViewController.navigationItem.title=self.navigationItem.title;
    [self.navigationController pushViewController:atmNavigationViewController animated:YES];

}

-(IBAction)showCurrentLocationMapButtonClicked:(id)sender{
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    
    ATMLocationViewController* atmNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"surchargeFreeAtms"];
    atmNavigationViewController.showMyLocationOnly= TRUE;
    atmNavigationViewController.locationArr=_contentArr;
    atmNavigationViewController.selectedIndex=(int)clickedButtonPath.row;
    atmNavigationViewController.navigationItem.title=self.navigationItem.title;
    atmNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:atmNavigationViewController animated:YES];
}


/*********************************************************************************************************/
                                    #pragma mark - BranchLocation Cell Delegate Method
/*********************************************************************************************************/

-(void)getDirectionButtonClicked:(id)sender {
    
    UITableViewCell *clickedCell = (UITableViewCell *)sender  ;
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    
    [self showDirectionOutsideApp:clickedButtonPath];
}

- (void)showDirectionOutsideApp:(NSIndexPath*)clickedIndex {
    
    if (![self currentLocationEnabled]){
        return;
    }
    
    CLLocation *sourceLocation = [locationManager location];
    Location *objLocation = self.contentArr[clickedIndex.row];
    
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",[sourceLocation coordinate].latitude, [sourceLocation coordinate].longitude, [objLocation.Gpslatitude floatValue], [objLocation.Gpslongitude floatValue]];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
}

-(BOOL)checkIfLatLongZero:(Location*)objLocation{
    NSString * lat = [NSString stringWithFormat:@"%.1f",[objLocation.Gpslatitude floatValue]];
    NSString * lng = [NSString stringWithFormat:@"%.1f",[objLocation.Gpslongitude floatValue]];
    
    if ([lat isEqualToString: @"0.0"] || [lng isEqualToString:@"0.0"] ){
        return YES;
    }
    return NO;
}

-(BOOL)currentLocationEnabled {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        
        NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        NSString * messageStr = [NSString stringWithFormat:@"We would like to use your location to show convenient locations near and around you. Please enable location services from Settings-->%@-->Location",appName];
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Location Permission"
                                      message:messageStr
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"YES"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                        [alert dismissViewControllerAnimated:YES completion:^{
                                        }];
                                    }];
        [alert addAction:okButton];
        
        
        
        UIAlertAction* retryBtn = [UIAlertAction
                                   actionWithTitle:@"NO"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:^{
                                       }];
                                   }];
        [alert addAction:retryBtn];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

/*********************************************************************************************************/
                        #pragma mark - Table view delagte and data source Method
/*********************************************************************************************************/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    int rowHeight=100;
//    return rowHeight;
    
    return UITableViewAutomaticDimension;

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contentArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BranchLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BranchLocationCell"];
    [cell setDelegate:self];
    
    if(!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BranchLocationCell" forIndexPath:indexPath];
    }
    
    Location *objLocation = _contentArr[indexPath.row];
    
    if ([self checkIfLatLongZero:objLocation]) {
        cell.getDirectionbtn.hidden = YES;
        cell.showOnMapBtn.hidden = YES;
    }
    
    [cell.currentLocationBtn setTag:indexPath.row];
    [cell.getDirectionbtn setTag:indexPath.row];
    
    NSString *officeTimeString = @"";
    NSString *driveThruString = @"";
    NSArray *hoursArr = nil;
    
    if([objLocation.hours count]>0){
        
        hoursArr= objLocation.hours;
        NSPredicate *suffixPredicate = [NSPredicate predicateWithFormat:@"Daynumber = %d",[ShareOneUtility getDayOfWeek]];
        
        NSArray *currentDayHourArr = [hoursArr filteredArrayUsingPredicate:suffixPredicate];
        
        if([currentDayHourArr count]>0){
            
            Hours *objHours = [currentDayHourArr lastObject];
            
            if(objHours.Drivethruopentime &&  objHours.Drivethruclosetime) {
                driveThruString = [NSString stringWithFormat:@"%@ - %@",[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Drivethruopentime andDateFormat:@"hh:mm a"],[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Drivethruclosetime andDateFormat:@"hh:mm a"]];
            }
            
            
            if(objHours.Lobbyopentime && objHours.Lobbyclosetime) {
                officeTimeString = [NSString stringWithFormat:@"%@ - %@",[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Lobbyopentime andDateFormat:@"hh:mm a"] ,[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Lobbyclosetime andDateFormat:@"hh:mm a"]];
            }
            
            
            if (objHours.Drivethruopentime == nil && objHours.Drivethruclosetime == nil){
                cell.drivestatusLbl.hidden = YES;
                cell.driveThruHoursLbl.hidden = YES;
                cell.driveThruHeadingLabel.hidden = YES;
                cell.timeTopConstraint.constant = 5;
                [cell layoutIfNeeded];
            }
        }
    }
    
    // Set Drive Thru Is Open Or Closed
    if ([objLocation.Drivethruisopen boolValue]) {
        [[cell drivestatusLbl] setText:@"OPEN"];
        [[cell drivestatusLbl] setTextColor:[UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:19.0/255.0 alpha:1.0]];
        
    }
    else {
        [[cell drivestatusLbl] setText:@"CLOSED"];
        [[cell drivestatusLbl] setTextColor:[UIColor redColor]];
    }
    
    // Set Lobby Is Open Or Closed
    if ([objLocation.Lobbyisopen boolValue]){
        [[cell officestatusLbl] setText:@"OPEN"];
        [[cell officestatusLbl] setTextColor:[UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:19.0/255.0 alpha:1.0]];
    }
    else {
        [[cell officestatusLbl] setText:@"CLOSED"];
        [[cell officestatusLbl] setTextColor:[UIColor redColor]];
    }
    
    cell.locationNameLbl.text = objLocation.Name;
    cell.officeHourLbl.text = officeTimeString;
    cell.driveThruHoursLbl.text = driveThruString;
    cell.phoneNoLbl.text = [NSString stringWithFormat:@"%@",objLocation.Phonenumber];
    cell.addrressLbl.text = [NSString stringWithFormat:@"%@",objLocation.address.Address1];
    cell.milesLbl.text = [NSString stringWithFormat:@"%@ Miles away",objLocation.distance];
    cell.cityStateLbl.text = [NSString stringWithFormat:@"%@, %@",objLocation.address.City,objLocation.address.State];
    
    if([objLocation.photos count]>0){
        Photos *objPhotos = objLocation.photos[0];
        NSData *data = [[NSData alloc]initWithBase64EncodedString:objPhotos.Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image64 = [UIImage imageWithData:data];
        [cell.branchlocationImgview setImage:image64];
        cell.branchlocationImgview.hidden = NO;
    }
    else{
        cell.branchlocationImgview.hidden = YES;
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BranchLocationCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    cell.addrressLbl.text=@"Bartlett/Cordova Office 8am - 5pm Drive Thru 8am - 5pm";
//    cell.streetAddressLbl.text=@"8058 US Highway 64 Bartlett, TN 38133";
//    cell.phoneNoLbl.text=@"(901) 452-7900";
//    cell.milesLbl.text=@"12 Miles away";
//    cell.officestatusLbl.text=@"OPEN";
//    cell.drivestatusLbl.text=@"OPEN";
//    NSURL *imageURL = [NSURL URLWithString:@""];
//    [cell.branchlocationImgview setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"image_placeholder"]];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

@end
