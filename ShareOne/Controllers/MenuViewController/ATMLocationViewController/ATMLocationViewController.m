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
#import "LRouteController.h"
#import "HomeViewController.h"

@interface ATMLocationViewController ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
    BOOL isComingFromATM;
    NSString *lat;
    NSString *lon;
    
    GMSMarker *selectedMarker;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart,*_markerFinish,*movemarker;


}

@property (nonatomic,strong) NSArray *LocCopyArray ;

@property (nonatomic,strong) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapMenuView;
@property (weak, nonatomic) IBOutlet UITextField *MapTextFld;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIButton *myLocBtn;

#pragma mark - Select location from Menu
@property (weak, nonatomic) IBOutlet UIButton *locationSearchByBranch;
@property (weak, nonatomic) IBOutlet UIButton *locationByAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationSearchByAtm;

-(void)drawRoute;

@end

@implementation ATMLocationViewController

/*********************************************************************************************************/
                    #pragma mark - View Controler LifeCycle Methods
/*********************************************************************************************************/

- (void)viewDidLoad
{

    
    [self createCurrentLocation];


    [self initGoogleMap];
    
    [self.view layoutIfNeeded];

    _locationByAllBtn.selected = YES;
   

    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    if(isComingFromATM==NO){
        self.searchView.hidden = YES ;
        self.myLocBtn.hidden = YES ;
    }
    [super viewWillAppear:animated];
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
//        CLLocation *location2=[[CLLocation alloc]initWithLatitude:37.785834 longitude:-122.406417];
    
//    user= [location2 coordinate];
//    CLLocation *currentLocation=[[CLLocation alloc]initWithLatitude:user.latitude longitude:user.longitude];
    
    lat=[NSString stringWithFormat:@"%f",user.latitude];
    lon=[NSString stringWithFormat:@"%f",user.longitude];

    
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",user.latitude ,user.longitude];
    NSLog(@"CoordinateStr:%@",CoordinateStr);
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*********************************************************************************************************/
                                #pragma mark - Init Google Map
/*********************************************************************************************************/

-(void)initGoogleMap
{
    if(!self.locationArr){
        isComingFromATM=TRUE;
        
        if (![self checkIfCoopIDExist]){
            return;
        }
        
        if (![self currentLocationEnabled]){
            return;
        }
        
        [self getDataWithCurrentLocation];
        return;
    }
    
    
    
    for (Location * loc in _locationArr) {
        NSLog(@"%f %f",[[loc Gpslatitude]floatValue], [[loc Gpslongitude]floatValue]);
    }
    
    Location *objLocation= nil;

    if(_showMyLocationOnly){
        objLocation=  _locationArr[_selectedIndex];
    }
    else{
      objLocation=  [_locationArr lastObject];
    }
    NSLog(@"%f %f",[[objLocation Gpslatitude]floatValue], [[objLocation Gpslongitude]floatValue]);
    float lat_local=[[objLocation Gpslatitude] floatValue];
    float lon_local=[[objLocation Gpslongitude] floatValue];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat_local
                                                            longitude:lon_local
                                                                 zoom:15];
    _mapView.camera=camera;
    _mapView.myLocationEnabled = YES;
    _mapView.delegate=self;
    
    [self createGoogleMapMarker:_mapView];
    
}

#pragma mark - Web Requests

-(void)getDataWithZip:(NSString *)zip {
    NSDictionary *resultsWithZip =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"100",@"maxResults",zip, @"zip", nil];
    [self getData:resultsWithZip];
}

-(void)getDataWithCurrentLocation {
    NSDictionary *resultsWithLatLon =[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"maxRadius",@"100",@"maxResults",lat,@"latitude",lon,@"longitude", nil];
    
    [self getData:resultsWithLatLon];
}

-(void)getData:(NSDictionary *)dict{
    
    __weak ATMLocationViewController *weakSelf = self;
    
//    http://api.co-opfs.org/locator/proximitySearch?latitude=34.104369&longitude=117.573459
//    NSDictionary *searchByZipCode =[NSDictionary dictionaryWithObjectsAndKeys:@"91730",@"ZipCode", nil];
//    
//    NSDictionary *searchByStateNCity =[NSDictionary dictionaryWithObjectsAndKeys:@"CA",@"state",@"Hermosa Beach",@"city", nil];
//    
//    NSDictionary *searchByCoordinate =[NSDictionary dictionaryWithObjectsAndKeys:@"34.104369",@"latitude",@"117.573459",@"longitude", nil];
//    
    NSDictionary *maxResultsNRadiousNZip = dict ;
     
//    @"A",@"loctype"
    
    [ShareOneUtility showProgressViewOnView:weakSelf.view];
    
    [Location getAllBranchLocations:maxResultsNRadiousNZip delegate:weakSelf completionBlock:^(NSArray *locations) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if([locations count]==0){
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:CO_OP_NO_DATA_MSG
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [self navigateToLastController];
                                           [alert dismissViewControllerAnimated:YES completion:^{
                                           }];
                                       }];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if ([locations[0] isKindOfClass:[NSNumber class]]){
            
            NSString *errorMsg = locations[1] ;
            
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:errorMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [self navigateToLastController];
                                           [alert dismissViewControllerAnimated:YES completion:^{
                                           }];
                                       }];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else {
            if([locations count]>0){
                weakSelf.locationArr=locations;
                
                self.LocCopyArray = [[NSArray alloc] initWithArray:self.locationArr];
                
                Location *objLocation= _locationArr[0];
                float lat_local=[[objLocation latitude] floatValue];
                float lon_local=[[objLocation longitude] floatValue];
                
                
                
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat_local
                                                                        longitude:lon_local
                                                                             zoom:15];
                _mapView.camera=camera;
                _mapView.myLocationEnabled = YES;
                _mapView.delegate=self;

                [self createGoogleMapMarker:_mapView];

            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
 
}

#pragma mark - Drawing Methods

-(void)createGoogleMapMarker:(GMSMapView *)mapView
{
    GMSMutablePath *path = [GMSMutablePath path];

    for(int count=0; count<[_locationArr count]; count++){
        
        Location *objLocation= nil;

        if(_showMyLocationOnly){
            
          objLocation=  _locationArr[_selectedIndex];
        }
        else
          objLocation=  _locationArr[count];

        GMSMarker *marker = [[GMSMarker alloc] init];
        
        if (objLocation.locatortype == nil) {
            marker.icon = [UIImage imageNamed:@"bank_icon.png"];
        }
        else {
            if ([objLocation.locatortype isEqualToString:@"A"]){
                marker.icon = [UIImage imageNamed:@"atm_icon.png"];
            }
            else if ([objLocation.locatortype isEqualToString:@"S"]){
                marker.icon = [UIImage imageNamed:@"bank_icon.png"];
            }
        }
        
        marker.groundAnchor = CGPointMake(0.5, 0.5);
        
        float lat_local ,lon_local;
        NSString *markerTitle;
        NSString *markerSnippet;
        
        if(isComingFromATM){
            lat_local=[[objLocation latitude] floatValue];
            lon_local=[[objLocation longitude] floatValue];
            marker.position = CLLocationCoordinate2DMake(lat_local, lon_local);
            markerTitle=objLocation.institutionname;
            markerSnippet= [NSString stringWithFormat:@"%@, %@, %@",(NSString*)objLocation.address, objLocation.city,objLocation.countryabbreviation];

            NSLog(@"%@",markerTitle);
            NSLog(@"%@",markerSnippet);
        }
        else{
            lat_local=[[objLocation Gpslatitude] floatValue];
            lon_local=[[objLocation Gpslongitude] floatValue];
            marker.position = CLLocationCoordinate2DMake(lat_local, lon_local);
            markerTitle=objLocation.address.Address1;
            markerSnippet =[NSString stringWithFormat:@"%@, %@",objLocation.address.City,objLocation.address.Country];
        }
        
        [path addCoordinate: marker.position];
        
        if (!(lat_local == 0.0) || !(lon_local == 0.0)){
            
            
            marker.title = markerTitle;
            marker.snippet = markerSnippet;
            marker.map = mapView;
        }
        if(_showMyLocationOnly)
            break;
    }
    
    Location * lastLoc;
    if(_showMyLocationOnly){
        lastLoc=  _locationArr[_selectedIndex];
        
        [mapView animateToLocation:CLLocationCoordinate2DMake([[lastLoc Gpslatitude]floatValue], [[lastLoc Gpslongitude]floatValue])];
    }
    else{
        lastLoc=  [_locationArr lastObject];
        
        GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:[[lastLoc Gpslatitude]floatValue]
                                                                longitude:[[lastLoc Gpslongitude]floatValue]
                                                                     zoom:10];
        [mapView setCamera:sydney];
    }
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
//    [_getDirectionButton setHidden:FALSE];
    selectedMarker=marker;
    [self showDirectionMenu:mapView];
    
    return FALSE;
}
- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker{
   // [_getDirectionButton setHidden:[selectedMarker isEqual:marker]];
}

-(void)showDirectionMenu:(id)sender {
    
    GMSMapView * mapV = (GMSMapView*)sender;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:selectedMarker.title message:selectedMarker.snippet preferredStyle:UIAlertControllerStyleActionSheet];
     
     [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
         
         mapV.selectedMarker = nil;
         
     }]];
     
     /*[actionSheet addAction:[UIAlertAction actionWithTitle:@"Show Inside App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     
     __weak ATMLocationViewController *weakSelf = self;
     [ShareOneUtility showProgressViewOnView:weakSelf.view];
     [self showCurrentLocationWithRefrenceMarker];
     
     }]];*/
     
     [actionSheet addAction:[UIAlertAction actionWithTitle:@"Get Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     
     [self showDirectionOutsideApp];
     
     }]];
     
     if (IS_IPAD) {
     
     UIPopoverPresentationController *popPresenter = [actionSheet
     popoverPresentationController];
     
     popPresenter.sourceView = mapV;
    
    CGPoint pos =   [mapV.projection pointForCoordinate:selectedMarker.position];
    CGRect vFrame = CGRectMake(pos.x, pos.y, 0, 0);
    popPresenter.sourceRect = vFrame;
         
     [self presentViewController:actionSheet animated:YES completion:nil];
     
     }else{
         [self presentViewController:actionSheet animated:YES completion:nil];
     }
    
}

-(IBAction)getDirectionButtonAction:(id)sender{
    
    [self showDirectionOutsideApp];
    
    
    
}

- (void)showDirectionOutsideApp {
    
    if (![self currentLocationEnabled]){
        return;
    }
    
    CLLocation *sourceLocation = [[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    CLLocation * destinationLocation = [[CLLocation alloc]initWithLatitude:selectedMarker.position.latitude longitude:selectedMarker.position.longitude];
    
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",
                               [sourceLocation coordinate].latitude, [sourceLocation coordinate].longitude,
                               [destinationLocation coordinate].latitude, [destinationLocation coordinate].longitude];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
}

-(void)showCurrentLocationWithRefrenceMarker{
    
    GMSMarker *_markerCurrentLoc = [GMSMarker new];
    _markerCurrentLoc.position = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);
    _markerCurrentLoc.map = self.mapView;
//    _markerCurrentLoc.title=@"Current Location";

    [self.mapView setSelectedMarker:_markerCurrentLoc];
    
    [self drawRoute];
}

-(void)drawRoute{
    
    __weak ATMLocationViewController *weakSelf = self;

    _polyline.map = nil;
    _markerStart.map = nil;
    _markerFinish.map = nil;

    LRouteController *_routeController = [[LRouteController alloc] init];
    NSMutableArray *_coordinates = [[NSMutableArray alloc] init];
    
    CLLocation *currentLoc = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    CLLocation *destinationLoc = [[CLLocation alloc] initWithLatitude:selectedMarker.position.latitude longitude:selectedMarker.position.longitude];
    
    [_coordinates addObject:currentLoc];
    [_coordinates addObject:destinationLoc];
        
    [_routeController getPolylineWithLocations:_coordinates travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        if (error){
            NSLog(@"%@", error);
        }
        else if (!polyline){
            NSLog(@"No route");
            [_coordinates removeAllObjects];
        }
        else{
            _markerStart.position = [[_coordinates objectAtIndex:0] coordinate];
            _markerStart.map = self.mapView;
            _markerFinish.position = [[_coordinates lastObject] coordinate];
            _markerFinish.map = self.mapView;
            _polyline = polyline;
            _polyline.strokeWidth = 3;
            _polyline.strokeColor = [UIColor blueColor];
            _polyline.map = self.mapView;
        }
    }];
}


-(BOOL)checkIfCoopIDExist {
    
    NSLog(@"%@",[Configuration getCoOpID]);
    
    if ([Configuration getCoOpID] == nil || [[Configuration getCoOpID] isEqualToString:@""] || [Configuration getCoOpID].length == 0){
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Co-op ID Not Configured"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self navigateToLastController];
                                       [alert dismissViewControllerAnimated:YES completion:^{
                                       }];
                                   }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
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
                                       if (isComingFromATM) {
                                           [self navigateToLastController];
                                       }
                                       [alert dismissViewControllerAnimated:YES completion:^{
                                       }];
                                   }];
        [alert addAction:retryBtn];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

-(void)navigateToLastController{
    
    NSDictionary *cacheControlerDict = [Configuration getAllMenuItemsIncludeHiddenItems:NO][0];
    
    NSString *webUrl = [cacheControlerDict valueForKey:WEB_URL];
    
    HomeViewController *objHomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    objHomeViewController.url= webUrl;
    
    [ShareOneUtility saveMenuItemObjectForTouchIDAuthentication:cacheControlerDict];
    
    self.navigationController.viewControllers = [NSArray arrayWithObjects:[self getLoginViewForRootView], objHomeViewController,nil];
}


#pragma mark - IBActions for Zip Search

- (IBAction)mapMenuButtonAction:(id)sender {
    
    if (_mapMenuView.isHidden) {
        _mapMenuView.hidden = false;
    }
    else
    {
        _mapMenuView.hidden = YES;
    }
}


- (IBAction)searchLocationButtonAction:(id)sender {
    NSString *inputZip = self.MapTextFld.text ;
    [self getDataWithZip:inputZip];
    
    [self.MapTextFld resignFirstResponder];
    
}

-(IBAction)SelectLocationTypeFromMenu:(id)sender
{
    UIButton* selectedBtn = sender;
    NSString *filterInput = @"" ;
    
    // All Branches & ATMS
    if (selectedBtn.tag == 1) {
        _locationByAllBtn.selected = YES;
        _locationSearchByBranch.selected = false;
        _locationSearchByAtm.selected = false;
        filterInput = @"" ;
    }
    // Only Branches
    else  if (selectedBtn.tag == 2) {
        
        _locationByAllBtn.selected = false;
        _locationSearchByBranch.selected = YES;
        _locationSearchByAtm.selected = false;
        filterInput = @"S" ;
       
        
    }
    // Only ATMS
    else if (selectedBtn.tag == 3) {
        
        _locationByAllBtn.selected = false;
        _locationSearchByBranch.selected = false;
        _locationSearchByAtm.selected = YES;
        filterInput = @"A" ;
    }
    
    
    if([filterInput isEqualToString:@""]==NO){
        NSString *predString = [NSString stringWithFormat:@"(locatortype == '%@')", filterInput];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:predString, filterInput];
        self.locationArr = nil ;
        
        NSArray *tmpArr = [self.LocCopyArray filteredArrayUsingPredicate:predicate];
        self.locationArr = [[NSArray alloc] initWithArray:tmpArr];
    }
    else {
        self.locationArr = nil ;
        self.locationArr = [[NSArray alloc] initWithArray:self.LocCopyArray];
    }

    
    [self.mapView clear];
    [self initGoogleMap];
    
    _mapMenuView.hidden = YES;
}

- (IBAction)currentLocationBtnTapped:(id)sender {
    [self getDataWithCurrentLocation];
}

@end
