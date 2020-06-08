//
//  AboutViewController.m
//  Secret
//
//  Created by wangjundong on 2017/9/26.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _qrImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gesture)];
    [_qrImageView addGestureRecognizer:ges];
    // Do any additional setup after loading the view.
}

- (void)gesture
{
    
    
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];

    NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(_qrImageView.image)]];

    //取出探测到的数据
    for (CIQRCodeFeature *result in features) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result.messageString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
            
        }];
    }
  
}
@end
