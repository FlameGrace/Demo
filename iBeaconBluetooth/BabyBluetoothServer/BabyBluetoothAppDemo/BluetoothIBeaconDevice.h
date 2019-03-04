//
//  BluetoothIBeaconDevice.h
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>


@interface BluetoothIBeaconDevice : NSObject

@property (strong, nonatomic) CLBeaconRegion *ibeacon;

+ (instancetype)manager;

@end
