//
//  NDMapBoxViewController.m
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDMapBoxViewController.h"
#import "RESideMenu.h"
#import "Mapbox.h"
#import "AFNetworking.h"

#define driving @"mapbox.driving"
#define walking @"mapbox.walking"
#define cyclying @"mapbox.cycling"


@interface NDMapBoxViewController () <MGLMapViewDelegate>

@property (strong, readwrite, nonatomic) MGLMapView *mapView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@property (strong, readwrite, nonatomic) NSMutableArray *routePolyLine;

@property (weak, nonatomic) IBOutlet UISegmentedControl *routeStyelSegControl;

@property (strong, readwrite, nonatomic) NSMutableArray *trailsArray;

@property (weak, nonatomic) IBOutlet UISwitch *trailsShowSwitch;

@end

@implementation NDMapBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(41.2854277, -81.5656396) zoomLevel:11 animated:NO];
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _routePolyLine = [NSMutableArray new];
    _trailsArray = [NSMutableArray new];
    
    [_menuBarButtonItem setAction:@selector(presentLeftMenuViewController:)];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self drawFacilities];
    [self drawTrails];
}
- (void)drawTrails
{
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        
    });
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"trails8" ofType:@"geojson"];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
    for (NSDictionary *feature in jsonDict[@"features"]) {
        NSArray *rawCoordinates = [feature[@"geometry"][@"coordinates"] firstObject];
        NSUInteger coordinatesCount = rawCoordinates.count;
        CLLocationCoordinate2D coordinates[coordinatesCount];
        for (NSUInteger index = 0; index < coordinatesCount; index++) {
            NSArray *point = [rawCoordinates objectAtIndex:index];
            CLLocationDegrees lat = [[point objectAtIndex:1] doubleValue];
            CLLocationDegrees lng = [[point objectAtIndex:0] doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
            coordinates[index] = coordinate;
        }
        MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:coordinates count:coordinatesCount];
        polyline.title = @"trails";
        [_trailsArray addObject:polyline];
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//                       {
//                           [weakSelf.mapView addAnnotation:polyline];
//                       });
    }
}

- (void)drawFacilities
{
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"facilities" ofType:@"geojson"];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
        for (NSDictionary *feature in jsonDict[@"features"]) {
            MGLPointAnnotation *marker = [[MGLPointAnnotation alloc] init];
            marker.coordinate = CLLocationCoordinate2DMake([feature[@"geometry"][@"coordinates"][1] doubleValue], [feature[@"geometry"][@"coordinates"][0] doubleValue]);
            marker.title = feature[@"properties"][@"name"];
            marker.subtitle = feature[@"properties"][@"res_name"];
            __weak typeof(self) weakSelf = self;
            [weakSelf.mapView addAnnotation:marker];
        }
    });
}

- (MGLAnnotationImage *)mapView:(MGLMapView * __nonnull)mapView imageForAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    return nil;
}

- (BOOL)mapView:(MGLMapView * __nonnull)mapView annotationCanShowCallout:(id<MGLAnnotation> __nonnull)annotation
{
    return YES;
}

- (UIView *)mapView:(MGLMapView *)mapView leftCalloutAccessoryViewForAnnotation:(id <MGLAnnotation>)annotation;
{
   return [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

- (void)mapView:(MGLMapView *)mapView annotation:(id <MGLAnnotation>)annotation calloutAccessoryControlTapped:(UIControl *)control
{
    [mapView removeAnnotations:_routePolyLine];
    [_routePolyLine removeAllObjects];
    NSLog(@"User:%f%f",mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude);
    NSLog(@"Curr:%f%f",annotation.coordinate.latitude, annotation.coordinate.longitude);
    NSString *routeStyle = [NSString new];

    switch (_routeStyelSegControl.selectedSegmentIndex) {
        case 0:
            routeStyle = driving;
            break;
        case 1:
            routeStyle = walking;
            break;
        case 2:
            routeStyle = cyclying;
        default:
            routeStyle = walking;
            break;
    }
    NSString *url = [NSString stringWithFormat:@"%@/%@/%f,%f;%f,%f%@",@"https://api.mapbox.com/v4/directions", routeStyle, annotation.coordinate.longitude, annotation.coordinate.latitude, mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude, @".json?access_token=pk.eyJ1IjoiY2hhbmdzaHUxOTkxIiwiYSI6InlQbmlERXMifQ.c12pyT4RSGAc6N0eloV3Eg"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject[@"routes"]);
        for (NSDictionary *route in responseObject[@"routes"]) {
            NSArray *rawCoordinates = route[@"geometry"][@"coordinates"];
            NSUInteger coordinatesCount = rawCoordinates.count;
            CLLocationCoordinate2D coordinates[coordinatesCount];
            for (NSUInteger index = 0; index < coordinatesCount; index++) {
                NSArray *point = [rawCoordinates objectAtIndex:index];
                CLLocationDegrees lat = [[point objectAtIndex:1] doubleValue];
                CLLocationDegrees lng = [[point objectAtIndex:0] doubleValue];
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
                coordinates[index] = coordinate;
            }
            MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:coordinates count:coordinatesCount];
            polyline.title = @"test";
            [_routePolyLine addObject:polyline];
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [weakSelf.mapView addAnnotations:_routePolyLine];
                       });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (CGFloat)mapView:(MGLMapView * __nonnull)mapView alphaForShapeAnnotation:(MGLShape * __nonnull)annotation
{
    return 1.0f;
}

- (CGFloat)mapView:(MGLMapView * __nonnull)mapView lineWidthForPolylineAnnotation:(MGLPolyline * __nonnull)annotation
{
    return 2.0f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    if ([annotation.title isEqualToString:@"trails"]) {
        return [UIColor orangeColor];
    }
    else{
        switch (_routeStyelSegControl.selectedSegmentIndex) {
            case 0:
                return [UIColor cyanColor];
            case 1:
                return [UIColor redColor];
            case 2:
                return [UIColor greenColor];
        }
    }
    return [UIColor blackColor];
}

- (IBAction)switchShowTrails:(id)sender {
    if (_trailsShowSwitch.isOn) {
        [_mapView addAnnotations:_trailsArray];
    }
    else {
        [_mapView removeAnnotations:_trailsArray];
    }
}

@end
