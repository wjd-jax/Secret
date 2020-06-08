//
//  PhotoListViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoCollectionViewCell.h"
#import "JDFileManager.h"
#import "JDHeader.h"
#import <TZImagePickerController.h>
#import "JDUserModel.h"
#import "JDImageManager.h"
#import <UIImageView+WebCache.h>
#import <YBImageBrowser.h>
#import <SVProgressHUD.h>
@interface PhotoListViewController () <TZImagePickerControllerDelegate, UICollectionViewDelegate>

/** 图片提前缓存(直接传递Image给cell,避免cell不断读取本地数据卡顿imageWithContentsOfFile) */
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *sheetActionArray;
@property (nonatomic, strong) YBImageBrowser *photoBrowser;

@end

@implementation PhotoListViewController

static NSString *const reuseIdentifier = @"PhotolistCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.delaysContentTouches = false;
    [self getData];
}
- (void)getData {

            [SVProgressHUD show];
    [self.images removeAllObjects];
    dispatch_queue_t queue = dispatch_queue_create("photolist.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{

        for (NSInteger i = 0; i < self.model.photoArray.count; i++) {
            NSString *imageName = self.model.photoArray[i];
            UIImage *image = [UIImage imageWithContentsOfFile:[JDFileManager getThumPhotoPathWithName:imageName]];
            if (image) {
                [self.images addObject:image];
            }
        }
        
        JDDISPATCH_MAIN_THREAD(^{
                            [SVProgressHUD dismiss];
            [self.collectionView reloadData];
        });
        
    });
}

- (IBAction)addPhoto:(id)sender {

    [JDUserModel shareInstance].needLock = NO;

    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.maxImagesCount = 100;
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {

                [SVProgressHUD show];

        [JDUserModel shareInstance].needLock = YES;
        dispatch_queue_t queue = dispatch_queue_create("photo.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{

            [JDFileManager addImageWithImageArray:photos
                                      assetsArray:assets
                                            model:self.model
                                         callBack:^(BOOL success) {
                                             [self.model update];
                                                             [SVProgressHUD dismiss];
                                             [self getData];
                                             [JDImageManager delectPhotoWithAssets:assets];
                                         }];
        });
    }];

    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - 懒加载读取本地图片
- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {

    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    } else {

        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width / asize.height > oldsize.width / oldsize.height) {
            rect.size.width = asize.height * oldsize.width / oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width) / 2;
            rect.origin.y = 0;
        } else {
            rect.size.width = asize.width;
            rect.size.height = asize.width * oldsize.height / oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height) / 2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height)); //clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark -TZImagePickerControllerDelegate
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {

    [JDUserModel shareInstance].needLock = YES;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageVIew.image = self.images[indexPath.item];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

//设置大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    float width = (self.view.bounds.size.width - 10) / 4;
    return CGSizeMake(width, width);
}

#pragma mark -  选中时的操作
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    YBImageBrowser  *photoBrowser = [YBImageBrowser new];
    self.photoBrowser = photoBrowser;
    
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < self.images.count; i++) {
        
        NSString *photoName = self.model.photoArray[i];
        NSString *url = [JDFileManager getPhotoPathWithName:photoName];
        YBImageBrowseCellData *data = [YBImageBrowseCellData new];
        data.image = [YBImage imageWithContentsOfFile:url];
        data.extraData = photoName;
        data.sourceObject = [self sourceObjAtIdx:i];
        data.url = [NSURL URLWithString:url];
        [items addObject:data];
    }
    

    YBImageBrowserToolBar *bar = [YBImageBrowserToolBar new];
    [bar setOperationButtonImage:[UIImage imageNamed:@"share"]
                           title:@""
                       operation:^(id<YBImageBrowserCellDataProtocol> _Nonnull data) {
                           YBImageBrowseCellData *cellData = data;
                           [self shareWithData:cellData.url];
                       }];
    self.photoBrowser.toolBars = @[bar];
    self.photoBrowser.defaultSheetView.actions = self.sheetActionArray;
    self.photoBrowser.dataSourceArray = items;

    self.photoBrowser.currentIndex = indexPath.item;

    [self.photoBrowser show];
}

- (id)sourceObjAtIdx:(NSInteger)idx {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    return cell ? cell.imageVIew : nil;
}

- (void)shareWithData:(id)data {

    NSArray *activityItems = @[data];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];

    UIPopoverPresentationController *popover = activityVC.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.view;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //设置选中时的颜色
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.shawView.hidden = NO;
}

#pragma mark - KSPhotoBrowserDelegate
//- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
//    NSLog(@"selected index: %@", @(index));
//}
//- (void)ks_photoBrowser:(KSPhotoBrowser *)browser deleteItem:(KSPhotoItem *)item atIndex:(NSUInteger)index
//{
//    [self.model deletePhotoWithIndex:index];
//    [self getData];
//}

#pragma mark - 选中效果
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.shawView.hidden = YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSMutableArray *)sheetActionArray {

    if (!_sheetActionArray) {

        YBImageBrowserSheetAction *deleteAction = [YBImageBrowserSheetAction actionWithName:@"删除"
                                                                                   identity:@""
                                                                                     action:^(id<YBImageBrowserCellDataProtocol> _Nonnull data) {

                                                                                         YBImageBrowseCellData *celldata = data;
                                                                                         [self.model deletePhotoWithPhotoName:celldata.extraData];
                                                                                         [self getData];
                                                                                         [self.photoBrowser hide];
                                                                                         
                                                                                     }];
        _sheetActionArray = @[deleteAction].mutableCopy;
    }

    return _sheetActionArray;
}


@end
