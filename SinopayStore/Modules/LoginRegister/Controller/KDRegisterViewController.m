//
//  KDRegisterViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDRegisterViewController.h"
#import "KDAuthenticateViewController.h"

@interface KDRegisterViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet ZFBaseTextField *areaTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet ZFBaseTextField *pwdTF1;
@property (weak, nonatomic) IBOutlet ZFBaseTextField *pwdTF2;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation KDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"注册", nil);
    
    _topConstraint.constant = IPhoneXTopHeight+20;
    [self setStyle];
    
    //上次保存的数据
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"areaNum%@", phoneNum]];
    if (areaNum) {
        _areaTextField.text = areaNum;
    }
    
    //之前请求过就不再请求
    if ([ZFGlobleManager getGlobleManager].areaNumArray && [ZFGlobleManager getGlobleManager].areaNumArray.count > 0) {
        _areaArray = [ZFGlobleManager getGlobleManager].areaNumArray;
    } else {
        [self getCountryCode];
    }
    [self createPickView];
}

- (void)setStyle{
    //国际化
    _phoneTextField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    _pwdTF1.placeholder = NSLocalizedString(@"请输入6位数字登录密码", nil);
    _pwdTF2.placeholder = NSLocalizedString(@"请再次输入", nil);
    [_nextStepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    
    [_phoneTextField limitTextLength:11];
    [_codeTextField limitTextLength:6];
    [_pwdTF1 limitTextLength:6];
    [_pwdTF2 limitTextLength:6];
    
    UIButton *telBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop_blue"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop_blue"] forState:UIControlStateSelected];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    
    _getCodeBtn.layer.cornerRadius = 5;
    _nextStepBtn.layer.cornerRadius = 5;
}

#pragma mark 获取手机区号
- (void)getCountryCode{
    
    _areaArray = [[NSMutableArray alloc] init];
    NSDictionary *parameters = @{@"txnType": @"15"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
            
            NSString *language = [NetworkEngine getCurrentLanguage];
            NSString *languageDesc = @"chnDesc";//简体
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"engDesc";//英文
            }
            if ([language isEqualToString:@"2"]) {
                languageDesc = @"fonDesc";//繁体
            }
            
            for (NSDictionary *dict in countryArr) {
                NSString *str = [NSString stringWithFormat:@"%@+%@", [dict objectForKey:languageDesc], [dict objectForKey:@"countryCode"]];
                [_areaArray addObject:str];
            }
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:_areaArray];
            
            [_pickerView reloadAllComponents];
            NSString *countryStr = [NSString stringWithFormat:@"+%@", [[_areaArray[0] componentsSeparatedByString:@"+"] lastObject]];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"areaNum%@", phoneNum]];
            if (areaNum) {
                countryStr = areaNum;
            }
            _areaTextField.text = countryStr;
        } else {
            
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)createPickView{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // 代理
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    toolView.backgroundColor = GrayBgColor;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [toolView addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];
    [confirmBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [toolView addSubview:confirmBtn];
    
    self.areaTextField.delegate = self;
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = toolView;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView {
    [_areaTextField resignFirstResponder];
}

#pragma mark 验证手机号
- (BOOL)checkPhoneNum{
    NSString *moblie = self.phoneTextField.text;
    
    if (!moblie || moblie.length == 0) {
        _tipLabel.text = NSLocalizedString(@"请输入手机号", nil);
        return NO;
    }
    
    if (moblie.length > 11 || moblie.length < 7) {
        _tipLabel.text = NSLocalizedString(@"手机号码有误", nil);
        return NO;
    }
    _tipLabel.text = @"";
    return YES;
}

- (IBAction)clickGetCodeBtn:(id)sender {
    if (![self checkPhoneNum]) {
        return;
    }
    [self getSessionID];
}


#pragma mark 获取临时sessionID
- (void)getSessionID{
    
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _phoneTextField.text,
                                 @"txnType": @"01"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            NSString *securityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].tempSecurityKey = securityKey;
            [ZFGlobleManager getGlobleManager].tempSessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].userPhone = _phoneTextField.text;
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            
            [self getVerCode];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {

    }];
}

#pragma mark 获取短信验证码
- (void)getVerCode{
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": _phoneTextField.text,
                                 @"txnType": @"05",
                                 @"verifyCodeType":@"02",
                                 @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _getCodeBtn.enabled = NO;
            _downCount = 60;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_codeTextField becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
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

#pragma mark 下一步检测信息
- (BOOL)isInfoOK{
    [self.view endEditing:YES];
    
    if (![self checkPhoneNum]) {
        return NO;
    }
    
    if (_codeTextField.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"验证码输入错误", nil);
        return NO;
    }
    
    if (_pwdTF1.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"请输入6位数字登录密码", nil);
        return NO;
    }
    
    if (![_pwdTF1.text isEqualToString:_pwdTF2.text]) {
        _tipLabel.text = NSLocalizedString(@"两次输入的密码不一致", nil);
        return NO;
    }
    _tipLabel.text = @"";
    
    return YES;
}

- (IBAction)clickNextStep:(id)sender {
    
//    KDAuthenticateViewController *avc = [KDAuthenticateViewController new];
//    avc.authentType = 0;
//    [self pushViewController:avc];
//    return;
    if (![self isInfoOK]) {
        return;
    }
    
    NSString *pwStr = [TripleDESUtils getEncryptWithString:_pwdTF1.text keyString:[ZFGlobleManager getGlobleManager].tempSecurityKey
                                                  ivString:TRIPLEDES_IV];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": _phoneTextField.text,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID,
                                 @"password":pwStr,
                                 @"smsVerifyCode":_codeTextField.text,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID,
                                 @"txnType": @"02"
                                 };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            KDAuthenticateViewController *avc = [KDAuthenticateViewController new];
            [self pushViewController:avc];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _areaTextField) {
        if (![ZFGlobleManager getGlobleManager].areaNumArray || [ZFGlobleManager getGlobleManager].areaNumArray.count == 0) {
            [self getCountryCode];
            return NO;
        }
    }
    return YES;
}

#pragma mark - pickview delegate
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _areaArray.count;
}

- (NSInteger) numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return _areaArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.bounds.size.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    textlabel.textAlignment = NSTextAlignmentCenter;
    textlabel.text = _areaArray[row];
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
}

@end
