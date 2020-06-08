//
//  JDUserModel.m
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "JDUserModel.h"
#import "JDHeader.h"

static JDUserModel *model;

@implementation JDUserModel

+ (instancetype)shareInstance{
    
    JDDISPATCH_ONCE_BLOCK(^{
        model = [[JDUserModel alloc]init];
        model.needLock = YES;
    });
    return model;
}
@end
