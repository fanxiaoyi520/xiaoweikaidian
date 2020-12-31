//
//  KDForgetPWController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDForgetPWController.h"
#import "KDGetCodeController.h"

@interface KDForgetPWController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong)UITextField *phoneTextField;
///区号
@property (nonatomic, strong)ZFBaseTextField *areaTextField;
/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;
/** 下一步按钮 */
@property(nonatomic, weak) UIButton *nextStepBtn;

@end

@implementation KDForgetPWController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.naviTitle = NSLocalizedString(@"找回登录密码", nil);
    [self createView];
}

- (void)createView{
    //区号 手机号背景
    UIView *backTextField = [[UIView alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-40, 40)];
    backTextField.backgroundColor = UIColorFromRGB(0xeeeeee);
    backTextField.layer.cornerRadius = 5;
    [self.view addSubview:backTextField];
    //区号
    _areaTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _areaTextField.text = @"+86";
    [backTextField addSubview:_areaTextField];
    
    UIButton *telBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop_blue"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop_blue"] forState:UIControlStateSelected];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(_areaTextField.right+5, 0, backTextField.width-_areaTextField.width-5, 40)];
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _phoneTextField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [backTextField addSubview:_phoneTextField];
    
    //下一步
    UIButton *nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextStepBtn.frame = CGRectMake(20, backTextField.bottom+45, SCREEN_WIDTH-40, 40);
//    nextStepBtn.layer.cornerRadius = 5.0;
    [nextStepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [nextStepBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [nextStepBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_non_clickable"] forState:UIControlStateDisabled];
    [nextStepBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateHighlighted];
    nextStepBtn.enabled = NO;
//    nextStepBtn.backgroundColor = MainThemeColor;
    [nextStepBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextStepBtn];
    self.nextStepBtn = nextStepBtn;
    
    [self getCountryCode];
    [self createPickView];
}

#pragma mark 获取手机区号
- (void)getCountryCode{
    //之前请求过就不再请求
    if ([ZFGlobleManager getGlobleManager].areaNumArray && [ZFGlobleManager getGlobleManager].areaNumArray.count > 0) {
        _areaArray = [ZFGlobleManager getGlobleManager].areaNumArray;
        return;
    }
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
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    toolView.backgroundColor = GrayBgColor;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];
    [confirmBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [toolView addSubview:confirmBtn];
    
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = toolView;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView{
    [_areaTextField resignFirstResponder];
}

- (void)nextStep{
    [_phoneTextField resignFirstResponder];
    NSString *moblie = self.phoneTextField.text;
    
    NSString *errorMessage = @"";
    if (!moblie || moblie.length == 0) {
        errorMessage = NSLocalizedString(@"请输入手机号", nil);
        [[MBUtils sharedInstance] showMBTipWithText:errorMessage inView:self.view];
        return;
    }
    
    if (moblie.length > 11 || moblie.length < 7) {
        errorMessage = NSLocalizedString(@"手机号码有误", nil);
        [[MBUtils sharedInstance] showMBTipWithText:errorMessage inView:self.view];
        return;
    }
    
    [self getSessionID];
}

#pragma mark 获取临时sessionID
- (void)getSessionID{
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    NSString *txnType = @"01";
    if (_forgetType == 1) {
        txnType = @"36";
    }
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _phoneTextField.text,
                                 @"txnType": txnType};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            NSString *securityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].tempSecurityKey = securityKey;
            [ZFGlobleManager getGlobleManager].tempSessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userPhone = _phoneTextField.text;
            
            [self getVeriCode];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)getVeriCode{
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
            //跳转
            KDGetCodeController *gcVC = [[KDGetCodeController alloc] init];
            gcVC.forgetType = _forgetType;
            [self.navigationController pushViewController:gcVC animated:YES];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
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
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
}


#pragma mark - 监听文本框输入
- (void)textFieldDidChange {
    self.nextStepBtn.enabled = _phoneTextField.text.length;
}


@end
