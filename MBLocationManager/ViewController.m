//
//  ViewController.m
//  MBLocationManager
//
//  Created by Matej Balantič on 05/03/14.
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import "ViewController.h"
#import "MBLocationManager.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLocation:)
                                                 name:kMBLocationManagerNotificationLocationUpdatedName
                                               object:nil];
}


-(void)changeLocation:(NSNotification*)notification
{
    CLLocation *location = [[MBLocationManager sharedManager] currentLocation];
    self.locationLabel.text = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    NSLog(@"Location changed to %@", self.locationLabel.text);
}


@end
