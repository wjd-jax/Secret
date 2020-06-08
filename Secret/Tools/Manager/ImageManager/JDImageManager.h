//
//  JDImageManager.h
//  Secret
//
//  Created by wangjundong on 2017/8/15.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDImageManager : NSObject

/**
 从相册中删除

 @param assets 需要删除的相册数组
 */
+ (void)delectPhotoWithAssets:(NSArray *)assets;

@end
