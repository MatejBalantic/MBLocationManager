//
//  MBLocationManager.m
//  MBLocationManager
//
//  Created by Matej Balantič on 02/02/14.
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import "MBLocationManager.h"



@interface MBLocationManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) MBLocationManagerMonitorMode mode;

@end;



@implementation MBLocationManager

#pragma mark - Static methods
+(MBLocationManager *)sharedManager {
    static dispatch_once_t pred;
    static MBLocationManager *shared;
    
    dispatch_once(&pred, ^{
        shared = [[MBLocationManager alloc] init];
    });
    return shared;
}

+(float)kilometresBetweenPlace1:(CLLocation*)place1 andPlace2:(CLLocation*) place2
{
    CLLocationDistance dist = [place1 distanceFromLocation:place2]/1000;
    NSString *strDistance = [NSString stringWithFormat:@"%.2f", dist];
    return [strDistance floatValue];
}

+(float)kilometresFromLocation:(CLLocation*)location
{
    return [self kilometresBetweenPlace1:location andPlace2:[self sharedManager].currentLocation];
}

#pragma mark - LocationManager
-(CLLocationManager*)locationManager
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

#pragma mark - Location update
-(void)startLocationUpdates
{
    if (self.mode == kMBLocationManagerModeStandard) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    // based on docs, locationmanager's location property is populated with latest
    // known location even before we started monitoring, so let's simulate a change
    if (self.locationManager.location) {
        [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
    }
}
-(void)startLocationUpdates:(MBLocationManagerMonitorMode)mode
             distanceFilter:(CLLocationDistance)filter
                   accuracy:(CLLocationAccuracy)accuracy
{
    self.mode = mode;
    self.locationManager.distanceFilter = filter;
    self.locationManager.desiredAccuracy = accuracy;
    
    [self startLocationUpdates];
}
- (void)stopLocationUpdates
{
    if (self.mode == kMBLocationManagerModeStandard) {
        [self.locationManager stopUpdatingLocation];
    }
    else {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
    
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (![locations count]) {
        return;
    }
    
    // location didn't change
    if (nil != self.currentLocation && [[locations lastObject] isEqual:self.currentLocation]) {
        return;
    }
    
    // update last known location
    self.currentLocation = [locations lastObject];
    
    // notify about the change
    [[NSNotificationCenter defaultCenter] postNotificationName:kMBLocationManagerNotificationLocationUpdatedName
                                                        object:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // notify failed location update
    [[NSNotificationCenter defaultCenter] postNotificationName:kMBLocationManagerNotificationFailedName
                                                        object:self
                                                      userInfo:@{@"error": error}];
}

@end
