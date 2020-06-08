//
//  JDImageManager.m
//  Secret
//
//  Created by wangjundong on 2017/8/15.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "JDImageManager.h"
#import <Photos/Photos.h>
#import "JDUserModel.h"
#import "JDAlertViewManager.h"

@implementation JDImageManager

+ (void)delectPhotoWithAssets:(NSArray *)assets
{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"defaultDeletePhoto"]) {
        
        [JDUserModel shareInstance].needLock = NO;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:assets];
        } completionHandler:^(BOOL success, NSError *error) {
            [JDUserModel shareInstance].needLock = YES;
        }];
    }
    else
    {
        [JDAlertViewManager alertWithTitle:@"添加成功!" message:@"是否删除相册中的原文件?" textFieldNumber:0 actionNumber:2 actionTitles:@[@"取消",@"删除"] textFieldHandler:nil actionHandler:^(UIAlertAction *action, NSUInteger index) {
            if (index == 1){
                [JDUserModel shareInstance].needLock = NO;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest deleteAssets:assets];
                } completionHandler:^(BOOL success, NSError *error) {
                    [JDUserModel shareInstance].needLock = YES;
                }];
            }
        }];
    }
}

@end
