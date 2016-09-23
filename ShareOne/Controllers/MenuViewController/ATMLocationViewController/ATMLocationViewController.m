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
@interface ATMLocationViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@property (nonatomic,strong) IBOutlet GMSMapView *mapView;
@property (nonatomic,strong) NSMutableArray *locationArr;

@end

@implementation ATMLocationViewController

/*********************************************************************************************************/
                    #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad
{
    [self initLocationArray];
    
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self initGoogleMap];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*********************************************************************************************************/
                                #pragma mark - Init Location Array
/*********************************************************************************************************/

-(void)initLocationArray
{
    self.locationArr=[[NSMutableArray alloc] init];
    self.locationArr=[ShareOneUtility getLocationArray];
}

/*********************************************************************************************************/
                                #pragma mark - Init Google Map
/*********************************************************************************************************/

-(void)initGoogleMap
{
    NSArray *latlongArr=[[self.locationArr objectAtIndex:0] componentsSeparatedByString:@","];
    float lat=[[latlongArr objectAtIndex:0] floatValue];
    float lon=[[latlongArr objectAtIndex:1] floatValue];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:13];
    _mapView.camera=camera;
    //_mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    [self createGoogleMapMarker:_mapView];

}
-(void)createGoogleMapMarker:(GMSMapView *)mapView
{
    // Creates a marker in the center of the map.
    for(int count=0; count<[self.locationArr count]; count++)
    {
        NSArray *latlongArr=[[self.locationArr objectAtIndex:count] componentsSeparatedByString:@","];
        float lat=[[latlongArr objectAtIndex:0] floatValue];
        float lon=[[latlongArr objectAtIndex:1] floatValue];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lon);
        marker.title = @"AtM Location";
        marker.snippet = @"";
        marker.map = mapView;
    }
    
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
    
}
@end
