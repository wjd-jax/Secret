//
//  VideoCollectionViewCell.h
//  Secret
//
//  Created by wangjundong on 2017/8/18.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface VideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)configWithModel:(VideoModel *)model;
@end
