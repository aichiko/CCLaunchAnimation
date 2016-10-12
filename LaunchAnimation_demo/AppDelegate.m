//
//  AppDelegate.m
//  LaunchAnimation_demo
//
//  Created by 24hmb on 16/10/11.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CCLaunchAnimation.h"
#import "WKWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    [self launchAnimation];
    
    return YES;
}

- (void)launchAnimation {
    __weak typeof(self) weakSelf = self;
    [CCLaunchAnimation showLaunchViewWithDuration:3 ShowFinish:^{
        //3秒后切换根视图
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            __strong typeof(self) strongSelf = weakSelf;
            weakSelf.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
        });
    } click:^(NSString *url) {
        weakSelf.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
        WKWebViewController *wkWebVC = [[WKWebViewController alloc]init];
        wkWebVC.requestURL = url;
        [(UINavigationController *)weakSelf.window.rootViewController pushViewController:wkWebVC animated:YES];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows)
        {
            if(tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0)
    {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)nextResponder;
            if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
                activityViewController = [nav.viewControllers lastObject];
            } else {
                activityViewController = tab.selectedViewController;
            }
        } else if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)nextResponder;
            activityViewController = [nav.viewControllers lastObject];
        } else if([nextResponder isKindOfClass:[UIViewController class]]){
            activityViewController = nextResponder;
        }else{
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}

@end
