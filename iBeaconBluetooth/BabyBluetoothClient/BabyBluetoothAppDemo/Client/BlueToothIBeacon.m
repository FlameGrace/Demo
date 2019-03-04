//
//  BlueToothIBeacon.m
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import "BlueToothIBeacon.h"
#import <CoreLocation/CoreLocation.h>

#define iBeaconMonitorSignal @"E6A38A31-496A-435E-B477-76B6B557A7DE"
#define iBeaconMonitorMajorValue 100
#define iBeaconMonitorMinorValue 101
#define APP_TAG @"iBeacon"


@interface BlueToothIBeacon() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *iBeaconManager;
@property (strong, nonatomic) CLBeaconRegion *ibeacon;

@end

@implementation BlueToothIBeacon


static BlueToothIBeacon *shareManager = nil;

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
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] && !self.iBeaconManager) {
        self.iBeaconManager = [[CLLocationManager alloc]init];
        self.iBeaconManager.delegate = self;
        [self.iBeaconManager requestAlwaysAuthorization];
        if ([self.iBeaconManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            [self.iBeaconManager setAllowsBackgroundLocationUpdates:YES];
        }
        _ibeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:iBeaconMonitorSignal] major:iBeaconMonitorMajorValue minor:iBeaconMonitorMinorValue identifier:@"iBeacon"];
        _ibeacon.notifyEntryStateOnDisplay = YES;
        [self.iBeaconManager startMonitoringForRegion:_ibeacon];
        NSLog(@"%@ GrootiBeaconManager ibeaconManager startMonitoringForRegion",APP_TAG);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"%@ GrootiBeaconManager ibeaconManager didStartMonitoringForRegion",APP_TAG);
}
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"%@ GrootiBeaconManager ibeaconManager didEnterRegion",APP_TAG);
    [[NSNotificationCenter defaultCenter]postNotificationName:BTC_didEnterIBeaconMonitor_Noti object:nil];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%@ GrootiBeaconManager ibeaconManager didExitRegion",APP_TAG);
    [self.iBeaconManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    [[NSNotificationCenter defaultCenter]postNotificationName:BTC_didExitIBeaconMonitor_Noti object:nil];
}
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"%@ GrootiBeaconManager ibeaconManager didRangeBeacons %@",region,APP_TAG);
    if ([[region.proximityUUID UUIDString]isEqualToString:iBeaconMonitorSignal]){
        [self.iBeaconManager stopMonitoringForRegion:region];
        [self.iBeaconManager stopRangingBeaconsInRegion:region];
        NSLog(@"%@ GrootiBeaconManager ibeaconManager didRangeBeacons",APP_TAG);
        [[NSNotificationCenter defaultCenter]postNotificationName:BTC_didEnterIBeaconMonitor_Noti object:nil];
    }
}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if(state == CLRegionStateInside)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:BTC_didEnterIBeaconMonitor_Noti object:nil];
    }
    if(state == CLRegionStateOutside)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:BTC_didExitIBeaconMonitor_Noti object:nil];
    }
    NSLog(@"%@ GrootiBeaconManager ibeaconManager didDetermineState %ld",APP_TAG,(long)state);
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ibeaconManager monitoringDidFailForRegion:%@", error);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ibeaconManager Location manager failed:%@", error);
}
    

@end
