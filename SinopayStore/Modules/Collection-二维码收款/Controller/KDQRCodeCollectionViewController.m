//
//  KDQRCodeCollectionViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDQRCodeCollectionViewController.h"
#import "ZFTabBarViewController.h"
#import "ZFNavigationController.h"
#import "SGQRCodeTool.h"
#import "XLSwitchBtn.h"
#import "KDAuthenticateViewController.h"
#import "KDOrderDetailController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KDReceiptDetailController.h"
#import "ZFScanQrcodeController.h"
#import "KDSetMoneyController.h"

///高度比
#define HEIGHT_RATE SCREEN_HEIGHT/667

@interface KDQRCodeCollectionViewController ()<UITextFieldDelegate,CLLocationManagerDelegate>
///提示店铺名
@property (nonatomic, strong)UILabel *toplabel;
/** 二维码 */
@property (nonatomic, weak) UIImageView *qrcodeIV;
/** 蓝色背景 */
@property(nonatomic, weak) UIView *bgView;
/** 白色视图 */
@property(nonatomic, weak) UIView *whiteView;
/** 保存按钮 */
@property(nonatomic, weak) UIButton *saveBtn;

/** 银联扫码枪二维码 **/
@property(nonatomic, copy) NSString *upopCode;
/** 银联国际二维码 **/
@property(nonatomic, copy) NSString *unionPayCode;
/** 请求失败视图 */
@property(nonatomic, weak) UIView *failureView;

/** 推送 收款成功白色蒙版视图 */
@property(nonatomic, weak) UIView *collectionView;
/** 推送 交易金额 */
@property(nonatomic, weak) UILabel *amountLabel;
/** 推送 手机尾号 */
@property(nonatomic, weak) UILabel *mobilSuffixLabel;

///放大视图
@property (nonatomic, strong)UIView *bigViewBack;
///放大的二维码
@property (nonatomic, strong)UIImageView *bigQRCodeImage;

@property (nonatomic, strong)UIView *bottomTipBgView;

///2018-11-20
///收款码按钮
@property (nonatomic, strong)UIButton *showCodeBtn;
///扫码按钮
@property (nonatomic, strong)UIButton *scanBtn;
///按钮下横线
@property (nonatomic, strong)UILabel *lineLabel;
///扫一扫底部背景
@property (nonatomic, strong)UIView *scanBackView;
///金额输入框
@property (nonatomic, strong)UITextField *amountTF;
@property (nonatomic, strong)UITextField *moneyTF;
///设置金额、保存图片按钮底部
@property (nonatomic, strong)UIView *setAndSaveBackView;
///设置金额按钮
@property (nonatomic, strong)UIButton *setMoneyBtn;
///显示金额标签
@property (nonatomic, strong)UILabel *moneyLabel;
///金额
@property (nonatomic, strong)NSString *money;
///1:云闪付 2：支付宝
@property (nonatomic, strong)NSString *payType;
///支付类型图标
@property (nonatomic, strong)NSString *logoImageName;
@property (nonatomic, strong) UIView *onlyAlipybgView;
@property (nonatomic, assign)NSInteger i_tag;
@end


@implementation KDQRCodeCollectionViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[ZFGlobleManager getGlobleManager] determineWhetherTheAPPOpensTheLocation]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示", nil)
                                                          message:NSLocalizedString(@"请到设置->隐私->定位服务中开启【小微开店】定位服务，以便于距离筛选能够准确获得你的位置信息", nil)
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"设置", nil),nil];
        [alert show];
    } else {
        [[TZLocationManager manager] startLocation];
        [[TZLocationManager manager] startLocationWithGeocoderBlock:^(NSArray *array) {
            if (array.count > 0){
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[[ZFGlobleManager getGlobleManager] getLocationArray:array] forKey:@"location"];
                [userDefaults synchronize];
            } else {
                NSLog(@"No results were returned.");
            }
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{//点击弹窗按钮后
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (ALIPAYANDUNIONPAY) {
        self.payType = @"1";
        self.logoImageName = @"logo_unionpay";
    } else if (ONLIALIPAY) {
        self.payType = @"2";
        self.logoImageName = @"icon_aipayerweima";
    } else {
        self.payType = @"1";
        self.logoImageName = @"logo_unionpay";
    }

    [self setHomeNaviTitle:[ZFGlobleManager getGlobleManager].merName];
    [self setupInfoView];
    [self isPermissionedPushNotification];

    // 创建通知观察者,监听用户点击查看前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmReadNoticeContent:) name:@"ReadRemoteNotificationContent" object:nil];
    
    //检查版本
    [self checkVersion];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 判断资料是否提交
    [self infoCommited];
    NSString *orderID = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_ORDERID];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UNREAD_MESSAGE] || orderID.length>0) {
        DLog(@"非前台点击通知，收到消息--有未读消息");
        [self.tabBarController.tabBar showBadgeOnItemIndex:1];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hiddenBigImage];
}

#pragma mark - 初始化视图
#pragma mark 顶部切换按钮视图
- (void)createSwitchBtn{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [self.bgView addSubview:backView];
    
    NSArray *titleArray = @[NSLocalizedString(@"收款码", nil),NSLocalizedString(@"扫一扫收款", nil)];
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, backView.height-10);
        btn.tag = i+100;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.lineBreakMode = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
            
        if (i == 0) {
            _showCodeBtn = btn;
        } else {
            btn.alpha = 0.6;
            _scanBtn = btn;
        }
    }
    _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backView.height-5, 60, 2)];
    _lineLabel.backgroundColor = [UIColor whiteColor];
    _lineLabel.centerX = _showCodeBtn.centerX;
    [backView addSubview:_lineLabel];
}

- (void)switchBtnClick:(UIButton *)btn{
    NSInteger tag = btn.tag;
    btn.alpha = 1;
    _lineLabel.centerX = btn.centerX;
    
    if (tag == 100) {
        [_amountTF resignFirstResponder];
        _scanBtn.alpha = 0.6;
        _scanBackView.hidden = YES;
        _whiteView.hidden = NO;
        _bottomTipBgView.hidden = NO;
        if (ALIPAYANDUNIONPAY) {
            
        } else if(ONLIALIPAY) {
            if ([self.money doubleValue] < 0.01) {
                [self.onlyAlipybgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.moneyTF becomeFirstResponder];
                    obj.hidden = NO;
                    self.onlyAlipybgView.hidden = NO;
                }];
                [_setAndSaveBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.hidden = YES;
                    self.qrcodeIV.hidden = YES;
                }];
            }
        } else {
            
        }
    } else {
        [_amountTF becomeFirstResponder];
        _showCodeBtn.alpha = 0.6;
        _scanBackView.hidden = NO;
        _whiteView.hidden = YES;
        _bottomTipBgView.hidden = YES;
        
        if (ALIPAYANDUNIONPAY) {
            
        } else if(ONLIALIPAY) {
            [self.onlyAlipybgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.hidden = YES;
                self.onlyAlipybgView.hidden = YES;
            }];
        } else {
            
        }
    }
}

#pragma mark 扫一扫视图
- (void)createScanBackView{
    _scanBackView = [UIView new];
    _scanBackView.layer.cornerRadius = 5.0f;
    _scanBackView.backgroundColor = [UIColor whiteColor];
    _scanBackView.frame = CGRectMake(20, 45, SCREEN_WIDTH-40, SCREEN_HEIGHT*0.64);
    [self.bgView addSubview:_scanBackView];

    // 文字
    UILabel *toplabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _scanBackView.width, 50)];
    toplabel.layer.cornerRadius = 5.0f;
    toplabel.layer.masksToBounds = YES;
    toplabel.backgroundColor = GrayBgColor;
    toplabel.text = [ZFGlobleManager getGlobleManager].merShortName;
    toplabel.textColor = MainThemeColor;
    toplabel.textAlignment = NSTextAlignmentCenter;
    toplabel.font = [UIFont boldSystemFontOfSize:25.0];
    [_scanBackView addSubview:toplabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, toplabel.bottom + 20, 160, 16)];
    label.text = NSLocalizedString(@"收款金额", nil);
    label.font = [UIFont boldSystemFontOfSize:15];
    label.alpha = 0.6;
    [_scanBackView addSubview:label];
    
    UILabel *symbolL = [[UILabel alloc] initWithFrame:CGRectMake(20, label.bottom+15, 70, 30)];
    symbolL.text = [ZFGlobleManager getGlobleManager].merTxnCurr;
    symbolL.font = [UIFont boldSystemFontOfSize:28];
    symbolL.adjustsFontSizeToFitWidth = YES;
    symbolL.alpha = 0.8;
    [_scanBackView addSubview:symbolL];
    
    _amountTF = [[UITextField alloc] initWithFrame:CGRectMake(symbolL.right+10, symbolL.y, _scanBackView.width-symbolL.right-30, 40)];
    _amountTF.keyboardType = UIKeyboardTypeDecimalPad;
    _amountTF.font = [UIFont boldSystemFontOfSize:36];
    _amountTF.delegate = self;
    _amountTF.alpha = 0.8;
    _amountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_scanBackView addSubview:_amountTF];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, _amountTF.bottom+10, _scanBackView.width-40, 1)];
    lineView.backgroundColor = MainThemeColor;
    lineView.alpha = 0.2;
    [_scanBackView addSubview:lineView];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(20, lineView.bottom+30, _scanBackView.width-40, 40);
    [confirmBtn setTitle:NSLocalizedString(@"扫码收款", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.cornerRadius = 5.0;
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [_scanBackView addSubview:confirmBtn];
    
    UILabel *tipsLab = [UILabel new];
    [_scanBackView addSubview:tipsLab];
    tipsLab.text = NSLocalizedString(@"当前支持:", nil);
    tipsLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    tipsLab.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    CGSize size = [tipsLab.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12]}];
    CGSize statuseStrSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    tipsLab.frame = CGRectMake(20, confirmBtn.bottom + 19, statuseStrSize.width, 12);
    
    NSArray *imageArray = nil;
    if (ALIPAYANDUNIONPAY) {
        imageArray = @[@"icon_unionpay18x18",@"icon_alipay18x18"];
    } else if (ONLIALIPAY) {
        imageArray = @[@"icon_alipay18x18"];
    } else {
        imageArray = @[@"icon_unionpay18x18"];
    }
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [UIImageView new];
        [_scanBackView addSubview:imageView];
        imageView.frame = CGRectMake(tipsLab.right+6+idx*(18+6), confirmBtn.bottom+16, 18, 18);
        imageView.image = [UIImage imageNamed:imageArray[idx]];
    }];
     
    _scanBackView.height = tipsLab.bottom+19;
}

- (void)confirmClick{
    _i_tag = 0;
    [[TZLocationManager manager] startLocation];
    [[TZLocationManager manager] startLocationWithGeocoderBlock:^(NSArray *array) {
        if (array.count > 0){
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[[ZFGlobleManager getGlobleManager] getLocationArray:array] forKey:@"location"];
            [userDefaults synchronize];
            
            [_amountTF resignFirstResponder];
            NSString *amount = _amountTF.text;
            if ([amount doubleValue] < 0.01) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入金额", nil) inView:self.view];
                return;
            }
            
            AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示", nil)
                                                                  message:NSLocalizedString(@"未获得授权使用相机，请在iOS\"设置中\"-\"隐私\"-\"相机\"中打开", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"设置", nil),nil];
                [alert show];
            } else {
                _i_tag = _i_tag + 1;
                if (_i_tag < 2) {
                    ZFScanQrcodeController *scanVC = [[ZFScanQrcodeController alloc] init];
                    scanVC.amount = [NSString stringWithFormat:@"%.f", [amount doubleValue]*100];
                    [self pushViewController:scanVC];
                }
            }
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"No results were returned.", nil) inView:self.view];
            NSLog(@"No results were returned.");
        }
    }];
}

#pragma mark 收款码视图
- (void)setupInfoView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-44)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    self.bgView = bgView;
    
    [self createSwitchBtn];
    [self createScanBackView];
    // 白色容器视图
    UIView *whiteView = [UIView new];
    whiteView.layer.cornerRadius = 5.0f;
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.frame = CGRectMake(20, 45, SCREEN_WIDTH-40, SCREEN_HEIGHT*0.63);
    [bgView addSubview:whiteView];
    self.whiteView = whiteView;
    
    // 文字
    _toplabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, whiteView.width, 50)];
    _toplabel.layer.cornerRadius = 5.0f;
    _toplabel.layer.masksToBounds = YES;
    _toplabel.backgroundColor = GrayBgColor;
    _toplabel.text = [ZFGlobleManager getGlobleManager].merShortName;
    _toplabel.textColor = MainThemeColor;
    _toplabel.textAlignment = NSTextAlignmentCenter;
    _toplabel.font = [UIFont boldSystemFontOfSize:25.0];
    [whiteView addSubview:_toplabel];
    
    // 二维码
    UIImageView *qrcodeIV = [UIImageView new];
    qrcodeIV.size = CGSizeMake(SCREEN_WIDTH*0.45, SCREEN_WIDTH*0.45);
    qrcodeIV.x = (whiteView.width-qrcodeIV.width)/2;
    qrcodeIV.y = _toplabel.bottom+25*HEIGHT_RATE;
    [whiteView addSubview:qrcodeIV];
    self.qrcodeIV = qrcodeIV;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage)];
    [self.qrcodeIV addGestureRecognizer:tap];
    
    //金额
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, qrcodeIV.bottom+10, whiteView.width-40, 30)];
    _moneyLabel.font = [UIFont boldSystemFontOfSize:28];
    _moneyLabel.textAlignment = NSTextAlignmentCenter;
    [whiteView addSubview:_moneyLabel];

    _setAndSaveBackView = [[UIView alloc] initWithFrame:CGRectMake(0, qrcodeIV.bottom+50*HEIGHT_RATE, _whiteView.width, 16)];
    [whiteView addSubview:_setAndSaveBackView];
     
    _setMoneyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _setMoneyBtn.frame = CGRectMake(0, 0, _setAndSaveBackView.width/2, _setAndSaveBackView.height);
    [_setMoneyBtn setTitle:NSLocalizedString(@"设置金额", nil) forState:UIControlStateNormal];
    _setMoneyBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_setMoneyBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [_setMoneyBtn addTarget:self action:@selector(setMoneyClick) forControlEvents:UIControlEventTouchUpInside];
    [_setAndSaveBackView addSubview:_setMoneyBtn];
    
    UIView *verticalL = [[UIView alloc] initWithFrame:CGRectMake(_setMoneyBtn.right, 0, 1, _setAndSaveBackView.height)];
    verticalL.backgroundColor = MainThemeColor;
    verticalL.alpha = 0.2;
    [_setAndSaveBackView addSubview:verticalL];
    
    // 保存按钮
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(verticalL.right, 0, _setAndSaveBackView.width/2, _setAndSaveBackView.height);
    [saveBtn setTitle:NSLocalizedString(@"保存收款码", nil) forState:0];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [saveBtn setTitleColor:MainThemeColor forState:0];
    [saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_setAndSaveBackView addSubview:saveBtn];
    // 默认隐藏
    _setAndSaveBackView.hidden = YES;
    self.saveBtn = saveBtn;
    
    if (ALIPAYANDUNIONPAY) {
        //先显示本地缓存的再更新
        NSString *unionCode = [[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY];
        if (unionCode) {
            self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
        }
        
        [self getMerchantQRode];
    } else if (ONLIALIPAY) {
        [_setAndSaveBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
            self.qrcodeIV.hidden = YES;
        }];
        [self onlyAlipyUI];
    } else {
        //先显示本地缓存的再更新
         NSString *unionCode = [[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY];
         if (unionCode) {
             self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
         }
         
         [self getMerchantQRode];
    }
    
    [self addSupportAppUI];
    
    // 添加失败UI
    [self addFailureUI];
    
    [self createBigView];
    // 收款成功UI
    [self addCollectionSuccessUI];
}

- (void)onlyAlipyUI {
    UIView *bgView = [UIView new];
    [self.bgView addSubview:bgView];
    bgView.frame = self.whiteView.frame;
    self.onlyAlipybgView = bgView;
    
    UILabel *tipsLab = [[UILabel alloc] init];
    tipsLab.frame = CGRectMake(20, _toplabel.bottom+58, _toplabel.width-40, 16);
    tipsLab.text = NSLocalizedString(@"请设置收款金额", nil);
    tipsLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    tipsLab.textColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1/1.0];
    [self.onlyAlipybgView addSubview:tipsLab];
    
    CGRect sizeToFit = [[ZFGlobleManager getGlobleManager].merTxnCurr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1/1.0],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]}context:nil];
    UILabel *moneyNameLabel = [[UILabel alloc] init];
    moneyNameLabel.frame = CGRectMake(20, tipsLab.bottom+56, sizeToFit.size.width, 18);
    moneyNameLabel.text = [ZFGlobleManager getGlobleManager].merTxnCurr;
    moneyNameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    moneyNameLabel.textColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1/1.0];
    [self.onlyAlipybgView addSubview:moneyNameLabel];
    
    UITextField *moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(moneyNameLabel.right+10, moneyNameLabel.y-14, self.whiteView.width-moneyNameLabel.right-30, 32)];
    moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
    moneyTextField.font = [UIFont boldSystemFontOfSize:32];
    moneyTextField.delegate = self;
    moneyTextField.alpha = 0.8;
    moneyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.onlyAlipybgView addSubview:moneyTextField];
    self.moneyTF = moneyTextField;
    [_moneyTF becomeFirstResponder];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(20, moneyNameLabel.bottom+18, self.whiteView.width-40, 1);
    lineView.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1/1.0];
    [self.onlyAlipybgView addSubview:lineView];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.onlyAlipybgView addSubview:sureBtn];
    sureBtn.frame = CGRectMake(20, lineView.bottom+56, self.whiteView.width-40, 40);
    sureBtn.backgroundColor = [UIColor colorWithRed:35/255.0 green:107/255.0 blue:190/255.0 alpha:1/1.0];
    [sureBtn setTitle:NSLocalizedString(@"确 定", nil) forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    sureBtn.layer.cornerRadius = 4;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn addTarget:self action:@selector(onlyAlipyAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addSupportAppUI {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, self.setAndSaveBackView.bottom+15*HEIGHT_RATE, self.whiteView.width-40, 1)];
    lineView.backgroundColor = MainThemeColor;
    lineView.alpha = 0.2;
    [self.whiteView addSubview:lineView];
    
    /**
    CGFloat sWidth = (self.whiteView.width-20)/3;
    CGFloat sHeight = SCREEN_WIDTH*0.16;
    CGFloat sIVWH = SCREEN_WIDTH*0.1;
    for (int i = 0; i < 3; i++) {
        UIView *sBgView = [[UIView alloc] initWithFrame:CGRectMake(sWidth*i+5*(i+1), CGRectGetMaxY(lineView.frame)+15*HEIGHT_RATE, sWidth, sHeight)];
        sBgView.backgroundColor = [UIColor clearColor];
        [self.whiteView addSubview:sBgView];
        
        UIImageView *sImageView = [[UIImageView alloc] init];
        sImageView.frame = CGRectMake((sWidth-sIVWH)/2, (sHeight-sIVWH-3-SCREEN_WIDTH*0.05)/2, sIVWH, sIVWH);
        [sBgView addSubview:sImageView];
        
        UILabel *sLabel = [[UILabel alloc] init];
        sLabel.frame = CGRectMake(0, CGRectGetMaxY(sImageView.frame)+3, sWidth, SCREEN_WIDTH*0.07);
        sLabel.textAlignment = NSTextAlignmentCenter;
        sLabel.font = [UIFont systemFontOfSize:12.0];
        sLabel.numberOfLines = 0;
        sLabel.adjustsFontSizeToFitWidth = YES;
        sLabel.textColor = [UIColor blackColor];
        [sBgView addSubview:sLabel];
        
        if (i == 0) {
            sImageView.image = [UIImage imageNamed:@"btn_sinopay_highlight"];
            sLabel.text = NSLocalizedString(@" 力付 ", nil);
        } else if (i == 1) {
            sImageView.image = [UIImage imageNamed:@"btn_unionpay_highlight"];
            sLabel.text = NSLocalizedString(@" 云闪付 ", nil);
        } else {
            sImageView.image = [UIImage imageNamed:@"icon_unionpay"];
            sLabel.text = NSLocalizedString(@"公众号支付", nil);
        }
    }
     */
    NSArray *logoImageArray = nil;
    NSArray *titleArray = nil;
    if (ALIPAYANDUNIONPAY) {
        logoImageArray = @[@"1unionpay",@"2alipay"];
        titleArray = @[NSLocalizedString(@" 云闪付 ", nil),NSLocalizedString(@" 支付宝 ", nil)];
    } else if (ONLIUNIONPAY) {
        logoImageArray = @[@"1unionpay"];
        titleArray = @[NSLocalizedString(@" 云闪付 ", nil)];
    } else if (ONLIALIPAY) {
        logoImageArray = @[@"1alipay"];
        titleArray = @[NSLocalizedString(@" 支付宝 ", nil)];
    }
    
    CGFloat sWidth = (self.whiteView.width-20)/2;
    CGFloat sHeight = SCREEN_WIDTH*0.16;
    CGFloat sIVWH = SCREEN_WIDTH*0.1;
    for (int i = 0; i < logoImageArray.count; i++) {
        UIButton *sBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        sBgView.frame = CGRectMake(sWidth*i+5*(i+1), CGRectGetMaxY(lineView.frame)+15*HEIGHT_RATE, sWidth, sHeight);
        sBgView.backgroundColor = [UIColor clearColor];
        [self.whiteView addSubview:sBgView];
        [sBgView addTarget:self action:@selector(switchPaymentMethodAction:) forControlEvents:UIControlEventTouchUpInside];
        sBgView.tag = 100 + i;
        if (logoImageArray.count==1) sBgView.frame = CGRectMake((self.whiteView.width-sWidth)/2, CGRectGetMaxY(lineView.frame)+15*HEIGHT_RATE, sWidth, sHeight);
        
        UIImageView *sImageView = [[UIImageView alloc] init];
        sImageView.userInteractionEnabled = NO;
        sImageView.frame = CGRectMake((sWidth-sIVWH)/2, (sHeight-sIVWH-3-SCREEN_WIDTH*0.05)/2, sIVWH, sIVWH);
        [sBgView addSubview:sImageView];
        sImageView.tag = 200;
        
        UILabel *sLabel = [[UILabel alloc] init];
        sLabel.frame = CGRectMake(0, CGRectGetMaxY(sImageView.frame)+3, sWidth, SCREEN_WIDTH*0.07);
        sLabel.textAlignment = NSTextAlignmentCenter;
        sLabel.font = [UIFont systemFontOfSize:12.0];
        sLabel.numberOfLines = 0;
        sLabel.adjustsFontSizeToFitWidth = YES;
        sLabel.textColor = [UIColor blackColor];
        [sBgView addSubview:sLabel];
        sLabel.tag = 300;

        sImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@40x40",logoImageArray[i]]];
        sLabel.text = [NSString stringWithFormat:@"%@",titleArray[i]];
        CGSize labelSize = [sLabel.text boundingRectWithSize:CGSizeMake(sWidth, 5000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]} context:nil].size;
        sLabel.frame = CGRectMake(sLabel.frame.origin.x, sLabel.frame.origin.y, sLabel.frame.size.width, labelSize.height);
        
        if (logoImageArray.count==1) {
            sBgView.userInteractionEnabled = NO;
            sLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        } else {
            if (i == 0) {
                sLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
            } else if (i == 1) {
                sLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5/1.0];
            }
        }
    }
    
    _bottomTipBgView = [[UIView alloc] initWithFrame:CGRectMake(self.whiteView.x, IPhoneXTopHeight+self.whiteView.bottom-8, self.whiteView.width, 40)];
    _bottomTipBgView.layer.cornerRadius = 5.0f;
    [self.view addSubview:_bottomTipBgView];
    
    UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomTipBgView.width, _bottomTipBgView.height)];
    layerView.backgroundColor = [UIColor whiteColor];
    layerView.alpha = 0.3;
    layerView.layer.cornerRadius = 5;
    [_bottomTipBgView addSubview:layerView];
    
    UILabel *bottomTipLabel = [[UILabel alloc] init];
    bottomTipLabel.frame = CGRectMake(10, 10, _bottomTipBgView.width-20, 30);
    bottomTipLabel.textColor = [UIColor whiteColor];
    bottomTipLabel.textAlignment = NSTextAlignmentCenter;
    bottomTipLabel.font = [UIFont boldSystemFontOfSize:12.0];
    bottomTipLabel.numberOfLines = 0;
    bottomTipLabel.adjustsFontSizeToFitWidth = YES;
    if (ALIPAYANDUNIONPAY) {
        bottomTipLabel.text = NSLocalizedString(@"支持云闪付/支付宝扫一扫支付", nil);
    } else if (ONLIALIPAY) {
        bottomTipLabel.text = NSLocalizedString(@"支持支付宝扫一扫支付", nil);
    } else {
        bottomTipLabel.text = NSLocalizedString(@"支持云闪付扫一扫支付", nil);
    }

    [_bottomTipBgView addSubview:bottomTipLabel];
}

//创建放大视图
- (void)createBigView{
    _bigViewBack = [[UIView alloc] initWithFrame:self.view.bounds];
    _bigViewBack.backgroundColor = [UIColor whiteColor];
    _bigViewBack.hidden = YES;
    _bigViewBack.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:_bigViewBack];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenBigImage)];
    [_bigViewBack addGestureRecognizer:tap];
    
    _bigQRCodeImage = [[UIImageView alloc] init];
    _bigQRCodeImage.size = CGSizeMake(SCREEN_WIDTH*0.8, SCREEN_WIDTH*0.8);
    _bigQRCodeImage.center = _bigViewBack.center;
    [_bigViewBack addSubview:_bigQRCodeImage];
}

#pragma mark - 点击方法
- (void)switchPaymentMethodAction:(UIButton *)sender {
    UIButton *yxfBtn = [self.whiteView viewWithTag:100];
    UIButton *zfbBtn = [self.whiteView viewWithTag:101];
    NSString *unionCode = [[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY];
    
    if (sender.tag == 100) {
        self.payType = @"1";
        UIImageView *oldsImageView = [yxfBtn viewWithTag:200];
        UILabel *oldsLabel = [yxfBtn viewWithTag:300];
        oldsImageView.image = [UIImage imageNamed:@"icon_1unionpay40x40"];
        oldsLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        UIImageView *sImageView = [zfbBtn viewWithTag:200];
        UILabel *sLabel = [zfbBtn viewWithTag:300];
        sImageView.image = [UIImage imageNamed:@"icon_2alipay40x40"];
        sLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5/1.0];
        self.logoImageName = @"logo_unionpay";
        if (unionCode) {
            self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
        }
        
        if (_money.length > 0) {
            _money = nil;
            _moneyLabel.text = @"";
            [_setMoneyBtn setTitle:NSLocalizedString(@"设置金额", nil) forState:UIControlStateNormal];
            NSString *unionCode = [[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY];
            if (unionCode) {
                self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
            }
            [self getMerchantQRode];
        }
    } else {
        self.payType = @"2";
        KDSetMoneyController *setVC = [[KDSetMoneyController alloc] init];
        setVC.payType = self.payType;
        setVC.money = self.money;
        setVC.block = ^(NSString * _Nonnull money) {
            UIImageView *oldsImageView = [yxfBtn viewWithTag:200];
            UILabel *oldsLabel = [yxfBtn viewWithTag:300];
            oldsImageView.image = [UIImage imageNamed:@"icon_2unionpay40x40"];
            oldsLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5/1.0];
            UIImageView *sImageView = [zfbBtn viewWithTag:200];
            UILabel *sLabel = [zfbBtn viewWithTag:300];
            sImageView.image = [UIImage imageNamed:@"icon_1alipay40x40"];
            sLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
            self.logoImageName = @"icon_aipayerweima";
            if (unionCode) {
                self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
            }
            
            self.money = money;
            self.moneyLabel.text = [NSString stringWithFormat:@"%@ %.2f", [ZFGlobleManager getGlobleManager].merTxnCurr, [money doubleValue]];
            [self.setMoneyBtn setTitle:NSLocalizedString(@"修改金额", nil) forState:UIControlStateNormal];
            [self getMerchantQRode];
        };
        [self pushViewController:setVC];
    }
}

- (void)setMoneyClick{
    if ((ALIPAYANDUNIONPAY) || (ONLIUNIONPAY)) {
        if ([self.payType isEqualToString:@"1"]) {
            if (_money.length > 0) {
                _money = nil;
                _moneyLabel.text = @"";
                [_setMoneyBtn setTitle:NSLocalizedString(@"设置金额", nil) forState:UIControlStateNormal];
                NSString *unionCode = [[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY];
                if (unionCode) {
                    self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:unionCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
                }
                [self getMerchantQRode];
            } else {
                KDSetMoneyController *setVC = [[KDSetMoneyController alloc] init];
                setVC.payType = self.payType;
                setVC.block = ^(NSString * _Nonnull money) {
                    self.money = money;
                    self.moneyLabel.text = [NSString stringWithFormat:@"%@ %.2f", [ZFGlobleManager getGlobleManager].merTxnCurr, [money doubleValue]];
                    [self.setMoneyBtn setTitle:NSLocalizedString(@"清除金额", nil) forState:UIControlStateNormal];
                    [self getMerchantQRode];
                };
                [self pushViewController:setVC];
            }
        } else {
            KDSetMoneyController *setVC = [[KDSetMoneyController alloc] init];
            setVC.payType = self.payType;
            setVC.block = ^(NSString * _Nonnull money) {
                self.money = money;
                self.moneyLabel.text = [NSString stringWithFormat:@"%@ %.2f", [ZFGlobleManager getGlobleManager].merTxnCurr, [money doubleValue]];
                [self.setMoneyBtn setTitle:NSLocalizedString(@"修改金额", nil) forState:UIControlStateNormal];
                [self getMerchantQRode];
            };
            [self pushViewController:setVC];
        }
    } else if (ONLIALIPAY){
        [self.onlyAlipybgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.moneyTF becomeFirstResponder];
            obj.hidden = NO;
            self.onlyAlipybgView.hidden = NO;
        }];
        [_setAndSaveBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _moneyLabel.text = @"";
            _money = nil;
            obj.hidden = YES;
            self.qrcodeIV.hidden = YES;
        }];
    }
}

- (void)saveBtnClicked {
    DLog(@"保存二维码");
    UIImage *imageForSave = [self getSaveImage];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[imageForSave CGImage] orientation:(ALAssetOrientation)[imageForSave imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存失败", nil) inView:self.view];
        } else {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存成功", nil) inView:self.view];
        }
    }];
}

//显示大图
- (void)showBigImage {
    if (!self.failureView.isHidden) {
        return;
    }
    _bigViewBack.hidden = NO;
    _bigQRCodeImage.image = self.qrcodeIV.image;
    [UIView animateWithDuration:0.5 animations:^{
        _bigViewBack.alpha = 1;
    }];
}

//隐藏大图
- (void)hiddenBigImage{
    _bigViewBack.alpha = 0;
    _bigViewBack.hidden = YES;
}

- (void)onlyAlipyAction:(UIButton *)sender
{
    [_moneyTF resignFirstResponder];
    NSString *amount = _moneyTF.text;
    if ([amount doubleValue] < 0.01) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入金额", nil) inView:self.view];
        return;
    }
    [self.onlyAlipybgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
        self.onlyAlipybgView.hidden = YES;
    }];
    
    [_setAndSaveBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = NO;
        self.qrcodeIV.hidden = NO;
    }];
    
    self.money = amount;
    self.moneyLabel.text = [NSString stringWithFormat:@"%@ %.2f", [ZFGlobleManager getGlobleManager].merTxnCurr, [amount doubleValue]];
    [self.setMoneyBtn setTitle:NSLocalizedString(@"清除金额", nil) forState:UIControlStateNormal];
    [self getMerchantQRode];
}

#pragma mark - TextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _amountTF) {
        if ([string isEqualToString:@"."]) {
            if ([_amountTF.text containsString:@"."]) {
                return NO;
            }
            if (_amountTF.text.length < 1) {
                return NO;
            }
        }
        
        // 小数点后最多能输入两位
        if ([_amountTF.text containsString:@"."]) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1 && ![string isEqualToString:@""]) {
                    return NO;
                }
            }
        }
        
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@".1234567890"] invertedSet];
        NSString *str = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        return [string isEqualToString:str];
    } else if (textField == _moneyTF){
        if ([string isEqualToString:@"."]) {
            if ([_moneyTF.text containsString:@"."]) {
                return NO;
            }
            if (_moneyTF.text.length < 1) {
                return NO;
            }
        }
        // 小数点后最多能输入两位
        if ([_moneyTF.text containsString:@"."]) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1 && ![string isEqualToString:@""]) {
                    return NO;
                }
            }
        }
        
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@".1234567890"] invertedSet];
        NSString *str = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        return [string isEqualToString:str];
    }
    
    return YES;
}

#pragma mark - 网络请求方法
- (void)getMerchantQRode {
    NSString *txnAmt = @"";
    if (_money.length > 0) {
        txnAmt = [NSString stringWithFormat:@"%.f", [_money doubleValue]*100];
    }
    NSString *qrcType = nil;
    if ([self.payType isEqualToString:@"2"]) {
        qrcType = @"Alipay";
    } else {
        qrcType = @"1";
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *locationStr = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"location"]];
    NSDictionary *dict = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                           @"qrcType" :  qrcType,//[NSString stringWithFormat:@"%zd", type], // 二维码类型
                           @"txnAmt" : txnAmt,
                           @"txnType" : @"12",
                           @"location":locationStr,
                           };
    if (![[NSUserDefaults standardUserDefaults] objectForKey:UNIONPay_QRCODE_KEY]) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    
    if (_money.length > 0) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    self.qrcodeIV.hidden = YES;
    _moneyLabel.hidden = YES;
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 生成成功
            // 显示保存二维码按钮
            self.setAndSaveBackView.hidden = NO;
            self.failureView.hidden = YES;
            self.qrcodeIV.hidden = NO;
            _moneyLabel.hidden = NO;
            self.unionPayCode = [requestResult objectForKey:@"qrCode"];
            self.qrcodeIV.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:self.unionPayCode logoImageName:self.logoImageName logoScaleToSuperView:0.2];
            if (!_money) {
                [[NSUserDefaults standardUserDefaults] setObject:_unionPayCode forKey:UNIONPay_QRCODE_KEY];
            }
        } else { // 请求失败
            self.failureView.hidden = NO;
            self.qrcodeIV.image = nil;
        }
    } failure:^(id error) { // 网络错误
        self.failureView.hidden = NO;
        self.qrcodeIV.image = nil;
    }];
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

#pragma mark -- 远程推送相关
// 检查用户对通知功能的设置状态
- (void)isPermissionedPushNotification {
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        DLog(@"用户关闭了通知功能");
        [XLAlertController acWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请打开通知功能,否则无法收到交易提醒", nil) confirmBtnTitle:NSLocalizedString(@"设置", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
            // 去设置中心
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        } cancleAction:^(UIAlertAction *action) {
            
        }];
    } else {
        DLog(@"可以进行推送");
    }
}

// 点击查看消息，进行界面跳转
- (void)confirmReadNoticeContent:(NSNotification *)notify {
    // 获取跟控制器
    UIViewController *rootVC = nil;
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    ZFTabBarViewController *tabVC = (ZFTabBarViewController *)window.rootViewController;
    rootVC = [(ZFNavigationController *)[tabVC selectedViewController] visibleViewController];
    NSString *orderID = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_ORDERID];
    if (orderID.length > 0) {
        DLog(@"非前台点击通知，跳到详情页");
        // 非前台点击通知，红点，不振动
        DLog(@"非前台--订单ID：%@", notify.userInfo[@"orderID"]);
        
        NSString *orderID = notify.userInfo[@"orderID"];
        if (orderID.length > 0) {
            // 跳转到消息列表页面
//            KDOrderDetailController *odvc = [[KDOrderDetailController alloc] init];
//            odvc.orderID = orderID;
//            [rootVC.navigationController pushViewController:odvc animated:YES];
            KDReceiptDetailController *odvc = [[KDReceiptDetailController alloc] init];
            odvc.orderID = orderID;
            [rootVC.navigationController pushViewController:odvc animated:YES];
            
        }
        // 收到交易通知设置红点
        [self.tabBarController.tabBar showBadgeOnItemIndex:1];
        //清空orderID
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PUSH_ORDERID];
    } else {
        DLog(@"----前台收到消息，弹出收款成功页面------");
        // 前台收到通知，红点，振动
        DLog(@"前台--订单ID：%@", notify.userInfo[@"orderID"]);
        
        // 振动模式才有效
        if (@available(iOS 9.0, *)) {
            AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                //播放震动完事调用的块
            });
        }
        
        if (notify.userInfo[@"orderID"]) { // 是交易通知时才跳转页面
            // 只在此页面弹出成功页面
            if ([rootVC isKindOfClass:[KDQRCodeCollectionViewController class]]) {
                // 显示收款成功UI
                [self showCollectSuccessUI:notify];
            }
            // 收到交易通知设置红点
            [self.tabBarController.tabBar showBadgeOnItemIndex:1];
        }
    }
}

// 显示收款成功UI
- (void)showCollectSuccessUI:(NSNotification *)notify {
    
    if (notify.userInfo[@"txnAmt"] && notify.userInfo[@"mobile"]) {
        self.collectionView.hidden = NO;
        NSString *amount = [NSString stringWithFormat:@"%.2f", [notify.userInfo[@"txnAmt"] floatValue]/100];
        // 金额
        self.amountLabel.text = [NSString stringWithFormat:@"+ %@", amount];
        // 手机尾号
        NSString *mobile = [NSString stringWithFormat:@"%@",notify.userInfo[@"mobile"]];
        self.mobilSuffixLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"手机尾号", nil), notify.userInfo[@"mobile"]];
        if ([mobile isEqualToString:@""]) self.mobilSuffixLabel.hidden = YES;
        
        // 显示一秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideCollectSuccessUIAnimation];
        });
    } else {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"参数有误", nil) inView:self.view];
        return;
    }
}

- (void)hideCollectSuccessUIAnimation {
    // 避免与动画冲突
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.hidden = YES;
    });
    
    // 先画出移动路径，起点、中间某一点、终点
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.collectionView.center];
    CGPoint endPoint = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8);;
    CGPoint controlPoint = CGPointMake(SCREEN_WIDTH/2, 50+20);
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    // 关键帧动画，将几个点形成移动的动画效果（有点像我们只做GIF图，很精细的那种）
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    pathAnimation.removedOnCompletion = NO; // 默认YES，动画结束后一切还原
    
    // 逐渐变小
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    // fromValue：开始值    toValue：结束值
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // 设置 X 轴和 Y 轴缩放比例都为1.0，而 Z 轴不变
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)];
    transformAnimation.removedOnCompletion = NO;
    
    // 透明；使用基础动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.1];
    opacityAnimation.removedOnCompletion = NO;
    
    //组合效果；使用动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[pathAnimation, transformAnimation, opacityAnimation];
    //设置动画执行时间
    animationGroup.duration = 2.0;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.removedOnCompletion = NO;
    
    // 将整个动画组所有的设置属性赋给某一个View
    [self.collectionView.layer addAnimation:animationGroup forKey:nil];
}

#pragma mark - 其他方法
// 保存二维码
- (UIImage *)getSaveImage{
    CGFloat heightRate = (SCREEN_HEIGHT/667);
    CGFloat multipleCount = 5;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*multipleCount, 510*heightRate)];
    backView.backgroundColor = MainThemeColor;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*heightRate*multipleCount, backView.width, 30*multipleCount)];
    tipLabel.text = NSLocalizedString(@"扫码向我付款", nil);
    tipLabel.font = [UIFont boldSystemFontOfSize:26*multipleCount];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    [backView addSubview:tipLabel];
    
    UIView *imageBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200*heightRate*multipleCount, 200*heightRate*multipleCount)];
    imageBack.backgroundColor = [UIColor whiteColor];
    imageBack.center = CGPointMake(backView.width/2, tipLabel.bottom+40*multipleCount+imageBack.height/2);;
    [backView addSubview:imageBack];
    
    UIImageView *qrImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170*heightRate*multipleCount, 170*heightRate*multipleCount)];
    qrImage.center = CGPointMake(imageBack.width/2, imageBack.height/2);
    [imageBack addSubview:qrImage];
    qrImage.image = self.qrcodeIV.image;
    
    if (_money.length > 0) {
        imageBack.height = 240*heightRate*multipleCount;
        UILabel *moneyL = [[UILabel alloc] initWithFrame:CGRectMake(0, qrImage.bottom+8*heightRate*multipleCount, imageBack.width, 40*heightRate*multipleCount)];
        moneyL.textAlignment = NSTextAlignmentCenter;
        moneyL.text = [NSString stringWithFormat:@"%@ %.2f", [ZFGlobleManager getGlobleManager].merTxnCurr, [_money doubleValue]];
        moneyL.font = [UIFont boldSystemFontOfSize:24*multipleCount];
        [imageBack addSubview:moneyL];
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageBack.bottom+30*heightRate*multipleCount, backView.width, 30*multipleCount)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:28*multipleCount];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [ZFGlobleManager getGlobleManager].merShortName;
    [backView addSubview:nameLabel];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, nameLabel.bottom+60*heightRate*multipleCount, backView.width, 80*multipleCount)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:bottomView];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 218*multipleCount, 48*multipleCount)];
    logoImage.image = [UIImage imageNamed:@"pic_savepic_unionpay_english"];
    [bottomView addSubview:logoImage];
    
    logoImage.center = CGPointMake(bottomView.width/2, bottomView.height/2);
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20*multipleCount, 20*multipleCount)];
//    label.text = NSLocalizedString(@"小微开店", nil);
//    label.font = [UIFont systemFontOfSize:36*multipleCount];
//    [label sizeToFit];
    
//    logoImage.origin = CGPointMake((backView.width-logoImage.width-label.width-40)/2, 16*multipleCount);
//    label.center = CGPointMake(logoImage.right+20*multipleCount+label.width/2, logoImage.centerY);
//    [bottomView addSubview:label];
    
    backView.size = CGSizeMake(backView.width, bottomView.bottom);
    
    UIGraphicsBeginImageContextWithOptions(backView.size, YES, 1);
    [backView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [self resizeImageToSize:CGSizeMake(backView.width, backView.height) sizeOfImage:saveImage];
}

//重新生成图片的方法
-(UIImage*)resizeImageToSize:(CGSize)size sizeOfImage:(UIImage*)image {
    
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

// 请求失败UI
- (void)addFailureUI {
    self.qrcodeIV.userInteractionEnabled = YES;
    UIView *failureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.qrcodeIV.width, self.qrcodeIV.height)];
    [self.qrcodeIV addSubview:failureView];
    self.failureView = failureView;
    self.failureView.hidden = YES;
    
    // 表情图片
    float width = self.qrcodeIV.width;
    UIImageView *bqImageView = [[UIImageView alloc] init];
    bqImageView.image = [UIImage imageNamed:@"icon_no_web"];
    bqImageView.x = width*0.3;
    bqImageView.y = width*0.1;
    bqImageView.size = CGSizeMake(width*0.4, width*0.4);
    [failureView addSubview:bqImageView];
    
    // 文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bqImageView.frame)+10, width, 40)];
    tipLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    tipLabel.font = [UIFont systemFontOfSize:15.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = NSLocalizedString(@"请求失败，请重试", nil);
    [failureView addSubview:tipLabel];
    
    // 提示按钮
    UIButton *tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipLabel.frame), width, 20)];
    tipBtn.tag = 1;
    [tipBtn setTitle:NSLocalizedString(@"重新加载", nil) forState:UIControlStateNormal];
    [tipBtn setTitleColor:MainFontColor forState:UIControlStateNormal];
    tipBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [tipBtn addTarget:self action:@selector(getMerchantQRode) forControlEvents:UIControlEventTouchUpInside];
    [failureView addSubview:tipBtn];
}

// 收到成功通知
- (void)addCollectionSuccessUI {
    // 白色遮罩
    UIView *collectionView = [[UIView alloc] init];
    collectionView.backgroundColor = ZFAlpColor(255, 255, 255, 0.9);
    collectionView.frame = ZFSCREEN;
    [[UIApplication sharedApplication].keyWindow addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionView.hidden = YES;
    
    // 成功图片
    UIImageView *successIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_success"]];
    successIV.frame = CGRectMake((collectionView.width-90)/2, 150, 90, 90);
    [collectionView addSubview:successIV];
    
    // 收款成功文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(successIV.frame), collectionView.width, 60)];
    tipLabel.textColor = [UIColor blackColor];
    tipLabel.font = [UIFont systemFontOfSize:18.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = NSLocalizedString(@"收款成功", nil);
    [collectionView addSubview:tipLabel];
    
    // 金额
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipLabel.frame), collectionView.width, 60)];
    amountLabel.textColor = [UIColor blackColor];
    amountLabel.font = [UIFont boldSystemFontOfSize:36.0];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.text = [NSString stringWithFormat:@"+ %@", @"0.00"];
    [collectionView addSubview:amountLabel];
    self.amountLabel = amountLabel;
    
    // 手机尾号
    UILabel *mobilSuffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(amountLabel.frame), collectionView.width, 12)];
    mobilSuffixLabel.textColor = [UIColor blackColor];
    mobilSuffixLabel.font = [UIFont systemFontOfSize:14.0];
    mobilSuffixLabel.adjustsFontSizeToFitWidth = YES;
    mobilSuffixLabel.textAlignment = NSTextAlignmentCenter;
    mobilSuffixLabel.text = NSLocalizedString(@"手机尾号: ", nil);
    [collectionView addSubview:mobilSuffixLabel];
    self.mobilSuffixLabel = mobilSuffixLabel;
}

// 是否提交资料
- (void)infoCommited {
    if ([[ZFGlobleManager getGlobleManager].fillingStatus isEqualToString:@"1"]) {
        [XLAlertController acWithMessage:NSLocalizedString(@"为保障收款功能正常使用，请完善商户资料后使用", nil) confirmBtnTitle:NSLocalizedString(@"提交资料", nil) confirmAction:^(UIAlertAction *action) {
            KDAuthenticateViewController *avc = [KDAuthenticateViewController new];
            avc.authentType = 1;
            avc.block = ^(BOOL isReload) {
                if (isReload) {
                    _toplabel.text = [ZFGlobleManager getGlobleManager].merShortName;
                    [self setHomeNaviTitle:[ZFGlobleManager getGlobleManager].merName];
                }
            };
            [self pushViewController:avc];
        }];
        return;
    }
}

@end
