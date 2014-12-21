//
//  MBLocationManager.m
//  MBLocationManager
//
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 Notification posted when location of the device changes
 */
static NSString *const kMBLocationManagerNotificationLocationUpdatedName = @"MBLocationManagerNotificationLocationUpdated";
static NSString *const kMBLocationManagerNotificationFailedName = @"MBLocationManagerNotificationFailed";

/**
 Notification posted when the authorization status changes
 */
static NSString *const kMBLocationManagerNotificationAuthorizationChangedName = @"MBLocationManagerNotificationAuthorizationChangedName";

/**
 MBLocationManagerMonitorMode
 `kMBLocationManagerModeStandard` triggers CoreLocation's `startUpdatingLocation`, which
 uses device's built-in GPS to determine location. Such location will be more acurate, but
 will also reduce battery performance.
 
 `kMBLocationManagerModeSignificantLocationUpdates` on the other hand triggers CoreLocation's
 `startMonitoringSignificantLocation` instead. This method is more appropriate for the majority
 of applications that just need an initial user location fix and need updates only when the
 user moves a significant distance. This interface delivers new events only when it detects
 changes to the device’s associated cell towers, resulting in less frequent updates and
 significantly lower power usage.
 
 */
typedef enum {
    kMBLocationManagerModeStandard,
    kMBLocationManagerModeStandardWhenInUse, // this is new in iOS 8 - app can request for permission for only when app is in use
    kMBLocationManagerModeSignificantLocationUpdates
} MBLocationManagerMonitorMode;



/**
 Location manager tracks user's movement and stores last known location in a property.
    On every change, a notification is posted. It can be used as a tool for easy access to
    last user's location without implementing the whole CoreLocation logic in the controllers.
 
    It also contains convenient methods for calculating distance between two places.
 */
@interface MBLocationManager : NSObject

/**
 Returns shared (singleton) instance of the location manager
 */
+(MBLocationManager *)sharedManager;

/**
 Returns the distance in kilometers between two locations
 @param place1 The first location to mesure distance from
 @param place2 The second location to mesure distance to
 @return The distance in kilometers
 */
+(float)kilometresBetweenPlace1:(CLLocation*)place1 andPlace2:(CLLocation*) place2;

/**
 Returns the distance in kilometers between current and given location
    Method will return null if current location is unknown
 
 @param place1 The location to mesure distance to
 @return The distance in kilometers
 */
+(float)kilometresFromLocation:(CLLocation*)location;


/**
 Begins (resumes) the location updates. This is batery-consuming
 operation, so it does make sense if `stopLocationUpdates` is called when
 application goes to background or terminates, otherwise app will get woken
 up and notified about user's movements.
 
 Start this immedialy after application launch to make we get location fix
 soon enought to be used in the app.
 
 A notification `GETCLocationManagerNotificationLocationUpdatedName` will be
 posted on every change of location. Last known location can be accessed from
 `currentLocation` property.
 */
-(void)startLocationUpdates;

/**
 Begins (resumes) the location updates. This is batery-consuming
    operation, so it does make sense if `stopLocationUpdates` is called when
    application goes to background or terminates, otherwise app will get woken
    up and notified about user's movements.
 
    Start this immedialy after application launch to make we get location fix
    soon enought to be used in the app.
 
    A notification `GETCLocationManagerNotificationLocationUpdatedName` will be 
    posted on every change of location. Last known location can be accessed from
    `currentLocation` property.
 
 @param mode Determines a location update mode (standard or significant location change)
 @param filter The minimum distance (measured in meters) a device must move horizontally 
                before an update event is generated.
 @param accuracy The accuracy of the location data.
 */
-(void)startLocationUpdates:(MBLocationManagerMonitorMode)mode
             distanceFilter:(CLLocationDistance)filter
                   accuracy:(CLLocationAccuracy)accuracy;

/**
 Ends (pauses) the location updates.
 */
- (void)stopLocationUpdates;



/**
 * The last known location of the user's device. This information may be used
    to display user's location in the app or do calculation based on that.
 */
@property (readonly) CLLocation *currentLocation;

/**
 The CoreData CLLocationManager. Read-only property that you can access to configure
 manager with settings.
 */
@property (nonatomic, readonly) CLLocationManager *locationManager;

@end
