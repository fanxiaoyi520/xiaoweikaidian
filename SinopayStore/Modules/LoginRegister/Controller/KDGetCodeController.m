//
//  KDGetCodeController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDGetCodeController.h"

@interface KDGetCodeController ()<UITextFieldDelegate>

@property (strong, nonatomic) ZFBaseTextField *codeTextField;
@property (strong, nonatomic) UIButton *getCodeBtn;
///
@property (nonatomic, strong) ZFBaseTextField *pwdTextField1;
@property (nonatomic, strong) ZFBaseTextField *pwdTextField2;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

@end

@implementation KDGetCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"重置密码", nil);
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getCodeSuccess];
}

#pragma mark 创建视图
- (void)createView{
    //验证码输入框
    _codeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-215, 40)];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeTextField.delegate = self;
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    [_codeTextField limitTextLength:6];
    [self.view addSubview:_codeTextField];
    
    //获取验证码按钮
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_codeTextField.right+15, _codeTextField.y, 160, 40)];
    _getCodeBtn.backgroundColor = MainThemeColor;
    _getCodeBtn.layer.cornerRadius = 5;
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeBtn addTarget:self action:@selector(getVeriCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCodeBtn];
    
    //密码
    _pwdTextField1 = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _getCodeBtn.bottom+20, SCREEN_WIDTH-40, 40)];
    _pwdTextField1.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField1.keyboardType = UIKeyboardTypeNumberPad;
    _pwdTextField1.secureTextEntry = YES;
    _pwdTextField1.delegate = self;
    _pwdTextField1.placeholder = NSLocalizedString(@"请输入6位数字登录密码", nil);
    [_pwdTextField1 limitTextLength:6];
    [self.view addSubview:_pwdTextField1];
    
    _pwdTextField2 = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _pwdTextField1.bottom+10, _pwdTextField1.width, _pwdTextField1.height)];
    _pwdTextField2.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField2.keyboardType = UIKeyboardTypeNumberPad;
    _pwdTextField2.secureTextEntry = YES;
    _pwdTextField2.delegate = self;
    _pwdTextField2.placeholder = NSLocalizedString(@"请再次输入", nil);
    [_pwdTextField2 limitTextLength:6];
    [self.view addSubview:_pwdTextField2];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _pwdTextField2.bottom+10, SCREEN_WIDTH-40, 14)];
    _tipLabel.textColor = [UIColor redColor];
    _tipLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_tipLabel];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _pwdTextField2.bottom+45, SCREEN_WIDTH-40, 40)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
}

- (IBAction)getVeriCode{
    
    NSString *txnType = @"05";
    NSString *verifyCodeType = @"06";
    if (_forgetType == 1) {
        txnType = @"31";
        verifyCodeType = @"32";
    }
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"txnType": txnType,
                                 @"verifyCodeType":verifyCodeType,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [self getCodeSuccess];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)getCodeSuccess{
    _getCodeBtn.enabled = NO;
    _downCount = 60;
    [self retextBtn];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
    [_codeTextField becomeFirstResponder];
}

- (void)retextBtn{
    _downCount--;
    NSString *str = NSLocalizedString(@"后重新获取", nil);
    if ([str hasPrefix:@"Retrieve"]) {
        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%@ %zds", str, _downCount] forState:UIControlStateNormal];
    } else {
        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds%@", _downCount, str] forState:UIControlStateNormal];
    }
    if (_downCount == 0) {
        _getCodeBtn.enabled = YES;
        [_getCodeBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [_timer invalidate];
    }
}

- (IBAction)confirmBtn:(id)sender {
    if (_codeTextField.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"验证码输入错误", nil);
        return;
    }
    
    if (_pwdTextField1.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"请输入6位数字登录密码", nil);
        return ;
    }
    
    if (![_pwdTextField1.text isEqualToString:_pwdTextField2.text]) {
        _tipLabel.text = NSLocalizedString(@"两次输入的密码不一致", nil);
        return ;
    }
    _tipLabel.text = @"";
    
    [self findLoginPW];
}

#pragma mark 找回密码
- (void)findLoginPW{
    // 3DES加密
    NSString *password = _pwdTextField1.text;
    //登录前和登录后的key不一样
    NSString *key = [ZFGlobleManager getGlobleManager].tempSecurityKey;
    NSString *encrypptpasswordString = [TripleDESUtils getEncryptWithString:password keyString: key ivString: TRIPLEDES_IV];
    
    NSString *txnType = @"06";
    if (_forgetType == 1) {
        txnType = @"32";
    }
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"txnType": txnType,
                                 @"smsVerifyCode":_codeTextField.text,
                                 @"password":encrypptpasswordString,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"修改成功", nil) inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        [[MBUtils sharedInstance] dismissMB];
        
    }];
}

@end
