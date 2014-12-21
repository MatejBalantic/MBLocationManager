[![Build Status](https://travis-ci.org/MatejBalantic/MBLocationManager.svg)](https://travis-ci.org/MatejBalantic/MBLocationManager)

MBLocationManager
=================

Location manager provides convenient and easy-to-use access to latest iOS device location. It wraps CoreLocation
with convenient singleton class, relieving you of keeping reference to location manager object.

Main features:
* subscribe to location updates with 3 lines of code
* three modes of operation: track user's location only when application is in use (iOS 8 only), track the location even when in background or track only significant location changes
* use CoreLocation's distance filters and accuracy modes
* easy pause and resume on app going to background or foreground
* instantiate location manager once, use it wherever you need by subscribing to notification

Integrates with iOS 7 and the new iOS 8 CoreLocation APIs.

Now also fully unit tested.

## Installation
Installation should be done via Cocoa Pods. 

Install CocoaPods if you didn't yet:
```bash
sudo gem install cocoapods
pod setup
```

Change to the directory of your Xcode project, and Create and Edit your ``Podfile`` and add following line
```
pod 'MBLocationManager'
```

```bash
pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)


## Usage

#### 1. Add required .plist entries

As of iOS 8 you are required to define a message that will be presented to the user on location authorization request. You define this message into your app's  *-Info.plist file. You need to add at least one of the following keys, depending on which location update mode you request:

* ``NSLocationWhenInUseUsageDescription``
* ``NSLocationAlwaysUsageDescription``

Make sure you enter this key in the right .plist file (common mistake is entering it into test-Info.plist). Also do not to add the actual message text as a value. **Failing to add the key(s) to plist file will prevent your app to ask for user permission and thus will render location updates useless.**

#### 2. Start tracking location 
To start tracking location on the device, call ``startLocationUpdates:distanceFilter:accuracy`` from 
``application:didFinishLaunchingWithOptions`` in the AppDelegate.h

```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandardWhenInUse
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyThreeKilometers];

    return YES;
}
```

#### 3. Subscribe to the notification events
From the viewcontroller where you intend to use a location of the device, subscribe to notification ``kMBLocationManagerNotificationLocationUpdatedName``
which is triggered whenever a new location is detected. When notification is posted, access 
MBLocationManager's property ``currentLocation``

Notification ``kMBLocationManagerNotificationFailedName`` informs you about failed attempt to determine 
the location (see   [locationManager:didFailWithError](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManagerDelegate_Protocol/CLLocationManagerDelegate/CLLocationManagerDelegate.html#jumpTo_7) )


```objectivec
- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLocation:)
                                                 name:kMBLocationManagerNotificationLocationUpdatedName
                                               object:nil];
                                               
                                               
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerFailed:)
                                                 name:kMBLocationManagerNotificationFailedName
                                               object:nil];
}

-(void)locationManagerFailed:(NSNotification*)notification
{
   NSLog(@"Location manager failed");
}

-(void)changeLocation:(NSNotification*)notification
{
    CLLocation *location = [[MBLocationManager sharedManager] currentLocation];
    NSLog(@"Location changed to %@", self.locationLabel.text);
}
```

#### 4. (Optional) Pause location updates when in background
To improve battery life, you might prevent app from tracking location changes when
entering background.

```objectivec
- (void)applicationDidEnterBackground:(UIApplication *)application
{
   [[MBLocationManager sharedManager] stopLocationUpdates];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[MBLocationManager sharedManager] startLocationUpdates];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[MBLocationManager sharedManager] stopLocationUpdates];
}
```

## Fine-tune CoreLocation settings
By accessing ``locationManager`` property you are able to fine-tune CoreLocation settings, such as
``activityType`` and ``pausesLocationUpdatesAutomatically``. 

CoreLocation documentation:
https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/CLLocationManager/CLLocationManager.html#//apple_ref/occ/cl/CLLocationManager
