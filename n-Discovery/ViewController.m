//
//  ViewController.m
//  n-Discovery
//
//  Created by Chang on 7/30/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "ViewController.h"
#import "Mapbox.h"
#import "RMUserTrackingBarButtonItem.h"
#import "RESideMenu.h"

@interface ViewController () <MGLMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menubutton;
@property (strong, readwrite, nonatomic) MGLMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *styleURL = [NSURL URLWithString:@"asset://styles/dark-v7.json"];
//    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds
//                                            styleURL:styleURL];
    _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(41.2854277, -81.5656396) zoomLevel:11 animated:NO];
    
//    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.menubutton setAction:@selector(presentLeftMenuViewController:)];
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
//    [_mapView setUserTrackingMode:MGLUserTrackingModeFollow];
    
    _mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Declare the annotation `point` and set its coordinates, title, and subtitle
    MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(41.2854277, -81.5656396);
    point.title = @"Hello world!";
    point.subtitle = @"Welcome to The Ellipse.";
    
    // Add annotation `point` to the map
    [_mapView addAnnotation:point];
    [_mapView addAnnotation:_mapView.userLocation];
}
- (IBAction)GetUserLocation:(id)sender {
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Always show a callout when an annotation is tapped.
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    return YES;
}

@end
