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
}
@property (nonatomic,strong) IBOutlet GMSMapView *mapView;

@end

@implementation ATMLocationViewController

/*********************************************************************************************************/
                    #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad
{
    
    [self initLocationArray];
    [self initGoogleMap];
    [self.view layoutIfNeeded];
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
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
        [self getData];
        return;
    }
    
    Location *objLocation= _locationArr[0];
    float lat=[[objLocation latitude] floatValue];
    float lon=[[objLocation longitude] floatValue];

    
    
//    NSArray *latlongArr=[[_locationArr objectAtIndex:0] componentsSeparatedByString:@","];
//    float lat=[[latlongArr objectAtIndex:0] floatValue];
//    float lon=[[latlongArr objectAtIndex:1] floatValue];

    

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lon
                                                            longitude:lat
                                                                 zoom:13];
    _mapView.camera=camera;
//    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    
    [self createGoogleMapMarker:_mapView];

}
-(void)getData{
    
    __weak ATMLocationViewController *weakSelf = self;
    
    NSDictionary *searchByZipCode =[NSDictionary dictionaryWithObjectsAndKeys:@"91730",@"ZipCode", nil];
    
    NSDictionary *searchByStateNCity =[NSDictionary dictionaryWithObjectsAndKeys:@"CA",@"state",@"Hermosa Beach",@"city", nil];
    
    NSDictionary *searchByCoordinate =[NSDictionary dictionaryWithObjectsAndKeys:@"34.104369",@"latitude",@"117.573459",@"longitude", nil];
    
    NSDictionary *maxResultsNRadiousNZip =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"20",@"maxResults",@"91730",@"zip", nil];
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];

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

        Location *objLocation= _locationArr[count];
        
        float lat=[[objLocation latitude] floatValue];
        float lon=[[objLocation longitude] floatValue];

        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lon, lat);
        marker.title = objLocation.address;
        marker.snippet = [NSString stringWithFormat:@"%@, %@",objLocation.city,objLocation.countryname];
        marker.map = mapView;
        
        if(_showMyLocationOnly)
            break;
    }
    
}

@end
