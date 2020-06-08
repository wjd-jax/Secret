//
//  JDPasswordManager.m
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//

#import "JDPasswordManager.h"
#import "JDKeyChainWapper.h"

@implementation JDPasswordManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
#pragma mark - getter
- (NSString *)adminPassword {
    return [JDKeyChainWapper loadStringDataWithIdentifier:@"adminPassword"];
}

- (NSString *)guestPassword {
    return [JDKeyChainWapper loadStringDataWithIdentifier:@"guestPassword"];
}

- (NSString *)destroyPassword {
    return [JDKeyChainWapper loadStringDataWithIdentifier:@"destroyPassword"];
}

- (BOOL)isFistLaunch {

    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
}

#pragma mark - setting
- (void)setAdminPassword:(NSString *)adminPassword {

    [JDKeyChainWapper saveStringWithdIdentifier:@"adminPassword" data:adminPassword];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
}
- (void)setGuestPassword:(NSString *)guestPassword {

    [JDKeyChainWapper saveStringWithdIdentifier:@"guestPassword" data:guestPassword];
}
- (void)setDestroyPassword:(NSString *)destroyPassword {

    [JDKeyChainWapper saveStringWithdIdentifier:@"destroyPassword" data:destroyPassword];
}


@end
