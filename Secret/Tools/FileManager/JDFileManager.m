//
//  JDFileManager.m
//  Secret
//
//  Created by wangjundong on 2017/8/10.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "JDFileManager.h"
#import "JDHeader.h"
#import <TZImageManager.h>
#import <SVProgressHUD.h>

static NSFileManager *iFileManager;

@implementation JDFileManager

+ (NSFileManager *)getNSFileManager {

    if (!iFileManager) {
        iFileManager = [NSFileManager defaultManager];
    }
    return iFileManager;
}

+ (NSString *)saveCoverImage:(UIImage *)image {

    NSString *coverName = [NSString stringWithFormat:@"%@.gif", [NSUUID UUID].UUIDString];
    NSString *fullCoverPath = [self getCoverPathWithName:coverName];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [self createFileWithPath:fullCoverPath content:data];
    return coverName;
}

#pragma mark -  导出视频
+ (void)saveVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath, NSString *seconds))completion {

    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                    options:options
                                              resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
                                                AVURLAsset *videoAsset = (AVURLAsset *)avasset;
                                                [self startExportVideoWithVideoAsset:videoAsset completion:completion];
                                              }];
}

+ (NSString *)getVideoDurationWithCMtime:(CMTime)time {

    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    NSString *videoDurationText;
    if (dHours > 0) {
        videoDurationText = [NSString stringWithFormat:@"%lu:%lu:%lu", (unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    } else if (dMinutes > 0) {
        videoDurationText = [NSString stringWithFormat:@"%lu:%lu", (unsigned long)dMinutes, (unsigned long)dSeconds];
    } else {
        videoDurationText = [NSString stringWithFormat:@"%lu", (unsigned long)dSeconds];
    }
    return videoDurationText;
}

+ (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath, NSString *seconds))completion {

    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    CMTime time = [videoAsset duration];
    NSString *seconds = [self getVideoDurationWithCMtime:time];
    if ([presets containsObject:AVAssetExportPreset640x480]) {

        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];

        NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
        NSString *outputPath = [self getVideoPathWithName:videoName];
        [self createParentDirectory:outputPath];

        DLog(@"video outputPath = %@", outputPath);

        session.outputURL = [NSURL fileURLWithPath:outputPath];

        session.shouldOptimizeForNetworkUse = true;

        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            DLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }

        AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width) {
            // 修正视频转向
            session.videoComposition = videoComposition;
        }

        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
          switch (session.status) {
              case AVAssetExportSessionStatusUnknown:
                  DLog(@"AVAssetExportSessionStatusUnknown");
                  break;
              case AVAssetExportSessionStatusWaiting:
                  DLog(@"AVAssetExportSessionStatusWaiting");
                  break;
              case AVAssetExportSessionStatusExporting:
                  DLog(@"AVAssetExportSessionStatusExporting");
                  break;
              case AVAssetExportSessionStatusCompleted: {
                  DLog(@"AVAssetExportSessionStatusCompleted");
                  dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(videoName, seconds);
                    }
                  });
              } break;
              case AVAssetExportSessionStatusFailed:
                  DLog(@"AVAssetExportSessionStatusFailed");
                  break;
              default:
                  break;
          }
        }];
    }
}

/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            // Portrait
            degress = 90;
        } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            // PortraitUpsideDown
            degress = 270;
        } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            // LandscapeRight
            degress = 0;
        } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}
/// 获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);

        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];

        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if (degrees == 180) {
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if (degrees == 270) {
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2 * 3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }

        roateInstruction.layerInstructions = @[ roateLayerInstruction ];
        // 加入视频方向信息
        videoComposition.instructions = @[ roateInstruction ];
    }
    return videoComposition;
}

#pragma mark - 保存相册图片数组
+ (void)addImageWithImageArray:(NSArray< UIImage * > *)photos assetsArray:(NSArray *)assets model:(PhotoLibraryModel *)model callBack:(void (^)(BOOL success))callBack {

    NSMutableArray *array = [NSMutableArray arrayWithArray:model.photoArray];
    NSMutableArray *addArray = [NSMutableArray array];
    NSString *imageName;

    for (PHAsset *asset in assets) {

        imageName = [NSString stringWithFormat:@"%@.jpg", [NSUUID UUID].UUIDString];
        [addArray addObject:imageName];

        [[TZImageManager manager] getOriginalPhotoDataWithAsset:asset
                                                     completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {

                                                       NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@", imageName]];
                                                       [self createFileWithPath:savedImagePath content:data];

                                                     }];
    }
    for (NSString *addImageIname in addArray) {
        [array insertObject:addImageIname atIndex:0];
    }
    //线程生成缩略图
    dispatch_queue_t queue = dispatch_queue_create("thumb.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{

      for (int i = 0; i < photos.count; i++) {
          UIImage *oImage = [photos objectAtIndex:i];
          UIImage *thumbImage = [self thumbnailWithImageWithoutScale:oImage size:CGSizeMake(SCREEN_WIDHT / 2, SCREEN_WIDHT / oImage.size.width * oImage.size.height / 2)];
          NSData *imagedata = UIImageJPEGRepresentation(thumbImage, 1); //UIImagePNGRepresentation(thumbImage);
          NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Thumb/%@", [NSString stringWithFormat:@"thumb_%@", addArray[i]]]];
          [self createFileWithPath:savedImagePath content:imagedata];
      }
      //需要缩略图的回调
      JDDISPATCH_MAIN_THREAD(^{
        if (callBack) {
            callBack(YES);
        }
      });

    });
    model.photoArray = array;
}

+ (NSString *)typeForImageData:(NSData *)data {

    uint8_t c;

    [data getBytes:&c length:1];

    switch (c) {

        case 0xFF:

            return @"image/jpeg";

        case 0x89:

            return @"image/png";

        case 0x47:

            return @"image/gif";

        case 0x49:

        case 0x4D:

            return @"image/tiff";
    }

    return nil;
}

//缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {

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

+ (BOOL)changeCoverImage:(UIImage *)image model:(PhotoLibraryModel *)model {

    NSData *imagedata = UIImageJPEGRepresentation(image, 1);
    NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"cover/%@.jpg", model.uuid]];
    return [self createFileWithPath:savedImagePath content:imagedata];
}

#pragma mark 目录下创建文件
+ (BOOL)createFileWithPath:(NSString *)aPath content:(NSData *)aContent {
    BOOL result = NO;
    result = [self createParentDirectory:aPath];
    if (result) {
        result = [[self getNSFileManager] createFileAtPath:aPath contents:aContent attributes:nil];
    }
    return result;
}

#pragma mark - 创建目录的上级目录
+ (BOOL)createParentDirectory:(NSString *)aPath {
    //存在上级目录，并且上级目录不存在的创建所有的上级目录
    BOOL result = NO;
    NSString *parentPath = [self getParentPath:aPath];
    if (parentPath && ![self dirExistAtPath:parentPath]) {
        return [[self getNSFileManager] createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else if ([self dirExistAtPath:parentPath]) {
        result = YES;
    }

    return result;
}

#pragma mark 删除文件
+ (BOOL)deleteFileWithName:(NSString *)aFileName
                     error:(NSError **)aError {
    NSFileManager *tempFileManager = [self getNSFileManager];
    return [tempFileManager removeItemAtPath:aFileName
                                       error:aError];
}

+ (BOOL)deleteCoverWithName:(NSString *)name {

    NSString *savedImagePath = [self getCoverPathWithName:name]; //
    return [self deleteFileWithName:savedImagePath error:nil];
}

+ (BOOL)deleteVideoWithName:(NSString *)name;
{
    NSString *videoPath = [self getVideoPathWithName:name]; //
    return [self deleteFileWithName:videoPath error:nil];
}

+ (BOOL)deletePhotoWithName:(NSString *)imageName {
    //原图
    NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@", imageName]];
    //缩略图
    NSString *savedThumbImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Thumb/%@", [NSString stringWithFormat:@"thumb_%@", imageName]]];
    BOOL a = [self deleteFileWithName:savedImagePath error:nil];
    BOOL b = [self deleteFileWithName:savedThumbImagePath error:nil];
    return a & b;
}

+ (void)exportAllPhotoWithPhotoArray:(NSArray *)photos {

    [SVProgressHUD show];
    dispatch_queue_t queue = dispatch_queue_create("photo.queueSave", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        
      for (NSString *imageName in photos) {
          //原图
          NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@", imageName]];

          UIImage *image = [UIImage imageWithContentsOfFile:savedImagePath];
          UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
      }
        [SVProgressHUD showSuccessWithStatus:@"导出成功!"];
        [SVProgressHUD dismissWithDelay:2 completion:nil];
    });
}
+ (void)deleteAllPhotoWithPhotoArray:(NSArray *)photos {

    dispatch_queue_t queue = dispatch_queue_create("photo.queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
      for (NSString *imageName in photos) {
          //原图
          NSString *savedImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@", imageName]];
          //缩略图
          NSString *savedThumbImagePath = [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Thumb/%@", [NSString stringWithFormat:@"thumb_%@", imageName]]];
          [self deleteFileWithName:savedImagePath error:nil];
          [self deleteFileWithName:savedThumbImagePath error:nil];
      }
    });
}

#pragma mark - 读取
+ (NSString *)getCoverPathWith:(PhotoLibraryModel *)model {

    NSString *urlStr = [self getCoverPathWithName:model.coverImageName];
    return urlStr;
}

+ (NSString *)getCoverPathWithName:(NSString *)name {

    NSString *urlStr = [NSString stringWithFormat:@"%@/cover/%@", [self getDocumentPath], name];
    return urlStr;
}

+ (NSString *)getVideoPathWithName:(NSString *)name;
{
    return [NSString stringWithFormat:@"%@/Video/%@", [self getDocumentPath], name];
}

+ (NSString *)getPhotoPathWithName:(NSString *)name {

    NSString *urlStr = [NSString stringWithFormat:@"%@/Photo/%@", [self getDocumentPath], name];
    return urlStr;
}

+ (NSString *)getThumPhotoPathWithName:(NSString *)name {

    NSString *urlStr = [NSString stringWithFormat:@"%@/Thumb/%@", [self getDocumentPath], [NSString stringWithFormat:@"thumb_%@", name]];
    return urlStr;
}

#pragma mark - 获取上级目录
+ (NSString *)getParentPath:(NSString *)aPath {
    // //删除最后一个目录
    return [aPath stringByDeletingLastPathComponent];
}

#pragma mark 获取documents的全路径
+ (NSString *)getDocumentPath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = [path objectAtIndex:0];
    return result;
}


#pragma mark - 判断文件夹是否存在
+ (BOOL)dirExistAtPath:(NSString *)aPath
{
    BOOL isDir = NO;
    BOOL result = [[self getNSFileManager] fileExistsAtPath:aPath isDirectory:&isDir];
    return result && isDir;
}

@end
