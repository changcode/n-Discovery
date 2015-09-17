//
//  AppDelegate.m
//  n-Discovery
//
//  Created by Chang on 7/30/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "AppDelegate.h"
#import "NDRootViewController.h"
#import "Mapbox.h"
#import "KCLaunchImageViewController.h"
#import "UIImage+ForiPhone.h"

@interface AppDelegate () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MGLAccountManager setAccessToken:@"pk.eyJ1IjoiY2hhbmdzaHUxOTkxIiwiYSI6InlQbmlERXMifQ.c12pyT4RSGAc6N0eloV3Eg"];
    [self handleLaunchImage];
    [self handleLocationManger];
    
    UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:userSettings];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma-mark ThirdpartMethods
- (void)handleLaunchImage {
    UIImageView *splashScreen = [[UIImageView alloc] initWithImage:[UIImage autoSelectImageWithImageName:@"FakeLaunchImage"]];
    [self.window addSubview:splashScreen];
    
    
    NDRootViewController *startUpViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"NDrootViewController"];;
    self.window.rootViewController =
    [KCLaunchImageViewController addTransitionToViewController:startUpViewController
                                          modalTransitionStyle:UIModalTransitionStyleCrossDissolve
                                                 withImageName:@"DisplayImage"
                                                     taskBlock:^(void){
                                                         [splashScreen removeFromSuperview];
                                                     }];
}

- (void)handleLocationManger {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
}

- (void)handleEnterRegionEvent:(CLRegion *)region {
    NSLog(@"Enter place");
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"You have entered someplace, %@ nearby",region.identifier];
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)handleExitRegionEvent:(CLRegion *)region {
    NSLog(@"exit place");
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"You just left %@",region.identifier];
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

#pragma-mark RegionMethods
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleEnterRegionEvent:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleExitRegionEvent:region];
    }
}

- (void)handleRegionEvent:(CLRegion*) region {
    
}

@end
