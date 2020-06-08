//
//  PhotoTableViewCell.m
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "JDFileManager.h"

@implementation PhotoTableViewCell


- (void)congifUIWithModel:(PhotoLibraryModel *)model{
    
    self.nameLabel.text = model.name;
    self.photoNumberLabel.text = [NSString stringWithFormat:@"%d张照片",[model getPhotoNum]];

//    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[JDFileManager getCoverPathWith:model]] placeholderImage:[UIImage imageNamed:@"defaut_Image"]];
    NSString *path = [JDFileManager getCoverPathWith:model];
    UIImage  *image = [[UIImage alloc]initWithContentsOfFile:path];
    if (image) {
        self.coverImageView.image = image;
    }
    else
    {
        self.coverImageView.image = [UIImage imageNamed:@"defaut_Image"];
    }
}


@end
