//
//  AppDelegate.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/1.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "BabyBluetooth.h"
#import "BlueToothClient.h"
#import "BlueToothIBeacon.h"

#define iBeaconMonitorSignal @"E6A38A31-496A-435E-B477-76B6B557A7DE"
#define iBeaconMonitorMajorValue 100
#define iBeaconMonitorMinorValue 101

@interface AppDelegate()<CLLocationManagerDelegate>

@property (assign, nonatomic) double ac;
@property (assign, nonatomic) NSNumber *isEnter;
@property (assign, nonatomic) BOOL outLine;

@end

@implementation AppDelegate
{
    UINavigationController *_rootViewController;
    CLLocationManager *_locationManager;
    CLBeaconRegion *_ibeacon;
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self writeDataString:@"didExitRegion"];
    [self didExitIBeaconMonitor:0];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region
{
    [self writeDataString:@"didEnterRegion"];
    [self didEnterIBeaconMonitor:0];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    if([region.proximityUUID.UUIDString isEqual:iBeaconMonitorSignal])
    {
        CLBeacon *beacon = beacons.firstObject;
        [self didEnterIBeaconMonitor:beacon.accuracy];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    [self writeDataString:@"didDetermineState"];
    if(state == CLRegionStateInside)
    {
        [self didEnterIBeaconMonitor:-1];
    }
    if(state == CLRegionStateOutside)
    {
        [self didExitIBeaconMonitor:-1];
    }
}

- (void)setOutLine:(BOOL)outLine
{
    if( outLine == _outLine)
    {
        return;
    }
    _outLine = outLine;
    if(outLine)
    {
        self.isEnter = @(0);
        [self showNotifiState:-1];
    }
}

- (void)setIsEnter:(NSNumber *)isEnter
{
    if(_isEnter == isEnter)
    {
        return;
    }
    _isEnter = isEnter;
    [self showNotifiState:isEnter.integerValue];
    if(isEnter)
    {
        [self poweredOn];
    }
}

- (void)didEnterIBeaconMonitor:(double)didDetermineState
{
    self.isEnter = @(1);
    double ac = self.ac;
    self.ac = didDetermineState;
    if((ac != -1 && ac!=0 )&&(didDetermineState == -1 || didDetermineState==0 ))
    {
        self.outLine = YES;
    }
    else
    {
        self.outLine = NO;
        [_locationManager startRangingBeaconsInRegion:_ibeacon];
    }
}

- (void)didExitIBeaconMonitor:(double)didDetermineState
{
    self.isEnter = @(0);
}

- (void)showNotifiState:(NSInteger)state
{
    UILocalNotification *lo = [[UILocalNotification alloc]init];
    
    if(state == 1)
    {
        lo.alertBody = @"进入";
    }
    if(state == 0)
    {
        lo.alertBody = @"出来";
    }
    if(state == -1)
    {
        lo.alertBody = @"离线";
    }
    lo.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    [[UIApplication sharedApplication] scheduleLocalNotification:lo];
    [self writeDataString:lo.alertBody];
}

- (void)writeDataString:(NSString *)date
{
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[self recordPath]];
    [handle seekToEndOfFile];
    NSString *now = [NSString stringWithFormat:@"%@：%@\n",date,[self nowDate]];
    [handle writeData:[now dataUsingEncoding:NSUTF8StringEncoding]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIUserNotificationSettings *st = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication]registerUserNotificationSettings:st];
    
    [self poweredOn];
    // This location manager will be used to notify the user of region state transitions.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    [_locationManager requestAlwaysAuthorization];
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    _ibeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:iBeaconMonitorSignal] major:iBeaconMonitorMajorValue minor:iBeaconMonitorMinorValue identifier:@"iBeacon"];
    _ibeacon.notifyEntryStateOnDisplay = YES;
    _ibeacon.notifyOnExit = YES;
    _ibeacon.notifyOnEntry = YES;
    [_locationManager startMonitoringForRegion:_ibeacon];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(poweredOn) name:BabyNotificationAtCentralManagerEnable object:nil];
    
    return YES;
}


- (void)poweredOn
{
    [[BlueToothClient manager] scanPeripherals];

}

- (NSString *)recordPath
{
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.txt"];
    if(![[NSFileManager defaultManager]fileExistsAtPath:file])
    {
        [[@"创建\n" dataUsingEncoding:NSUTF8StringEncoding] writeToFile:file atomically:YES];
    }
    return file;
}

- (NSString *)nowDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:[NSDate date]];
}





@end
