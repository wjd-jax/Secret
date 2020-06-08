//
//  JDPasswordManager.h
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//  密码管理类

#import <Foundation/Foundation.h>

@interface JDPasswordManager : NSObject

@property (copy, nonatomic) NSString *adminPassword;   //管理员密码
@property (copy, nonatomic) NSString *guestPassword;   //客人密码(伪装)
@property (copy, nonatomic) NSString *destroyPassword; //清空密码

@property (nonatomic, assign) BOOL isFistLaunch;       //是否是初始化状态

/**
 初始化
 */
+ (instancetype)sharedInstance;

@end
