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
    [self createCurrentLocation];
    
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)initGoogleMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude
                                                            longitude:locationManager.location.coordinate.longitude
                                                                 zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    [self createGoogleMapMarker:_mapView];

}
-(void)createGoogleMapMarker:(GMSMapView *)mapView
{
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    marker.title = @"AtM Location";
    marker.snippet = @"";
    marker.map = mapView;
}
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
    [self initGoogleMap];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
