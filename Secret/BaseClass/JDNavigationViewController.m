//
//  JDNavigationViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "JDNavigationViewController.h"
#import "JDHeader.h"

@interface JDNavigationViewController ()

@end

@implementation JDNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (void)initialize {
    //appearance方法返回一个导航栏的外观对象
    //修改了这个外观对象，相当于修改了整个项目中的外观
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    //设置导航栏背景颜色
    [navigationBar setBarTintColor:JDCOLOR_FROM_RGB_OxFF_ALPHA(0x28282A,0.8)];
    [navigationBar setTintColor:[UIColor whiteColor]];
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]};


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
