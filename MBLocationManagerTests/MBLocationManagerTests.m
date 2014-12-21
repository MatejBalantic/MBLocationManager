#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "MBLocationManager.h"

@protocol MBLocationManagerMockNotificationObserver <NSObject>
-(void)received:(NSNotification*)notification;
@end

@interface MBLocationManager (XCTestCase) <CLLocationManagerDelegate>
+ (void)setSharedManager:(MBLocationManager *)manager;
- (id)initWithLocationManager:(CLLocationManager *)locationManager;
@end

@interface MBLocationManagerTests : XCTestCase
@property (nonatomic) MBLocationManager *subject;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) id<MBLocationManagerMockNotificationObserver> notificationLocationUpdateObserver;
@property (nonatomic) id<MBLocationManagerMockNotificationObserver> notificationFailedObserver;
@property (nonatomic) id<MBLocationManagerMockNotificationObserver> notificationAuthorizationChangedObserver;
@end

@implementation MBLocationManagerTests

- (void)setUp
{
    self.locationManager = mock(CLLocationManager.class);
    self.subject = [[MBLocationManager alloc] initWithLocationManager:self.locationManager];
    [MBLocationManager setSharedManager:self.subject];

    self.notificationLocationUpdateObserver = mockProtocol(@protocol(MBLocationManagerMockNotificationObserver));
    [[NSNotificationCenter defaultCenter] addObserver:self.notificationLocationUpdateObserver selector:@selector(received:) name:kMBLocationManagerNotificationLocationUpdatedName object:nil];

    self.notificationFailedObserver = mockProtocol(@protocol(MBLocationManagerMockNotificationObserver));
    [[NSNotificationCenter defaultCenter] addObserver:self.notificationFailedObserver selector:@selector(received:) name:kMBLocationManagerNotificationFailedName object:nil];

    self.notificationAuthorizationChangedObserver = mockProtocol(@protocol(MBLocationManagerMockNotificationObserver));
    [[NSNotificationCenter defaultCenter] addObserver:self.notificationAuthorizationChangedObserver selector:@selector(received:) name:kMBLocationManagerNotificationAuthorizationChangedName object:nil];

    [super setUp];
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationLocationUpdateObserver];

    [super tearDown];
}

- (void)testSharedManager
{
    [MBLocationManager setSharedManager:nil];

    MBLocationManager *manager = [MBLocationManager sharedManager];
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.locationManager);
    XCTAssertEqualObjects(manager.locationManager.delegate, manager);
}

- (void)testKilometresBetweenPlace1andPlace2
{
    float distance = [MBLocationManager kilometresBetweenPlace1:[self locationLjubljana]
                                                      andPlace2:[self locationVrhnika]];

    XCTAssertEqualObjects([self round:distance], @"24.080");
}

- (void)testKilometresFromLocation
{
    [self.subject locationManager:self.locationManager didUpdateLocations:@[[self locationVrhnika]]];
    float distance = [MBLocationManager kilometresFromLocation:[self locationLjubljana]];
    XCTAssertEqualObjects([self round:distance], @"24.080");
}

- (void)testStartLocationUpdatesDistanceFilterAccuracyModeStandard
{
    [self.subject startLocationUpdates:kMBLocationManagerModeStandard
                        distanceFilter:0
                              accuracy:0];

    [MKTVerify(self.locationManager) startUpdatingLocation];
    [MKTVerify(self.locationManager) requestAlwaysAuthorization];
}

- (void)testStartLocationUpdatesDistanceFilterAccuracyModeStandardWhenInUse
{
    [self.subject startLocationUpdates:kMBLocationManagerModeStandardWhenInUse
                        distanceFilter:0
                              accuracy:0];

    [MKTVerify(self.locationManager) startUpdatingLocation];
    [MKTVerify(self.locationManager) requestWhenInUseAuthorization];
}

- (void)testStartLocationUpdatesDistanceFilterAccuracyModeSignificantLocationUpdates
{
    [self.subject startLocationUpdates:kMBLocationManagerModeSignificantLocationUpdates
                        distanceFilter:0
                              accuracy:0];

    [MKTVerify(self.locationManager) startMonitoringSignificantLocationChanges];
    [MKTVerify(self.locationManager) requestAlwaysAuthorization];
}

- (void)testStartLocationUpdatesDistanceFilterAccuracyUpdateLocation
{
    [given([self.locationManager location]) willReturn:[self locationLjubljana]];

    [self.subject startLocationUpdates:kMBLocationManagerModeStandardWhenInUse
                        distanceFilter:0
                              accuracy:0];

    [MKTVerify(self.notificationLocationUpdateObserver) received:anything()];
    XCTAssert([[self locationLjubljana] distanceFromLocation:self.subject.currentLocation] == 0);
}

- (void)testLocationManagerDidUpdateLocationNoLocations
{
    [self.subject locationManager:self.locationManager didUpdateLocations:@[]];

    [verifyCount(self.notificationLocationUpdateObserver, never()) received:anything()];
    XCTAssertNil(self.subject.currentLocation);
}

- (void)testLocationManagerDidUpdateLocationWithLocations
{
    NSArray *locations = @[[self locationLjubljana], [self locationVrhnika]];

    [self.subject locationManager:self.locationManager didUpdateLocations:locations];

    MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
    [MKTVerify(self.notificationLocationUpdateObserver) received:[captor capture]];
    NSNotification *notification = [captor value];
    XCTAssert([[self locationVrhnika] distanceFromLocation:self.subject.currentLocation] == 0);
    XCTAssertEqualObjects(notification.object, self.subject);
}

- (void)testLocationManagerDidFailWithError
{
    NSError *error = [NSError errorWithDomain:@"testDomain" code:0 userInfo:nil];
    [self.subject locationManager:self.locationManager didFailWithError:error];

    MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
    [MKTVerify(self.notificationFailedObserver) received:[captor capture]];
    NSNotification *notification = [captor value];
    XCTAssertEqualObjects(notification.userInfo[@"error"], error);
    XCTAssertEqualObjects(notification.object, self.subject);
}

- (void)testLocationManagerDidChangeAuthorizationStatus
{
    [self.subject locationManager:self.locationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];

    MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
    [MKTVerify(self.notificationAuthorizationChangedObserver) received:[captor capture]];
    NSNotification *notification = [captor value];
    XCTAssert([notification.userInfo[@"status"] intValue] == kCLAuthorizationStatusDenied);
    XCTAssertEqualObjects(notification.object, self.subject);
}

#pragma mark - Helpers

- (CLLocation *)locationLjubljana
{
    return [[CLLocation alloc] initWithLatitude:46.0661174 longitude:14.5320991];
}

- (CLLocation *)locationVrhnika
{
    return [[CLLocation alloc] initWithLatitude:45.9414531 longitude:14.2779068];
}

- (NSString *)round:(float)distance
{
    return [NSString stringWithFormat:@"%.03f", distance];
}

@end
