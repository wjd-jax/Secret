//
//  PhotoCollectionViewCell.h
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage.h>

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imageVIew;
@property (weak, nonatomic) IBOutlet UIView *shawView;

- (void)configWithName:(NSString *)imageName;

@end
