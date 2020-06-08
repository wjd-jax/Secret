//
//  MoviePlayerViewController.h
//


#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface MoviePlayerViewController : UIViewController
/** 视频URL */
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) NSString *coverImageName;
@property (nonatomic, strong)VideoModel *model;

@end
