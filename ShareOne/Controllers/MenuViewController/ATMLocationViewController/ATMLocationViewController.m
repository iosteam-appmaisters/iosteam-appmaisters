//
//  ATMLocationViewController.m
//  ShareOne
//
//  Created by Shahrukh Jamil on 9/22/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "ATMLocationViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "ShareOneUtility.h"
#import "Location.h"
@interface ATMLocationViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    BOOL isComingFromATM;
    NSString *lat;
    NSString *lon;
}
@property (nonatomic,strong) IBOutlet GMSMapView *mapView;

@end

@implementation ATMLocationViewController

/*********************************************************************************************************/
                    #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad
{
    
    [self createCurrentLocation];

    [self initLocationArray];
    [self initGoogleMap];
    [self.view layoutIfNeeded];
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

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
    CLLocation *currentLocation=[[CLLocation alloc]initWithLatitude:user.latitude longitude:user.longitude];
    
    lat=[NSString stringWithFormat:@"%f",user.latitude];
    lon=[NSString stringWithFormat:@"%f",user.longitude];

    
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",user.latitude ,user.longitude];
    NSLog(@"CoordinateStr:%@",CoordinateStr);
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*********************************************************************************************************/
                                #pragma mark - Init Location Array
/*********************************************************************************************************/

-(void)initLocationArray
{
    
    //self.locationArr=[[NSMutableArray alloc] init];
//    self.locationArr=[ShareOneUtility getLocationArray];
}

/*********************************************************************************************************/
                                #pragma mark - Init Google Map
/*********************************************************************************************************/

-(void)initGoogleMap
{
    if(!self.locationArr){
        isComingFromATM=TRUE;
        [self getData];
        return;
    }
    
    
    
    Location *objLocation= nil;

    if(_showMyLocationOnly){
        objLocation=  _locationArr[_selectedIndex];
    }
    else{
      objLocation=  _locationArr[0];
    }
//    float lat=[[objLocation latitude] floatValue];
//    float lon=[[objLocation longitude] floatValue];
    
    float lat=[[objLocation Gpslatitude] floatValue];
    float lon=[[objLocation Gpslongitude] floatValue];



//    NSArray *latlongArr=[[_locationArr objectAtIndex:0] componentsSeparatedByString:@","];
//    float lat=[[latlongArr objectAtIndex:0] floatValue];
//    float lon=[[latlongArr objectAtIndex:1] floatValue];

    

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:13];
    _mapView.camera=camera;
//    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    
    [self createGoogleMapMarker:_mapView];

}
-(void)getData{
    
    __weak ATMLocationViewController *weakSelf = self;
    
    
//    http://api.co-opfs.org/locator/proximitySearch?latitude=34.104369&longitude=117.573459
    NSDictionary *searchByZipCode =[NSDictionary dictionaryWithObjectsAndKeys:@"91730",@"ZipCode", nil];
    
    NSDictionary *searchByStateNCity =[NSDictionary dictionaryWithObjectsAndKeys:@"CA",@"state",@"Hermosa Beach",@"city", nil];
    
    NSDictionary *searchByCoordinate =[NSDictionary dictionaryWithObjectsAndKeys:@"34.104369",@"latitude",@"117.573459",@"longitude", nil];
    
    NSDictionary *maxResultsNRadiousNZip =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"20",@"maxResults",lat,@"latitude",lon,@"longitude",@"A",@"loctype", nil];
     
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    /*
    [Location getShareOneBranchLocations:nil delegate:nil completionBlock:^(NSArray *locations) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];
        if([locations count]>0){
            weakSelf.locationArr=locations;
            Location *objLocation= _locationArr[0];
            float lat=[[objLocation latitude] floatValue];
            float lon=[[objLocation longitude] floatValue];
            
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lon
                                                                    longitude:lat
                                                                         zoom:13];
            _mapView.camera=camera;
            //    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            _mapView.myLocationEnabled = YES;
            
            [self createGoogleMapMarker:_mapView];
        }
        
        
    } failureBlock:^(NSError *error) {
        
    }];
     */


    [Location getAllBranchLocations:maxResultsNRadiousNZip delegate:weakSelf completionBlock:^(NSArray *locations) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if([locations count]>0){
            weakSelf.locationArr=locations;
            Location *objLocation= _locationArr[0];
            float lat=[[objLocation latitude] floatValue];
            float lon=[[objLocation longitude] floatValue];
            
            
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lon
                                                                    longitude:lat
                                                                         zoom:13];
            _mapView.camera=camera;
            //    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            _mapView.myLocationEnabled = YES;
            
            [self createGoogleMapMarker:_mapView];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
 
}

-(void)createGoogleMapMarker:(GMSMapView *)mapView
{
    // Creates a marker in the center of the map.
    for(int count=0; count<[_locationArr count]; count++){
        
//        NSArray *latlongArr=[[_locationArr objectAtIndex:count] componentsSeparatedByString:@","];
//        float lat=[[latlongArr objectAtIndex:0] floatValue];
//        float lon=[[latlongArr objectAtIndex:1] floatValue];

        Location *objLocation= nil;

        if(_showMyLocationOnly){
            
          objLocation=  _locationArr[_selectedIndex];
        }
        else
          objLocation=  _locationArr[count];

        GMSMarker *marker = [[GMSMarker alloc] init];

        
        float lat ,lon;
        NSString *address;
        NSString *addressDetails;
        
        if(isComingFromATM){
            lat=[[objLocation latitude] floatValue];
            lon=[[objLocation longitude] floatValue];
            marker.position = CLLocationCoordinate2DMake(lon, lat);
            address=(NSString *)objLocation.address;
            addressDetails= objLocation.city;

        }
        else{
            lat=[[objLocation Gpslatitude] floatValue];
            lon=[[objLocation Gpslongitude] floatValue];
            marker.position = CLLocationCoordinate2DMake(lat, lon);
            address=objLocation.address.Address1;
            addressDetails =[NSString stringWithFormat:@"%@, %@",objLocation.address.City,objLocation.address.Country];
        }
        
        marker.title = address;
        marker.snippet =addressDetails;
        marker.map = mapView;
        
        if(_showMyLocationOnly)
            break;
    }
    
}

@end
