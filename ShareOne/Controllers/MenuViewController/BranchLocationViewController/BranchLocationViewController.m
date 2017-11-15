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
//    CLLocation *location2=[[CLLocation alloc]initWithLatitude:37.785834 longitude:-122.406417];
//    CLLocation *currentLocation=[[CLLocation alloc]initWithLatitude:user.latitude longitude:user.longitude];
    
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",user.latitude ,user.longitude];
    
//    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",33.473178 ,-90.208646];

    sourceaddress = CoordinateStr;
    
    //[self reverseGeoCode:currentLocation];
}

-(void)reverseGeoCode:(CLLocation *)location
{
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@",[error description]);
         }
         else
         {
             id userCity=[[[response results] firstObject] locality];
             NSLog(@"%@",userCity);
             sourceaddress=userCity;
             NSString *Distance=[ShareOneUtility getDistancefromAdresses:sourceaddress Destination:Destinationaddress];
             NSLog(@"Distance..........----------------------%f miles",[Distance floatValue]* 0.000621371);
         }
     }];
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
    
    __weak BranchLocationViewController *weakSelf = self;
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Location *objLocation = self.contentArr[clickedButtonPath.row];
    
    if ([self checkIfLatLongZero:objLocation]) {
        [[UtilitiesHelper shareUtitlities] showToastWithMessage:@"The latitude and longitude are 0,0" title:@"Error" delegate:weakSelf];
        return;
    }
    
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
    
    __weak BranchLocationViewController *weakSelf = self;
    
    UITableViewCell *clickedCell = (UITableViewCell *)sender  ;
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Location *objLocation = self.contentArr[clickedButtonPath.row];
    
    if ([self checkIfLatLongZero:objLocation]) {
        [[UtilitiesHelper shareUtitlities] showToastWithMessage:@"The latitude and longitude are 0,0" title:@"Error" delegate:weakSelf];
        return;
    }
    
    [self showDirectionOutsideApp:clickedButtonPath];
    
    /*UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Branch Direction" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Show Inside App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self showDirectionInsideApp:clickedButtonPath];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Show Outside App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self showDirectionOutsideApp:clickedButtonPath];
        
    }]];
    
    if (IS_IPAD) {
        
        UIPopoverPresentationController *popPresenter = [actionSheet
                                                         popoverPresentationController];
        //provide source view to actionsheet as popover presentation
        
        popPresenter.sourceView = sender;
        //popPresenter.sourceRect = sender.bounds;
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }else{
        [self presentViewController:actionSheet animated:YES completion:nil];
    }*/
}

-(void)showDirectionInsideApp:(NSIndexPath*)clickedIndex
{
    Location *objLocation = self.contentArr[clickedIndex.row];
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",[objLocation.Gpslatitude floatValue],[objLocation.Gpslongitude floatValue]];
    
    GetDirectionViewController* getdirectionNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GetDirectionViewController"];
    getdirectionNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    getdirectionNavigationViewController.sourceAddress=sourceaddress;
    getdirectionNavigationViewController.DestinationAddress=CoordinateStr;
    getdirectionNavigationViewController.locationArr=_contentArr;
    getdirectionNavigationViewController.selectedIndex=(int)clickedIndex.row;
    
    getdirectionNavigationViewController.navigationItem.title=self.navigationItem.title;
    [self.navigationController pushViewController:getdirectionNavigationViewController animated:YES];
}


- (void)showDirectionOutsideApp:(NSIndexPath*)clickedIndex {
    
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
    [cell.currentLocationBtn setTag:indexPath.row];
    [cell.getDirectionbtn setTag:indexPath.row];
    NSString *officeTimeString= nil;
    NSString *driveThruString= nil;
    
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
            else {
                driveThruString = [NSString stringWithFormat:@""];
            }
            
            
            if(objHours.Lobbyopentime && objHours.Lobbyclosetime) {
                officeTimeString = [NSString stringWithFormat:@"%@ - %@",[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Lobbyopentime andDateFormat:@"hh:mm a"] ,[ShareOneUtility getDateInCustomeFormatWithSourceDate:objHours.Lobbyclosetime andDateFormat:@"hh:mm a"]];
            }
            else {
                officeTimeString = [NSString stringWithFormat:@""];
            }
            
            
            if ([objHours.Drivethruisopen boolValue]) {
                [[cell drivestatusLbl] setText:@"OPEN"];
                [[cell drivestatusLbl] setTextColor:[UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:19.0/255.0 alpha:1.0]];
                
            }
            else {
                [[cell drivestatusLbl] setText:@"CLOSED"];
                [[cell drivestatusLbl] setTextColor:[UIColor redColor]];
                
                if (objHours.Drivethruopentime == nil && objHours.Drivethruclosetime == nil){
                    cell.drivestatusLbl.hidden = YES;
                    cell.driveThruHoursLbl.hidden = YES;
                    cell.driveThruHeadingLabel.hidden = YES;
                    cell.timeTopConstraint.constant = 5;
                    [cell layoutIfNeeded];
                }
            }
            
            /*([objHours.Drivethruisopen boolValue]) ? [[cell drivestatusLbl] setText:@"OPEN"] : [[cell drivestatusLbl] setText:@"CLOSED"];
            
            ([[[cell drivestatusLbl] text] isEqualToString:@"OPEN"]) ? [[cell drivestatusLbl] setTextColor:[UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:19.0/255.0 alpha:1.0]] : [[cell drivestatusLbl] setTextColor:[UIColor redColor]];*/
            
            
            ([objHours.Lobbyisopen boolValue]) ? [[cell officestatusLbl] setText:@"OPEN"] : [[cell officestatusLbl] setText:@"CLOSED"];
            
            ([[[cell officestatusLbl] text] isEqualToString:@"OPEN"]) ? [[cell officestatusLbl] setTextColor:[UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:19.0/255.0 alpha:1.0]] : [[cell officestatusLbl] setTextColor:[UIColor redColor]];
            
            
        }
        
    }
    
    else{
        
        officeTimeString = [NSString stringWithFormat:@""];
        driveThruString = [NSString stringWithFormat:@""];
        
        [[cell drivestatusLbl] setText:@"CLOSED"];
        [[cell drivestatusLbl] setTextColor:[UIColor redColor]];
        
        [[cell officestatusLbl] setText:@"CLOSED"];
        [[cell officestatusLbl] setTextColor:[UIColor redColor]];
        
    }
    
    cell.locationNameLbl.text=objLocation.Name;
    cell.officeHourLbl.text=officeTimeString;
    cell.driveThruHoursLbl.text=driveThruString;
    [cell.phoneNoLbl setText:[NSString stringWithFormat:@"%@",objLocation.Phonenumber]];
    cell.addrressLbl.text=[NSString stringWithFormat:@"%@",objLocation.address.Address1/*,objLocation.address.City,objLocation.address.State*/];
    cell.milesLbl.text=[NSString stringWithFormat:@"%@ Miles away",objLocation.distance];
    cell.cityStateLbl.text=[NSString stringWithFormat:@"%@, %@",objLocation.address.City,objLocation.address.State];
    
    if([objLocation.photos count]>0){
        
        
        Photos *objPhotos = objLocation.photos[0];
        NSData *data = [[NSData alloc]initWithBase64EncodedString:objPhotos.Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image64 = [UIImage imageWithData:data];
        [cell.branchlocationImgview setImage:image64];
    }
    else{
        NSURL *imageURL = [NSURL URLWithString:@""];
        [cell.branchlocationImgview setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"image_placeholder"]];
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
