//
//  JDPasswordViewController.m
//  Secret
//
//  Created by 王军东 on 2018/11/19.
//  Copyright © 2018 wangjundong. All rights reserved.
//

#import "JDPasswordViewController.h"
#import "XMPayCodeView.h"
#import "JDPasswordManager.h"
#import "define.h"
#import "JDAlertViewManager.h"
#import "JDUserModel.h"

@interface JDPasswordViewController ()

@property (nonatomic, strong) XMPayCodeView *payCodeView; // 密码输入框
@property (nonatomic, strong) UILabel *tipLabel;          // 说明
@property (nonatomic, strong) UIButton *sureBtn;          // 确定按钮

@property (assign, nonatomic) BOOL isSetPassword; //是否是设置密码的状态

@end

@implementation JDPasswordViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.payCodeView];
    [self.view addSubview:self.sureBtn];

    JDWeakSelf(self);

    //回调
    [self.payCodeView setPayBlock:^(NSString *payCode) {

        // 完成输入
        if (payCode.length == 6) {

            switch (weakself.type) {

            case PasswordType_Change: {

                if ([payCode isEqualToString:[JDPasswordManager sharedInstance].adminPassword]) {

                    weakself.tipLabel.text = @"请输入新密码";
                    [weakself.payCodeView clear];
                    weakself.type = PasswordType_UnLock;
                    weakself.isSetPassword = YES;
                    weakself.payCodeView.secureTextEntry = NO;
                    weakself.sureBtn.enabled = NO;
                    weakself.sureBtn.backgroundColor = [UIColor lightGrayColor];

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakself.payCodeView becomeKeyBoardFirstResponder];
                    });
                } else {
                    weakself.tipLabel.text = @"密码错误!请重试";
                    [weakself.payCodeView clear];
                }
            } break;
            case PasswordType_GuestPassword: {
                weakself.sureBtn.enabled = YES;
                weakself.sureBtn.backgroundColor = [UIColor orangeColor];
            } break;
            default: {
                //设置状态
                if (weakself.isSetPassword) {

                    weakself.sureBtn.hidden = NO;
                    weakself.sureBtn.enabled = YES;
                    weakself.sureBtn.backgroundColor = [UIColor orangeColor];

                } else {

                    //验证
                    if ([payCode isEqualToString:[JDPasswordManager sharedInstance].adminPassword]) {
                        [weakself enter];
                    } else {
                        weakself.tipLabel.text = @"密码错误,请重试!";
                        [weakself.payCodeView clear];
                    }
                }
            } break;
            }

        } else {
            weakself.sureBtn.enabled = NO;
            weakself.sureBtn.backgroundColor = [UIColor lightGrayColor];
        }

    }];

    // 1秒后，让密码输入成为第一响应
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.payCodeView becomeKeyBoardFirstResponder];
    });
}

- (void)viewWillAppear:(BOOL)animated {

    _isSetPassword = [JDPasswordManager sharedInstance].isFistLaunch;

    if (_isSetPassword) {
        self.tipLabel.text = @"初次使用,请先设置保险柜密码!";
        self.payCodeView.secureTextEntry = NO; // 设置明文
        self.sureBtn.hidden = NO;
    } else {
        self.tipLabel.text = @"请输入密码";
        self.payCodeView.secureTextEntry = NO; // 设置暗文
        self.sureBtn.hidden = YES;
    }
    //    self.payCodeView.endEditingOnFinished = YES; // 完成输入，退出键盘

    //修改密码和设置伪装密码
    switch (self.type) {

    case PasswordType_GuestPassword: {
        self.title = @"设置伪装密码";
        self.tipLabel.text = @"请输入伪装密码";
        self.payCodeView.secureTextEntry = NO; // 设置明文
        self.sureBtn.hidden = NO;
    } break;
    case PasswordType_Change: {
        self.title = @"修改密码";
        self.tipLabel.text = @"请输入原密码";
        self.payCodeView.secureTextEntry = YES; // 设置明文
        self.sureBtn.hidden = YES;
    } break;
    default:

        break;
    }
}

- (void)sureBtnClick:(UIButton *)btn {

    if (self.type == PasswordType_GuestPassword) {

        [JDPasswordManager sharedInstance].guestPassword = self.payCodeView.payCode;
        UIAlertController *alet = [UIAlertController alertControllerWithTitle:@"设置成功" message:@"伪装密码可以任意修改" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {

                                                        [self.navigationController popViewControllerAnimated:YES];
                                                    }];
        [alet addAction:act];
        [self presentViewController:alet animated:YES completion:nil];

    } else {

        NSString *pass = [NSString stringWithFormat:@"确认密码:%@", self.payCodeView.payCode];

        UIAlertController *alet = [UIAlertController alertControllerWithTitle:pass message:@"忘记密码后不可找回,请牢记!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {

                                                        self.tipLabel.text = @"设置成功,请验证密码进入";
                                                        [JDPasswordManager sharedInstance].adminPassword = self.payCodeView.payCode;
                                                        _isSetPassword = [JDPasswordManager sharedInstance].isFistLaunch;
                                                        [self.payCodeView clear];
                                                    }];

        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action) {

                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self.payCodeView clear];
                                                              });

                                                          }];
        [alet addAction:act];
        [alet addAction:cancelAct];

        [self presentViewController:alet animated:YES completion:nil];
    }
}

- (void)enter {

    [JDUserModel shareInstance].isAdimnUser = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    self.view.window.rootViewController = ctrl;
}

#pragma mark - lazy
- (UILabel *)tipLabel {

    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
        _tipLabel.text = @"";
        _tipLabel.font = [UIFont boldSystemFontOfSize:18];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (XMPayCodeView *)payCodeView {
    if (!_payCodeView) {
        _payCodeView = [[XMPayCodeView alloc] initWithFrame:CGRectMake(0, 180, self.view.bounds.size.width, 60)];
    }
    return _payCodeView;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        // 确定按钮
        _sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.payCodeView.frame) + 60, self.view.bounds.size.width - 100, 50)];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        _sureBtn.backgroundColor = [UIColor lightGrayColor];
        [_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.layer.cornerRadius = 4;
        _sureBtn.enabled = NO;
    }
    return _sureBtn;
}

-(void)dealloc{
    
}
@end
