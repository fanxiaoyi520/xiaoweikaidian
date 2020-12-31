//
//  KDAddCashierController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/24.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddCashierController.h"

@interface KDAddCashierController ()
@property (nonatomic, strong)UITextField *textField;

@end

@implementation KDAddCashierController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"收银员录入", nil);
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)createView{
    self.view.backgroundColor = GrayBgColor;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight + 20, SCREEN_WIDTH, 44)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, backView.height)];
    _textField.placeholder = NSLocalizedString(@"请输入收银员登录账号", nil);
    _textField.font = [UIFont systemFontOfSize:16];
    _textField.keyboardType = UIKeyboardTypeEmailAddress;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_textField limitTextLength:20];
    [backView addSubview:_textField];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, backView.bottom+10, SCREEN_WIDTH-40, 40)];
    tipLabel.text = NSLocalizedString(@"由字母数字下划线组成且开头必须是字母，位数限制：6~20", nil);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.numberOfLines = 2;
    tipLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:tipLabel];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, backView.bottom+62, SCREEN_WIDTH-40, 44)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
}

- (void)confirmBtnClick{
    [self.view endEditing:YES];
    
    NSString *cashierName = _textField.text;
    if (!cashierName || cashierName.length < 6) {
        [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"收银员登录账号输入有误", nil) inView:self.view];
        return;
    }
    
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"cashierName":_textField.text,
                           @"txnType":@"64"
                           };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:[requestResult objectForKey:@"msg"] inView:[UIApplication sharedApplication].keyWindow];
            self.block(YES);
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
