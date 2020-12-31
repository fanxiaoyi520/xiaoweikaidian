//
//  ZFValidatePwdController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFValidatePwdController.h"
#import "ZFPwdInputView.h"
#import "IQKeyboardManager.h"
#import "KDRMGetCodeController.h"
#import "KDRedemptionDetailController.h"

@interface ZFValidatePwdController ()<InputPwdDelegate>

///输入密码控件
@property (nonatomic, strong)ZFPwdInputView *pwdView;
///密码
@property (nonatomic, strong)NSString *passWord;

@end

@implementation ZFValidatePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"输入支付密码", nil);
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [_pwdView.textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)createView{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60+64, SCREEN_WIDTH-40, 40)];
    tipLabel.text = [NSString stringWithFormat:@"%@ %@, %@ %@", NSLocalizedString(@"到账金额", nil), [_redemptionDict objectForKey:@"inAccountAmt"], NSLocalizedString(@"服务费", nil), [_redemptionDict objectForKey:@"serviceCharge"]];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    _pwdView = [[ZFPwdInputView alloc] initWithFrame:CGRectMake(40, tipLabel.bottom+30, SCREEN_WIDTH-80, 45)];
    _pwdView.delegate = self;
    [self.view addSubview:_pwdView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-140, _pwdView.bottom+20, 100, 20)];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickForgetBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickForgetBtn{
    KDRMGetCodeController *gcVC = [[KDRMGetCodeController alloc] init];
    gcVC.getCodeType = 1;
    [self pushViewController:gcVC];
}

- (void)inputString:(NSString *)password{
    if (password.length == 6) {
        _passWord = password;
        [self veriPwdCode];
    }
}

#pragma mark - 验证支付密码
- (void)veriPwdCode{
    NSString *pw = [TripleDESUtils getEncryptWithString:_passWord keyString:AgencyTripledesKey ivString:TRIPLEDES_IV];
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"payPassword":pw,
                           TxnType:@"21"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [self withDraw];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [_pwdView inputPwd];
            _pwdView.textField.text = @"";
            [_pwdView.textField becomeFirstResponder];
        }
    } failure:^(id error) {
        [_pwdView inputPwd];
        _pwdView.textField.text = @"";
    }];
}

- (void)withDraw{
    
    [NetworkEngine agentPostWithParams:_redemptionDict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDRedemptionDetailController *rdVC = [[KDRedemptionDetailController alloc] init];
            rdVC.orderNum = [requestResult objectForKey:@"orderNumber"];
            rdVC.detailType = 1;
            [self pushViewController:rdVC];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"withdraw_complete" object:nil];
            [self removeVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(id error) {
        
    }];
}

- (void)removeVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    // 移除提现和验证密码页面
    [vcArray removeObjectAtIndex:2];
    [vcArray removeObjectAtIndex:2];
    [self.navigationController setViewControllers:vcArray animated:NO];
}

@end
