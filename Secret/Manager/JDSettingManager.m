//
//  JDSettingManager.m
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//

#import "JDSettingManager.h"

@implementation JDSettingManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - getting

- (BOOL)calculatorUnLock {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"calculatorUnLock"];
}

- (BOOL)shakeUnLock {

    return [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeUnLock"];
}

- (BOOL)defaultDeletePhoto {

    return [[NSUserDefaults standardUserDefaults] boolForKey:@"defaultDeletePhoto"];
}

#pragma mark - setting

- (void)setShakeUnLock:(BOOL)shakeUnLock {
    [[NSUserDefaults standardUserDefaults] setBool:shakeUnLock forKey:@"shakeUnLock"];
}

- (void)setCalculatorUnLock:(BOOL)calculatorUnLock {
    [[NSUserDefaults standardUserDefaults] setBool:calculatorUnLock forKey:@"calculatorUnLock"];
}

- (void)setDefaultDeletePhoto:(BOOL)defaultDeletePhoto {
    [[NSUserDefaults standardUserDefaults] setBool:defaultDeletePhoto forKey:@"defaultDeletePhoto"];
}
@end
