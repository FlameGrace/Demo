//
//  AppDelegate.m
//  LaunchAnimation
//
//  Created by Flame Grace on 2017/11/24.
//  Copyright © 2017年 Flame Grace. All rights reserved.
//
#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:self.window.screen.bounds];
    NSMutableArray* imagess = [NSMutableArray array];
    
    /** 加载图片 */
    for (int i = 1; i <= 90; i++)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pic%d",i] ofType:@"png"];
        if (path.length) {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [imagess addObject:image];
        }
    }
    image.animationImages = imagess;
    image.animationDuration = 4;
    image.animationRepeatCount = 1;
    NSString *lastPath = [[NSBundle mainBundle] pathForResource:@"pic90" ofType:@"png"];
    UIImage *lastImage = [UIImage imageWithContentsOfFile:lastPath];
    image.image = lastImage;
    [self.window addSubview:image];
    [image startAnimating];
    
    [image performSelector:@selector(stopAnimating) withObject:nil afterDelay:4];
    [image performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:4];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
