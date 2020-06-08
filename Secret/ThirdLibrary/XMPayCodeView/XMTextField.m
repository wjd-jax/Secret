//
//  XMTextField.m
//  XMScreenLockDemo
//
//  Created by sfk-ios on 2018/5/9.
//  Copyright © 2018年 sfk-JasonSu. All rights reserved.
//

#import "XMTextField.h"

@implementation XMTextField

/// 实现删除方法
- (void)deleteBackward
{
    [super deleteBackward];
    
    BOOL conform = [self.xmDelegate conformsToProtocol:@protocol(XMTextFieldDelegate)];
    BOOL canResponse = [self.xmDelegate respondsToSelector:@selector(xmTextFeildDeleteBackward:)];
    if (self.xmDelegate && conform && canResponse) {
        [self.xmDelegate xmTextFeildDeleteBackward:self];
    }
}

- (void)setXmDelegate:(id<XMTextFieldDelegate>)xmDelegate
{
    _xmDelegate = xmDelegate;
    self.delegate = xmDelegate;
}

@end
