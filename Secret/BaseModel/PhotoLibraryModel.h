//
//  PhotoLibraryModel.h
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoLibraryModel : NSObject

@property (nonatomic, copy) NSString *uuid;               //相册uuid
@property (nonatomic, copy) NSString *uid;                //相册归属人,admin或者user
@property (nonatomic, copy) NSString *name;               //名字
@property (nonatomic, copy) NSString *coverImageName;     //封面名字
@property (nonatomic, retain) NSMutableArray *photoArray; //相册内容,图片路径数组

/**
 获取所有相册

 @return 相册模型数组
 */
+ (NSArray *)getAllPhotoLibrary;

/**
 使用名字初始化一个相册

 @param name 相册名字
 @return 相册模型
 */
- (instancetype)initWithName:(NSString *)name;

/**
 修改名字并保存到数据库

 @param name 新名字
 @return 保存成功或者失败
 */
- (BOOL)changeName:(NSString *)name;
- (int)getPhotoNum;
- (BOOL)update;
- (BOOL)save;
- (void)exportALLPhoto;     //d
- (BOOL)deletePhotoLibrary; //删除文件夹
- (BOOL)deletePhotoWithIndex:(NSInteger)index;
- (BOOL)deletePhotoWithPhotoName:(NSString *)name;

- (void)updateCoverImageName:(UIImage *)coverImage;
- (void)addImageWithImageArray:(NSArray*)photos  assetsArray:(NSArray *)assets;

/**
 删除所有图片

 @return 结果
 */
- (BOOL)deleteALLPhoto;


@end
