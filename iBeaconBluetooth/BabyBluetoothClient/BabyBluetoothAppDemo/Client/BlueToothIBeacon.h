//
//  BlueToothIBeacon.h
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BTC_didEnterIBeaconMonitor_Noti @"BTC_didEnterIBeaconMonitor_Noti"
#define BTC_didExitIBeaconMonitor_Noti @"BTC_didExitIBeaconMonitor_Noti"

@interface BlueToothIBeacon : NSObject

+ (instancetype)manager;

@end

