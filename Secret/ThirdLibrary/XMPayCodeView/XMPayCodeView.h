//
//  XMPayCodeView.h
//  XMScreenLockDemo
//
//  Created by sfk-ios on 2018/5/9.
//  Copyright © 2018年 sfk-JasonSu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PayCodeBlock)(NSString *payCode);

@interface XMPayCodeView : UIView

+ (instancetype)payCodeView;

/// 设置是否暗文显示
@property (assign, nonatomic) BOOL secureTextEntry;
/// 最后一位输入完成时，是否退下键盘
@property (assign, nonatomic) BOOL endEditingOnFinished;
/// 支付密码
@property (copy, nonatomic, readonly) NSString *payCode;
/// 输入完成block
@property (copy, nonatomic) PayCodeBlock payBlock;

/******** method ********/
/// 让第一格成为键盘响应者
- (void)becomeKeyBoardFirstResponder;
- (void)clear;
@end
