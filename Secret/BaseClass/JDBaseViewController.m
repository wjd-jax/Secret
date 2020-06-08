//
//  JDBaseViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "JDBaseViewController.h"
#import "JDHeader.h"
@interface JDBaseViewController ()

@end

@implementation JDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JDCOLOR_FROM_RGB_OxFF_ALPHA(0xefeff4, 1);
    // Do any additional setup after loading the view.
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
