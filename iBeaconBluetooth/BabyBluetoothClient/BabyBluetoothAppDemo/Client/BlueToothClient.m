//
//  BlueToothClient.m
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import "BlueToothClient.h"


@interface BlueToothClient() <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *characteristic;
@property (strong, nonatomic) NSMutableArray *peripherals;

@end

@implementation BlueToothClient

static BlueToothClient *shareManager = nil;
static NSInteger btc_indexs = 0;

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc]init];
    });
    return shareManager;
}

- (instancetype)init {
    if (self = [super init] )
    {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 //蓝牙power没打开时alert提示框
                                 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                                 //重设centralManager恢复的IdentifierKey
                                 @"babyBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                                 nil];
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
        
        
        
    }
    return  self;
    
}

- (BOOL)isConnect
{
    if(self.peripheral)
    {
        return YES;
    }
    return NO;
}


- (void)writeNewValue
{
    if(self.isConnect)
    {
        NSInteger d =  btc_indexs ++;
        NSString *da = [NSString stringWithFormat:@"%@, date:%@",@(d),[[NSDate date]description]];
        NSLog(@"开始写入：%@",da);
        [self.peripheral writeValue:[da dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (NSMutableArray *)peripherals
{
    if(!_peripherals)
    {
        _peripherals = [[NSMutableArray alloc]init];
    }
    return _peripherals;
}

//扫描Peripherals
- (void)scanPeripherals {
    if([self isConnect]||self.centralManager.isScanning)
    {
        return;
    }
    [self writeDataString:@"开始扫描"];
    NSLog(@"开始扫描");
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFE0"];
    [self.centralManager scanForPeripheralsWithServices:@[uuid] options:nil];
}

//连接Peripherals
- (void)connectToPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"开始连接");
    [self writeDataString:@"开始连接"];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

//断开设备连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    NSLog(@"开始断开连接");
    [self writeDataString:@"开始断开连接"];
    [self.centralManager cancelPeripheralConnection:peripheral];
}


//停止扫描
- (void)cancelScan {
    NSLog(@"开始停止扫描");
    [self writeDataString:@"开始停止扫描"];
    [self.centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate委托方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BabyNotificationAtCentralManagerDidUpdateState" object:@{@"central":central}];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BabyNotificationAtCentralManagerEnable" object:@{@"central":central}];
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"willRestoreState:%@",dict);
}

//扫描到Peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //日志
    NSLog(@"当扫描到设备:%@,advertisementData:%@",peripheral.name,advertisementData);
    [self writeDataString:[NSString stringWithFormat:@"当扫描到设备:%@,advertisementData:%@",peripheral.name,advertisementData]];
    [self.peripherals addObject:peripheral];
    [self connectToPeripheral:peripheral];
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //设置委托
    [peripheral setDelegate:self];
    [self writeDataString:[NSString stringWithFormat:@">>>连接到名称为（%@）的设备-成功",peripheral.name]];
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFE0"];
    [peripheral discoverServices:@[uuid]];
    
}

//连接到Peripherals-失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@">>>连接失败：%@，错误：%@",peripheral.name,error);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //发出通知
    NSLog(@">>> didDisconnectPeripheral for %@ with error: %@", peripheral.name, [error localizedDescription]);
  if(self.peripheral && [peripheral isEqual:peripheral])
  {
      self.peripheral = nil;
      self.characteristic = nil;
      btc_indexs = 0;
      [[NSNotificationCenter defaultCenter]postNotificationName:BTC_Discon_Noti object:nil];
      [self scanPeripherals];
  }
    
}

//扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSLog(@">>>didDiscoverServices for %@ with error: %@", peripheral.name, [error localizedDescription]);
    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqual:@"FFE0"])
        {
            CBUUID *uuid = [CBUUID UUIDWithString:@"FFE1"];
            [peripheral discoverCharacteristics:@[uuid] forService:service];
        }
    }
}

//发现服务的Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSLog(@"error didDiscoverCharacteristicsForService for %@ with error: %@", service.UUID, [error localizedDescription]);
    if(!error)
    {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if([[characteristic UUID].UUIDString isEqualToString:@"FFE1"])
            {
                if(!self.peripheral)
                {
                    [self cancelScan];
                    NSLog(@"已扫描到设备");
                    [self writeDataString:@"已扫描到设备"];
                    self.peripheral = peripheral;
                    self.characteristic = characteristic;
                    [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    [self.peripherals removeAllObjects];
                }
            }
        }
    }
}

//读取Characteristics的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"error didUpdateValueForCharacteristic %@ with error: %@", characteristic.UUID, [error localizedDescription]);
    [[NSNotificationCenter defaultCenter]postNotificationName:BTC_DidRead_Noti object:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [self writeDataString:@"写入数据"];
        NSLog(@">>>uuid:%@,写入数据:%@",characteristic.UUID,characteristic.value);
    [[NSNotificationCenter defaultCenter]postNotificationName:BTC_DidWrite_Noti object:nil];
    
}


//characteristic.isNotifying 状态改变
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@">>>uuid:%@,订阅结果:%@",characteristic.UUID,characteristic.isNotifying?@"isNotifying":@"Notifying");
    if(characteristic.isNotifying && !error)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:BTC_Notify_Noti object:nil];
        [self writeNewValue];
    }

}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"peripheralDidUpdateName:%@",peripheral.name);
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"didModifyServices:%@",invalidatedServices);
}


- (NSString *)nowDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:[NSDate date]];
}


- (void)writeDataString:(NSString *)date
{
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[self recordPath]];
    [handle seekToEndOfFile];
    NSString *now = [NSString stringWithFormat:@"%@：%@\n",date,[self nowDate]];
    [handle writeData:[now dataUsingEncoding:NSUTF8StringEncoding]];
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

@end
