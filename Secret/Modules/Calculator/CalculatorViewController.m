//
//  CalculatorViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/9.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculateMethod.h"
#import "JDAlertViewManager.h"
#import "JDKeyChainWapper.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "JDHeader.h"
#import "JDUserModel.h"
#import "JDPasswordManager.h"

@interface CalculatorViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;   //算数显示
@property (weak, nonatomic) IBOutlet UILabel *equationLabel; //结果显示

@property (copy, nonatomic) NSString *password1; //密码1
@property (copy, nonatomic) NSString *password2; //密码2

@property (nonatomic, retain) CalculateMethod *calMethod;

@property (nonatomic, assign) BOOL isDecimal; //是否小数
@property (nonatomic, assign) BOOL isResult;  //是否是结果

@property (nonatomic, assign) float currentNumber; //当前数字
@property (nonatomic, assign) float lastResult;    //当前数字

@property (nonatomic, assign) NSInteger hanleTag; //操作符 '/'=201 'x'=202 '+'=203 '-'=204

@property (copy, nonatomic) NSString *turePassword; //真实密码
@property (copy, nonatomic) NSString *fakePassword; //伪装密码

@end

@implementation CalculatorViewController
#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _calMethod = [[CalculateMethod alloc] init];
    // 设置允许摇一摇功能
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    // 并让自己成为第一响应者
    [self becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _turePassword = [JDPasswordManager sharedInstance].adminPassword;
    _fakePassword = [JDPasswordManager sharedInstance].guestPassword;
}

#pragma mark - handle
//取反
- (IBAction)negation:(UIButton *)sender {

    _resultLabel.text = [NSString stringWithFormat:@"%@", @(0 - _resultLabel.text.floatValue)];
}

//运算符输入
- (IBAction)handleClick:(UIButton *)sender {

    _isDecimal = NO;
    _lastResult = _resultLabel.text.floatValue;
    _hanleTag = sender.tag;
    _resultLabel.text = @"0";
}
//小数点
- (IBAction)doClick:(UIButton *)sender {

    if (_isDecimal) {
        return;
    } else {
        _isDecimal = YES;
        _resultLabel.text = [_resultLabel.text stringByAppendingString:@"."];
    }
}

//清除
- (IBAction)clearClick:(UIButton *)sender {

    [_calMethod clear];

    _isDecimal = NO;
    _hanleTag = 0;
    _resultLabel.text = @"0";

    _equationLabel.text = @"";
}

#pragma mark - 百分号,判断是否是用户密码
- (IBAction)percentClick:(UIButton *)sender {

    if ([_resultLabel.text isEqualToString:_turePassword]
        || [_resultLabel.text isEqualToString:_fakePassword]) {
        [self changeToHome];
        return;
    }

    _resultLabel.text = [NSString stringWithFormat:@"%@", @(_resultLabel.text.floatValue / 100)];

    NSRange range = [_resultLabel.text rangeOfString:@"."];
    if (range.location != NSNotFound) {
        _isDecimal = YES;
    }
}

#pragma mark - 数字输入
- (IBAction)numberClick:(UIButton *)sender {

    //超过位数不能继续输入
    if (_resultLabel.text.length > 15) {
        return;
    }
    if ([_resultLabel.text isEqualToString:@"0"] || _isResult) {
        _resultLabel.text = @"";
        if (_isResult) {
            _isResult = NO;
        }
    }

    _resultLabel.text = [_resultLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", @(sender.tag - 100)]];
    _currentNumber = _resultLabel.text.floatValue;

    if (([_resultLabel.text isEqualToString:_turePassword]
         || [_resultLabel.text isEqualToString:_fakePassword])) {

        [self changeToHome];
        return;
    }
}

#pragma mark - 结果
- (IBAction)resultClick:(UIButton *)sender {

    if (_hanleTag == 0) return;

    _calMethod.operand1 = _lastResult;
    _calMethod.operand2 = _currentNumber;
    _resultLabel.text = [_calMethod performOperation:(int) _hanleTag];
    UIButton *button = [self.view viewWithTag:_hanleTag];
    _equationLabel.text = [NSString stringWithFormat:@"%@ %@ %@ =", @(_lastResult), button.titleLabel.text, @(_currentNumber)];
    _currentNumber = 0;
    _lastResult = 0;
    _hanleTag = 0;
    _isResult = YES;
}

- (void)changeToHome {

    [JDUserModel shareInstance].isAdimnUser = [_resultLabel.text isEqualToString:_turePassword];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    self.view.window.rootViewController = ctrl;
}

#pragma mark - 开始摇动
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"touchID"]) {
        LAContext *context = [[LAContext alloc] init];
        LAPolicy lapolicy = LAPolicyDeviceOwnerAuthentication;
        [context evaluatePolicy:lapolicy
                localizedReason:@"使用快速进入应用验证"
                          reply:^(BOOL success, NSError *_Nullable error) {
                              if (success) {
                                  JDDISPATCH_MAIN_THREAD(^{
                                      [self changeToHome];
                                      [JDUserModel shareInstance].isAdimnUser = YES;
                                  });
                              }
                          }];
    }
}

@end
