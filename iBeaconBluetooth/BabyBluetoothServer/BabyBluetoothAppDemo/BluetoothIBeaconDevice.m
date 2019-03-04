//
//  BluetoothIBeaconDevice.m
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import "BluetoothIBeaconDevice.h"
//#define iBeaconMonitorSignal @"E6A38A31-496A-435E-B477-76B6B557A7DE"
#define iBeaconMonitorSignal @"E6A38A31-496A-435E-B477-76B6B557A7DE"
#define iBeaconMonitorMajorValue 100
#define iBeaconMonitorMinorValue 101

@interface BluetoothIBeaconDevice()

@end

@implementation BluetoothIBeaconDevice


static BluetoothIBeaconDevice *shareManager = nil;

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc]init];
    });
    return shareManager;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self initManager];
    }
    return self;
}


- (void)initManager{
    _ibeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:iBeaconMonitorSignal] major:iBeaconMonitorMajorValue minor:iBeaconMonitorMinorValue identifier:@"iBeacon"];
}

@end
