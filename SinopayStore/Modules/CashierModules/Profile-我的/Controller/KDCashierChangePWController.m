//
//  KDCashierChangePWController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierChangePWController.h"
#import "ZFNavigationController.h"

@interface KDCashierChangePWController ()

///原密码
@property (nonatomic, strong)UITextField *passWord;
///密码
@property (nonatomic, strong)UITextField *passWord1;
///确认密码
@property (nonatomic, strong)UITextField *passWord2;
///确认按钮
@property (nonatomic, strong)UIButton *confirmBtn;
///错误提示标签
@property (nonatomic, strong)UILabel *tipLabel;

@end

@implementation KDCashierChangePWController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.naviTitle = NSLocalizedString(@"修改密码", nil);
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)createView{
    
    //底部背景
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 81)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    //原密码label
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    view1.backgroundColor = GrayBgColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 15)];
    label.text = NSLocalizedString(@"原密码", nil);
    label.font = [UIFont systemFontOfSize:15];
    [view1 addSubview:label];
    
    //原密码
    _passWord = [[UITextField alloc] initWithFrame:CGRectMake(20, label.bottom+10, SCREEN_WIDTH-40, 40)];
    _passWord.placeholder = NSLocalizedString(@"请输入原密码", nil);
    [_passWord addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _passWord.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord.keyboardType = UIKeyboardTypeNumberPad;
    _passWord.font = [UIFont systemFontOfSize:15];
    [_passWord limitTextLength:6];
    _passWord.secureTextEntry = YES;
    
    //新密码label
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, _passWord.bottom, SCREEN_WIDTH, 45)];
    view2.backgroundColor = GrayBgColor;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 15)];
    label2.text = NSLocalizedString(@"新密码", nil);
    label2.font = [UIFont systemFontOfSize:15];
    [view2 addSubview:label2];
    
    [backView addSubview:view1];
    [backView addSubview:_passWord];
    [backView addSubview:view2];
    backView.size = CGSizeMake(SCREEN_WIDTH, 190);
    
    //密码
    _passWord1 = [[UITextField alloc] initWithFrame:CGRectMake(20, view2.bottom, SCREEN_WIDTH-40, 40)];
    _passWord1.placeholder = NSLocalizedString(@"请输入6位数字登录密码", nil);
    [_passWord1 addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _passWord1.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord1.keyboardType = UIKeyboardTypeNumberPad;
    _passWord1.secureTextEntry = YES;
    _passWord1.font = [UIFont systemFontOfSize:15];
    [_passWord1 limitTextLength:6];
    [backView addSubview:_passWord1];
    
    //中间横线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _passWord1.bottom, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = GrayBgColor;
    [backView addSubview:lineView];
    
    //确认密码
    _passWord2 = [[UITextField alloc] initWithFrame:CGRectMake(_passWord1.x, _passWord1.bottom+1, _passWord1.width, _passWord1.height)];
    _passWord2.placeholder = NSLocalizedString(@"请再次输入", nil);
    [_passWord2 addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _passWord2.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord2.keyboardType = UIKeyboardTypeNumberPad;
    _passWord2.secureTextEntry = YES;
    _passWord2.font = [UIFont systemFontOfSize:15];
    [_passWord2 limitTextLength:6];
    [backView addSubview:_passWord2];
    
    //错误提示标签
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, backView.bottom+5, _passWord2.width, 20)];
    _tipLabel.textColor = UIColorFromRGB(0xE24A4A);
    _tipLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_tipLabel];
    
    //确认按钮
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(20, backView.bottom+44, SCREEN_WIDTH-40, 40);
    [_confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(clickCOnfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.layer.cornerRadius = 5.0;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_non_clickable"] forState:UIControlStateDisabled];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateHighlighted];
    _confirmBtn.enabled = NO;
    [self.view addSubview:_confirmBtn];
}

- (void)clickCOnfirmBtn{
    if (_passWord.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"原密码输入错误", nil);
        return;
    }
    
    if (_passWord1.text.length != 6) {
        _tipLabel.text = NSLocalizedString(@"请输入6位数字登录密码", nil);
        return;
    }
    
    if (![_passWord1.text isEqualToString:_passWord2.text]) {
        _tipLabel.text = NSLocalizedString(@"两次输入的密码不一致", nil);
        return;
    }
    _tipLabel.text = @"";
    [self.view endEditing:YES];
    
    [self changeLoginPW];
}

- (void)changeLoginPW{
    NSString *oldPw = [TripleDESUtils getEncryptWithString:_passWord.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    NSString *nowPw = [TripleDESUtils getEncryptWithString:_passWord1.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"oldPwd":oldPw,
                           @"newPwd":nowPw,
                           @"txnType":@"37"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            
            [self logout];//成功后退出
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 登出
- (void)logout{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"40"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"修改成功", nil) inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //清空密码
                [ZFGlobleManager getGlobleManager].loginVC.pwdTextField.text = @"";
                [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[ZFGlobleManager getGlobleManager].loginVC];
            });
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - 监听文本框输入
- (void)textFieldDidChange {
    _confirmBtn.enabled = _passWord.text.length && _passWord1.text.length && _passWord2.text.length;
}

@end
