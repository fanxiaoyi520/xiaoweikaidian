//
//  KDAddMerGetCodeController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddMerGetCodeController.h"
#import "ZFPickerView.h"
#import "KDAddMerBaseController.h"
#import "KDAgentForgetPWController.h"
#import "KDAddAgentInfoController.h"

@interface KDAddMerGetCodeController ()<ZFPickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *areaNumL;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;

@property (nonatomic, strong)ZFPickerView *areaPicker;
@property (nonatomic, strong)NSMutableArray *areaArray;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

@end

@implementation KDAddMerGetCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = NSLocalizedString(@"注册", nil);
    if (_codeType == 1) {
        title = NSLocalizedString(@"忘记密码", nil);
    }
    self.naviTitle = title;
    _topHeight.constant = IPhoneXTopHeight+20;
   
    //之前请求过就不再请求
    if ([ZFGlobleManager getGlobleManager].areaNumArray && [ZFGlobleManager getGlobleManager].areaNumArray.count > 0) {
        _areaArray = [ZFGlobleManager getGlobleManager].areaNumArray;
    } else {
        [self getCountryCode];
    }
    [self createPicker];
}

- (void)createPicker{
    _areaPicker = [[ZFPickerView alloc] init];
    _areaPicker.delegate = self;
    [self.view addSubview:_areaPicker];
}

#pragma mark - 点击方法
#pragma mark 区号
- (IBAction)areaNumBtn:(id)sender {
    [self.view endEditing:YES];
    if (!_areaArray) {
        return;
    }
    
    _areaPicker.dataArray = _areaArray;
    [_areaPicker show];
}

- (IBAction)getCodeBtn:(id)sender {
    [self.view endEditing:YES];
    NSString *phone = _phoneNumTF.text;
    if (!phone || phone.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入手机号", nil) inView:self.view];
        return;
    }
    if (_codeType == 2) {//新增代理
        [self checkUser];
        return;
    }
    [self getCode];
}

- (IBAction)nextBtn:(id)sender {
    [self.view endEditing:YES];
    NSString *phone = _phoneNumTF.text;
    NSString *msgCode = _codeTF.text;
    
    if (!phone || phone.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入手机号", nil) inView:self.view];
        return;
    }
    if ([_getCodeBtn.titleLabel.text isEqualToString:@"获取验证码"]) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请先获取验证码", nil) inView:self.view];
        return;
    }
    if (!msgCode || msgCode.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入验证码", nil) inView:self.view];
        return;
    }
    
    if (_codeType == 1) {
        [self forgetPwValidateCode];
    } else if (_codeType == 2) {
        [self validateAgentCode];
    } else {
        [self validateCode];
    }
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

#pragma mark - delegate
- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index{
    _areaNumL.text = [NSString stringWithFormat:@"+%@", [[_areaArray[index] componentsSeparatedByString:@"+"] lastObject]];
}

#pragma mark - 数据
#pragma mark 获取验证码
- (void)getCode{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    NSString *agentAcct = @"";
    if (_codeType == 0) {
        agentAcct = [ZFGlobleManager getGlobleManager].userPhone;
    }
    NSDictionary *dict = @{
                           @"countryCode":code,
                           @"phoneNum":phone,
                           @"agentAcct":agentAcct,
                           @"reqType":@"01"
                           };
    
    if (_codeType == 1) {
        dict = @{
                 @"countryCode":code,
                 @"phoneNum":phone,
                 @"userType":@"AGENT",
                 @"reqType":@"07"
                 };
    }
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _getCodeBtn.enabled = NO;
            _downCount = 60;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_codeTF becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 验证
- (void)validateCode{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    NSString *msgCode = _codeTF.text;
    
    NSDictionary *dict = @{
                           @"countryCode":code,
                           @"phoneNum":phone,
                           @"otpNum":msgCode,
                           @"otpType":@"merRegist",
                           @"reqType":@"02"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDAddMerBaseController *bVC = [[KDAddMerBaseController alloc] init];
            bVC.phoneNum = phone;
            bVC.areaNum = code;
            [self pushViewController:bVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 忘记密码验证
- (void)forgetPwValidateCode{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    NSString *msgCode = _codeTF.text;

    NSDictionary *dict = @{
                           @"countryCode":code,
                           @"phoneNum":phone,
                           @"otpNum":msgCode,
                           @"otpType":@"forgetLoginPwd",
                           @"reqType":@"02"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDAgentForgetPWController *fVC = [[KDAgentForgetPWController alloc] init];
            fVC.phoneNum = phone;
            fVC.areaNum = code;
            [self pushViewController:fVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - 新增代理
#pragma mark 判断用户是否存在
- (void)checkUser{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    
    NSDictionary *dict = @{
                           @"userLoginName":phone,
                           @"areaCode":code,
                           TxnType:@"01"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [self getCodePost];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取验证码
- (void)getCodePost{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    
    NSDictionary *dict = @{
                           @"areaCode":code,
                           @"telPhone":phone,
                           TxnType:@"02"
                           };
    //    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _getCodeBtn.enabled = NO;
            _downCount = 180;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_codeTF becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 验证
- (void)validateAgentCode{
    NSString *code = [_areaNumL.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phone = _phoneNumTF.text;
    NSString *msgCode = _codeTF.text;
    
    NSDictionary *dict = @{
                           @"areaCode":code,
                           @"telPhone":phone,
                           @"msgCode":msgCode,
                           TxnType:@"03"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDAddAgentInfoController *agentInfo = [[KDAddAgentInfoController alloc] init];
            agentInfo.areaNum = code;
            agentInfo.account = phone;
            [self pushViewController:agentInfo];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
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
            _areaNumL.text = @"+86";
        } else {
            
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}
@end
