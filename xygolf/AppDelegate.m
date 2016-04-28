//
//  AppDelegate.m
//  xygolf
//
//  Created by LiuC on 16/3/23.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"
#import "TNPanNavigationController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MobClick.h"
#import "JPUSHService.h"


@interface AppDelegate ()

@property (assign, nonatomic) BOOL  JPushisProduction;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    
//    [MobClick startWithAppkey:UMengAppKey reportPolicy:(ReportPolicy)REALTIME channelId:nil];
    
    //
//    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    
//    UIViewController *logInVC = [mainStory instantiateViewControllerWithIdentifier:@"LogInViewController"];
//    
//    TNPanNavigationController *theNav = [[TNPanNavigationController alloc] initWithRootViewController:logInVC];
//    
//    self.window.rootViewController = theNav;
//    
//    [self.window makeKeyAndVisible];
    _JPushisProduction = YES;
    
    [JPUSHService setupWithOption:launchOptions appKey:JPushKey channel:JPushchannel apsForProduction:_JPushisProduction];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"jpush register fail error:%@",error.localizedDescription);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    __weak typeof(self) weakSelf = self;
    //
    __block UIBackgroundTaskIdentifier bgTask;
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bgTask != UIBackgroundTaskInvalid)
                bgTask = UIBackgroundTaskInvalid;
            //通过判断是否还有组信息来确定是否已经下场，若没有组信息则不启动心跳
//            DataTable *grpInf;// = [[DataTable alloc] init];
//            grpInf = [weakSelf.dbCon ExecDataTable:@"select *from tbl_groupInf"];
            
//            NSLog(@"background1,baIdentifier:%lu",(unsigned long)bgTask);
//            if (![grpInf.Rows count]) {
//                grpInf = nil;
//                return ;
//            }
//            grpInf = nil;
            //重启心跳服务
//            HeartBeatAndDetectState *backGroundHeartbeat = [[HeartBeatAndDetectState alloc] init];
//            [backGroundHeartbeat initHeartBeat];
//            [backGroundHeartbeat enableHeartBeat];
            
        });
        
//        NSLog(@"background2");
        
    }];
    //
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(bgTask != UIBackgroundTaskInvalid)
//                bgTask = UIBackgroundTaskInvalid;
////            NSLog(@"background3");
//        });
////        NSLog(@"background4");
//    });

    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}


@end
