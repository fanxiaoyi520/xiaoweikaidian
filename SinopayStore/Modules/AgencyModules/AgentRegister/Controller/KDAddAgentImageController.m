//
//  KDAddAgentImageController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddAgentImageController.h"
#import "KDAddAgentSuccessController.h"
#import "ZFImageUtils.h"
#import "UIImage+Extension.h"
#import "ZFPreviewImageController.h"
#import "ZFReadProtocolController.h"

@interface KDAddAgentImageController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIView *imagesBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesBVHeight;

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;

@property (nonatomic, strong)NSMutableDictionary *addImagesDict;
@property (nonatomic, strong)NSArray *typeArray;
/// 0 1 2 3
@property (nonatomic, assign)NSInteger currentTag;
///上传次序
@property (nonatomic, assign)NSInteger uploadImageIndex;

@end

@implementation KDAddAgentImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"代理资料", nil);
    _addImagesDict = [[NSMutableDictionary alloc] init];
    _typeArray = @[@"monthlyStatement", @"liveAsProof", @"idCardFront", @"idCardReverseside"];
    if (_agentType == 1) {//公司
        _typeArray = @[@"monthlyStatement", @"companyRegisterCard", @"businessLicense", @"idCardFront", @"idCardReverseside"];
    }
    
    [self createImageView];
}

- (void)createImageView{
    [_imagesBV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _uploadImageIndex = 0;
    
    NSArray *imageNames = @[@"icon_yuejiedan", @"icon_zhuzhi", @"icon_zhengmian", @"icon_fanmian"];
    NSArray *titleArray = @[@"月结单", @"住址证明", @"身份证正面", @"身份证反面"];
    if (_agentType == 1) {
        imageNames = @[@"icon_yuejiedan", @"icon_gongsizhuce", @"icon_zhizhao", @"icon_zhengmian", @"icon_fanmian"];
        titleArray = @[@"月结单", @"公司注册证", @"营业执照", @"身份证正面", @"身份证反面"];
    }
    CGFloat bottom = 0;
    CGFloat Width = (SCREEN_WIDTH-55)/2;
    CGFloat height = Width*0.62;
    for (NSInteger i = 0; i < _typeArray.count; i++) {
        CGFloat x = (Width+15)*(i%2) + 20;
        CGFloat y = (height+50)*(i/2);
        
        NSString *key = _typeArray[i];
        UIImage *image = [_addImagesDict objectForKey:key];
        NSString *imageName = imageNames[i];
        BOOL candelete3 = (image);
        UIImageView *imageView = [self getImageViewWithFrame:CGRectMake(x, y, Width, height) isCanDelete:candelete3 tag:i];
        imageView.image = image?image:[UIImage imageNamed:imageName];
        [_imagesBV addSubview:imageView];
        
        UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(x, y+height+10, Width, 15)];
        titleL.text = NSLocalizedString(titleArray[i], nil);
        titleL.font = [UIFont systemFontOfSize:14];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.textColor = UIColorFromRGB(0x000000);
        titleL.alpha = 0.8;
        [_imagesBV addSubview:titleL];
        
        bottom = y+height+50;
    }
    _imagesBVHeight.constant = bottom;
}

- (UIImageView *)getImageViewWithFrame:(CGRect)frame isCanDelete:(BOOL)isCanDelete tag:(NSInteger)tag{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = tag;
    imageView.userInteractionEnabled = YES;
//    imageView.backgroundColor = UIColorFromRGB(0xEDF0FB);
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageView addGestureRecognizer:tap];
    
    if (isCanDelete) {
        UIButton *deletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deletBtn.frame = CGRectMake(imageView.width-20, -10, 30, 30);
        [deletBtn setImage:[UIImage imageNamed:@"delet_zhaopian"] forState:UIControlStateNormal];
        deletBtn.tag = tag;
        [deletBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:deletBtn];
    }
    
    return imageView;
}

#pragma mark - 点击方法
#pragma mark 点击图片
- (void)imageTap:(UITapGestureRecognizer *)tap{
    _currentTag = tap.view.tag;
    UIImage *image = [_addImagesDict objectForKey:_typeArray[_currentTag]];
    if (image) {
        [self showPreviewWith:0 images:@[image] isUrl:NO];
    } else {
        [self showImageUtilWith:1];
    }
}

#pragma mark 删除
- (void)deleteImage:(UIButton *)btn{
    [_addImagesDict removeObjectForKey:_typeArray[btn.tag]];
    [self createImageView];
}

- (void)showPreviewWith:(NSInteger)index images:(NSArray *)imageArray isUrl:(BOOL)isUrl{
    ZFPreviewImageController *piVC = [[ZFPreviewImageController alloc] init];
    piVC.isHiddenDelete = YES;
    piVC.isURL = isUrl;
    piVC.index = index;
    piVC.imageArray = (NSMutableArray *)imageArray;
    [self pushViewController:piVC];
}

- (void)showImageUtilWith:(NSInteger)count{
    ZFImageUtils *imageU = [[ZFImageUtils alloc] init];
    imageU.block = ^(NSArray<UIImage *> *photos) {
        [self dealWithImages:photos];
    };
    [imageU presentWithMaxCount:count controller:self];
}

#pragma mark 处理获取到图片
- (void)dealWithImages:(NSArray<UIImage *> *)photos{
    [_addImagesDict setObject:photos[0] forKey:_typeArray[_currentTag]];
    [self createImageView];
}

#pragma mark 同意按钮
- (IBAction)agreeBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark 用户协议
- (IBAction)protocolBtn:(id)sender {
    ZFReadProtocolController *pVC = [[ZFReadProtocolController alloc] init];
    [self pushViewController:pVC];
}

#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    if (![self isCanNextStep]) {
        return;
    }
    [[MBUtils sharedInstance] showMBInView:self.view];
    [self uploadImage];
}

- (BOOL)isCanNextStep{
    
    for (NSInteger i = 0; i < _typeArray.count; i++) {
        UIImage *image = [_addImagesDict objectForKey:_typeArray[i]];
        
        if (!image) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请完善照片信息", nil) inView:self.view];
            return NO;
        }
    }
    
    if (!_agreeBtn.selected) {
        return NO;
    }
    
    return YES;
}

- (NSString *)imageToString:(UIImage *)image{
    return [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark -- 拍照代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 退出拍照页面,对拍摄的照片编辑
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *scaleImage = [[info objectForKey:UIImagePickerControllerOriginalImage] scaleImage400];
        [self dealWithImages:@[scaleImage]];
    }];
}

#pragma mark - 上传
- (void)uploadImage{
    NSString *loginUser = @"";
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        loginUser = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    }
    
    NSString *uploadStatus = @"";
    NSString *imageKey = @"";
    NSString *imageStr = @"";
    if (_uploadImageIndex < _typeArray.count) {
        imageKey = _typeArray[_uploadImageIndex];
        imageStr = [UIImageJPEGRepresentation([_addImagesDict objectForKey:imageKey], 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        if (_uploadImageIndex == _typeArray.count-1) {
            uploadStatus = @"00";
        }
    }
    
    NSDictionary *dict = @{
                           @"image":imageStr,
                           @"imageKey":imageKey,
                           @"agentAccount":_account,
                           @"currentLoginUser":loginUser,
                           @"uploadStatus":uploadStatus,
                           TxnType:@"07"
                           };
    
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            if (self.uploadImageIndex < _typeArray.count-1) {
                self.uploadImageIndex++;
                [self uploadImage];
            } else {
                KDAddAgentSuccessController *suVC = [[KDAddAgentSuccessController alloc] init];
                [self pushViewController:suVC];
                [self removeVC];
            }
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(id error) {
        
    }];
}

- (void)removeVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSMutableArray *resultVC = [NSMutableArray arrayWithObjects:vcArray[0], vcArray[vcArray.count-1], nil];
    [self.navigationController setViewControllers:resultVC animated:NO];
    
    if ([_account isEqualToString:@"zz"]) {
        [self imageWithScreenshot];
    }
}

- (UIImage *)imageWithScreenshot {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    UIImage *screenImage = [UIImage imageWithData:imageData];
    if (screenImage) {
        return nil;
    }
    return screenImage;
}

@end
