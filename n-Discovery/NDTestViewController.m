//
//  NDTestViewController.m
//  n-Discovery
//
//  Created by Chang on 9/2/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDTestViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "AFNetworking.h"
#import "SLParallaxController.h"

@interface NDTestViewController () <CLLocationManagerDelegate>

@end

@implementation NDTestViewController{
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];

}




- (IBAction)test:(id)sender {
    [self.navigationController pushViewController:[SLParallaxController new] animated:YES];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"%@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog(@"%@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
    }
}

@end
