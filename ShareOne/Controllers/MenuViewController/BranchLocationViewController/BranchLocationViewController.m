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
    
    NSDictionary *searchByZipCode =[NSDictionary dictionaryWithObjectsAndKeys:@"91730",@"ZipCode", nil];
    
    NSDictionary *searchByStateNCity =[NSDictionary dictionaryWithObjectsAndKeys:@"CA",@"state",@"Hermosa Beach",@"city", nil];
    
    NSDictionary *searchByCoordinate =[NSDictionary dictionaryWithObjectsAndKeys:@"34.104369",@"latitude",@"117.573459",@"longitude", nil];
    
    NSDictionary *maxResultsNRadiousNZip =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"20",@"maxResults",@"91730",@"zip", nil];


    [Location getAllBranchLocations:maxResultsNRadiousNZip delegate:weakSelf completionBlock:^(NSArray *locations) {
        
        if([locations count]>0){
            weakSelf.contentArr=locations;
            [weakSelf.tableView reloadData];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*********************************************************************************************************/
                                        #pragma mark - StartUp Method
/*********************************************************************************************************/

-(void)setData
{
    sourceaddress=@"";
    Destinationaddress=@"South San Francisco";
}
/*********************************************************************************************************/
                        #pragma mark - Create Current Location
/*********************************************************************************************************/

-(void)createCurrentLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D user = [location coordinate];
    NSLog(@"%f",user.longitude);
    NSLog(@"%f",user.longitude);
    CLLocation *location2=[[CLLocation alloc]initWithLatitude:37.785834 longitude:-122.406417];
    [self reverseGeoCode:location2];
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
    ATMLocationViewController* atmNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ATMLocationViewController"];
    atmNavigationViewController.locationArr=_contentArr;
    atmNavigationViewController.navigationItem.title=self.navigationItem.title;
    [self.navigationController pushViewController:atmNavigationViewController animated:YES];

}

-(IBAction)showCurrentLocationMapButtonClicked:(id)sender{
    
    ATMLocationViewController* atmNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ATMLocationViewController"];
    atmNavigationViewController.showMyLocationOnly= TRUE;
    atmNavigationViewController.locationArr=_contentArr;
    atmNavigationViewController.navigationItem.title=self.navigationItem.title;

    atmNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:atmNavigationViewController animated:YES];

}


/*********************************************************************************************************/
                                    #pragma mark - BranchLocation Cell Delegate Method
/*********************************************************************************************************/

-(void)getDirectionButtonClicked:(id)sender
{
    GetDirectionViewController* getdirectionNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GetDirectionViewController"];
    getdirectionNavigationViewController.modalTransitionStyle= UIModalTransitionStyleFlipHorizontal;
    getdirectionNavigationViewController.sourceAddress=sourceaddress;
    getdirectionNavigationViewController.DestinationAddress=Destinationaddress;
    getdirectionNavigationViewController.navigationItem.title=self.navigationItem.title;
    [self.navigationController pushViewController:getdirectionNavigationViewController animated:YES];
    
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
    
    NSString *officeTimeString= nil;
    NSString *driveThruString= nil;

    
    
    if([objLocation.mondayDriveThruOpen length]>0)
        driveThruString = [NSString stringWithFormat:@"Drive Thru %@am - %@pm",objLocation.mondayDriveThruOpen,objLocation.mondayDriveThruClose];
    else
        driveThruString = [NSString stringWithFormat:@"Drive Thru %.0fam - %.0fpm",8.00,9.00];
    
    
    if([objLocation.mondayOpen length]>0)
        officeTimeString = [NSString stringWithFormat:@"Office %.0fam - %.0fpm",[objLocation.mondayOpen floatValue],[objLocation.mondayClose floatValue]];
    else
        officeTimeString = [NSString stringWithFormat:@"Office"];
    
    
    
        
    cell.addrressLbl.text=objLocation.institutionName;
    cell.officeHourLbl.text=officeTimeString;
    cell.driveThruHoursLbl.text=driveThruString;

    cell.streetAddressLbl.text=[NSString stringWithFormat:@"%@",objLocation.address];
    cell.milesLbl.text=[NSString stringWithFormat:@"%@ Miles away",objLocation.distance];
    
    ([objLocation.driveThru boolValue]) ? [[cell drivestatusLbl] setText:@"OPEN"] : [[cell drivestatusLbl] setText:@"CLOSE"];
    
    ([[[cell drivestatusLbl] text] isEqualToString:@"OPEN"]) ? [[cell drivestatusLbl] setTextColor:[UIColor greenColor]] : [[cell drivestatusLbl] setTextColor:[UIColor redColor]];
    
    
    ([objLocation.open24Hours boolValue]) ? [[cell officestatusLbl] setText:@"OPEN"] : [[cell officestatusLbl] setText:@"CLOSE"];
    
    ([[[cell officestatusLbl] text] isEqualToString:@"OPEN"]) ? [[cell officestatusLbl] setTextColor:[UIColor greenColor]] : [[cell officestatusLbl] setTextColor:[UIColor redColor]];


    
    
    NSURL *imageURL = [NSURL URLWithString:@""];
    [cell.branchlocationImgview setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"image_placeholder"]];

    
    
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
