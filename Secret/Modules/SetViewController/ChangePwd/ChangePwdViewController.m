//
//  ChangePwdViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/11.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "JDKeyChainWapper.h"
#import "JDAlertViewManager.h"

@interface ChangePwdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (copy, nonatomic) NSString *oldPassWor;
@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_passwordTextField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (IBAction)returnClick:(UIBarButtonItem *)sender {
    
    if ([_verifyLabel.text isEqualToString:@"验证原密码"]) {
        NSString *oldPass = [JDKeyChainWapper loadStringDataWithIdentifier:@"password"];
        if([oldPass isEqualToString:_passwordTextField.text]){
            _passwordTextField.text =@"";
            _verifyLabel.text = @"输入新密码";
            _passwordTextField.placeholder =@"输入4-8位新密码";
        }
        else
        {
            _passwordTextField.text =@"";
            _verifyLabel.text = @"验证原密码";
            _passwordTextField.placeholder =@"密码错误,请重新输入";
        }
    }
    else
    {
        if (_passwordTextField.text.length>=4&&_passwordTextField.text.length<=8) {
            
            if ([_passwordTextField.text hasPrefix:@"0"]) {
                _passwordTextField.text =@"";
                _passwordTextField.placeholder =@"请不要用0开头";
                return;
            }
            [JDKeyChainWapper saveStringWithdIdentifier:@"password"
                                                   data:_passwordTextField.text];
            [self.navigationController popViewControllerAnimated:YES];
            
            [JDAlertViewManager alertWithTitle:@"修改密码成功!" message:_passwordTextField.text textFieldNumber:0 actionNumber:1 actionTitles:@[@"确认"] textFieldHandler:nil actionHandler:^(UIAlertAction *action, NSUInteger index) {
            }];
        }
        else
        {
            _passwordTextField.text =@"";
            _passwordTextField.placeholder =@"新密码长度错误!";
        }
    }
}





@end
