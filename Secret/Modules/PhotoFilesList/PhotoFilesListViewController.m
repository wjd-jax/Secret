//
//  PhotoFilesListViewController.m
//  Secret
//
//  Created by wangjundong on 2017/8/8.
//  Copyright © 2017年 wangjundong. All rights reserved.
//
#import "PhotoFilesListViewController.h"
#import "JDAlertViewManager.h"
#import "PhotoTableViewCell.h"
#import "JDActionSheetView.h"
#import "PhotoLibraryModel.h"
#import "PhotoListViewController.h"
#import <TZImagePickerController.h>
#import "JDUserModel.h"
#import "JDFileManager.h"
#import "define.h"
#import "JDHeader.h"
#import <Photos/Photos.h>
#import "JDImageManager.h"
#import <SVProgressHUD.h>

@interface PhotoFilesListViewController ()<UITableViewDelegate,UITableViewDataSource,TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain)NSMutableArray *photoLibraryArray;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;

@end

@implementation PhotoFilesListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.tableFooterView =[[UIView alloc]init];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateData];
}

#pragma mark - tableDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photoLibraryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCellID"];
    [cell congifUIWithModel:[_photoLibraryArray objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PhotoLibraryModel *model = [_photoLibraryArray objectAtIndex:indexPath.row];
    [JDActionSheetView showActionSheetWithTitle:model.name cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@[@"重命名",@"添加照片",@"清空照片",@"修改封面",@"全部导出"] handler:^(JDActionSheetView *actionSheet, NSInteger index) {
        switch (index) {
            case -1://删除
                [self deletePhoteLibraryWithModel:model];
                break;
            case 2://添加照片
                [self addPhotoWithModel:model];
                break;
            case 3://清空照片
                [self deleteAllPhoto:model];
                break;
            case 1://重命名
                [self changeNameWithModel:model];
                break;
            case 4://修改封面
                [self changeCoverImageWithModel:model];
                break;
            case 5://全部导出
                [self exportALL:model];
                break;
            default:
                break;
        }
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
#pragma mark - 文件夹操作

- (void)exportALL:(PhotoLibraryModel *)model{
    
    [JDAlertViewManager alertWithTitle:@"确认导出到相册?" message:@"" textFieldNumber:0 actionNumber:2 actionTitles:@[@"取消",@"导出"] textFieldHandler:nil actionHandler:^(UIAlertAction *action, NSUInteger index) {
        if (index == 1) {
            [model exportALLPhoto];
        }
    }];
    
}
- (void)deleteAllPhoto:(PhotoLibraryModel *)model{
    
    [JDAlertViewManager alertWithTitle:@"确认删除?" message:@"清空会删除所有照片切无法找回" textFieldNumber:0 actionNumber:2 actionTitles:@[@"取消",@"删除"] textFieldHandler:nil actionHandler:^(UIAlertAction *action, NSUInteger index) {
        if (index == 1) {
            [model deleteALLPhoto];
            [self updateData];
        }
    }];
}

- (void)addPhotoWithModel:(PhotoLibraryModel *)model{
    
    
    [JDUserModel shareInstance].needLock = NO;
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.maxImagesCount = 100;
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        [SVProgressHUD show];

        [JDUserModel shareInstance].needLock = YES;
        dispatch_queue_t queue= dispatch_queue_create("photo.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            [model addImageWithImageArray:photos assetsArray:assets];
            JDDISPATCH_MAIN_THREAD(^{
                [JDImageManager delectPhotoWithAssets:assets];
                [self updateData];
                [SVProgressHUD dismiss];
            });
        });
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


//删除文件夹
- (void)deletePhoteLibraryWithModel:(PhotoLibraryModel *)model {
    [JDAlertViewManager alertWithTitle:@"确认删除?" message:@"相册下照片也会同时清空" textFieldNumber:0 actionNumber:2 actionTitles:@[@"取消",@"确认"] textFieldHandler:nil actionHandler:^(UIAlertAction *action, NSUInteger index) {
        if (index == 1) {
            [model deletePhotoLibrary];
            [self updateData];
        }
    }];
}
//修改封面
- (void)changeCoverImageWithModel:(PhotoLibraryModel *)model{
    //
    [JDUserModel shareInstance].needLock = NO;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;

    imagePickerVc.cropRect = CGRectMake(0, SCREEN_HEIGHT/2 - SCREEN_WIDHT/2, SCREEN_WIDHT, SCREEN_WIDHT);
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        [model updateCoverImageName:[photos firstObject]];
        [self updateData];
        
        [JDUserModel shareInstance].needLock = YES;
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

//修改名字
- (void)changeNameWithModel:(PhotoLibraryModel *)model
{
    __block UITextField *fileNameTextField;
    
    [JDAlertViewManager alertWithTitle:@"重命名相簿" message:@"" textFieldNumber:1 actionNumber:2 actionTitles:@[@"取消",@"确认"] textFieldHandler:^(UITextField *textField, NSUInteger index) {
        
        fileNameTextField = textField;
        textField.placeholder = model.name;
        
    } actionHandler:^(UIAlertAction *action, NSUInteger index) {
        
        if (index == 1) {
            model.name = fileNameTextField.text;
            [model update];
            [self updateData];
        }
    }];
}
- (IBAction)addClick:(id)sender {
    
    __block UITextField *fileNameTextField;
    
    [JDAlertViewManager alertWithTitle:@"新建相簿" message:@"" textFieldNumber:1 actionNumber:2 actionTitles:@[@"取消",@"确认"] textFieldHandler:^(UITextField *textField, NSUInteger index) {
        
        fileNameTextField = textField;
        textField.placeholder = @"相册";
        
    } actionHandler:^(UIAlertAction *action, NSUInteger index) {
        
        if (index == 1) {
            PhotoLibraryModel *model = [[PhotoLibraryModel alloc]initWithName:
                                        fileNameTextField.text.length>0?fileNameTextField.text:fileNameTextField.placeholder];
            [model save];
            [self updateData];
        }
    }];
}
#pragma mark - 更新数据
- (void)updateData
{
    _photoLibraryArray =[NSMutableArray arrayWithArray:[PhotoLibraryModel getAllPhotoLibrary]];
    [self.tableView reloadData];
    _remindLabel.hidden = (_photoLibraryArray.count > 0);
}

#pragma mark -TZImagePickerControllerDelegate
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    
    [JDUserModel shareInstance].needLock = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showPhotoList"]) {
       
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        PhotoListViewController *plvc = segue.destinationViewController;
        plvc.model = [_photoLibraryArray objectAtIndex:indexPath.row];
    }
}
@end
