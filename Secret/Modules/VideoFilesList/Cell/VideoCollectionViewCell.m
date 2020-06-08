//
//  VideoCollectionViewCell.m
//  Secret
//
//  Created by wangjundong on 2017/8/18.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@implementation VideoCollectionViewCell
- (void)configWithModel:(VideoModel *)model;
{
    _coverImageView.image = [UIImage imageWithContentsOfFile:[model getFullCoverImagePath]];
    _timeLabel.text = [NSString stringWithFormat:@"%@'",model.time];
}
@end
