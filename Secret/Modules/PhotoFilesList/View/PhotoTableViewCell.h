//
//  PhotoTableViewCell.h
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoLibraryModel.h"

@interface PhotoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoNumberLabel;

- (void)congifUIWithModel:(PhotoLibraryModel *)model;

@end
