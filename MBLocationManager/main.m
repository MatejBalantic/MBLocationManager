//
//  main.m
//  MBLocationManager
//
//  Created by Matej Balantič on 05/03/14.
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        BOOL inTests = (NSClassFromString(@"XCTest") != nil);
        if (inTests) {
            return UIApplicationMain(argc, argv, nil, @"TestAppDelegate");
        }
        else {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
}
