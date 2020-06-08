//
//  MoviePlayerViewController.m
//


#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "JDHeader.h"

@interface MoviePlayerViewController ()
@property (nonatomic, strong) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation MoviePlayerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    _coverImageView.image  =   [UIImage imageWithContentsOfFile:_coverImageName];
    
}



- (void)dealloc
{
    
    
}



#pragma mark - Action
- (IBAction)deleteAcition:(id)sender {
    
    [JDAlertViewManager actionSheettWithTitle:@"确认删除?" message:nil actionNumber:2 actionTitles:@[@"取消",@"删除"] actionHandler:^(UIAlertAction *action, NSUInteger index) {
        if (index == 1) {
            
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteVideo" object:_model];
        }
        
    }];
    
}

- (IBAction)playAction:(id)sender {
    
    AVPlayerViewController *avc =[[AVPlayerViewController alloc]init];
    avc.player = [[AVPlayer alloc]initWithURL:self.videoURL];
    avc.videoGravity = AVLayerVideoGravityResizeAspect;
    [avc.player play];
    [self presentViewController:avc animated:NO completion:nil];
}

- (IBAction)shareClick:(UIBarButtonItem *)sender {
    
    NSArray *activityItems = @[self.videoURL];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    
    UIPopoverPresentationController *popover = activityVC.popoverPresentationController;
    if (popover) {
        popover.sourceView = sender.customView;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}



@end
