//
//  GetDirectionViewController.m
//  ShareOne
//
//  Created by Shahrukh Jamil on 9/28/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "GetDirectionViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "LRouteController.h"
#import "ShareOneUtility.h"

@interface GetDirectionViewController ()<GMSMapViewDelegate>
{
    LRouteController *_routeController;
    
    NSString *tittle;
    GMSMarker *_markerStart,*_markerFinish,*movemarker;
    
    GMSPolyline *_polyline;
    NSMutableArray *LocationArr;
}
@property (nonatomic,strong) IBOutlet GMSMapView *mapView;
@property (nonatomic,strong) NSMutableArray *coordinates;

@end

@implementation GetDirectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCoorindatesArray];
    [self initGoogleMap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*********************************************************************************************************/
                        #pragma mark - StartUp Method
/*********************************************************************************************************/

-(void)initCoorindatesArray
{
    LocationArr=[[NSMutableArray alloc] init];
//    NSString * center1=[ShareOneUtility geoCodeUsingAddress:self.sourceAddress];
//    NSString * center2=[ShareOneUtility geoCodeUsingAddress:self.DestinationAddress];
    
    NSString * center1=self.sourceAddress;
    NSString * center2=self.DestinationAddress;

    [LocationArr addObject:center1];
    [LocationArr addObject:center2];
    NSLog(@"Location Arr -----------%@",LocationArr);

}

/*********************************************************************************************************/
                            #pragma mark - Init Google Map
/*********************************************************************************************************/

-(void)initGoogleMap
{
    NSArray *latlongArr=[[LocationArr objectAtIndex:0] componentsSeparatedByString:@","];
    float lat=[[latlongArr objectAtIndex:0] floatValue];
    float lon=[[latlongArr objectAtIndex:1] floatValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:10];
    _mapView.camera=camera;
//    _mapView.myLocationEnabled = YES;
    
    [self createGoogleMapMarker:_mapView];
}
-(void)createGoogleMapMarker:(GMSMapView *)mapView
{
    // Creates a marker in the center of the map.
    for(int count=0; count<[LocationArr count]; count++)
    {
        NSArray *latlongArr=[[LocationArr objectAtIndex:count] componentsSeparatedByString:@","];
        float lat=[[latlongArr objectAtIndex:0] floatValue];
        float lon=[[latlongArr objectAtIndex:1] floatValue];
        if(count==0)
        {
            
            tittle=@"Pickup";
            _markerFinish = [GMSMarker new];
            _markerFinish.position = CLLocationCoordinate2DMake(lat, lon);
//            _markerFinish.title = @"Pickup Point";
            _markerFinish.snippet = @"";
            
            
            _markerFinish.map = self.mapView;
            _markerFinish.icon = [UIImage imageNamed:@"pushpin_PassengerOnBoard.png"];
            //_markerFinish.flat = YES;
            
            [self.mapView setSelectedMarker:_markerFinish];
            
        }
        else
        {
            tittle=@"Destination";
            _markerStart = [GMSMarker new];
            _markerStart.position = CLLocationCoordinate2DMake(lat, lon);
            _markerStart.title = @"";
            _markerStart.snippet = @"";
            // _markerStart.flat = YES;
            
            
            _markerStart.map = self.mapView;
            _markerStart.icon = [UIImage imageNamed:@"Destination.png"];
            //[mapView_ setSelectedMarker:_markerStart];
        }
    }
    [self setpolyLine];
}

-(void)setpolyLine
{
    _routeController = [LRouteController new];
    _polyline.map = nil;
    _markerStart.map = nil;
    _markerFinish.map = nil;
    _coordinates=[[NSMutableArray alloc] init];
    for (int count=0; count<2; count++)
        {
            
            NSArray *latlongArr=[[LocationArr objectAtIndex:count] componentsSeparatedByString:@","];
            float lat=[[latlongArr objectAtIndex:0] floatValue];
            float lon=[[latlongArr objectAtIndex:1] floatValue];
            if(count==0)
                [_coordinates addObject:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
            else
                [_coordinates addObject:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
            
            
            if ([_coordinates count] > 1)
            {
                [_routeController getPolylineWithLocations:_coordinates travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
                    if (error)
                    {
                        NSLog(@"%@", error);
                    }
                    else if (!polyline)
                    {
                        NSLog(@"No route");
                        [_coordinates removeAllObjects];
                    }
                    else
                    {
                        NSLog(@"Coordinates...%@",_coordinates);
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
            
            
        }
}
@end
