//
//  KDAgentForgetPWController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/6.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentForgetPWController.h"

@interface KDAgentForgetPWController ()
///密码
@property (nonatomic, strong)UITextField *passWord1;
///确认密码
@property (nonatomic, strong)UITextField *passWord2;
///确认按钮
@property (nonatomic, strong)UIButton *confirmBtn;

@end

@implementation KDAgentForgetPWController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"忘记密码", nil);
    [self createView];
}

- (void)createView{
    
    //底部背景
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 81)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    //新密码label
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 15)];
    label2.text = NSLocalizedString(@"新密码", nil);
    label2.font = [UIFont systemFontOfSize:15];
    [view2 addSubview:label2];
    [backView addSubview:view2];
    
    //密码
    _passWord1 = [[UITextField alloc] initWithFrame:CGRectMake(20, view2.bottom, SCREEN_WIDTH-40, 44)];
    _passWord1.placeholder = NSLocalizedString(@"请输入新密码", nil);
    _passWord1.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord1.keyboardType = UIKeyboardTypeEmailAddress;
    _passWord1.secureTextEntry = YES;
    _passWord1.font = [UIFont systemFontOfSize:15];
    _passWord1.backgroundColor = GrayBgColor;
    _passWord1.borderStyle = UITextBorderStyleRoundedRect;
    [_passWord1 limitTextLength:16];
    [backView addSubview:_passWord1];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, _passWord1.bottom+20, 200, 15)];
    label3.text = NSLocalizedString(@"确认密码", nil);
    label3.font = [UIFont systemFontOfSize:15];
    [backView addSubview:label3];
    
    //确认密码
    _passWord2 = [[UITextField alloc] initWithFrame:CGRectMake(_passWord1.x, label3.bottom+10, _passWord1.width, _passWord1.height)];
    _passWord2.placeholder = NSLocalizedString(@"请再次输入", nil);
    _passWord2.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord2.keyboardType = UIKeyboardTypeEmailAddress;
    _passWord2.secureTextEntry = YES;
    _passWord2.font = [UIFont systemFontOfSize:15];
    _passWord2.backgroundColor = GrayBgColor;
    _passWord2.borderStyle = UITextBorderStyleRoundedRect;
    [_passWord2 limitTextLength:16];
    [backView addSubview:_passWord2];
    
    backView.size = CGSizeMake(SCREEN_WIDTH, _passWord2.bottom);
    
    //确认按钮
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(20, backView.bottom+44, SCREEN_WIDTH-40, 44);
    [_confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(clickCOnfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.layer.cornerRadius = 5.0;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_non_clickable"] forState:UIControlStateDisabled];
    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateHighlighted];
    [self.view addSubview:_confirmBtn];
}

- (void)clickCOnfirmBtn{
    [self.view endEditing:YES];
    
    if (_passWord1.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入新密码", nil) inView:self.view];
        return;
    }
    
    if (_passWord1.text.length < 6) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"密码长度6-16位", nil) inView:self.view];
        return;
    }
    
    if (_passWord2.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入确认密码", nil) inView:self.view];
        return;
    }
    
    if (![_passWord1.text isEqualToString:_passWord2.text]) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"两次输入的密码不一致", nil) inView:self.view];
        return;
    }
    
    [self changeLoginPW];
}

- (void)changeLoginPW{
    
    NSDictionary *dict = @{
                           @"phoneNum":_phoneNum,
                           @"countryCode":_areaNum,
                           @"userNewPwd":_passWord1.text,
                           @"userType":@"AGENT",
                           @"reqType":@"08"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"修改成功", nil) inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
            
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
