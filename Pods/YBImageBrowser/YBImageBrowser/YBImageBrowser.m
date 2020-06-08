//
//  YBImageBrowser.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/24.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBImageBrowser.h"
#import "YBImageBrowserViewLayout.h"
#import "YBImageBrowserView.h"
#import "YBImageBrowser+Internal.h"
#import "YBIBUtilities.h"
#import "YBIBWebImageManager.h"
#import "YBIBTransitionManager.h"
#import "YBIBLayoutDirectionManager.h"
#import "YBIBCopywriter.h"

// It is necessary to set this variable to the global level.
static BOOL _statusBarIsHiddenBefore;

@interface YBImageBrowser () <UIViewControllerTransitioningDelegate, YBImageBrowserViewDelegate, YBImageBrowserDataSource> {
    BOOL _isFirstViewDidAppear;
    YBImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isRestoringDeviceOrientation;
    UIInterfaceOrientation _statusBarOrientationBefore;
}
@property (nonatomic, strong) YBIBLayoutDirectionManager *layoutDirectionManager;
@property (nonatomic, strong) YBIBTransitionManager *transitionManager;
@end

@implementation YBImageBrowser

#pragma mark - life cycle

- (void)dealloc {
    // If the current instance is released (possibly uncontrollable release), we need to restore the changes to external business.
    [YBIBWebImageManager restoreOutsideConfiguration];
    self.hiddenSourceObject = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self initVars];
        [YBIBWebImageManager storeOutsideConfiguration];
        [self.layoutDirectionManager startObserve];
    }
    return self;
}

- (void)initVars {
    self->_isFirstViewDidAppear = NO;
    self->_isRestoringDeviceOrientation = NO;
    
    self->_currentIndex = 0;
    self->_supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    self->_backgroundColor = [UIColor blackColor];
    self->_enterTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_outTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_transitionDuration = 0.25;
    self->_autoHideSourceObject = YES;
    
    YBImageBrowserToolBar *toolBar = [YBImageBrowserToolBar new];
    self->_defaultToolBar = toolBar;
    self->_toolBars = @[toolBar];
    
    YBImageBrowserSheetView *sheetView = [YBImageBrowserSheetView new];
    YBImageBrowserSheetAction *saveAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].saveToPhotoAlbum identity:kYBImageBrowserSheetActionIdentitySaveToPhotoAlbum action:nil];
    sheetView.actions = @[saveAction];
    self->_defaultSheetView = sheetView;
    self->_sheetView = sheetView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self->_backgroundColor;
    [self addGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _statusBarIsHiddenBefore = [UIApplication sharedApplication].statusBarHidden;
    if (!_statusBarIsHiddenBefore) [self setStatusBarHide:YES];
    
    if (!self->_isFirstViewDidAppear) {
        
        [self addSubViews];
        
        [self updateLayoutOfSubViewsWithLayoutDirection:[YBIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
        
        [self.browserView scrollToPageWithIndex:self->_currentIndex];
 
        self->_isFirstViewDidAppear = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_statusBarIsHiddenBefore) [self setStatusBarHide:NO];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setStatusBarHide:(BOOL)hide {
    if (self.isControllerPreferredForStatusBar) {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        statusBar.alpha = hide ? 0 : 1;
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:NO];
    }
}

#pragma mark - gesture

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:respondsToLongPress:)]) {
            [self.delegate yb_imageBrowser:self respondsToLongPress:sender];
            return;
        }
        
        if (self.sheetView && (![[self currentData] respondsToSelector:@selector(yb_browserAllowShowSheetView)] || [[self currentData] yb_browserAllowShowSheetView])) {
            [self.view addSubview:self.sheetView];
            [self.sheetView yb_browserShowSheetViewWithData:[self currentData] layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
        }
    }
}

#pragma mark - private

- (void)addSubViews {
    [self.view addSubview:self.browserView];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj];
        if ([obj respondsToSelector:@selector(setYb_browserShowSheetViewBlock:)]) {
            __weak typeof(self) wSelf = self;
            [obj setYb_browserShowSheetViewBlock:^(id<YBImageBrowserCellDataProtocol> _Nonnull data) {
                __strong typeof(wSelf) sSelf = wSelf;
                if (sSelf.sheetView) {
                    [sSelf.view addSubview:sSelf.sheetView];
                    [sSelf.sheetView yb_browserShowSheetViewWithData:data layoutDirection:sSelf->_layoutDirection containerSize:sSelf->_containerSize];
                }
            }];
        }
    }];
}

- (void)updateLayoutOfSubViewsWithLayoutDirection:(YBImageBrowserLayoutDirection)layoutDirection {
    self->_layoutDirection = layoutDirection;
    CGSize containerSize = layoutDirection == YBImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YBIMAGEBROWSER_HEIGHT, YBIMAGEBROWSER_WIDTH) : CGSizeMake(YBIMAGEBROWSER_WIDTH, YBIMAGEBROWSER_HEIGHT);
    self->_containerSize = containerSize;
    
    if (self.sheetView && self.sheetView.superview)
        [self.sheetView yb_browserHideSheetViewWithAnimation:NO];
    
    [self.browserView updateLayoutWithDirection:layoutDirection containerSize:containerSize];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj yb_browserUpdateLayoutWithDirection:layoutDirection containerSize:containerSize];
    }];
}

- (BOOL)isControllerPreferredForStatusBar {
    static BOOL isControllerPreferred = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
        id value = dict[@"UIViewControllerBasedStatusBarAppearance"];
        isControllerPreferred = value ? [value boolValue] : YES;
    });
    return isControllerPreferred;
}

#pragma mark - public

- (void)setDataSource:(id<YBImageBrowserDataSource>)dataSource {
    self.browserView.yb_dataSource = dataSource;
}

- (id<YBImageBrowserDataSource>)dataSource {
    return self.browserView.yb_dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex + 1 > [self.browserView.yb_dataSource yb_numberOfCellForImageBrowserView:self.browserView]) {
        YBIBLOG_ERROR(@"The index out of range.");
    } else {
        _currentIndex = currentIndex;
        if (self.browserView.superview) [self.browserView scrollToPageWithIndex:currentIndex];
    }
}

- (void)reloadData {
    [self.browserView reloadData];
    [self.browserView scrollToPageWithIndex:self->_currentIndex];
}

- (id<YBImageBrowserCellDataProtocol>)currentData {
    return [self.dataSource yb_imageBrowserView:self.browserView dataForCellAtIndex:self.browserView.currentIndex];
}

- (void)show {
    [self showFromController:YBIBGetTopController()];
}

- (void)showFromController:(UIViewController *)fromController {
    self->_statusBarOrientationBefore = [UIApplication sharedApplication].statusBarOrientation;
    self.browserView.statusBarOrientationBefore = self->_statusBarOrientationBefore;
    [fromController presentViewController:self animated:YES completion:nil];
}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    ((YBImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages = distanceBetweenPages;
}

- (CGFloat)distanceBetweenPages {
    return ((YBImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages;
}

- (void)setGiProfile:(YBIBGestureInteractionProfile *)giProfile {
    self.browserView.giProfile = giProfile;
}

- (YBIBGestureInteractionProfile *)giProfile {
    return self.browserView.giProfile;
}

#pragma mark - internal

- (void)setHiddenSourceObject:(id)hiddenSourceObject {
    if (!self->_autoHideSourceObject) return;
    if (_hiddenSourceObject && [_hiddenSourceObject respondsToSelector:@selector(setHidden:)])
        [_hiddenSourceObject setValue:@(NO) forKey:@"hidden"];
    if (hiddenSourceObject && [hiddenSourceObject respondsToSelector:@selector(setHidden:)])
        [hiddenSourceObject setValue:@(YES) forKey:@"hidden"];
    _hiddenSourceObject = hiddenSourceObject;
}

#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}

#pragma mark - <YBImageBrowserViewDelegate>

- (void)yb_imageBrowserViewDismiss:(YBImageBrowserView *)browserView {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    if ([UIApplication sharedApplication].statusBarOrientation != self->_statusBarOrientationBefore && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = self->_statusBarOrientationBefore;
        [invocation setArgument:&val atIndex:2];
        self->_isRestoringDeviceOrientation = YES;
        [invocation invoke];
    }
    
    [self hide];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    void (^animationsBlock)(void) = ^{
        self.view.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:alpha];
    };
    void (^completionBlock)(BOOL) = ^(BOOL x){
        if (alpha == 1) [self setStatusBarHide:YES];
        if (alpha < 1) [self setStatusBarHide:NO];
    };
    if (duration <= 0) {
        animationsBlock();
        completionBlock(YES);
    } else {
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index {
    self->_currentIndex = index;
    
    id<YBImageBrowserCellDataProtocol> data = [self.dataSource yb_imageBrowserView:self.browserView dataForCellAtIndex:index];
    
    id sourceObj = nil;
    if ([data respondsToSelector:@selector(yb_browserCellSourceObject)]) sourceObj = data.yb_browserCellSourceObject;
    self.hiddenSourceObject = sourceObj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:pageIndexChanged:data:)])
        [self.delegate yb_imageBrowser:self pageIndexChanged:index data:data];
    
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.defaultToolBar && self.sheetView && [self.sheetView yb_browserActionsCount] >= 2)
            self.defaultToolBar.operationType = YBImageBrowserToolBarOperationTypeMore;
        
        if ([obj respondsToSelector:@selector(yb_browserPageIndexChanged:totalPage:data:)])
            [obj yb_browserPageIndexChanged:index totalPage:[self.dataSource yb_numberOfCellForImageBrowserView:self.browserView] data:data];
    }];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView hideTooBar:(BOOL)hidden {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
    }];
    if (self.sheetView && self.sheetView.superview && hidden)
        [self.sheetView yb_browserHideSheetViewWithAnimation:YES];
}

#pragma mark - <YBImageBrowserDataSource>

- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.dataSourceArray.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.dataSourceArray[index];
}

#pragma mark - getter

- (YBImageBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [YBImageBrowserView new];
        _browserView.yb_delegate = self;
        _browserView.yb_dataSource = self;
        _browserView.giProfile = [YBIBGestureInteractionProfile new];
    }
    return _browserView;
}

- (YBIBLayoutDirectionManager *)layoutDirectionManager {
    if (!_layoutDirectionManager) {
        _layoutDirectionManager = [YBIBLayoutDirectionManager new];
        __weak typeof(self) wSelf = self;
        [_layoutDirectionManager setLayoutDirectionChangedBlock:^(YBImageBrowserLayoutDirection layoutDirection) {
            __strong typeof(self) sSelf = wSelf;
            if (layoutDirection == YBImageBrowserLayoutDirectionUnknown || sSelf.transitionManager.isTransitioning || sSelf->_isRestoringDeviceOrientation) return;
            
            [sSelf updateLayoutOfSubViewsWithLayoutDirection:layoutDirection];
        }];
    }
    return _layoutDirectionManager;
}

- (YBIBTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [YBIBTransitionManager new];
        _transitionManager.imageBrowser = self;
    }
    return _transitionManager;
}

@end
