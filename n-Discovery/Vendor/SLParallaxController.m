//
//  SLParallaxController.m
//  SLParallax
//
//  Created by Stefan Lage on 14/03/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import "SLParallaxController.h"

#import "AFNetworking.h"

#import "NDQuestionTableViewController.h"

#define SCREEN_HEIGHT_WITHOUT_STATUS_BAR     [[UIScreen mainScreen] bounds].size.height - 20
#define SCREEN_WIDTH                         [[UIScreen mainScreen] bounds].size.width
#define HEIGHT_STATUS_BAR                    20
//#define Y_DOWN_TABLEVIEW                     SCREEN_HEIGHT_WITHOUT_STATUS_BAR - 40
#define Y_DOWN_TABLEVIEW                     SCREEN_HEIGHT_WITHOUT_STATUS_BAR - 120
#define DEFAULT_HEIGHT_HEADER                100.0f
#define MIN_HEIGHT_HEADER                    10.0f
#define DEFAULT_Y_OFFSET                     ([[UIScreen mainScreen] bounds].size.height == 480.0f) ? -200.0f : -250.0f
//-200.0f origin
#define FULL_Y_OFFSET                        -100.0f
#define MIN_Y_OFFSET_TO_REACH                -30
#define OPEN_SHUTTER_LATITUDE_MINUS          .005
#define CLOSE_SHUTTER_LATITUDE_MINUS         .018


@interface SLParallaxController ()<UIGestureRecognizerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic)   UITapGestureRecognizer  *tapMapViewGesture;
@property (strong, nonatomic)   UITapGestureRecognizer  *tapTableViewGesture;
@property (nonatomic)           CGRect                  headerFrame;
@property (nonatomic)           float                   headerYOffSet;
@property (nonatomic)           BOOL                    isShutterOpen;
@property (nonatomic)           BOOL                    displayMap;
@property (nonatomic)           float                   heightMap;

@property (strong, nonatomic)   NSDictionary            *jsonFromFile;

@property (strong, nonatomic)   CLLocationManager       *locationManager;
@property (strong, nonatomic)   NSMutableArray          *monitorRegionsArray;

@property (strong, readwrite, nonatomic) NSMutableArray *trailsArray;
@property (strong, readwrite, nonatomic) NSMutableArray *routePolyLine;

@end


@implementation SLParallaxController

-(id)init{
    self =  [super init];
    if(self){
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setupMapView];
    
    
    [self loadJSONFile];
    self.mapView.showsUserLocation = YES;
    [self zoomToUserLocation:self.mapView.userLocation minLatitude:0 animated:YES];
    [self drawFacilities];

    _monitorRegionsArray = [[NSMutableArray alloc] init];
    [self handleLocationMonitor];
    
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"needs to cancel region");
    for (CLRegion *region in _monitorRegionsArray) {
        [_locationManager stopMonitoringForRegion:region];
    }
            [_monitorRegionsArray removeAllObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Set all view we will need
-(void)setup{
    _heighTableViewHeader       = DEFAULT_HEIGHT_HEADER;
    _heighTableView             = SCREEN_HEIGHT_WITHOUT_STATUS_BAR;
    _minHeighTableViewHeader    = MIN_HEIGHT_HEADER;
    _default_Y_tableView        = HEIGHT_STATUS_BAR;
    _Y_tableViewOnBottom        = Y_DOWN_TABLEVIEW;
    _minYOffsetToReach          = MIN_Y_OFFSET_TO_REACH;
    _latitudeUserUp             = CLOSE_SHUTTER_LATITUDE_MINUS;
    _latitudeUserDown           = OPEN_SHUTTER_LATITUDE_MINUS;
    _default_Y_mapView          = DEFAULT_Y_OFFSET;
    _headerYOffSet              = DEFAULT_Y_OFFSET;
    _heightMap                  = 1000.0f;
    _regionAnimated             = YES;
    _userLocationUpdateAnimated = YES;
}

-(void)setupTableView{
    self.tableView                  = [[UITableView alloc]  initWithFrame: CGRectMake(0, 200, SCREEN_WIDTH, self.heighTableView)];
    self.tableView.tableHeaderView  = [[UIView alloc]       initWithFrame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.heighTableViewHeader)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    // Add gesture to gestures
    self.tapMapViewGesture      = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleTapMapView:)];
    self.tapTableViewGesture    = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleTapTableView:)];
    self.tapTableViewGesture.delegate = self;
    [self.tableView.tableHeaderView addGestureRecognizer:self.tapMapViewGesture];
    [self.tableView addGestureRecognizer:self.tapTableViewGesture];
    
    // Init selt as default tableview's delegate & datasource
    self.tableView.dataSource   = self;
    self.tableView.delegate     = self;
    [self.view addSubview:self.tableView];
}

-(void)setupMapView{
    self.mapView                        = [[MGLMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.heighTableView)];
    [self.mapView setShowsUserLocation:YES];
    self.mapView.delegate = self;
    [self.view insertSubview:self.mapView
                belowSubview: self.tableView];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Internal Methods

- (void)handleTapMapView:(UIGestureRecognizer *)gesture {
    if(!self.isShutterOpen){
        // Move the tableView down to let the map appear entirely
        [self openShutter];
        // Inform the delegate
        if([self.delegate respondsToSelector:@selector(didTapOnMapView)]){
            [self.delegate didTapOnMapView];
        }
    }
}

- (void)handleTapTableView:(UIGestureRecognizer *)gesture {
    if(self.isShutterOpen){
        // Move the tableView up to reach is origin position
        [self closeShutter];
        // Inform the delegate
        if([self.delegate respondsToSelector:@selector(didTapOnTableView)]){
            [self.delegate didTapOnTableView];
        }
    }
}

// Move DOWN the tableView to show the "entire" mapView
-(void) openShutter{
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.tableView.tableHeaderView     = [[UIView alloc] initWithFrame: CGRectMake(0.0, self.Y_tableViewOnBottom, self.view.frame.size.width, self.minHeighTableViewHeader)];
                         self.mapView.frame                 = CGRectMake(0, FULL_Y_OFFSET, self.mapView.frame.size.width, self.heightMap);
                         self.tableView.frame               = CGRectMake(0, self.Y_tableViewOnBottom, self.tableView.frame.size.width, self.tableView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         // Disable cells selection
                         [self.tableView setAllowsSelection:NO];
                         self.isShutterOpen = YES;
                         [self.tableView setScrollEnabled:NO];
                         // Center the user 's location
                         [self zoomToUserLocation:self.mapView.userLocation
                                      minLatitude:self.latitudeUserDown
                                         animated:self.regionAnimated];

                         // Inform the delegate
                         if([self.delegate respondsToSelector:@selector(didTableViewMoveDown)]){
                             [self.delegate didTableViewMoveDown];
                         }
                     }];
}

// Move UP the tableView to get its original position
-(void) closeShutter{
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.mapView.frame             = CGRectMake(0, self.default_Y_mapView, self.mapView.frame.size.width, self.heighTableView);
                         self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20, self.view.frame.size.width, 0)];
                         self.tableView.frame           = CGRectMake(0, 68, self.tableView.frame.size.width, self.tableView.frame.size.height - 68);
                     }
                     completion:^(BOOL finished){
                         // Enable cells selection
                         [self.tableView setAllowsSelection:YES];
                         self.isShutterOpen = NO;
                         [self.tableView setScrollEnabled:YES];
                         [self.tableView.tableHeaderView addGestureRecognizer:self.tapMapViewGesture];
                         // Center the user 's location
                         [self zoomToUserLocation:self.mapView.userLocation
                                      minLatitude:self.latitudeUserUp
                                         animated:self.regionAnimated];

                         // Inform the delegate
                         if([self.delegate respondsToSelector:@selector(didTableViewMoveUp)]){
                             [self.delegate didTableViewMoveUp];
                         }
                     }];
}

#pragma mark - Table view Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset        = scrollView.contentOffset.y;
    CGRect headerMapViewFrame   = self.mapView.frame;

    if (scrollOffset < 0) {
        // Adjust map
        headerMapViewFrame.origin.y = self.headerYOffSet - ((scrollOffset / 2));
    } else {
        // Scrolling Up -> normal behavior
        headerMapViewFrame.origin.y = self.headerYOffSet - scrollOffset / 2;
    }
    self.mapView.frame = headerMapViewFrame;

    // check if the Y offset is under the minus Y to reach
    if (self.tableView.contentOffset.y < self.minYOffsetToReach){
        if(!self.displayMap)
            self.displayMap                      = YES;
    }else{
        if(self.displayMap)
            self.displayMap                      = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(self.displayMap)
        [self openShutter];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    [self performSegueWithIdentifier:@"goToQuestion" sender:_jsonFromFile[@"trackpoints"][indexPath.row][@"questions"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToQuestion"]) {
        NDQuestionTableViewController *vc = segue.destinationViewController;
        vc.QuestionData = (NSArray *)sender;
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)_jsonFromFile[@"trackpoints"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *identifier;
    if(indexPath.row == 0){
        identifier = @"firstCell";
        // Add some shadow to the first cell
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];

            CGRect cellBounds       = cell.layer.bounds;
            CGRect shadowFrame      = CGRectMake(cellBounds.origin.x, cellBounds.origin.y, tableView.frame.size.width, 10.0);
            CGPathRef shadowPath    = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
            cell.layer.shadowPath   = shadowPath;
            [cell.layer setShadowOffset:CGSizeMake(-2, -2)];
            [cell.layer setShadowColor:[[UIColor grayColor] CGColor]];
            [cell.layer setShadowOpacity:.75];
        }
    }
    else{
        identifier = @"otherCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
    }
    [[cell textLabel] setText:[(NSArray *)_jsonFromFile[@"trackpoints"] objectAtIndex:indexPath.row][@"title"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //first get total rows in that section by current indexPath.
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];

    //this is the last row in section.
    if(indexPath.row == totalRow -1){
        // get total of cells's Height
        float cellsHeight = totalRow * cell.frame.size.height;
        // calculate tableView's Height with it's the header
        float tableHeight = (tableView.frame.size.height - tableView.tableHeaderView.frame.size.height);

        // Check if we need to create a foot to hide the backView (the map)
        if((cellsHeight - tableView.frame.origin.y)  < tableHeight){
            // Add a footer to hide the background
            int footerHeight = tableHeight - cellsHeight;
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, footerHeight)];
            [tableView.tableFooterView setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark - MapView Delegate

- (void)zoomToUserLocation:(MGLUserLocation *)userLocation minLatitude:(float)minLatitude animated:(BOOL)anim
{
    if (!userLocation)
        return;
    CLLocationCoordinate2D loc  = CLLocationCoordinate2DMake([_jsonFromFile[@"trackpoints"][0][@"coordinate"][1] doubleValue], [_jsonFromFile[@"trackpoints"][0][@"coordinate"][0] doubleValue]);
    [self.mapView setCenterCoordinate:loc zoomLevel:14 animated:YES];
}

- (void)drawFacilities
{
    for (NSDictionary *feature in _jsonFromFile[@"trackpoints"]) {
        MGLPointAnnotation *marker = [[MGLPointAnnotation alloc] init];
        marker.coordinate = CLLocationCoordinate2DMake([feature[@"coordinate"][1] doubleValue], [feature[@"coordinate"][0] doubleValue]);
        marker.title = feature[@"title"];
        marker.subtitle = feature[@"descriotion"];
        [self.mapView addAnnotation:marker];
    }
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
    _routePolyLine = [NSMutableArray new];
    [_routePolyLine removeAllObjects];
    NSLog(@"User:%f%f",mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude);
    NSLog(@"Curr:%f%f",annotation.coordinate.latitude, annotation.coordinate.longitude);
    NSString *routeStyle = @"mapbox.walking";

    NSString *url = [NSString stringWithFormat:@"%@/%@/%f,%f;%f,%f%@",@"https://api.mapbox.com/v4/directions", routeStyle, annotation.coordinate.longitude, annotation.coordinate.latitude, mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude, @".json?access_token=pk.eyJ1IjoiY2hhbmdzaHUxOTkxIiwiYSI6InlQbmlERXMifQ.c12pyT4RSGAc6N0eloV3Eg"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject[@"routes"]);
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
                           NSLog(@"JSON: %@", _routePolyLine);
                           [weakSelf.mapView addAnnotations:_routePolyLine];
                       });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapTableViewGesture) {
        return _isShutterOpen;
    }
    return YES;
}

#pragma mark - Load & Handle JSON
- (void)loadJSONFile {
    NSString *sampleFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:self.jsonfile];
    NSData *data = [NSData dataWithContentsOfFile:sampleFile];
    _jsonFromFile = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.title = _jsonFromFile[@"trackname"];
}


- (void)handleLocationMonitor {
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];

    [_monitorRegionsArray removeAllObjects];
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        for (NSDictionary *point in _jsonFromFile[@"trackpoints"]) {
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([point[@"coordinate"][1] floatValue], [point[@"coordinate"][0] floatValue]) radius:[point[@"radius"] doubleValue]/3.2 identifier:[NSString stringWithString:point[@"title"]]];
            NSLog(@"%@", region);
            [_monitorRegionsArray addObject:region];
            [_locationManager startMonitoringForRegion:region];
        }
    }
    NSLog(@"%@", [_locationManager monitoredRegions]);
}


#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    _mapView.showsUserLocation = (status == kCLAuthorizationStatusAuthorizedAlways);
}

-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"moinitoring fail!");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed");
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"!!!!");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Region" message:@"You are enter a region" delegate:nil cancelButtonTitle:@"Enter" otherButtonTitles:nil];
//    [alert show];
//    NSArray *question;
//    for (NSDictionary *point in _jsonFromFile[@"trackpoints"]) {
//        if ([point[@"title"] isEqualToString:region.identifier]) {
//            question = point[@"questions"];
//            break;
//        }
//    }
//    [_locationManager stopMonitoringForRegion:region];
//    [self performSegueWithIdentifier:@"goToQuestion" sender:question];
}

@end
