//
//  SettingViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "SettingViewController.h"
#import "JDHeader.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "JDUserModel.h"
#import <StoreKit/StoreKit.h>
#import "JDAlertViewManager.h"
#import "JDKeyChainWapper.h"
#import <UShareUI/UShareUI.h>
#import "UMSocialCore/UMSocialCore.h"
#import "JDUMShareManager.h"
#import "JDSettingManager.h"
#import "JDPasswordViewController.h"

@interface SettingViewController () <SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *defaultDeletePhotoSwitch; //是否默认删除文件
@property (weak, nonatomic) IBOutlet UISwitch *calcuterSwitch;           //摇一摇
@property (weak, nonatomic) IBOutlet UISwitch *sharkSwitch;

@property (nonatomic, retain) SKStoreProductViewController *storeProductViewController;
@property (nonatomic, assign) NSInteger selectItem;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sharkSwitch.on = [JDSettingManager sharedInstance].shakeUnLock;
    _defaultDeletePhotoSwitch.on = [JDSettingManager sharedInstance].defaultDeletePhoto;
    _calcuterSwitch.on = [JDSettingManager sharedInstance].calculatorUnLock;

    // Do any additional setup after loading the view.
}

- (IBAction)defaultDeletePhotoSwitchChange:(UISwitch *)sender {

    [JDSettingManager sharedInstance].defaultDeletePhoto = sender.on;
}

- (IBAction)calcuterSwitchChanged:(UISwitch *)sender {

    [JDSettingManager sharedInstance].calculatorUnLock = sender.on;
}

- (IBAction)sharkSwitchChanged:(UISwitch *)sender {

    if (sender.on) {
        [JDUserModel shareInstance].needLock = NO;
        LAContext *context = [[LAContext alloc] init];
        LAPolicy lapolicy = LAPolicyDeviceOwnerAuthentication;
        [context evaluatePolicy:lapolicy
                localizedReason:@"开启摇一摇快速进入应用需要验证您的指纹"
                          reply:^(BOOL success, NSError *_Nullable error) {
                              if (success) {

                                  JDDISPATCH_MAIN_THREAD(^{
                                      [JDUserModel shareInstance].needLock = YES;
                                      [JDSettingManager sharedInstance].shakeUnLock = sender.on;
                                  });
                              } else {
                                  JDDISPATCH_MAIN_THREAD(^{
                                      sender.on = NO;
                                      [JDUserModel shareInstance].needLock = YES;
                                  });
                              }
                          }];
    } else {

        [JDSettingManager sharedInstance].shakeUnLock = sender.on;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [JDUserModel shareInstance].isAdimnUser ? 3 : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"给我评分"]) {
        if (iOS10_3)
        //至此就实现在App内直接评论了。然而需要注意的是：打开次数一年不能多于3次。（当然开发期间可以无限制弹出，方便测试）
        {
            [SKStoreReviewController requestReview];
            return;
        } else {
            _storeProductViewController = [[SKStoreProductViewController alloc] init];
            _storeProductViewController.delegate = self;

            [_storeProductViewController loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier: KAPPID }
                completionBlock:^(BOOL result, NSError *_Nullable error) {

                    JDDISPATCH_MAIN_THREAD(^{
                        [self presentViewController:_storeProductViewController animated:YES completion:nil];
                    });
                }];
        }
    } else if ([cell.textLabel.text isEqualToString:@"伪装密码"] || [cell.textLabel.text isEqualToString:@"修改密码"]) {

        _selectItem = indexPath.item;

        [self performSegueWithIdentifier:@"setPassword" sender:nil];
    
    }
    if ([cell.textLabel.text isEqualToString:@"分享"]) {

        /* 设置友盟appkey */
        [[UMSocialManager defaultManager] setUmSocialAppkey:UMENG_APPKEY];
        [self configUSharePlatforms];

        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina), @(UMSocialPlatformType_QQ), @(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_Tim), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_Qzone)]];

        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {

            [JDUMShareManager shareMultimediaToPlatformType:platformType
                                           ShareContentType:ShareContentTypeWeb
                                                      title:@"我发现了一款好玩的APP 😌AppStore链接地址http://itunes.apple.com/us/app/id1274941977 (打不开的话,用自带浏览器打开哟!)"
                                         contentDescription:@"这是一款神秘的计算器(打不开的话,用自带浏览器打开哟!)"
                                                  thumbnail:[UIImage imageNamed:@"AppIcon"]
                                                        url:@"http://itunes.apple.com/us/app/id1274941977"
                                                  StreamUrl:@""
                                                    success:^(id result) {

                                                    }
                                                    failure:^(NSError *error){

                                                    }];

        }];
    }
}

- (void)configUSharePlatforms {
    //设置微信AppId、appSecret，分享url
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:WEIXIN_APPKEY
                                       appSecret:WEIXIN_APPSECRET
                                     redirectURL:REDIRECTURI];

    //设置手机QQ 的AppId，Appkey，和分享URL
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:QQ_APPKEY /*设置QQ平台的appID*/
                                       appSecret:QQ_APPSECRET
                                     redirectURL:REDIRECTURI];

    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
                                          appKey:SINA_APPKEY
                                       appSecret:SINA_APPSECRET
                                     redirectURL:REDIRECTURI];
}

//Appstore 取消按钮监听
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [_storeProductViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"setPassword"]) {
        
        JDPasswordViewController *plvc = segue.destinationViewController;
        plvc.type = (_selectItem == 0)?PasswordType_Change:PasswordType_GuestPassword;
    }
}


@end
