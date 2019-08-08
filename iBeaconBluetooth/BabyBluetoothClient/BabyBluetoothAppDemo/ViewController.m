//
//  ViewController.m
//  BabyBluetoothAppDemo
//
//  Created by MAC on 2019/2/26.
//  Copyright © 2019 刘彦玮. All rights reserved.
//

#import "ViewController.h"
#import "BlueToothClient.h"

@interface ViewController ()<UIDocumentInteractionControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextView *notifyTextView;
@property (weak, nonatomic) IBOutlet UITextView *didwriteTextView;
@property (weak, nonatomic) IBOutlet UITextView *didReadTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didNotify) name:BTC_Notify_Noti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didDiscon) name:BTC_Discon_Noti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRead) name:BTC_DidRead_Noti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didWrite) name:BTC_DidWrite_Noti object:nil];
//    if([BlueToothClient manager].isConnect)
//    {
//        [self didNotify];
//    }
}

- (void)didNotify
{
    self.notifyTextView.text = @"已经订阅";
}

- (void)didDiscon
{
    self.notifyTextView.text = @"已经断开连接";
}

- (void)didRead
{
    NSString *da = [NSString stringWithFormat:@"读取日期:%@",[[NSDate date]description]];
    self.didReadTextView.text = da;
}

- (void)didWrite
{
    NSString *da = [NSString stringWithFormat:@"写入日期:%@",[[NSDate date]description]];
    self.didwriteTextView.text = da;
}

- (IBAction)write:(id)sender {
    
    NSInteger d = 0;
    while (d<1000) {
        d++;
        [[BlueToothClient manager]writeNewValue];
    }
}


- (IBAction)reviewRecord:(id)sender {
    
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.txt"]];
    UIDocumentInteractionController *docVc = [UIDocumentInteractionController interactionControllerWithURL:url];
    docVc.delegate = self;
    [docVc presentPreviewAnimated:YES];
}

- (IBAction)removeRecord:(id)sender {
    
    [[NSFileManager defaultManager]removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.txt"] error:nil];
}

#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

@end
