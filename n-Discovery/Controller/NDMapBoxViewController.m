//
//  NDMapBoxViewController.m
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDMapBoxViewController.h"
#import "RESideMenu.h"
#import "MapboxGL.h"

@interface NDMapBoxViewController ()

@property (strong, readwrite, nonatomic) MGLMapView *mapView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@end

@implementation NDMapBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(41.2854277, -81.5656396) zoomLevel:11 animated:NO];
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;

    
    [_menuBarButtonItem setAction:@selector(presentLeftMenuViewController:)];
    
}

@end
