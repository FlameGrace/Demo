//
//  BlueToothClient.h
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BTC_Notify_Noti @"BTC_Notify_Noti"
#define BTC_Discon_Noti @"BTC_Discon_Noti"
#define BTC_DidWrite_Noti @"BTC_DidWrite_Noti"
#define BTC_DidRead_Noti @"BTC_DidRead_Noti"

@interface BlueToothClient : NSObject

@property (strong, nonatomic) CBCentralManager *centralManager;


+ (instancetype)manager;

- (void)scanPeripherals;
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;
- (void)cancelScan;

- (BOOL)isConnect;
- (void)writeNewValue;

@end
