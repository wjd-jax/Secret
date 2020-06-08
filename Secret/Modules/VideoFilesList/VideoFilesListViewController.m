//
//  VideoFilesListViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "VideoFilesListViewController.h"
#import <TZImagePickerController.h>
#import <Photos/Photos.h>
#import "JDUserModel.h"
#import "JDAlertViewManager.h"
#import "JDHeader.h"
#import "JDImageManager.h"
#import <TZImageManager.h>
#import "JDFileManager.h"
#import "VideoModel.h"
#import "VideoCollectionViewCell.h"
#import "MoviePlayerViewController.h"
#import <SVProgressHUD.h>

@interface VideoFilesListViewController ()<TZImagePickerControllerDelegate,UICollectionViewDelegate>

@property(nonatomic,retain)NSMutableArray *videoArray;  //视频数组
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;

@end

@implementation VideoFilesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.videoArray removeAllObjects];
    [self.videoArray addObjectsFromArray:[VideoModel getAllVideo]];
    [self updateData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteModel:) name:@"deleteVideo" object:nil];

}
-(void)deleteModel:(NSNotification *)sender
{
    VideoModel *model  = sender.object;
    [model deletFromBox];
    [_videoArray removeObject:model];
    [self updateData];
    
}

#pragma mark - 懒加载
-(NSMutableArray *)videoArray
{
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

- (IBAction)addVideoClick:(id)sender {
    
    [JDUserModel shareInstance].needLock = NO;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.maxImagesCount = 1;
    imagePickerVc.showSelectBtn = YES;
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = YES;
    imagePickerVc.allowPickingImage = NO;
    
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
       
        PHAsset *videoAsset = (PHAsset *)asset;
        NSString *covePath = [JDFileManager saveCoverImage:coverImage];
        [SVProgressHUD show];

        [JDFileManager saveVideoOutputPathWithAsset:asset completion:^(NSString *outputPath,NSString * seconds) {
            VideoModel *model = [[VideoModel alloc]initWithCoverImage:covePath videoPath:outputPath time:seconds];
            
            [self.videoArray addObject:model];
            [model saveModel];
            JDDISPATCH_MAIN_THREAD(^{
                
                 [SVProgressHUD dismiss];
                [JDImageManager delectPhotoWithAssets:@[videoAsset]];
                [self updateData];
                
            });
        }];
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    imagePickerVc.navigationItem.title = @"所有视频";
    
}

- (void)updateData{
  
    [_collectionView reloadData];
    _remindLabel.hidden = (_videoArray.count > 0);

}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoArray.count;
}


//设置大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width=(self.view.bounds.size.width-10)/4;
    return CGSizeMake(width, width);
}

static NSString *reuseIdentifier = @"videoCellID";


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configWithModel:self.videoArray[indexPath.row]];
    return cell;
}

#pragma mark -TZImagePickerControllerDelegate
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    
 
    [JDUserModel shareInstance].needLock = YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MoviePlayerViewController *movie = (MoviePlayerViewController *)segue.destinationViewController;
    UICollectionViewCell *cell            = (UICollectionViewCell *)sender;
    NSIndexPath *indexPath           = [self.collectionView indexPathForCell:cell];
    VideoModel *model = [_videoArray objectAtIndex:indexPath.row];
    NSURL *videoURL                  = [NSURL fileURLWithPath:[model getFullVideoPath]];
    movie.videoURL                   = videoURL;
    movie.model = model;
    movie.coverImageName             = [model getFullCoverImagePath];
}

@end
