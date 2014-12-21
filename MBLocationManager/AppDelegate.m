//
//  AppDelegate.m
//  MBLocationManager
//
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import "AppDelegate.h"
#import "MBLocationManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Start location updates
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyThreeKilometers];
    NSLog(@"Location manager initialized and started");
    return YES;
}
							
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // stop updates after the app goes to background
    [[MBLocationManager sharedManager] stopLocationUpdates];
    NSLog(@"Location manager stopped");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // resume updates with existing settings when the app enters foreground
    [[MBLocationManager sharedManager] startLocationUpdates];
    NSLog(@"Location manager resumed");
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // stop the updates when app terminates
    [[MBLocationManager sharedManager] stopLocationUpdates];
    NSLog(@"Location manager stopped");
}

@end
