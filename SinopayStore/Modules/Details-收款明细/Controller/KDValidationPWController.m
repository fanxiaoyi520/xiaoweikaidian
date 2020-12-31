//
//  KDValidationPWController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDValidationPWController.h"
#import "ZFPwdInputView.h"
#import "IQKeyboardManager.h"
#import "KDRevocateResultController.h"


@interface KDValidationPWController ()<InputPwdDelegate>

///输入密码控件
@property (nonatomic, strong)ZFPwdInputView *pwdView;
///密码
@property (nonatomic, strong)NSString *passWord;

@end

@implementation KDValidationPWController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [_pwdView.textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"撤销", nil);
    [self createView];
}

- (void)createView{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+70, SCREEN_WIDTH-40, 40)];
    tipLabel.text = NSLocalizedString(@"为保障账户安全，请输入6位登录密码", nil);
    tipLabel.font = [UIFont boldSystemFontOfSize:16];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    _pwdView = [[ZFPwdInputView alloc] initWithFrame:CGRectMake(40, tipLabel.bottom+30, SCREEN_WIDTH-80, 45)];
    _pwdView.delegate = self;
    [self.view addSubview:_pwdView];
}

- (void)inputString:(NSString *)password{
    if (password.length == 6) {
        _passWord = password;
        [self validateAndRevocation];
    }
}

#pragma mark 验证密码和撤销
- (void)validateAndRevocation{
    NSString *pwd = [TripleDESUtils getEncryptWithString:_passWord keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"orderId":_orderID,
                           @"merId":_merCode,
                           @"password":pwd,
                           @"txnType":@"23"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {

        [[MBUtils sharedInstance] dismissMB];
        KDRevocateResultController *rrVC = [[KDRevocateResultController alloc] init];
        rrVC.payType = self.payType;
        rrVC.status = [requestResult objectForKey:@"status"];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {//撤销成功
            rrVC.cardNum = [requestResult objectForKey:@"cardNum"];
            rrVC.orderID = [requestResult objectForKey:@"orderId"];
            rrVC.txnAmt = [requestResult objectForKey:@"txnAmt"];
        } else if ([[requestResult objectForKey:@"status"] isEqualToString:@"55"]){//密码错误
            [XLAlertController acWithMessage:[requestResult objectForKey:@"msg"] confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
                _pwdView.textField.text = @"";
                [_pwdView inputPwd];
                [_pwdView.textField becomeFirstResponder];
            }];
            return ;
        } else {//撤销失败
            rrVC.causeStr = [requestResult objectForKey:@"msg"];
        }
        [self pushViewController:rrVC];
        // 移除当前控制前
        NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [tempMArray removeObject:self];
        [self.navigationController setViewControllers:tempMArray animated:NO];
    } failure:^(id error) {

    }];
}

@end
