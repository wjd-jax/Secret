//
//  PhotoLibraryModel.m
//  Secret
//
//  Created by wangjundong on 2017/8/14.
//  Copyright © 2017年 wangjundong. All rights reserved.
//

#import "PhotoLibraryModel.h"
#import <UIKit/UIKit.h>
#import "JDUserModel.h"
#import <LKDBHelper.h>
#import "JDFileManager.h"

@implementation PhotoLibraryModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID UUID] UUIDString];
        self.uid = [JDUserModel shareInstance].isAdimnUser ? @"admin" : @"user";
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    self = [[PhotoLibraryModel alloc] init];
    if (self) {
        self.name = name;
    }
    return self;
}

+ (NSArray *)getAllPhotoLibrary {

    NSArray *array = [PhotoLibraryModel searchWithWhere:[NSString stringWithFormat:@"uid = '%@'", [JDUserModel shareInstance].isAdimnUser ? @"admin" : @"user"]];
    return array;
}

- (BOOL)changeName:(NSString *)name {

    self.name = name;
    return [self updateToDB];
}

- (void)updateCoverImageName:(UIImage *)coverImage {
    if ([JDFileManager changeCoverImage:coverImage model:self]) {
        self.coverImageName = [NSString stringWithFormat:@"%@.jpg", self.uuid];
        [self updateToDB];
    }
}

- (int)getPhotoNum {

    return (int)self.photoArray.count;
}

- (BOOL)update {

    return [self updateToDB];
}

- (BOOL)deletePhotoLibrary {

    [JDFileManager deleteCoverWithName:self.coverImageName];
    [JDFileManager deleteAllPhotoWithPhotoArray:self.photoArray];
    return [self deleteToDB];
}

- (void)exportALLPhoto {
    
     [JDFileManager exportAllPhotoWithPhotoArray:self.photoArray];
}

- (BOOL)deleteALLPhoto {

    [JDFileManager deleteAllPhotoWithPhotoArray:self.photoArray];
    [self.photoArray removeAllObjects];
    [self updateToDB];
    return YES;
}
- (BOOL)deletePhotoWithPhotoName:(NSString *)name {

    BOOL del = [JDFileManager deletePhotoWithName:name];
    for (NSString *photoName in self.photoArray) {
        if ([photoName isEqualToString:name]) {
            [self.photoArray removeObject:photoName];
            break;
        }
    }
    [self update];
    return del;
}
- (BOOL)deletePhotoWithIndex:(NSInteger)index {

    BOOL del = [JDFileManager deletePhotoWithName:[self.photoArray objectAtIndex:index]];
    [self.photoArray removeObjectAtIndex:index];
    [self update];
    return del;
}

- (void)addImageWithImageArray:(NSArray *)photos assetsArray:(NSArray *)assets {

    [JDFileManager addImageWithImageArray:photos assetsArray:assets model:self callBack:nil];
    [self update];
}

- (BOOL)save {

    return [self saveToDB];
}

#pragma mark - LKDB

+ (NSString *)getPrimaryKey {
    return @"uuid";
}

@end
