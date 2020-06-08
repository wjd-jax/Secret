//
//  XMTextField.h
//  XMScreenLockDemo
//
//  Created by sfk-ios on 2018/5/9.
//  Copyright © 2018年 sfk-JasonSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMTextFieldDelegate<UITextFieldDelegate>

@optional
- (void)xmTextFeildDeleteBackward:(UITextField *)textField;
@end

@interface XMTextField : UITextField
@property (nonatomic, weak) id <XMTextFieldDelegate> xmDelegate;
@end
