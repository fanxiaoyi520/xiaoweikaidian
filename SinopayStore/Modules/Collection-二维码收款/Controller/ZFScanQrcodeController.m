//
//  ZFScanQrcodeController.m
//  newupop
//
//  Created by 中付支付 on 2017/8/2.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFScanQrcodeController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "SGQRCodeScanningView.h"
#import "SGQRCodeConst.h"
#import "UIImage+SGHelper.h"
#import "KDScanTradeResultController.h"

@interface ZFScanQrcodeController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/// 会话对象
@property (nonatomic, strong) AVCaptureSession *session;
/// 图层类
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@property (nonatomic, strong)NSString *resultStr;

@end

@implementation ZFScanQrcodeController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![_session isRunning]) {
        [self.session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scanningView];
    [self createRightBtn];
    [self setupSGQRCodeScanning];
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

- (void)createRightBtn{
    // 返回按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(15, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, 22, 22);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_nav_return"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

- (void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) layer:self.view.layer];
    }
    return _scanningView;
}

- (void)removeScanningView {
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)rightBarButtonItenAction{
    [self readImageFromAlbum];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 栅栏函数
    dispatch_barrier_async(queue, ^{
        [self removeScanningView];
    });
}

- (void)readImageFromAlbum {
    
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
                        imagePicker.delegate = self;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    });
                }
            }];
            
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请去设置中打开访问相册开关", nil) preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
            [alertC addAction:cancel];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"无法访问相册", nil) preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }
}
#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - - 从相册中识别二维码, 并进行界面跳转
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    image = [UIImage imageSizeWithScreenImage:image];
    
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        DLog(@"scannedResult - - %@", scannedResult);
        [self dealWithResult:scannedResult];
    }
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
        // 1、如果扫描完成，停止会话
        [self.session stopRunning];
        // 2、删除预览图层
        [self.previewLayer removeFromSuperlayer];
        
        [self dealWithResult:obj.stringValue];
    }
}

#pragma mark 处理扫描结果
- (void)dealWithResult:(NSString *)result{
    if (result.length < 1) {
        [self.session startRunning];
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
        return;
    }
//    if (![result hasPrefix:@"hQVDUFY"]) {
//        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"二维码格式错误", nil) inView:self.view];
//        [self.session startRunning];
//        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
//        return;
//    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *locationStr = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"location"]];
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"qrCode":result,
                            @"merId":[ZFGlobleManager getGlobleManager].merID,
                            @"termId":[ZFGlobleManager getGlobleManager].terID,
                            @"txnAmt":_amount,
                            @"txnType":@"69",
                            @"location":locationStr,
                            };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        KDScanTradeResultController *srVC = [[KDScanTradeResultController alloc] init];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            srVC.tradeType = 0;
            srVC.amount = self.amount;
            srVC.cardNo = [requestResult objectForKey:@"cardNo"];
        } else {
            srVC.tradeType = 1;
            srVC.errMsg = [requestResult objectForKey:@"msg"];
        }
        [self pushViewController:srVC];
        [self removeVC];
    } failure:^(id error) {
        
    }];
}

- (void)removeVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    // 移除中间的控制器,下个页面可以直接回到首页
    [vcArray removeObjectAtIndex:1];
    [self.navigationController setViewControllers:vcArray animated:NO];
}

@end
