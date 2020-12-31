//
//  KDGetMSCodeViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/3/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDGetMSCodeViewController.h"


@interface KDGetMSCodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong)ZFBaseTextField *codeTextField;
@property (nonatomic, strong)UIButton *getCodeBtn;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;


@property(nonatomic, strong) NSDictionary *params;

@end

@implementation KDGetMSCodeViewController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        self.params = params;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"手机号验证", nil);
    
    [self createView];
    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_codeTextField becomeFirstResponder];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - 初始化视图
- (void)createView{
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+10, SCREEN_WIDTH - 40, 20)];
    phoneLabel.font = [UIFont systemFontOfSize:12];
    phoneLabel.textColor = [UIColor grayColor];
    phoneLabel.numberOfLines = 0;
    phoneLabel.text = [NSString stringWithFormat:@"%@+%@ %@", NSLocalizedString(@"验证已发送至手机：", nil), [ZFGlobleManager getGlobleManager].areaNum, [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    [self.view addSubview:phoneLabel];
    
    _codeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, phoneLabel.bottom+10, SCREEN_WIDTH-215, 40)];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_codeTextField limitTextLength:6];
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    _codeTextField.delegate = self;
    _codeTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_codeTextField];
    
    _getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _getCodeBtn.frame = CGRectMake(_codeTextField.right+15, _codeTextField.y, 160, 40);
    _getCodeBtn.layer.cornerRadius = 5;
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeBtn setBackgroundColor:MainThemeColor];
    [_getCodeBtn addTarget:self action:@selector(clickGetCodeBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCodeBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, _getCodeBtn.bottom+45, SCREEN_WIDTH-40, 40);
    nextBtn.layer.cornerRadius = 5;
    nextBtn.backgroundColor = MainThemeColor;
    [nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(clickNextStepBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

#pragma mark -- 点击方法
// 获取验证码
- (void)clickGetCodeBtn {
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:self.params success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
        // 设置获取验证码按钮状态
        self.orderId = [requestResult objectForKey:@"orderId"];
        [self setupBtnStatusOfSendMsg];
    } failure:^(NSError *error) {
        
    }];
}

- (void)clickNextStepBtn {
    [self.view endEditing:YES];
    if (_codeTextField.text.length != 6) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"验证码输入错误", nil) inView:self.view];
        return;
    }
    
    [self bondBankCardAction];
}

#pragma mark -- 网络请求
- (void)bondBankCardAction {
    NSString *phoneNo = [TripleDESUtils getEncryptWithString:[ZFGlobleManager getGlobleManager].userPhone keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    
    NSDictionary *params = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                             @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                             @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                             @"phoneNo" : phoneNo,
                             @"cardNum" : self.cardNum,
                             @"sysareaid" : @"SG",
                             @"province" : @"",
                             @"city" : @"",
                             @"district" : @"",
                             @"userKey" : @"",
                             @"orderId" : self.orderId,
                             @"smsCode" : self.codeTextField.text,
                             @"txnType" : @"60"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:params success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"银行卡绑定成功", nil) inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 返回银行卡列表页面
                [ZFGlobleManager getGlobleManager].isChanged = YES;
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            });
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - 其他方法
- (void)startTimer {
    _getCodeBtn.enabled = NO;
    _downCount = 60;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
}

- (void)retextBtn{
    _downCount--;
    [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds", _downCount] forState:UIControlStateNormal];
    if (_downCount == 0) {
        _getCodeBtn.enabled = YES;
        [_getCodeBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [_timer invalidate];
    }
}

// 发送成功之后的按钮状态
- (void)setupBtnStatusOfSendMsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _getCodeBtn.enabled = NO;
        _downCount = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
        [_codeTextField becomeFirstResponder];
    });
}


@end
