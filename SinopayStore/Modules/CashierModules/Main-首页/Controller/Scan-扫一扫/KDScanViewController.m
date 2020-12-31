//
//  KDScanViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "SGQRCodeScanningView.h"
#import "SGQRCodeConst.h"
#import "UIImage+SGHelper.h"
#import "KDScanResultViewController.h"
#import "YYModel.h"
#import "KDScanResult.h"
#import "KDInputReferenceController.h"

@interface KDScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/// 会话对象
@property (nonatomic, strong) AVCaptureSession *session;
/// 图层类
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@end

@implementation KDScanViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![_session isRunning]) {
        [self.session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.naviTitle = NSLocalizedString(@"扫一扫", nil);
    [self.view addSubview:self.scanningView];
    [self setupSGQRCodeScanning];
    
    //右上角按钮
    UIButton *inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inputBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    inputBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    inputBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [inputBtn setTitle:NSLocalizedString(@"手动输入", nil) forState:UIControlStateNormal];
    [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inputBtn addTarget:self action:@selector(inputYourself) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputBtn];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if ([_session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

//跳转到手动输入页
- (void)inputYourself{
    KDInputReferenceController *irVC = [[KDInputReferenceController alloc] init];
    [self pushViewController:irVC];
    [self removeVC];
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64) layer:self.view.layer];
    }
    return _scanningView;
}

- (void)setupSGQRCodeScanning {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 5.1 添加会话输入
    [_session addInput:input];
    
    // 5.2 添加会话输出
    [_session addOutput:output];
    
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    // 9、启动会话
    [_session startRunning];
}

#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        DLog(@"%@", obj.stringValue);
        [self dealWithResult:obj.stringValue];
    }
}

#pragma mark 处理扫描结果
- (void)dealWithResult:(NSString *)result{
    DLog(@"result = %@", result);
    
    if ([result hasPrefix:ScanQRCodeFormat]) {
        // 1、如果扫描完成，停止会话
        [self.session stopRunning];
        // 2、删除预览图层
        [self.previewLayer removeFromSuperlayer];
        //关闭用户交互 防止侧滑
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        // 扫描到的信息
        [self getScanResultWithSerialNumber:[result substringFromIndex:ScanQRCodeFormat.length]];
    } else {
        [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"二维码无效", nil) inView:self.view];
    }
}

- (void)removeVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    // 移除扫描控制器,下个页面可以直接回到首页
    [vcArray removeObjectAtIndex:1];
    [self.navigationController setViewControllers:vcArray animated:NO];
}


#pragma mark - 网络请求
// 获取扫描结果
- (void)getScanResultWithSerialNumber:(NSString *)num {
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"serialNumber": num,
                                 @"txnType": @"42",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            KDScanResultViewController *srVC = [[KDScanResultViewController alloc] init];
            srVC.scanResult = [KDScanResult yy_modelWithJSON:requestResult];
            [self pushViewController:srVC];
            [self removeVC];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOFAILEDTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOFAILEDTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
