//
//  JDPasswordViewController.h
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//

#import "JDBaseViewController.h"

typedef NS_ENUM(NSUInteger, PasswordType) {
    PasswordType_UnLock,        //解锁
    PasswordType_Change,        //修改密码
    PasswordType_GuestPassword, //访客密码
};

@interface JDPasswordViewController : JDBaseViewController

@property (nonatomic, assign) PasswordType type; // 1>修改密码,2>设置伪装密码

@end
