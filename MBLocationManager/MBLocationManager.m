//
//  MBLocationManager.m
//  MBLocationManager
//
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import "MBLocationManager.h"

@interface MBLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) MBLocationManagerMonitorMode mode;

@end;

@implementation MBLocationManager

#pragma mark - Static

static MBLocationManager *sharedManager;

#pragma mark - Initialization

- (id)init
{
    return [self initWithLocationManager:[[CLLocationManager alloc] init]];
}

- (id)initWithLocationManager:(CLLocationManager *)locationManager
{
    self = [super init];
    if (self) {
        NSParameterAssert(locationManager);
        _locationManager = locationManager;
        _locationManager.delegate = self;
    }
    return self;
}

#pragma mark - Public static methods

+ (MBLocationManager *)sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[MBLocationManager alloc] init];
    };
    return sharedManager;
}

+ (float)kilometresBetweenPlace1:(CLLocation*)place1 andPlace2:(CLLocation*) place2
{
    CLLocationDistance dist = [place1 distanceFromLocation:place2]/1000;
    NSString *strDistance = [NSString stringWithFormat:@"%.2f", dist];
    return [strDistance floatValue];
}

+ (float)kilometresFromLocation:(CLLocation*)location
{
    return [self kilometresBetweenPlace1:location andPlace2:[self sharedManager].currentLocation];
}

#pragma mark - Public methods

- (void)startLocationUpdates
{
    if (self.mode == kMBLocationManagerModeStandard) {
        [self requestAlwaysAuthorization]; // for significant location changes this auth is required (>= ios8)
        [self.locationManager startUpdatingLocation];
    }
    else if (self.mode == kMBLocationManagerModeStandardWhenInUse) {
        [self requestWhenInUseAuthorization]; // for significant location changes this auth is required (>= ios8)
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self requestAlwaysAuthorization]; // for significant location changes this auth is required (>= ios8)
        [self.locationManager startMonitoringSignificantLocationChanges];
    }

    // based on docs, locationmanager's location property is populated with latest
    // known location even before we started monitoring, so let's simulate a change
    if (self.locationManager.location) {
        [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
    }
}

- (void)startLocationUpdates:(MBLocationManagerMonitorMode)mode
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

#pragma mark - Private

/**
 iOS 8 requires you to request authorisation prior to starting location updates
 */
- (void)requestAlwaysAuthorization
{
    if (![self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        return;
    }

    [self.locationManager requestAlwaysAuthorization];
}

- (void)requestWhenInUseAuthorization
{
    if (![self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        return;
    }

    [self.locationManager requestWhenInUseAuthorization];
}

+ (void)setSharedManager:(MBLocationManager *)manager
{
    sharedManager = manager;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kMBLocationManagerNotificationFailedName
                                                        object:self
                                                      userInfo:@{@"error": error}];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMBLocationManagerNotificationAuthorizationChangedName
                                                        object:self userInfo:@{@"status": @(status)}];
}

@end
