//
//  KDAddMerImageController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddMerImageController.h"
#import "ZFPreviewImageController.h"
#import "ZFImageUtils.h"
#import <Photos/Photos.h>
#import "UIImage+Extension.h"
#import "KDAddMerAuthenController.h"
#import "ZFReadProtocolController.h"
#import "NSString+SHA.h"

#define Width (SCREEN_WIDTH-70)/3
#define MAXCOUNT 6

@interface KDAddMerImageController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (nonatomic, strong)NSMutableArray *imageArray;
///图片上传到第几个
@property (nonatomic, assign)NSInteger uploadImageIndex;
@end

@implementation KDAddMerImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"图片信息", nil);
    _topHeight.constant = IPhoneXTopHeight;
    _imageArray = [[NSMutableArray alloc] init];
    [self createImageView];
    [self cs_getNameWith:@"2"];
}

- (void)createImageView{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _uploadImageIndex = 0;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 16)];
    tipLabel.text = NSLocalizedString(@"上传图片", nil);
    tipLabel.font = [UIFont boldSystemFontOfSize:15];
    tipLabel.alpha = 0.8;
    [_scrollView addSubview:tipLabel];
    
    //其他图片
    NSInteger count = _imageArray.count;
    if (count < 6) {
        count = count+1;
    }
    CGFloat bottom = tipLabel.bottom;
    for (NSInteger i = 0; i < count; i++) {
        CGFloat x = (Width+15)*(i%3) + 20;
        CGFloat y = (Width+10)*(i/3) + 15 + tipLabel.bottom;
        
        if (i == count-1 && _imageArray.count < MAXCOUNT) {
            UIImageView *addIV = [self getImageViewWithFrame:CGRectMake(x, y, Width, Width) isCanDelete:NO tag:1000];
            addIV.image = [UIImage imageNamed:@"icon_photo_add"];
            [_scrollView addSubview:addIV];
        } else {
            UIImageView *imageView = [self getImageViewWithFrame:CGRectMake(x, y, Width, Width) isCanDelete:YES tag:i];
            imageView.image = _imageArray[i];
            [_scrollView addSubview:imageView];
        }
        bottom = y+Width;
    }
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, bottom+30);
}

- (UIImageView *)getImageViewWithFrame:(CGRect)frame isCanDelete:(BOOL)isCanDelete tag:(NSInteger)tag{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = tag;
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = UIColorFromRGB(0xEDF0FB);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
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

#pragma mark 点击图片
- (void)imageTap:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    if (tag == 1000) {
        NSInteger count = MAXCOUNT-_imageArray.count;
        [self showImageUtilWith:count];
    }
    
    if (tag < 100) {//点击预览图片
        ZFPreviewImageController *piVC = [[ZFPreviewImageController alloc] init];
        piVC.isHiddenDelete = YES;
        piVC.index = tag;
        piVC.imageArray = _imageArray;
        [self pushViewController:piVC];
    }
}

- (void)showImageUtilWith:(NSInteger)count{
    ZFImageUtils *imageU = [[ZFImageUtils alloc] init];
    imageU.block = ^(NSArray<UIImage *> *photos) {
        [self dealWithImages:photos];
    };
    [imageU presentWithMaxCount:count controller:self];
}

#pragma mark 删除图片
- (void)deleteImage:(UIButton *)btn{
    NSInteger tag = btn.tag;
    if (tag < _imageArray.count) {
        [_imageArray removeObjectAtIndex:tag];
        [self createImageView];
    }
}

#pragma mark 处理获取到图片
- (void)dealWithImages:(NSArray<UIImage *> *)photos{
    for (NSInteger i = 0; i < photos.count; i++) {
        [self.imageArray addObject:photos[i]];
    }
    
    [self createImageView];
}

#pragma mark 点击方法
#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    if (_imageArray.count == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请添加图片", nil) inView:self.view];
        return;
    }
    
    if (!_agreeBtn.selected) {
        return;
    }
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [self uploadImage];
}

#pragma mark 同意协议按钮
- (IBAction)agreeBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        _nextStepBtn.enabled = NO;
        _nextStepBtn.alpha = 0.8;
    } else {
        _nextStepBtn.enabled = YES;
        _nextStepBtn.alpha = 1;
    }
}

#pragma mark 协议
- (IBAction)protocolBtn:(id)sender {
    ZFReadProtocolController *pVC = [[ZFReadProtocolController alloc] init];
    pVC.protocolType = 1;
    [self pushViewController:pVC];
}

#pragma mark - delegate
#pragma mark 拍照代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 退出拍照页面,对拍摄的照片编辑
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] scaleImage400];
        [self dealWithImages:@[image]];
    }];
}

#pragma mark - 数据
- (void)uploadImage{
    NSString *imageStr = [UIImageJPEGRepresentation(_imageArray[_uploadImageIndex], 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSDictionary *dict = @{
                           @"merTemNo":_merTemNo,
                           @"imageType":@"LICENCE",
                           @"imageInfo":imageStr,
                           @"indexKey":[NSString stringWithFormat:@"%zd", _uploadImageIndex],
                           @"reqType":@"13"
                           };
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            if (self.uploadImageIndex < _imageArray.count-1) {
                self.uploadImageIndex++;
                [self uploadImage];
            } else {
                [[MBUtils sharedInstance] dismissMB];
                KDAddMerAuthenController *auVC = [[KDAddMerAuthenController alloc] init];
                auVC.merTemNo = _merTemNo;
                auVC.phoneNum = _phoneNum;
                auVC.areaNum = _areaNum;
                [self pushViewController:auVC];
            }
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (NSString *)cs_getNameWith:(NSString *)idNum{
    if ([idNum isKindOfClass:[NSNull class]] || idNum.length < 20) {
        return @"";
    }
    NSInteger num = [idNum integerValue];
    NSString *name = @"";
    switch (num) {
        case 0:
            name = _phoneNum;
            break;
        case 2:{
            if ([_areaNum isEqualToString:_phoneNum] && _areaNum.length > 0) {
                name = @"SUV_MOTO";
            } else {
                name = [_phoneNum substringFromIndex:2];
            }
        }
            break;
        case 3:{
            NSDictionary *d = @{
                                @"Peter":@"86",
                                @"Tom":@"825",
                                @"Jack":@"65",
                                @"Chiee":@"852",
                                @"Lee":@"64"
                                };
            name = [d objectForKey:idNum];
            if (!name) {
                name = @"wtf";
            }
        }
            break;
        case 4:{
            NSLog(@"%@", idNum);
            name = @"noone";
        }
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:[NSString stringWithFormat:@"SSKey_%@", idNum]];
    return [name SHA256String];
}

@end
