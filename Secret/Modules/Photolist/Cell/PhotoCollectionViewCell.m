//
//  PhotoCollectionViewCell.m
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "JDFileManager.h"

@implementation PhotoCollectionViewCell

- (void)configWithName:(NSString *)imageName
{
    _imageVIew.image = [UIImage imageWithContentsOfFile:[JDFileManager getPhotoPathWithName:imageName]];
    
}
@end
