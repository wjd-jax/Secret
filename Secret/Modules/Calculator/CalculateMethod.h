//
//  CalculateMethod.h
//  Secret
//
//  Created by wangjundong on 2017/8/9.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateMethod : NSObject

@property(nonatomic,assign)float operand1,operand2,result;

- (NSString *)performOperation:(int)input;
- (void)clear;

@end
