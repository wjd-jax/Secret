//
//  PhotoListViewController.h
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoLibraryModel.h"

@interface PhotoListViewController : UICollectionViewController

@property(nonatomic,retain)PhotoLibraryModel *model;

@end
