//
//  ViedoModel.m
//  Secret
//
//  Created by wangjundong on 2017/8/18.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "VideoModel.h"
#import <LKDBHelper.h>
#import "JDFileManager.h"
#import "JDUserModel.h"

@implementation VideoModel
- (instancetype)initWithCoverImage:(NSString *)coverImage videoPath:(NSString *)path time:(NSString *)timer
{
    self = [super init];
    if (self) {
        _coverImage = coverImage;
        _videoPath = path;
        _time = timer;
        self.uid = [JDUserModel shareInstance].isAdimnUser?@"admin":@"user";
    }
    return self;
}

+ (NSArray *)getAllVideo{
    
    NSArray *array = [VideoModel searchWithWhere:[NSString stringWithFormat:@"uid = '%@'",[JDUserModel shareInstance].isAdimnUser?@"admin":@"user"]];
    return array;
    
}

- (BOOL)saveModel{
    
    [self saveToDB];
    
    return YES;
}

- (BOOL)deletFromBox{
    
    [JDFileManager deleteCoverWithName:self.coverImage];
    [JDFileManager deleteVideoWithName:self.videoPath];
    [self deleteToDB];
    return YES;
}

- (NSString *)getFullCoverImagePath{
    
    return [JDFileManager getCoverPathWithName:self.coverImage];
}
- (NSString *)getFullVideoPath{
    
    return [JDFileManager getVideoPathWithName:self.videoPath];
}
@end
