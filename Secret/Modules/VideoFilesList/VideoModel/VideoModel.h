//
//  ViedoModel.h
//  Secret
//
//  Created by wangjundong on 2017/8/18.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property(nonatomic,copy)NSString *coverImage;  //封面名字
@property(nonatomic,copy)NSString *videoPath;   //视频地址
@property(nonatomic,copy)NSString *time;        //时长
@property(nonatomic,copy)NSString *uid;         //相册归属人,admin或者user

+ (NSArray *)getAllVideo;

- (instancetype)initWithCoverImage:(NSString *)coverImage videoPath:(NSString *)path time:(NSString *)timer;

- (BOOL)saveModel;
- (BOOL)deletFromBox;

- (NSString *)getFullCoverImagePath;
- (NSString *)getFullVideoPath;

@end

