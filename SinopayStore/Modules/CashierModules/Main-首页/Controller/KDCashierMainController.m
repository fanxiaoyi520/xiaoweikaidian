//
//  KDCashierMainController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierMainController.h"
#import "KDAwardRecodeViewController.h"
#import "KDScanViewController.h"
#import "KDWithdrawalViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZFTabBarViewController.h"
#import "ZFNavigationController.h"
#import "KDWithdrawalDetailsViewController.h"


@interface KDCashierMainController ()


/** 可提现金额Label */
@property(nonatomic, weak) UILabel *amountLabel;

/** 可提现金额 */
@property(nonatomic, copy) NSString *bounty;

@end

@implementation KDCashierMainController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.homeNaviTitle = @" ";
    
    self.homeNaviTitle = NSLocalizedString(@"- 奖励金 -", nil);
    
    [self initView];
    [self getWithdrawalAmount];
    //检查版本
    [self checkVersion];
    
    //撤销奖励通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rewardVoidNotification:) name:@"voidRewardNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([ZFGlobleManager getGlobleManager].isRWA) {
        [self getWithdrawalAmount];
    }
    
    NSString *transNumber = [[NSUserDefaults standardUserDefaults] objectForKey:TRANS_Number];
    if (transNumber.length > 0) {//后台推送过来 没有点击提示框
        [self getWithdrawalAmount];
        //清空transNumber
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TRANS_Number];
    }
}

- (void)rewardVoidNotification:(NSNotification *)notify {
    // 获取跟控制器
    UIViewController *rootVC = nil;
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    ZFTabBarViewController *tabVC = (ZFTabBarViewController *)window.rootViewController;
    rootVC = [(ZFNavigationController *)[tabVC selectedViewController] visibleViewController];
    NSString *transNumber = [[NSUserDefaults standardUserDefaults] objectForKey:TRANS_Number];
    
    if (transNumber.length > 0) {
        DLog(@"非前台点击通知，跳到详情页");
        
        // 跳转到消息列表页面
        KDWithdrawalDetailsViewController *wdvc = [[KDWithdrawalDetailsViewController alloc] init];
        wdvc.transNumber = transNumber;
        [rootVC.navigationController pushViewController:wdvc animated:YES];
        
        //清空transNumber
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TRANS_Number];
    }
    
    // 振动模式才有效
    if (@available(iOS 9.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
            //播放震动完事调用的块
        });
    }
    
    //刷新金额
    [self getWithdrawalAmount];
}

#pragma mark - 初始化视图
- (void)initView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT*0.2)];
    topView.backgroundColor = MainThemeColor;
    [self.view addSubview:topView];
    
    // 金额
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topView.height-40)];
    amountLabel.font = [UIFont boldSystemFontOfSize:36.0];
    amountLabel.text = @"0.00";
    amountLabel.textColor = [UIColor whiteColor];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:amountLabel];
    self.amountLabel = amountLabel;
    
    //添加刷新手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAmountLabel)];
    [_amountLabel addGestureRecognizer:tap];
    
    // 提现按钮
    UIButton *withdrawalBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(topView.frame)+30, SCREEN_WIDTH-80, 44)];
    [withdrawalBtn setTitle:NSLocalizedString(@"立即提现", nil) forState:UIControlStateNormal];
    [withdrawalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [withdrawalBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.8) forState:UIControlStateHighlighted];
    withdrawalBtn.layer.cornerRadius = 5.0f;
    withdrawalBtn.backgroundColor = MainThemeColor;
    [withdrawalBtn addTarget:self action:@selector(withdrawalBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withdrawalBtn];
    
    // 左右按钮
    CGFloat btnWidth = (SCREEN_WIDTH-35*3)*0.5;
//    // 验证码登录, 密码登录
//    for (int i = 0; i < 2; i++) {
//        UIButton *homeBtn = [[UIButton alloc] init];
//        NSString *title = @"";
//        NSString *imageName = @"";
//
//        if (i == 0) {
//            homeBtn.tag = CashierBtnTypeAward;
//            imageName = @"icon_reward";
//            title = NSLocalizedString(@"奖励记录", nil);
//        } else {
//            homeBtn.tag = CashierBtnTypeScan;
//            imageName = @"icon_scan";
//            title = NSLocalizedString(@"扫一扫", nil);
//        }
//        homeBtn.backgroundColor = ZFColor(228, 239, 250);
//        homeBtn.layer.cornerRadius = 10.0f;
//        homeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
//        [homeBtn setTitle:title forState:UIControlStateNormal];
//        [homeBtn setTitleColor:MainFontColor forState:UIControlStateNormal];
//        [homeBtn setTitleColor:UIColorFromRGB(0x4A90E2) forState:UIControlStateHighlighted];
//        [homeBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//        homeBtn.frame = CGRectMake(i*btnWidth+35*(i+1), CGRectGetMaxY(withdrawalBtn.frame)+80, btnWidth, btnWidth*1.15);
//        [homeBtn addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [homeBtn setAdjustsImageWhenHighlighted:NO];
//        [self.view addSubview:homeBtn];
//        // 设置偏移量
//        CGFloat totalHeight = homeBtn.imageView.height + homeBtn.titleLabel.height;
//        homeBtn.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight-homeBtn.imageView.height)-10, 0, 0, -homeBtn.titleLabel.width);
//        homeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -homeBtn.imageView.width, -(totalHeight-homeBtn.titleLabel.height)-10, 0);
//    }
    
    NSArray *imageArr = @[@"icon_reward", @"icon_scan"];
    NSArray *titleArr = @[NSLocalizedString(@"奖励记录", nil), NSLocalizedString(@"扫一扫", nil)];
    // 奖励记录、扫一扫
    for (int i = 0; i < 2; i++) {
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = ZFColor(228, 239, 250);
        backgroundView.layer.cornerRadius = 10;
        backgroundView.tag = i;
        backgroundView.frame = CGRectMake(i*btnWidth+35*(i+1), CGRectGetMaxY(withdrawalBtn.frame)+80, btnWidth, btnWidth*1.15);
        [self.view addSubview:backgroundView];

        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(backgroundViewClicked:)];
        [backgroundView addGestureRecognizer:tap];

        CGFloat bWidth = backgroundView.frame.size.width;
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(bWidth*0.2, 10, 35, 35);
        imageView.image = [UIImage imageNamed:imageArr[i]];
        imageView.center = CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height/2-15);
        [backgroundView addSubview:imageView];

        UILabel *titleL = [UILabel new];
        titleL.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, bWidth, 20);
        titleL.text = titleArr[i];
        titleL.textColor = MainFontColor;
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.font = [UIFont systemFontOfSize:15.0];
        titleL.adjustsFontSizeToFitWidth = YES;
        [backgroundView addSubview:titleL];
    }
}

#pragma mark - 点击方法
- (void)tapAmountLabel{
    _amountLabel.userInteractionEnabled = NO;
    dispatch_after(5, dispatch_get_main_queue(), ^{
        _amountLabel.userInteractionEnabled = YES;
    });
    [self getWithdrawalAmount];
}

- (void)withdrawalBtnClicked {
    KDWithdrawalViewController *vc = [KDWithdrawalViewController new];
    vc.withdrawalMoney = self.bounty;
    [self pushViewController:vc];
}

// 选择登录类型
- (void)homeBtnClicked:(UIButton *)sender {
    if (sender.tag == CashierBtnTypeAward) {
        KDAwardRecodeViewController *vc = [KDAwardRecodeViewController new];
        [self pushViewController:vc];
    } else {
        [self scanQRCode];
    }
}

- (void)backgroundViewClicked:(UITapGestureRecognizer *)gesr {
    NSInteger tag = gesr.view.tag;
    if (tag == 0) {
        KDAwardRecodeViewController *vc = [KDAwardRecodeViewController new];
        [self pushViewController:vc];
    } else {
        [self scanQRCode];
    }
}


#pragma mark - 网络请求
// 获取可提现金额
- (void)getWithdrawalAmount {
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"txnType": @"33",
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID
                                 };
//    [[MBUtils sharedInstance] showMBInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                // 赋值
                self.bounty = [NSString stringWithFormat:@"%.2f", [[requestResult objectForKey:@"bounty"] floatValue]/100.0];
                // 清空属性
                [ZFGlobleManager getGlobleManager].isRWA = NO;
                // 更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.amountLabel.text = self.bounty;
                });
            } else {
                [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

#pragma mark 版本更新
- (void)checkVersion{
    //检测本地版本
    NSString *currVersion = [[ZFGlobleManager getGlobleManager] getCurrentVersion];
    currVersion = [currVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    DLog(@"version = %zd", [currVersion integerValue]);
    NSString *title = NSLocalizedString(@"发现新版本", nil);
    NSString *message = NSLocalizedString(@"推荐更新", nil);
    
    NSDictionary *dict = @{@"appType":@"IOS",
                           @"txnType" : @"22"};
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        NSDictionary *resultDic = (NSDictionary *)requestResult;
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSString *serviceVersion = [resultDic objectForKey:@"versionNumber"];
            serviceVersion = [serviceVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            //服务器有新版本
            if ([serviceVersion integerValue] > [currVersion integerValue]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                NSString *urlStr = [resultDic objectForKey:@"versionUrl"];
                
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    exit(0);
                }];
                
                [alert addAction:confirmAction];
                //是否强制更新
                if ([[resultDic objectForKey:@"forceUpdate"] isEqualToString:@"0"]) {//不强制
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
                    
                    [alert addAction:cancelAction];
                }
                [self.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - 其他方法
- (void)scanQRCode{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检查打开相机的权限是否打开
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            NSString *title = [appName stringByAppendingString:NSLocalizedString(@"不能访问您的相机", nil)];
            [XLAlertController acWithTitle:title msg:NSLocalizedString(@"请前往\"设置\"打开相机访问权限", nil) confirmBtnTitle:NSLocalizedString(@"打开", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }];
        } else {
            KDScanViewController *vc = [[KDScanViewController alloc] init];
            [self pushViewController:vc];
        }
    } else {
        [XLAlertController acWithMessage:NSLocalizedString(@"该设备不支持相机", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil)];
    }
}


@end
