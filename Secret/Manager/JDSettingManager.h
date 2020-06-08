//
//  JDSettingManager.h
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDSettingManager : NSObject

@property (nonatomic, assign) BOOL defaultDeletePhoto; //是否默认删除源文件
@property (nonatomic, assign) BOOL calculatorUnLock;   //是否开启计算器页面
@property (nonatomic, assign) BOOL shakeUnLock;        //摇一摇解锁

+ (instancetype)sharedInstance;

@end
