//
//  ViewController.m
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import "ViewController.h"
#import "BabyPeripheralManager.h"
#import "BluetoothIBeaconDevice.h"

@interface ViewController ()

@property BabyPeripheralManager *peripheralManager;
@property (weak, nonatomic) IBOutlet UITextView *conTextView;
@property (weak, nonatomic) IBOutlet UITextView *writeTextView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isBeacon;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeAdvertisingData) userInfo:nil repeats:YES];
    [self.timer fire];
    // Do any additional setup after loading the view.
    self.peripheralManager = [[BabyPeripheralManager alloc]init];
    CBMutableService *service = makeCBService(@"FFE0");
    makeCharacteristicToService(service, @"FFE1", @"rwn", @"hhhh");
    self.peripheralManager.addServices(@[service]);
    self.peripheralManager.startAdvertising();
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRead) name:BTS_Read_Noti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCon) name:BTS_Con_Noti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didDiscon) name:BTS_DisCon_Noti object:nil];
    
}

- (void)changeAdvertisingData
{
    if(self.isBeacon)
    {
        self.isBeacon = NO;
        self.peripheralManager.startAdvertising();
    }
    else
    {
        self.isBeacon = YES;
        NSDictionary *peripheraData = [[BluetoothIBeaconDevice manager].ibeacon peripheralDataWithMeasuredPower:nil];
        [self.peripheralManager.peripheralManager startAdvertising:peripheraData];
    }
}

- (void)didRead
{
    NSString *d = [NSString stringWithFormat:@"有写入请求%@",[self nowDate]];
    self.writeTextView.text = d;
}

- (void)didCon
{
    NSString *d = [NSString stringWithFormat:@"有订阅%@",[self nowDate]];
    self.conTextView.text = d;
}

- (void)didDiscon
{
    NSString *d = [NSString stringWithFormat:@"无订阅%@",[self nowDate]];
    self.conTextView.text = d;
}


- (NSString *)nowDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:[NSDate date]];
}


@end
