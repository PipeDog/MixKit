//
//  MKAppDelegate.m
//  MixKit
//
//  Created by liang on 06/08/2021.
//  Copyright (c) 2021 liang. All rights reserved.
//

#import "MKAppDelegate.h"
#import <MKPerfMonitor.h>
#import <MKConsoleWindow.h>
#import "MKLogger.h"

@interface MKAppDelegate () <MKPerfMonitorDelegate>

@end

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[MKPerfMonitor defaultMonitor] bind:self];
    
    MKConsoleWindow *consoleWindow = [MKConsoleWindow sharedInstance];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [consoleWindow show];
    });
    
    return YES;
}

- (void)perfMonitor:(MKPerfMonitor *)perfMonitor flushAllPerfRecords:(NSArray<NSDictionary *> *)perfRecords
{
    NSLog(@"%@", perfRecords);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
