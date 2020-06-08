//
//  JDUserModel.h
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDUserModel : NSObject

@property(nonatomic,assign)BOOL isAdimnUser;    //是否是管理用户
@property(nonatomic,assign)BOOL needLock;       //是否开启指纹登录

+ (instancetype)shareInstance;

@end
