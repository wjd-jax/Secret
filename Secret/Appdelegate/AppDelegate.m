//
//  AppDelegate.m
//  私人保险柜
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "AppDelegate.h"
#import "JDUserModel.h"
#import "CalculatorViewController.h"
#import "UMMobClick/MobClick.h"
#import "define.h"
#import "JDSettingManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //    [JDUserModel shareInstance].isAdimnUser = YES;
    UMConfigInstance.appKey = UMENG_APPKEY;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance]; //配置以上参数后调用此方法初始化SDK！

    if ([JDSettingManager sharedInstance].calculatorUnLock) {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *root = [storyboard instantiateViewControllerWithIdentifier:@"CalculatorViewController"];
        self.window.rootViewController = root;
    }

    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    //如果开启了计算器
    if ([JDSettingManager sharedInstance].calculatorUnLock) {
        
        UIViewController *root = [storyboard instantiateViewControllerWithIdentifier:@"CalculatorViewController"];
        self.window.rootViewController = root;
        
    } else {
        
        UIViewController *root = [storyboard instantiateViewControllerWithIdentifier:@"JDPasswordViewController"];
        self.window.rootViewController = root;

    }
}


@end
