//
//  JDFileManager.h
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotoLibraryModel.h"


@interface JDFileManager : NSObject



/**
 添加照片到本地

 @param photos 照片数据
 */
+ (void)addImageWithImageArray:(NSArray<UIImage *> *)photos assetsArray:(NSArray *)assets model:(PhotoLibraryModel *)model callBack:(void(^)(BOOL success))callBack;
/**
 保存视频

 @param asset 视频asset
 @param completion 是否完成
 */
+ (void)saveVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath ,NSString * seconds))completion;

/**
 保存封面

 @param image 保存的图片
 @return 封面名字
 */
+ (NSString *)saveCoverImage:(UIImage *)image;
/**
 根据模型获取封面图片

 @param model 相册模型
 @return 封面url
 */
+ (NSString *)getCoverPathWith:(PhotoLibraryModel *)model;
+ (NSString *)getCoverPathWithName:(NSString *)name;
+ (NSString *)getPhotoPathWithName:(NSString *)name;
+ (NSString *)getVideoPathWithName:(NSString *)name;
+ (NSString *)getThumPhotoPathWithName:(NSString *)name;
/**
 删除封面图片

 @param name 封面名字
 @return 是否删除
 */
+ (BOOL)deleteCoverWithName:(NSString *)name;
+ (BOOL)deleteVideoWithName:(NSString *)name;

/**
 批量删除图片

 @param photos 图片数组
 */
+ (void)deleteAllPhotoWithPhotoArray:(NSArray *)photos;
+ (BOOL)changeCoverImage:(UIImage *)image model:(PhotoLibraryModel *)model;


/**
 根据名字删除图片

 @param imageName 名字
 @return 删除结果
 */
+ (BOOL)deletePhotoWithName:(NSString *)imageName;

/**
 导出所有

 @param photos 
 */
+ (void)exportAllPhotoWithPhotoArray:(NSArray *)photos;
@end
